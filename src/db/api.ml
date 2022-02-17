open Let
open Rtypes
open Common
open Misc

let get_balance ?dbh ~contract ~owner token_id =
  let oid = Utils.oid ~contract ~token_id ~owner in
  use dbh @@ fun dbh ->
  let|>? l =
    [%pgsql dbh
        "select case when balance is not null then balance else amount end \
         from tokens where oid = $oid"] in
  match l with
  | [ amount ] -> amount
  | _ -> None

let reset_mint_metadata_creators  dbh ~contract ~token_id ~metadata =
  let tid = Utils.tid ~contract ~token_id in
  let l = match metadata.tzip21_tm_creators with
    | Some (CParts l) ->
      List.map (fun p -> p.part_account, p.part_value) l
    | Some (CAssoc l) -> l
    | Some (CTZIP12 l) ->
      let len = List.length l in
      if len > 0 then
        let value = Int32.of_int (10000 / len) in
        List.map (fun account -> account, value) l
      else []
    | Some (CNull l) ->
      let l = List.filter_map (fun x -> x) l in
      let len = List.length l in
      if len > 0 then
        let value = Int32.of_int (10000 / len) in
        List.map (fun account -> account, value) l
      else []
    | None -> [] in
  iter_rp (fun (account, value) ->
      try
        ignore @@
        Tzfunc.Crypto.(Base58.decode ~prefix:Prefix.contract_public_key_hash account) ;
        [%pgsql dbh
            "update tzip21_creators set \
             account = $account, value = $value \
             where id = $tid"]
      with _ -> Lwt.return_ok ()) l

let reset_nft_item_meta_by_id ?dbh contract token_id =
  let tid = Utils.tid ~contract ~token_id in
  Format.eprintf "reset_nft_item_meta_by_id %s@." tid ;
  let update_royalties dbh royalties = match royalties with
    | Some r ->
      let royalties = EzEncoding.construct parts_enc @@ Metadata.to_4_decimals r in
      [%pgsql dbh
          "update token_info set royalties_metadata = $royalties \
           where id = $tid"]
    | _ -> Lwt.return_ok () in
  use dbh @@ fun dbh ->
  let>? l = [%pgsql dbh
      "select last_block, last_level, last, metadata, metadata_uri from token_info where \
       id = $tid and main"] in
  match l with
  | [] -> Lwt.return_ok ()
  | [ block, level, tsp, metadata, None ] ->
    begin
      Format.eprintf "ok@." ;
      let l = EzEncoding.destruct Rtypes.token_metadata_enc metadata in
      let>? (_, _, royalties) =
        Metadata.insert_token_metadata ~forward:true ~dbh ~block ~level ~tsp ~contract (token_id, l) in
      update_royalties dbh royalties
    end
  | [ block, level, tsp, _, Some uri ] ->
    begin
      try
        Metadata.get_json uri >>= function
        | Ok (metadata, _uri) ->
          let>? () =
            Metadata.insert_mint_metadata dbh ~forward:true ~contract ~token_id ~block ~level ~tsp metadata in
          update_royalties dbh metadata.tzip21_tm_royalties
        | Error (code, str) ->
          Lwt.return_error
            (`hook_error
               (Printf.sprintf "fetch metadata error %d:%s" code @@
                Option.value ~default:"None" str))
      with _ ->
        Lwt.return_error (`hook_error (Printf.sprintf "wrong json for %s:%s item" contract (Z.to_string token_id)))
    end
  | _ ->
    Lwt.return_error (`hook_error (Printf.sprintf "several results on LIMIT 1"))

let mk_nft_items_continuation nft_item =
  Printf.sprintf "%Ld_%s"
    (Int64.of_float @@ CalendarLib.Calendar.to_unixfloat nft_item.nft_item_date *. 1000.)
    nft_item.nft_item_id

let get_nft_items_by_owner ?dbh ?include_meta ?continuation ?(size=50) owner =
  Format.eprintf "get_nft_items_by_owner %s %s %s %d@."
    owner
    (match include_meta with None -> "None" | Some s -> string_of_bool s)
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size ;
  let burn_addresses = List.map Option.some Get.burn_addresses in
  use dbh @@ fun dbh ->
  let size64 = Int64.of_int size in
  let no_continuation, (ts, id) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  let>? l = [%pgsql.object dbh
      "select i.id, \
       last, metadata, tsp, creators, royalties, royalties_metadata, \
       sum(case \
       when t.balance is not null and not (owner = any($burn_addresses)) then t.balance \
       when not (owner = any($burn_addresses)) then t.amount \
       else 0 end) as supply, \
       array_agg(case \
       when owner = any($burn_addresses) then null \
       when balance is not null and \
       balance <> 0 or amount <> 0 then owner end) as owners \
       from (select tid, amount, balance, owner from tokens where \
       owner = $owner and
       ((balance is not null and balance > 0 or amount > 0))) t \
       inner join token_info i on i.id = t.tid \
       where \
       main and metadata <> '{}' and owner = $owner and (balance is not null and balance > 0 or amount > 0) and \
       ($no_continuation or (last = $ts and i.id < $id) or (last < $ts)) \
       group by (i.id, i.contract, i.token_id) \
       order by last desc, id desc limit $size64"] in
  map_rp (fun r -> Get.mk_nft_item dbh ?include_meta r) l >>=? fun nft_items_items ->
  let len = List.length nft_items_items in
  let nft_items_continuation =
    if len <> size then None
    else Some
        (mk_nft_items_continuation @@ List.hd (List.rev nft_items_items)) in
  Lwt.return_ok
    { nft_items_items ; nft_items_continuation ; nft_items_total = 0L }

let get_nft_items_by_creator ?dbh ?include_meta ?continuation ?(size=50) creator =
  Format.eprintf "get_nft_items_by_creator %s %s %s %d@."
    creator
    (match include_meta with None -> "None" | Some s -> string_of_bool s)
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size ;
  let burn_addresses = List.map Option.some Get.burn_addresses in
  use dbh @@ fun dbh ->
  let size64 = Int64.of_int size in
  let no_continuation, (ts, id) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  let>? l = [%pgsql.object dbh
      "select i.id, \
       last, metadata, i.tsp, i.creators, royalties, royalties_metadata, \
       array_agg(case \
       when owner = any($burn_addresses) then null \
       when balance is not null and balance <> 0 or amount <> 0 then owner end) as owners, \
       sum(case \
       when t.balance is not null and not (owner = any($burn_addresses)) then t.balance \
       when not (owner = any($burn_addresses)) then t.amount \
       else 0 end) as supply \
       from tokens as t, token_info as i, creators as c \
       where c.account = $creator and t.tid = i.id and c.id = i.id and \
       i.main and metadata <> '{}' and supply > 0 and \
       ($no_continuation or (last = $ts and i.id < $id) or (last < $ts)) \
       group by (i.id) \
       order by last desc, i.id desc limit $size64"] in
  let>? nft_items_items = map_rp (fun r -> Get.mk_nft_item dbh ?include_meta r) l in
  let len = List.length nft_items_items in
  let nft_items_continuation =
    if len <> size then None
    else Some
        (mk_nft_items_continuation @@ List.hd (List.rev nft_items_items)) in
  Lwt.return_ok
    { nft_items_items ; nft_items_continuation ; nft_items_total = 0L }

let get_nft_items_by_collection ?dbh ?include_meta ?continuation ?(size=50) contract =
  Format.eprintf "get_nft_items_by_collection %s %s %s %d@."
    contract
    (match include_meta with None -> "None" | Some s -> string_of_bool s)
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size ;
  let burn_addresses = List.map Option.some Get.burn_addresses in
  use dbh @@ fun dbh ->
  let size64 = Int64.of_int size in
  let no_continuation, (ts, id) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  let>? l = [%pgsql.object dbh
      "select i.id, \
       last, i.tsp, i.creators, i.royalties, i.royalties_metadata, \
       array_agg(case \
       when owner = any($burn_addresses) then null \
       when balance is not null and balance <> 0 or amount <> 0 then owner end) as owners, \
       sum(case \
       when t.balance is not null and not (owner = any($burn_addresses)) then t.balance \
       when not (owner = any($burn_addresses)) then t.amount \
       else 0 end) as supply \
       from tokens t \
       inner join token_info i on i.id = t.tid \
       where \
       main and i.contract = $contract and \
       ($no_continuation or (last = $ts and id < $id) or (last < $ts)) \
       group by (i.id) \
       order by i.last desc, i.id desc limit $size64"] in
  let>? nft_items_items = map_rp (fun r -> Get.mk_nft_item dbh ?include_meta r) l in
  let len = List.length nft_items_items in
  let nft_items_continuation =
    if len <> size then None
    else Some
        (mk_nft_items_continuation @@ List.hd (List.rev nft_items_items)) in
  Lwt.return_ok
    { nft_items_items ; nft_items_continuation ; nft_items_total = 0L }

let get_nft_item_meta_by_id ?dbh contract token_id =
  let tid = Utils.tid ~contract ~token_id in
  Format.eprintf "get_nft_meta_by_id %s@." tid;
  use dbh @@ fun dbh ->
  let>? meta = Get.mk_nft_item_meta dbh ~contract ~token_id in
  match Utils.rarible_meta_of_tzip21_meta meta with
  | None ->
    Lwt.return_ok {
      nft_item_meta_name = "Unnamed item" ;
      nft_item_meta_description = None ;
      nft_item_meta_attributes = None ;
      nft_item_meta_image = None ;
      nft_item_meta_animation = None ;
    }
  | Some meta -> Lwt.return_ok meta

let filter_items ?show_deleted items =
  match show_deleted with
  | None | Some false -> List.filter (fun i -> i.nft_item_supply > Z.zero) items
  | Some true -> items

let rec get_nft_all_items_aux
    ~dbh ?last_updated_to ?last_updated_from ?show_deleted ?include_meta
    ?continuation ~size acc =
  Format.eprintf "get_nft_all_items_aux %s %s %s %s %s %Ld@."
    (match last_updated_to with None -> "None" | Some s -> Tzfunc.Proto.A.cal_to_str s)
    (match last_updated_from with None -> "None" | Some s -> Tzfunc.Proto.A.cal_to_str s)
    (match show_deleted with None -> "None" | Some s -> string_of_bool s)
    (match include_meta with None -> "None" | Some s -> string_of_bool s)
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size ;
  let no_continuation, (ts, id) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  let no_last_updated_to, last_updated_to_v =
    last_updated_to = None,
    (match last_updated_to with None -> CalendarLib.Calendar.now () | Some ts -> ts) in
  let no_last_updated_from, last_updated_from_v =
    last_updated_from = None,
    (match last_updated_from with None -> CalendarLib.Calendar.now () | Some ts -> ts) in
  let len = Int64.of_int @@ List.length acc in

  if len < size  then
    let>? tis = [%pgsql.object dbh
        "select id, last, tsp, creators, royalties, royalties_metadata, \
         main, metadata from token_info where \
         ($no_last_updated_to or (last <= $last_updated_to_v)) and \
         ($no_last_updated_from or (last >= $last_updated_from_v)) and \
         ($no_continuation or (last = $ts and id < $id) or (last < $ts)) \
         order by last desc, id desc limit $size"] in
    let continuation = match List.rev tis with
      | [] -> None
      | hd :: _ -> Some (hd#last, hd#id) in
    let tis = List.filter_map (fun x -> x) @@
      List.map (fun ti -> if ti#main && ti#metadata <> "{}" then Some ti else None) tis in
    match tis with
    | [] ->
      get_nft_all_items_aux
        ~dbh ?last_updated_to ?last_updated_from ?show_deleted ?include_meta
        ?continuation ~size acc
    | _ ->
      let>? items = map_rp (fun r -> Get.mk_nft_item_without_owners dbh ?include_meta r) tis in
      match items with
      | [] ->
        get_nft_all_items_aux
          ~dbh ?last_updated_to ?last_updated_from ?show_deleted ?include_meta
          ?continuation ~size acc
      | _ ->
        let items = filter_items ?show_deleted items in
        get_nft_all_items_aux
          ~dbh ?last_updated_to ?last_updated_from ?show_deleted ?include_meta
          ?continuation ~size (acc @ items)
  else
  if len = size then Lwt.return_ok acc
  else
    Lwt.return_ok @@
    List.filter_map (fun x -> x) @@
    List.mapi (fun i item -> if i < Int64.to_int size then Some item else None) acc

let get_nft_all_items
    ?dbh ?last_updated_to ?last_updated_from ?show_deleted ?include_meta
    ?continuation ?(size=50) () =
  Format.eprintf "get_nft_all_items %s %s %s %s %s %d@."
    (match last_updated_to with None -> "None" | Some s -> Tzfunc.Proto.A.cal_to_str s)
    (match last_updated_from with None -> "None" | Some s -> Tzfunc.Proto.A.cal_to_str s)
    (match show_deleted with None -> "None" | Some s -> string_of_bool s)
    (match include_meta with None -> "None" | Some s -> string_of_bool s)
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size ;
  use dbh @@ fun dbh ->
  let size = Int64.of_int size in
  let>? nft_items_items = get_nft_all_items_aux
      ~dbh ?last_updated_to ?last_updated_from ?show_deleted ?include_meta
      ?continuation ~size [] in
  let len = Int64.of_int @@ List.length nft_items_items in
  let nft_items_continuation =
    if len <> size then None
    else Some
        (mk_nft_items_continuation @@ List.hd (List.rev nft_items_items)) in
  Lwt.return_ok
    { nft_items_items ; nft_items_continuation ; nft_items_total = 0L }

let mk_nft_activity_continuation obj =
  Printf.sprintf "%Ld_%s"
    (Int64.of_float @@ CalendarLib.Calendar.to_unixfloat obj#date *. 1000.)
    obj#transaction

let get_nft_activities_by_collection ?dbh ?(sort=LATEST_FIRST) ?continuation ?(size=50) filter =
  Format.eprintf "get_nft_activities_by_collection %s [%s] %s %d@."
    filter.nft_activity_by_collection_contract
    (String.concat " " @@
     List.map (EzEncoding.construct nft_activity_filter_all_type_enc)
       filter.nft_activity_by_collection_types)
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size ;
  use dbh @@ fun dbh ->
  let contract = filter.nft_activity_by_collection_contract in
  let types = Utils.filter_all_type_to_string filter.nft_activity_by_collection_types in
  let size64 = Int64.of_int size in
  let no_continuation, (ts, h) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  let>? l =
    match sort with
    | LATEST_FIRST ->
      [%pgsql.object dbh
          "select activity_type, transaction, index, block, level, date, contract, \
           token_id, owner, amount, tr_from from nft_activities where \
           main and contract = $contract and \
           position(activity_type in $types) > 0 and \
           ($no_continuation or \
           (date = $ts and transaction < $h) or \
           (date < $ts)) \
           order by date desc, \
           transaction desc \
           limit $size64"]
    | EARLIEST_FIRST ->
      [%pgsql.object dbh
          "select activity_type, transaction, index, block, level, date, contract, \
           token_id, owner, amount, tr_from from nft_activities where \
           main and contract = $contract and \
           position(activity_type in $types) > 0 and \
           ($no_continuation or \
           (date = $ts and transaction > $h) or \
           (date > $ts)) \
           order by date asc, \
           transaction asc \
           limit $size64"]
  in
  map_rp (fun r -> let|>? a = Get.mk_nft_activity r in a, r) l >>=? fun activities ->
  let len = List.length activities in
  let nft_activities_continuation =
    if len <> size then None
    else Some
        (mk_nft_activity_continuation @@ snd @@ List.hd (List.rev activities)) in
  Lwt.return_ok
    { nft_activities_items = List.map fst activities ; nft_activities_continuation }

let get_nft_activities_by_item ?dbh ?(sort=LATEST_FIRST) ?continuation ?(size=50) filter =
  Format.eprintf "get_nft_activities_by_item %s %s [%s] %s %d@."
    filter.nft_activity_by_item_contract
    (Z.to_string filter.nft_activity_by_item_token_id)
    (String.concat " " @@
     List.map (EzEncoding.construct nft_activity_filter_all_type_enc)
       filter.nft_activity_by_item_types)
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size ;
  use dbh @@ fun dbh ->
  let contract = filter.nft_activity_by_item_contract in
  let token_id = filter.nft_activity_by_item_token_id in
  let types = Utils.filter_all_type_to_string filter.nft_activity_by_item_types in
  let size64 = Int64.of_int size in
  let no_continuation, (ts, h) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  let>? l =
    match sort with
    | LATEST_FIRST ->
      [%pgsql.object dbh
          "select activity_type, transaction, index, block, level, date, contract, \
           token_id, owner, amount, tr_from from nft_activities where \
           main and contract = $contract and token_id = ${Z.to_string token_id} and \
           position(activity_type in $types) > 0 and \
           ($no_continuation or \
           (date = $ts and transaction < $h) or \
           (date < $ts)) \
           order by date desc, \
           transaction desc limit $size64"]
    | EARLIEST_FIRST ->
      [%pgsql.object dbh
          "select activity_type, transaction, index, block, level, date, contract, \
           token_id, owner, amount, tr_from from nft_activities where \
           main and contract = $contract and token_id = ${Z.to_string token_id} and \
           position(activity_type in $types) > 0 and \
           ($no_continuation or \
           (date = $ts and transaction > $h) or \
           (date > $ts)) \
           order by date asc, \
           transaction asc \
           limit $size64"] in
  map_rp (fun r -> let|>? a = Get.mk_nft_activity r in a, r) l >>=? fun activities ->
  let len = List.length activities in
  let nft_activities_continuation =
    if len <> size then None
    else Some
        (mk_nft_activity_continuation @@ snd @@ List.hd (List.rev activities)) in
  Lwt.return_ok
    { nft_activities_items = List.map fst activities ; nft_activities_continuation }

let get_nft_activities_by_user ?dbh ?(sort=LATEST_FIRST) ?continuation ?(size=50) filter =
  Format.eprintf "get_nft_activities_by_user [%s] [%s] %s %d@."
    (String.concat ";" filter.nft_activity_by_user_users)
    (String.concat " " @@
     List.map (EzEncoding.construct nft_activity_filter_user_type_enc)
       filter.nft_activity_by_user_types)
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size ;
  use dbh @@ fun dbh ->
  let users = String.concat ";" filter.nft_activity_by_user_users in
  let types = Utils.filter_user_type_to_string filter.nft_activity_by_user_types in
  let size64 = Int64.of_int size in
  let no_continuation, (ts, h) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  let>? l =
    match sort with
    | LATEST_FIRST ->
      [%pgsql.object dbh
          "select activity_type, transaction, index, block, level, date, contract, \
           token_id, owner, amount, tr_from from nft_activities where \
           main and \
           ((owner <> '' and position(owner in $users) > 0) or \
           (tr_from is not null and position(tr_from in $users) > 0)) and \
           position(activity_type in $types) > 0 and \
           ($no_continuation or \
           (date = $ts and transaction < $h) or \
           (date < $ts)) \
           order by date desc, \
           transaction desc \
           limit $size64"]
    | EARLIEST_FIRST ->
      [%pgsql.object dbh
          "select activity_type, transaction, index, block, level, date, contract, \
           token_id, owner, amount, tr_from from nft_activities where \
           main and \
           ((owner <> '' and position(owner in $users) > 0) or \
           (tr_from is not null and position(tr_from in $users) > 0)) and \
           position(activity_type in $types) > 0 and \
           ($no_continuation or \
           (date = $ts and transaction > $h) or \
           (date > $ts)) \
           order by date asc, \
           transaction asc \
           limit $size64"]
  in
  map_rp (fun r -> let|>? a = Get.mk_nft_activity r in a, r) l >>=? fun activities ->
  let len = List.length activities in
  let nft_activities_continuation =
    if len <> size then None
    else Some
        (mk_nft_activity_continuation @@ snd @@ List.hd (List.rev activities)) in
  Lwt.return_ok
    { nft_activities_items = List.map fst activities ; nft_activities_continuation }

let get_nft_activities_all ?dbh ?(sort=LATEST_FIRST) ?continuation ?(size=50) types =
  Format.eprintf "get_nft_activities_all [%s] %s %d@."
    (String.concat " " @@ List.map (EzEncoding.construct nft_activity_filter_all_type_enc) types)
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size ;
  use dbh @@ fun dbh ->
  let types = Utils.filter_all_type_to_string types in
  let size64 = Int64.of_int size in
  let no_continuation, (ts, h) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  let>? l =
    match sort with
    | LATEST_FIRST ->
      [%pgsql.object dbh "show"
          "select activity_type, transaction, index, block, level, date, contract, \
           token_id, owner, amount, tr_from from nft_activities where \
           main and position(activity_type in $types) > 0 and \
           ($no_continuation or \
           (date = $ts and transaction < $h) or \
           (date < $ts)) \
           order by date desc, \
           transaction desc limit $size64"]
    | EARLIEST_FIRST ->
      [%pgsql.object dbh "show"
          "select activity_type, transaction, index, block, level, date, contract, \
           token_id, owner, amount, tr_from from nft_activities where \
           main and position(activity_type in $types) > 0 and \
           ($no_continuation or \
           (date = $ts and transaction > $h) or \
           (date > $ts)) \
           order by date asc, \
           transaction asc \
           limit $size64"]
  in
  map_rp (fun r -> let|>? a = Get.mk_nft_activity r in a, r) l >>=? fun activities ->
  let len = List.length activities in
  let nft_activities_continuation =
    if len <> size then None
    else Some
        (mk_nft_activity_continuation @@ snd @@ List.hd (List.rev activities)) in
  Lwt.return_ok
    { nft_activities_items = List.map fst activities ; nft_activities_continuation }

let get_nft_activities ?dbh ?sort ?continuation ?size = function
  | ActivityFilterByCollection filter ->
    get_nft_activities_by_collection ?dbh ?sort ?continuation ?size filter
  | ActivityFilterByItem filter ->
    get_nft_activities_by_item ?dbh ?sort ?continuation ?size filter
  | ActivityFilterByUser filter ->
    get_nft_activities_by_user ?dbh ?sort ?continuation ?size filter
  | ActivityFilterAll filter ->
    get_nft_activities_all ?dbh ?sort ?continuation ?size filter

let mk_nft_ownerships_continuation nft_ownership =
  Printf.sprintf "%Ld_%s"
    (Int64.of_float @@ (CalendarLib.Calendar.to_unixfloat nft_ownership.nft_ownership_date *. 1000.))
    nft_ownership.nft_ownership_id

let get_nft_ownerships_by_item ?dbh ?continuation ?(size=50) contract token_id =
  let tid = Common.Utils.tid ~contract ~token_id in
  let burn_addresses = List.map Option.some Get.burn_addresses in
  Format.eprintf "get_nft_ownerships_by_item %s %s %d@." tid
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size ;
  let size64 = Int64.of_int size in
  let no_continuation, (ts, id) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  use dbh @@ fun dbh ->
  let>? l = [%pgsql.object dbh
      "select oid as id, tsp, last, amount, balance, metadata, creators \
       from tokens t inner join token_info i on t.tid = i.id \
       where i.id = $tid and main and \
       not (owner = any($burn_addresses)) and \
       (balance is not null and balance > 0 or amount > 0) and \
       ($no_continuation or \
       (last = $ts and oid < $id) or \
       (last < $ts)) \
       order by last desc, oid desc \
       limit $size64"] in
  let>? nft_ownerships_ownerships = map_rp Get.mk_nft_ownership l in
  let len = List.length nft_ownerships_ownerships in
  let nft_ownerships_continuation =
    if len <> size then None
    else Some
        (mk_nft_ownerships_continuation @@ List.hd (List.rev nft_ownerships_ownerships)) in
  Lwt.return_ok
    { nft_ownerships_ownerships ; nft_ownerships_continuation ; nft_ownerships_total = 0L }

let get_nft_all_ownerships ?dbh ?continuation ?(size=50) () =
  Format.eprintf "get_nft_all_ownerships %s %d@."
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size ;
  let burn_addresses = List.map Option.some Get.burn_addresses in
  let size64 = Int64.of_int size in
  let no_continuation, (ts, id) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  use dbh @@ fun dbh ->
  let>? l = [%pgsql.object dbh
      "select oid as id, tsp, last, amount, balance, metadata, creators \
       from tokens t inner join token_info i on i.id = t.tid \
       where main and \
       not (owner = any($burn_addresses)) and \
       (balance is not null and balance > 0 or amount > 0) and \
       ($no_continuation or \
       (last = $ts and oid < $id) or \
       (last < $ts)) \
       order by last desc, oid desc \
       limit $size64"] in
  let>? nft_ownerships_ownerships = map_rp Get.mk_nft_ownership l in
  let len = List.length nft_ownerships_ownerships in
  let nft_ownerships_continuation =
    if len <> size then None
    else Some
        (mk_nft_ownerships_continuation @@ List.hd (List.rev nft_ownerships_ownerships)) in
  Lwt.return_ok
    { nft_ownerships_ownerships ; nft_ownerships_continuation ; nft_ownerships_total = 0L }

let generate_nft_token_id ?dbh contract =
  Format.eprintf "generate_nft_token_id %s@."
    contract ;
  use dbh @@ fun dbh ->
  let>? r = [%pgsql dbh
      "update contracts set counter = case when counter > last_token_id \
       then counter + 1 else last_token_id + 1 end \
       where address = $contract returning counter"] in
  match r with
  | [ i ] -> Lwt.return_ok {
      nft_token_id = i;
      nft_token_id_signature = None ;
    }
  | _ -> Lwt.return_error (`hook_error "no contracts entry for this contract")

let search_nft_collections_by_owner ?dbh ?continuation ?(size=50) owner =
  Format.eprintf "search_nft_collections_by_owner %s %s %d@."
    owner
    (match continuation with None -> "None" | Some c -> c)
    size ;
  use dbh @@ fun dbh ->
  let size64 = Int64.of_int size in
  let no_continuation, collection =
    continuation = None, (match continuation with None -> "" | Some c -> c) in
  let>? l = [%pgsql.object dbh
      "select address, owner, metadata, kind, ledger_key, m.name, \
       ledger_value, minters from contracts c \
       left join tzip16_metadata m on m.contract = c.address \
       where c.main and owner = $owner and \
       ((ledger_key = '\"nat\"' and ledger_value = '\"address\"') \
       or (ledger_key = '[ \"address\", \"nat\"]' and ledger_value = '\"nat\"') \
       or (ledger_key = '[\"nat\", \"address\"]' and ledger_value = '\"nat\"')) and \
       ($no_continuation or \
       (address > $collection)) \
       order by address asc limit $size64"] in
  let nft_collections_collections = List.filter_map (fun r -> Result.to_option (Get.mk_nft_collection r)) l in
  let len = List.length nft_collections_collections in
  let nft_collections_continuation =
    if len <> size then None
    else Some (List.hd (List.rev nft_collections_collections)).nft_collection_id in
  Lwt.return_ok
    { nft_collections_collections ; nft_collections_continuation ; nft_collections_total = 0L}

let get_nft_all_collections ?dbh ?continuation ?(size=50) () =
  Format.eprintf "get_nft_all_collections %s %d@."
    (match continuation with None -> "None" | Some c -> c)
    size ;
  use dbh @@ fun dbh ->
  let size64 = Int64.of_int size in
  let no_continuation, collection =
    continuation = None, (match continuation with None -> "" | Some c -> c) in
  let>? l = [%pgsql.object dbh
      "select address, owner, metadata, kind, ledger_key, m.name, \
       ledger_value, minters from contracts c \
       left join tzip16_metadata m on m.contract = c.address \
       where c.main and \
       ((ledger_key = '\"nat\"' and ledger_value = '\"address\"') \
       or (ledger_key = '[ \"address\", \"nat\"]' and ledger_value = '\"nat\"') \
       or (ledger_key = '[\"nat\", \"address\"]' and ledger_value = '\"nat\"')) and \
       ($no_continuation or address > $collection) \
       order by address asc limit $size64"] in
  let nft_collections_collections = List.filter_map (fun r -> Result.to_option (Get.mk_nft_collection r)) l in
  let len = List.length nft_collections_collections in
  let nft_collections_continuation =
    if len <> size then None
    else Some (List.hd (List.rev nft_collections_collections)).nft_collection_id in
  Lwt.return_ok
    { nft_collections_collections ; nft_collections_continuation ; nft_collections_total = 0L }

let mk_order_continuation order =
  Printf.sprintf "%Ld_%s"
    (Int64.of_float @@
     CalendarLib.Calendar.to_unixfloat order.order_elt.order_elt_last_update_at *. 1000.)
    order.order_elt.order_elt_hash

let mk_price_continuation ?d order =
  Printf.sprintf "%s_%s"
    (Utils.decimal_balance ?decimals:d order.order_elt.order_elt_make.asset_value)
    order.order_elt.order_elt_hash

let filter_orders ?origin ?statuses orders =
  List.filter (fun (order, _) ->
      (match statuses with
       | None -> true
       | Some ss ->
         List.exists (fun s -> order.order_elt.order_elt_status = s) ss) &&
      (* order.order_elt.order_elt_make_stock > Z.zero && *)
      match origin with
      | Some orig ->
        let origin_fees = order.order_data.order_rarible_v2_data_v1_origin_fees in
        List.exists (fun p -> p.part_account = orig) origin_fees
      | None -> true)
    orders

let rec get_orders_all_aux ?dbh ?origin ?(sort=OLATEST_FIRST) ?statuses ?continuation ~size acc =
  Format.eprintf "get_orders_all_aux %s %s %Ld %d@."
    (match origin with None -> "None" | Some s -> s)
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size
    (List.length acc) ;
  let no_continuation, (ts, h) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  let len = Int64.of_int @@ List.length acc in
  if len < size  then
    use dbh @@ fun dbh ->
    let>? l =
      match sort with
      | OLATEST_FIRST ->
        [%pgsql.object dbh
            "select maker, taker, maker_edpk, taker_edpk, \
             make_asset_type_class, make_asset_type_contract, make_asset_type_token_id, \
             make_asset_value, make_asset_decimals, \
             take_asset_type_class, take_asset_type_contract, take_asset_type_token_id, \
             take_asset_value, take_asset_decimals, \
             start_date, end_date, salt, signature, created_at, hash, last_update_at \
             from orders where \
             ($no_continuation or \
             (last_update_at < $ts) or \
             (last_update_at = $ts and \
             hash < $h)) \
             order by last_update_at desc, hash desc \
             limit $size"]
      | OEARLIEST_FIRST ->
        [%pgsql.object dbh
            "select maker, taker, maker_edpk, taker_edpk, \
             make_asset_type_class, make_asset_type_contract, make_asset_type_token_id, \
             make_asset_value, make_asset_decimals, \
             take_asset_type_class, take_asset_type_contract, take_asset_type_token_id, \
             take_asset_value, take_asset_decimals, \
             start_date, end_date, salt, signature, created_at, hash, last_update_at \
             from orders where \
             ($no_continuation or \
             (last_update_at > $ts) or \
             (last_update_at = $ts and \
             hash < $h)) \
             order by last_update_at asc, hash desc \
             limit $size"] in
    let continuation = match List.rev l with
      | [] -> None
      | hd :: _ -> Some (hd#last_update_at, hd#hash) in
    map_rp (fun r -> Get.mk_order ~dbh r) l >>=? fun orders ->
    match orders with
    | [] -> Lwt.return_ok acc
    | _ ->
      let orders = filter_orders ?origin ?statuses orders in
      get_orders_all_aux ~dbh ?origin ~sort ?statuses ?continuation ~size (acc @ orders)
  else
  if len = size then Lwt.return_ok acc
  else
    Lwt.return_ok @@
    List.filter_map (fun x -> x) @@
    List.mapi (fun i order -> if i < Int64.to_int size then Some order else None) acc

let get_orders_all ?dbh ?sort ?statuses ?origin ?continuation ?(size=50) () =
  Format.eprintf "get_orders_all %s %s %d@."
    (match origin with None -> "None" | Some s -> s)
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size ;
  let size = Int64.of_int size in
  let>? orders = get_orders_all_aux ?dbh ?origin ?sort ?statuses ?continuation ~size [] in
  let len = Int64.of_int @@ List.length orders in
  let orders, decs = List.split orders in
  let orders_pagination_continuation =
    if len = 0L || len < size then None
    else Some
        (mk_order_continuation @@ List.hd @@ List.rev orders) in
  Lwt.return_ok
    ({ orders_pagination_orders = orders ; orders_pagination_continuation }, decs)

let rec get_sell_orders_by_maker_aux ?dbh ?origin ?continuation ~size ~maker acc =
  Format.eprintf "get_sell_orders_by_maker_aux %s %s %Ld %s %d@."
    (match origin with None -> "None" | Some s -> s)
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size
    maker
    (List.length acc) ;
  let no_continuation, (ts, h) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  let len = Int64.of_int @@ List.length acc in
  if len < size  then
    use dbh @@ fun dbh ->
    let>? l =
      [%pgsql.object dbh
          "select hash, last_update_at from orders \
           where \
           maker = $maker and \
           ($no_continuation or \
           (last_update_at < $ts) or \
           (last_update_at = $ts and \
           hash < $h)) \
           order by last_update_at desc, hash desc \
           limit $size"] in
    let continuation = match List.rev l with
      | [] -> None
      | hd :: _ -> Some (hd#last_update_at, hd#hash) in
    map_rp (fun r -> Get.get_order ~dbh r#hash) l >>=? fun orders ->
    match orders with
    | [] -> Lwt.return_ok acc
    | _ ->
      let orders = List.filter_map (fun x -> x) orders in
      let orders = filter_orders ?origin orders in
      get_sell_orders_by_maker_aux ~dbh ?origin ?continuation ~size ~maker (acc @ orders)
  else
  if len = size then Lwt.return_ok acc
  else
    Lwt.return_ok @@
    List.filter_map (fun x -> x) @@
    List.mapi (fun i order -> if i < Int64.to_int size then Some order else None) acc

(* SELL ORDERS -> make asset = nft *)
let get_sell_orders_by_maker ?dbh ?origin ?continuation ?(size=50) maker =
  Format.eprintf "get_sell_orders_by_maker %s %s %s %d@."
    maker
    (match origin with None -> "None" | Some s -> s)
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size ;
  let size = Int64.of_int size in
  let>? orders = get_sell_orders_by_maker_aux ?dbh ?origin ?continuation ~size ~maker [] in
  let len = Int64.of_int @@ List.length orders in
  let orders, decs = List.split orders in
  let orders_pagination_continuation =
    if len = 0L || len < size then None
    else Some
        (mk_order_continuation @@ List.hd @@ List.rev orders) in
  Lwt.return_ok
    ({ orders_pagination_orders = orders ; orders_pagination_continuation }, decs)

(* let rec get_sell_orders_by_item_aux ?dbh ?origin ?continuation ?maker ~size contract token_id acc =
 *   let no_continuation, (p, h) =
 *     continuation = None,
 *     (match continuation with None -> 0., "" | Some (p, h) -> (p, h)) in
 *   let len = Int64.of_int @@ List.length acc in
 *   let no_maker, maker_v = maker = None, (match maker with None -> "" | Some m -> m) in
 *   if len < size  then
 *     use dbh @@ fun dbh ->
 *     let>? l =
 *       [%pgsql dbh "select hash from orders \
 *                    where make_asset_type_contract = $contract and \
 *                    make_asset_type_token_id = $token_id and \
 *                    ($no_maker or maker = $maker_v) and \
 *                    ($no_continuation or \
 *                    (make_price_usd > $p) or \
 *                    (make_price_usd = $p and hash < $h)) \
 *                    order by make_price_usd asc, hash desc limit $size"] in
 *     map_rp (fun h -> get_order ~dbh h) l >>=? fun orders ->
 *     match orders with
 *     | [] -> Lwt.return_ok acc
 *     | _ ->
 *       let orders = List.filter_map (fun x -> x) orders in
 *       let continuation = match List.rev orders with
 *         | [] -> None
 *         | hd :: _ ->
 *           Some (float_of_string hd.order_elt.order_elt_make_price_usd,
 *                 hd.order_elt.order_elt_hash) in
 *       let orders = filter_orders ?origin orders in
 *       get_sell_orders_by_item_aux
 *         ~dbh ?origin ?continuation ?maker ~size contract token_id (acc @ orders)
 *   else
 *   if len = size then Lwt.return_ok acc
 *   else
 *     Lwt.return_ok @@
 *     List.filter_map (fun x -> x) @@
 *     List.mapi (fun i order -> if i < Int64.to_int size then Some order else None) acc *)

let rec get_sell_orders_by_item_aux
    ?dbh ?origin ?continuation ?maker ?currency
    ?statuses ?start_date ?end_date ~size contract token_id acc =
  Format.eprintf "get_orders_all_aux %s %s %Ld %s %s %d@."
    (match origin with None -> "None" | Some s -> s)
    (match continuation with
     | None -> "None"
     | Some (p, s) -> p ^ "_" ^ s)
    size
    contract
    (Z.to_string token_id)
    (List.length acc) ;
  let no_continuation, (p, h) =
    continuation = None,
    (match continuation with None -> Z.zero, "" | Some (ts, h) -> (Z.of_string ts, h)) in
  let no_maker, maker_v = maker = None, (match maker with None -> "" | Some m -> m) in
  let no_currency = currency = None in
  let currency_tezos = currency = Some ATXTZ in
  let currency_c, currency_contract = match currency with
    | Some (ATFT { contract ; _ } ) -> true, contract
    | Some (ATMT { asset_contract ; _ } ) -> true, asset_contract
    | Some (ATNFT { asset_contract ; _ } ) -> true, asset_contract
    | _ -> false, "" in
  let currency_tid, currency_token_id = match currency with
    | Some (ATFT { token_id ; _ } ) -> true, Option.value ~default:Z.zero token_id
    | Some (ATMT { asset_token_id ; _ } ) -> true, asset_token_id
    | Some (ATNFT { asset_token_id ; _ } ) -> true, asset_token_id
    | _ -> false, Z.zero in
  let no_start_date, start_date_v =
    start_date = None, (match start_date with None -> CalendarLib.Calendar.now () | Some d -> d) in
  let no_end_date, end_date_v =
    end_date = None, (match end_date with None -> CalendarLib.Calendar.now () | Some d -> d) in
  let len = Int64.of_int @@ List.length acc in
  if len < size  then
    use dbh @@ fun dbh ->
    let>? l =
      [%pgsql.object dbh
          "select hash, make_asset_value from orders \
           where make_asset_type_contract = $contract and \
           make_asset_type_token_id = ${Z.to_string token_id} and \
           ($no_maker or maker = $maker_v) and \
           ($no_currency or \
           ($currency_tezos and take_asset_type_class = 'XTZ') or \
           ($currency_c and not $currency_tid and
           take_asset_type_contract = $currency_contract) or \
           ($currency_c and $currency_tid and \
           take_asset_type_contract = $currency_contract and \
           take_asset_type_token_id = ${Z.to_string currency_token_id})) and \
           ($no_start_date or created_at >= $start_date_v) and \
           ($no_end_date or created_at <= $end_date_v) and \
           ($no_continuation or \
           (make_asset_value > ${Z.to_string p}::numeric) or \
           (make_asset_value = ${Z.to_string p}::numeric and \
           hash > $h)) \
           order by make_asset_value asc, hash asc \
           limit $size"] in
    let continuation = match List.rev l with
      | [] -> None
      | hd :: _ -> Some (Z.to_string hd#make_asset_value, hd#hash) in
    map_rp (fun r -> Get.get_order ~dbh r#hash) l >>=? fun orders ->
    match orders with
    | [] -> Lwt.return_ok acc
    | _ ->
      let orders = List.filter_map (fun x -> x) orders in
      let orders = filter_orders ?origin ?statuses orders in
      get_sell_orders_by_item_aux
        ~dbh ?origin ?continuation ?maker ?currency
        ?statuses ?start_date ?end_date ~size contract token_id (acc @ orders)
  else
  if len = size then Lwt.return_ok acc
  else
    Lwt.return_ok @@
    List.filter_map (fun x -> x) @@
    List.mapi (fun i order -> if i < Int64.to_int size then Some order else None) acc

let get_sell_orders_by_item
    ?dbh ?origin ?continuation ?(size=50) ?maker ?currency
    ?statuses ?start_date ?end_date contract token_id =
  Format.eprintf "get_sell_orders_by_item %s %s %d@."
    (match origin with None -> "None" | Some s -> s)
    (match continuation with
     | None -> "None"
     | Some (f, s) -> f ^ "_" ^ s)
    size ;
  let size = Int64.of_int size in
  let>? orders =
    get_sell_orders_by_item_aux
      ?dbh ?origin ?continuation ?maker ?currency
      ?statuses ?start_date ?end_date ~size contract token_id [] in
  let len = Int64.of_int @@ List.length orders in
  let orders, decs = List.split orders in
  let orders_pagination_continuation =
    if len = 0L || len < size then None
    else
      let d = fst @@ List.hd decs in
      Some (mk_price_continuation ?d @@ List.hd @@ List.rev orders) in
  Lwt.return_ok
    ({ orders_pagination_orders = orders ; orders_pagination_continuation }, decs)

let rec get_sell_orders_by_collection_aux ?dbh ?origin ?continuation ~size collection acc =
  Format.eprintf "get_sell_orders_by_collection_aux %s %s %Ld %s %d@."
    (match origin with None -> "None" | Some s -> s)
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size
    collection
    (List.length acc) ;
  let no_continuation, (ts, h) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  let len = Int64.of_int @@ List.length acc in
  if len < size  then
    use dbh @@ fun dbh ->
    let>? l =
      [%pgsql.object dbh
          "select hash, last_update_at from orders \
           where make_asset_type_contract = $collection and \
           ($no_continuation or \
           (last_update_at < $ts) or \
           (last_update_at = $ts and \
           hash < $h)) \
           order by last_update_at desc, hash desc \
           limit $size"] in
    let continuation = match List.rev l with
      | [] -> None
      | hd :: _ -> Some (hd#last_update_at, hd#hash) in
    map_rp (fun r -> Get.get_order ~dbh r#hash) l >>=? fun orders ->
    match orders with
    | [] -> Lwt.return_ok acc
    | _ ->
      let orders = List.filter_map (fun x -> x) orders in
      let orders = filter_orders ?origin orders in
      get_sell_orders_by_collection_aux ~dbh ?origin ?continuation ~size collection (acc @ orders)
  else
  if len = size then Lwt.return_ok acc
  else
    Lwt.return_ok @@
    List.filter_map (fun x -> x) @@
    List.mapi (fun i order -> if i < Int64.to_int size then Some order else None) acc

let get_sell_orders_by_collection ?dbh ?origin ?continuation ?(size=50) collection =
  Format.eprintf "get_sell_orders_by_collection %s %s %s %d@."
    collection
    (match origin with None -> "None" | Some s -> s)
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size ;
  let size = Int64.of_int size in
  let>? orders =
    get_sell_orders_by_collection_aux ?dbh ?origin ?continuation ~size collection [] in
  let len = Int64.of_int @@ List.length orders in
  let orders, decs = List.split orders in
  let orders_pagination_continuation =
    if len = 0L || len < size then None
    else Some
        (mk_order_continuation @@ List.hd @@ List.rev orders) in
  Lwt.return_ok
    ({ orders_pagination_orders = orders ; orders_pagination_continuation }, decs)

let rec get_sell_orders_aux ?dbh ?origin ?continuation ~size acc =
  Format.eprintf "get_sell_orders_aux %s %s %Ld %d@."
    (match origin with None -> "None" | Some s -> s)
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size
    (List.length acc) ;
  let no_continuation, (ts, h) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  let len = Int64.of_int @@ List.length acc in
  if len < size  then
    use dbh @@ fun dbh ->
    let>? l =
      [%pgsql.object dbh
          "select hash, last_update_at from orders \
           where make_asset_type_class = 'FA_2' and \
           ($no_continuation or \
           (last_update_at < $ts) or \
           (last_update_at = $ts and \
           hash < $h)) \
           order by last_update_at desc, hash desc \
           limit $size"] in
    let continuation = match List.rev l with
      | [] -> None
      | hd :: _ -> Some (hd#last_update_at, hd#hash) in
    map_rp (fun r -> Get.get_order ~dbh r#hash) l >>=? fun orders ->
    match orders with
    | [] -> Lwt.return_ok acc
    | _ ->
      let orders = List.filter_map (fun x -> x) orders in
      let orders = filter_orders ?origin orders in
      get_sell_orders_aux ~dbh ?origin ?continuation ~size (acc @ orders)
  else
  if len = size then Lwt.return_ok acc
  else
    Lwt.return_ok @@
    List.filter_map (fun x -> x) @@
    List.mapi (fun i order -> if i < Int64.to_int size then Some order else None) acc

let get_sell_orders ?dbh ?origin ?continuation ?(size=50) () =
  Format.eprintf "get_sell_orders %s %s %d@."
    (match origin with None -> "None" | Some s -> s)
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size ;
  let size = Int64.of_int size in
  let>? orders = get_sell_orders_aux ?dbh ?origin ?continuation ~size [] in
  let len = Int64.of_int @@ List.length orders in
  let orders, decs = List.split orders in
  let orders_pagination_continuation =
    if len = 0L || len < size then None
    else Some
        (mk_order_continuation @@ List.hd @@ List.rev orders) in
  Lwt.return_ok
    ({ orders_pagination_orders = orders ; orders_pagination_continuation }, decs)

let rec get_bid_orders_by_maker_aux ?dbh ?origin ?continuation ~size ~maker acc =
  Format.eprintf "get_bid_orders_by_maker_aux %s %s %Ld %s %d@."
    (match origin with None -> "None" | Some s -> s)
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size
    maker
    (List.length acc) ;
  let no_continuation, (ts, h) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  let len = Int64.of_int @@ List.length acc in
  if len < size  then
    use dbh @@ fun dbh ->
    let>? l =
      [%pgsql.object dbh
          "select hash, last_update_at from orders \
           where \
           maker = $maker and \
           take_asset_type_class = 'FA_2' and \
           ($no_continuation or \
           (last_update_at < $ts) or \
           (last_update_at = $ts and \
           hash < $h)) \
           order by last_update_at desc, hash desc \
           limit $size"] in
    let continuation = match List.rev l with
      | [] -> None
      | hd :: _ -> Some (hd#last_update_at, hd#hash) in
    map_rp (fun r -> Get.get_order ~dbh r#hash) l >>=? fun orders ->
    match orders with
    | [] -> Lwt.return_ok acc
    | _ ->
      let orders = List.filter_map (fun x -> x) orders in
      let orders = filter_orders ?origin orders in
      get_bid_orders_by_maker_aux ~dbh ?origin ?continuation ~size ~maker (acc @ orders)
  else
  if len = size then Lwt.return_ok acc
  else
    Lwt.return_ok @@
    List.filter_map (fun x -> x) @@
    List.mapi (fun i order -> if i < Int64.to_int size then Some order else None) acc

(* BID ORDERS -> take asset = nft *)
let get_bid_orders_by_maker ?dbh ?origin ?continuation ?(size=50) maker =
  Format.eprintf "get_bid_orders_by_maker %s %s %s %d@."
    maker
    (match origin with None -> "None" | Some s -> s)
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size ;
  let size = Int64.of_int size in
  let>? orders = get_bid_orders_by_maker_aux ?dbh ?origin ?continuation ~size ~maker [] in
  let len = Int64.of_int @@ List.length orders in
  let orders, decs = List.split orders in
  let orders_pagination_continuation =
    if len = 0L || len < size then None
    else Some
        (mk_order_continuation @@ List.hd @@ List.rev orders) in
  Lwt.return_ok
    ({ orders_pagination_orders = orders ; orders_pagination_continuation }, decs)

(* let rec get_bid_orders_by_item_aux ?dbh ?origin ?continuation ?maker ~size contract token_id acc =
 *   let no_continuation, (p, h) =
 *     continuation = None,
 *     (match continuation with None -> 0., "" | Some (p, h) -> (p, h)) in
 *   let len = Int64.of_int @@ List.length acc in
 *   let no_maker, maker_v = maker = None, (match maker with None -> "" | Some m -> m) in
 *   if len < size  then
 *     use dbh @@ fun dbh ->
 *     let>? l =
 *       [%pgsql dbh "select hash from orders \
 *                    where \
 *                    take_asset_type_contract = $contract and \
 *                    take_asset_type_token_id = $token_id and \
 *                    ($no_maker or maker = $maker_v) and \
 *                    ($no_continuation or \
 *                    (take_price_usd < $p) or \
 *                    (take_price_usd = $p and hash < $h)) \
 *                    order by take_price_usd desc, hash desc limit $size"] in
 *     match l with
 *     | [] -> Lwt.return_ok acc
 *     | _ ->
 *       map_rp (fun h -> get_order ~dbh h) l >>=? fun orders ->
 *       let orders = List.filter_map (fun x -> x) orders in
 *       let orders = filter_orders ?origin orders in
 *       let last_order = List.hd (List.rev orders) in
 *       let continuation =
 *         float_of_string last_order.order_elt.order_elt_take_price_usd,
 *         last_order.order_elt.order_elt_hash in
 *       let orders = orders @ acc in
 *       get_bid_orders_by_item_aux ~dbh ?origin ~continuation ~size contract token_id orders
 *   else
 *   if len = size  then Lwt.return_ok acc
 *   else
 *     Lwt.return_ok @@
 *     List.filter_map (fun x -> x) @@
 *     List.mapi (fun i order -> if i < Int64.to_int size then Some order else None) acc
 *
 * let get_bid_orders_by_item ?dbh ?origin ?continuation ?(size=50) ?maker contract token_id =
 *   Format.eprintf "get_bid_orders_by_item %s %s %s %s %s %d@."
 *     (match maker with None -> "None" | Some s -> s)
 *     (match origin with None -> "None" | Some s -> s)
 *     contract
 *     token_id
 *     (match continuation with
 *      | None -> "None"
 *      | Some (f, s) -> string_of_float f ^ "_" ^ s)
 *     size ;
 *   let size = Int64.of_int size in
 *   let>? orders =
 *     get_bid_orders_by_item_aux ?dbh ?origin ?continuation ?maker ~size contract token_id [] in
 *   let len = Int64.of_int @@ List.length orders in
 *   let orders_pagination_contination =
 *     if len <> size then None
 *     else Some
 *         (mk_order_continuation @@ List.hd (List.rev orders)) in
 *   Lwt.return_ok
 *     { orders_pagination_orders = orders ; orders_pagination_contination } *)

let rec get_bid_orders_by_item_aux
    ?dbh ?origin ?continuation ?maker ?currency
    ?statuses ?start_date ?end_date ~size contract token_id acc =
  Format.eprintf "get_bid_orders_by_item_aux %s %s %Ld %s %s %d@."
    (match origin with None -> "None" | Some s -> s)
    (match continuation with
     | None -> "None"
     | Some (p, s) -> p ^ "_" ^ s)
    size
    contract
    (Z.to_string token_id)
    (List.length acc) ;
  let no_continuation, (p, h) =
    continuation = None,
    (match continuation with None -> Z.zero, "" | Some (ts, h) -> (Z.of_string ts, h)) in
  let no_maker, maker_v = maker = None, (match maker with None -> "" | Some m -> m) in
  let no_currency = currency = None in
  let currency_tezos = currency = Some ATXTZ in
  let currency_c, currency_contract = match currency with
    | Some (ATFT { contract ; _ } ) -> true, contract
    | Some (ATMT { asset_contract ; _ } ) -> true, asset_contract
    | Some (ATNFT { asset_contract ; _ } ) -> true, asset_contract
    | _ -> false, "" in
  let currency_tid, currency_token_id = match currency with
    | Some (ATFT { token_id ; _ } ) -> true, Option.value ~default:Z.zero token_id
    | Some (ATMT { asset_token_id ; _ } ) -> true, asset_token_id
    | Some (ATNFT { asset_token_id ; _ } ) -> true, asset_token_id
    | _ -> false, Z.zero in
  let no_start_date, start_date_v =
    start_date = None, (match start_date with None -> CalendarLib.Calendar.now () | Some d -> d) in
  let no_end_date, end_date_v =
    end_date = None, (match end_date with None -> CalendarLib.Calendar.now () | Some d -> d) in
  let len = Int64.of_int @@ List.length acc in
  if len < size  then
    use dbh @@ fun dbh ->
    let>? l =
      [%pgsql.object dbh
          "select hash, take_asset_value from orders \
           where take_asset_type_contract = $contract and \
           take_asset_type_token_id = ${Z.to_string token_id} and \
           ($no_maker or maker = $maker_v) and \
           ($no_currency or \
           ($currency_tezos and make_asset_type_class = 'XTZ') or \
           ($currency_c and not $currency_tid and
           make_asset_type_contract = $currency_contract) or \
           ($currency_c and $currency_tid and \
           make_asset_type_contract = $currency_contract and \
           make_asset_type_token_id = ${Z.to_string currency_token_id})) and \
           ($no_start_date or created_at >= $start_date_v) and \
           ($no_end_date or created_at <= $end_date_v) and \
           ($no_continuation or \
           (take_asset_value < ${Z.to_string p}::numeric) or \
           (take_asset_value = ${Z.to_string p}::numeric and \
           hash < $h)) \
           order by take_asset_value desc, hash desc \
           limit $size"] in
    let continuation = match List.rev l with
      | [] -> None
      | hd :: _ -> Some (Z.to_string hd#take_asset_value, hd#hash) in
    map_rp (fun r -> Get.get_order ~dbh r#hash) l >>=? fun orders ->
    match orders with
    | [] -> Lwt.return_ok acc
    | _ ->
      let orders = List.filter_map (fun x -> x) orders in
      let orders = filter_orders ?origin ?statuses orders in
      get_bid_orders_by_item_aux
        ~dbh ?origin ?continuation ?maker ?currency
        ?statuses ?start_date ?end_date ~size contract token_id (acc @ orders)
  else
  if len = size then Lwt.return_ok acc
  else
    Lwt.return_ok @@
    List.filter_map (fun x -> x) @@
    List.mapi (fun i order -> if i < Int64.to_int size then Some order else None) acc

let get_bid_orders_by_item
    ?dbh ?origin ?continuation ?(size=50) ?maker ?currency
    ?statuses ?start_date ?end_date contract token_id =
  Format.eprintf "get_bid_orders_by_item %s %s %s %s %s %d %s %s@."
    (match origin with None -> "None" | Some s -> s)
    (match statuses with None -> "None" | Some ss -> Utils.order_status_to_string ss)
    (match start_date with None -> "None" | Some sd -> Tzfunc.Proto.A.cal_to_str sd)
    (match end_date with None -> "None" | Some ed -> Tzfunc.Proto.A.cal_to_str ed)
    (match continuation with
     | None -> "None"
     | Some (f, s) -> f ^ "_" ^ s)
    size
    contract
    (Z.to_string token_id);
  let size = Int64.of_int size in
  let>? orders =
    get_bid_orders_by_item_aux
      ?dbh ?origin ?continuation ?maker ?currency
      ?statuses ?start_date ?end_date ~size contract token_id [] in
  let len = Int64.of_int @@ List.length orders in
  let orders, decs = List.split orders in
  let orders_pagination_continuation =
    if len = 0L || len < size then None
    else Some
        (mk_price_continuation @@ List.hd @@ List.rev orders) in
  Lwt.return_ok
    ({ orders_pagination_orders = orders ; orders_pagination_continuation }, decs)

let get_currencies_by_bid_orders_of_item ?dbh contract token_id =
  Format.eprintf "get_currencies_by_bid_orders_of_item %s %s\n%!" contract (Z.to_string token_id) ;
  use dbh @@ fun dbh ->
  let>? l =
    [%pgsql.object dbh
        "select hash, make_asset_type_class, \
         make_asset_type_contract, make_asset_type_token_id from orders \
         where take_asset_type_contract = $contract and \
         take_asset_type_token_id = ${Z.to_string token_id}"] in
  let>? assets = map_rp (fun r ->
      Lwt.return @@ Get.mk_asset
        r#make_asset_type_class
        r#make_asset_type_contract
        (Option.map Z.of_string r#make_asset_type_token_id)
        "0") l in
  let types = List.map (fun a -> a.asset_type) assets in
  let currencies =
    List.fold_left (fun acc t ->
        if List.exists (fun tt -> t = tt) acc then acc
        else t :: acc) [] types in
  Lwt.return_ok {
    order_currencies_order_type = COTBID ;
    order_currencies_currencies = currencies ;
  }

let get_currencies_by_sell_orders_of_item ?dbh contract token_id =
  Format.eprintf "get_currencies_by_bid_orders_of_item %s %s\n%!" contract (Z.to_string token_id) ;
  use dbh @@ fun dbh ->
  let>? l =
    [%pgsql.object dbh
        "select hash, take_asset_type_class, \
         take_asset_type_contract, take_asset_type_token_id from orders \
         where make_asset_type_contract = $contract and \
         make_asset_type_token_id = ${Z.to_string token_id}"] in
  let>? assets = map_rp (fun r ->
      Lwt.return @@ Get.mk_asset
        r#take_asset_type_class
        r#take_asset_type_contract
        (Option.map Z.of_string r#take_asset_type_token_id)
        "0") l in
  let types = List.map (fun a -> a.asset_type) assets in
  let currencies =
    List.fold_left (fun acc t ->
        if List.exists (fun tt -> t = tt) acc then acc
        else t :: acc) [] types in
  Lwt.return_ok {
    order_currencies_order_type = COTSELL ;
    order_currencies_currencies = currencies ;
  }

let insert_price_history dbh date make_value take_value hash_key =
  [%pgsql dbh
      "insert into order_price_history (date, make_value, take_value, hash) \
       values ($date, $make_value, $take_value, $hash_key)"]

let insert_origin_fees dbh fees hash_key =
  iter_rp (fun part ->
      let account = part.part_account in
      let value = part.part_value in
      [%pgsql dbh
          "insert into origin_fees (account, value, hash) \
           values ($account, $value, $hash_key)"])
    fees

let insert_payouts dbh p hash_key =
  [%pgsql dbh
      "delete from payouts where hash = $hash_key"] >>=? fun () ->
  iter_rp (fun part ->
      let account = part.part_account in
      let value = part.part_value in
      [%pgsql dbh
          "insert into payouts (account, value, hash) \
           values ($account, $value, $hash_key)"])
    p

let upsert_order ?dbh order =
  let order_elt = order.order_elt in
  let order_data = order.order_data in
  let maker = order_elt.order_elt_maker in
  let taker = order_elt.order_elt_taker in
  let maker_edpk = order_elt.order_elt_maker_edpk in
  let taker_edpk = order_elt.order_elt_taker_edpk in
  let>? make_class, make_contract, make_token_id, make_asset_value, make_decimals =
    Get.db_from_asset order_elt.order_elt_make in
  let>? take_class, take_contract, take_token_id, take_asset_value, take_decimals =
    Get.db_from_asset order_elt.order_elt_take in
  let start_date = order_elt.order_elt_start in
  let end_date = order_elt.order_elt_end in
  let salt = order_elt.order_elt_salt in
  let signature = order_elt.order_elt_signature in
  let created_at = order_elt.order_elt_created_at in
  let last_update_at = order_elt.order_elt_last_update_at in
  let payouts = order_data.order_rarible_v2_data_v1_payouts in
  let origin_fees = order_data.order_rarible_v2_data_v1_origin_fees in
  let hash_key = order_elt.order_elt_hash in
  use dbh @@ fun dbh ->
  let>? () = [%pgsql dbh
      "insert into orders(maker, taker, maker_edpk, taker_edpk, \
       make_asset_type_class, make_asset_type_contract, make_asset_type_token_id, \
       make_asset_value, make_asset_decimals, \
       take_asset_type_class, take_asset_type_contract, take_asset_type_token_id, \
       take_asset_value, take_asset_decimals, \
       start_date, end_date, salt, signature, created_at, last_update_at, hash) \
       values($maker, $?taker, $maker_edpk, $?taker_edpk, \
       $make_class, $?make_contract, $?{Option.map Z.to_string make_token_id}, $make_asset_value, $?make_decimals, \
       $take_class, $?take_contract, $?{Option.map Z.to_string take_token_id}, $take_asset_value, $?take_decimals, \
       $?start_date, $?end_date, ${Z.to_string salt}, $signature, $created_at, $last_update_at, $hash_key) \
       on conflict (hash) do update set (\
       make_asset_value, take_asset_value, last_update_at, signature) = \
       ($make_asset_value, $take_asset_value, $last_update_at, $signature)"] in
  Crawl.insert_order_activity_new ~decs:(make_decimals, take_decimals) dbh last_update_at order
  >>=? fun () ->
  insert_price_history dbh last_update_at make_asset_value take_asset_value hash_key >>=? fun () ->
  begin
    if last_update_at = created_at then insert_origin_fees dbh origin_fees hash_key
    else Lwt.return_ok ()
  end >>=? fun () ->
  insert_payouts dbh payouts hash_key >>=? fun () ->
  Produce.order_event_hash dbh order.order_elt.order_elt_hash ()

let mk_order_activity_continuation obj =
  Printf.sprintf "%Ld_%s"
    (Int64.of_float @@
     CalendarLib.Calendar.to_unixfloat obj#date *. 1000.)
    obj#id

let get_order_activities_by_collection ?dbh ?(sort=LATEST_FIRST) ?continuation ?(size=50) filter =
  Format.eprintf "get_order_activities_by_collection %s [%s] %s %d@."
    filter.order_activity_by_collection_contract
    (String.concat " " @@
     List.map (EzEncoding.construct order_activity_filter_all_type_enc)
       filter.order_activity_by_collection_types)
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size ;
  use dbh @@ fun dbh ->
  let contract = filter.order_activity_by_collection_contract in
  let types = Utils.filter_order_all_type_to_string filter.order_activity_by_collection_types in
  let size64 = Int64.of_int size in
  let no_continuation, (ts, h) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  let>? l =
    match sort with
    | LATEST_FIRST ->
      [%pgsql.object dbh
          "select a.id as id, order_activity_type, \
           o.make_asset_type_class, o.make_asset_type_contract, \
           o.make_asset_type_token_id, o.make_asset_value, o.make_asset_decimals, \
           o.take_asset_type_class, o.take_asset_type_contract, \
           o.take_asset_type_token_id, o.take_asset_value, o.take_asset_decimals, \
           o.maker, o.hash as o_hash, \
           match_left, match_right, \
           transaction, block, level, date, \
           \
           oleft.hash as oleft_hash, oleft.maker as oleft_maker, \

           oleft.salt as oleft_salt, \
           oleft.taker as oleft_taker, \
           oleft.make_asset_type_class as oleft_make_asset_type_class, \
           oleft.make_asset_type_contract as oleft_make_asset_type_contract, \
           oleft.make_asset_type_token_id as oleft_make_asset_type_token_id, \
           oleft.make_asset_value as oleft_make_asset_value, \
           oleft.make_asset_decimals as oleft_make_asset_decimals, \
           oleft.take_asset_type_class as oleft_take_asset_type_class, \
           oleft.take_asset_type_contract as oleft_take_asset_type_contract, \
           oleft.take_asset_type_token_id as oleft_take_asset_type_token_id, \
           oleft.take_asset_value as oleft_take_asset_value, \
           oleft.take_asset_decimals as oleft_take_asset_decimals, \
           \
           oright.hash as oright_hash, oright.maker as oright_maker, \
           oright.salt as oright_salt, \
           oright.taker as oright_taker, \
           oright.make_asset_type_class as oright_make_asset_type_class, \
           oright.make_asset_type_contract as oright_make_asset_type_contract, \
           oright.make_asset_type_token_id as oright_make_asset_type_token_id, \
           oright.make_asset_value as oright_make_asset_value, \
           oright.make_asset_decimals as oright_make_asset_decimals, \
           oright.take_asset_type_class as oright_take_asset_type_class, \
           oright.take_asset_type_contract as oright_take_asset_type_contract, \
           oright.take_asset_type_token_id as oright_take_asset_type_token_id, \
           oright.take_asset_value as oright_take_asset_value, \
           oright.take_asset_decimals as oright_take_asset_decimals \
           \
           from order_activities as a \
           left join orders as o on o.hash = a.hash \
           left join orders as oleft on oleft.hash = a.match_left \
           left join orders as oright on oright.hash = a.match_right where \
           main and position(order_activity_type in $types) > 0 and \
           (o.make_asset_type_contract = $contract or \
           o.take_asset_type_contract = $contract or \
           oleft.make_asset_type_contract = $contract or \
           oleft.take_asset_type_contract = $contract or \
           oright.make_asset_type_contract = $contract or \
           oright.take_asset_type_contract = $contract) and \
           ($no_continuation or \
           (date = $ts and id < $h) or \
           (date < $ts)) \
           order by date desc, \
           id desc \
           limit $size64"]
    | EARLIEST_FIRST ->
      [%pgsql.object dbh
          "select a.id as id, order_activity_type, \
           o.make_asset_type_class, o.make_asset_type_contract, \
           o.make_asset_type_token_id, o.make_asset_value, o.make_asset_decimals, \
           o.take_asset_type_class, o.take_asset_type_contract, \
           o.take_asset_type_token_id, o.take_asset_value, o.take_asset_decimals, \
           o.maker, o.hash as o_hash, \
           match_left, match_right, \
           transaction, block, level, date, \
           \
           oleft.hash as oleft_hash, oleft.maker as oleft_maker, \
           oleft.salt as oleft_salt, \
           oleft.taker as oleft_taker, \
           oleft.make_asset_type_class as oleft_make_asset_type_class, \
           oleft.make_asset_type_contract as oleft_make_asset_type_contract, \
           oleft.make_asset_type_token_id as oleft_make_asset_type_token_id, \
           oleft.make_asset_value as oleft_make_asset_value, \
           oleft.make_asset_decimals as oleft_make_asset_decimals, \
           oleft.take_asset_type_class as oleft_take_asset_type_class, \
           oleft.take_asset_type_contract as oleft_take_asset_type_contract, \
           oleft.take_asset_type_token_id as oleft_take_asset_type_token_id, \
           oleft.take_asset_value as oleft_take_asset_value, \
           oleft.take_asset_decimals as oleft_take_asset_decimals, \
           \
           oright.hash as oright_hash, oright.maker as oright_maker, \
           oright.salt as oright_salt, \
           oright.taker as oright_taker, \
           oright.make_asset_type_class as oright_make_asset_type_class, \
           oright.make_asset_type_contract as oright_make_asset_type_contract, \
           oright.make_asset_type_token_id as oright_make_asset_type_token_id, \
           oright.make_asset_value as oright_make_asset_value, \
           oright.make_asset_decimals as oright_make_asset_decimals, \
           oright.take_asset_type_class as oright_take_asset_type_class, \
           oright.take_asset_type_contract as oright_take_asset_type_contract, \
           oright.take_asset_type_token_id as oright_take_asset_type_token_id, \
           oright.take_asset_value as oright_take_asset_value, \
           oright.take_asset_decimals as oright_take_asset_decimals \
           \
           from order_activities as a \
           left join orders as o on o.hash = a.hash \
           left join orders as oleft on oleft.hash = a.match_left \
           left join orders as oright on oright.hash = a.match_right where \
           main and position(order_activity_type in $types) > 0 and \
           (o.make_asset_type_contract = $contract or \
           o.take_asset_type_contract = $contract or \
           oleft.make_asset_type_contract = $contract or \
           oleft.take_asset_type_contract = $contract or \
           oright.make_asset_type_contract = $contract or \
           oright.take_asset_type_contract = $contract) and \
           ($no_continuation or \
           (date = $ts and id > $h) or \
           (date > $ts)) \
           order by date asc, \
           id asc \
           limit $size64"] in
  let>? activities = map_rp (fun r ->
      let|>? (a, decs) = Get.mk_order_activity ~dbh r in
      (a, r), decs) l in
  let activities, decs = List.split activities in
  let len = List.length activities in
  let order_activities_continuation =
    if len <> size then None
    else Some
        (mk_order_activity_continuation @@ snd @@ List.hd (List.rev activities)) in
  Lwt.return_ok
    ({ order_activities_items = List.map fst activities ; order_activities_continuation }, decs)

let get_order_activities_by_item ?dbh ?(sort=LATEST_FIRST) ?continuation ?(size=50) filter =
  Format.eprintf "get_order_activities_by_item %s %s [%s] %s %d@."
    filter.order_activity_by_item_contract
    (Z.to_string filter.order_activity_by_item_token_id)
    (String.concat " " @@
     List.map (EzEncoding.construct order_activity_filter_all_type_enc)
       filter.order_activity_by_item_types)
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size ;
  use dbh @@ fun dbh ->
  let contract = filter.order_activity_by_item_contract in
  let token_id = filter.order_activity_by_item_token_id in
  let types = Utils.filter_order_all_type_to_string filter.order_activity_by_item_types in
  let size64 = Int64.of_int size in
  let no_continuation, (ts, h) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  let>? l =
    match sort with
    | LATEST_FIRST ->
      [%pgsql.object dbh
          "select a.id as id, order_activity_type, \
           o.make_asset_type_class, o.make_asset_type_contract, \
           o.make_asset_type_token_id, o.make_asset_value, o.make_asset_decimals, \
           o.take_asset_type_class, o.take_asset_type_contract, \
           o.take_asset_type_token_id, o.take_asset_value, o.take_asset_decimals, \
           o.maker, o.hash as o_hash, \
           match_left, match_right, \
           transaction, block, level, date, \
           \
           oleft.hash as oleft_hash, oleft.maker as oleft_maker, \
           oleft.salt as oleft_salt, \
           oleft.taker as oleft_taker, \
           oleft.make_asset_type_class as oleft_make_asset_type_class, \
           oleft.make_asset_type_contract as oleft_make_asset_type_contract, \
           oleft.make_asset_type_token_id as oleft_make_asset_type_token_id, \
           oleft.make_asset_value as oleft_make_asset_value, \
           oleft.make_asset_decimals as oleft_make_asset_decimals, \
           oleft.take_asset_type_class as oleft_take_asset_type_class, \
           oleft.take_asset_type_contract as oleft_take_asset_type_contract, \
           oleft.take_asset_type_token_id as oleft_take_asset_type_token_id, \
           oleft.take_asset_value as oleft_take_asset_value, \
           oleft.take_asset_decimals as oleft_take_asset_decimals, \
           \
           oright.hash as oright_hash, oright.maker as oright_maker, \
           oright.salt as oright_salt, \
           oright.taker as oright_taker, \
           oright.make_asset_type_class as oright_make_asset_type_class, \
           oright.make_asset_type_contract as oright_make_asset_type_contract, \
           oright.make_asset_type_token_id as oright_make_asset_type_token_id, \
           oright.make_asset_value as oright_make_asset_value, \
           oright.make_asset_decimals as oright_make_asset_decimals, \
           oright.take_asset_type_class as oright_take_asset_type_class, \
           oright.take_asset_type_contract as oright_take_asset_type_contract, \
           oright.take_asset_type_token_id as oright_take_asset_type_token_id, \
           oright.take_asset_value as oright_take_asset_value, \
           oright.take_asset_decimals as oright_take_asset_decimals \
           \
           from order_activities as a \
           left join orders as o on o.hash = a.hash \
           left join orders as oleft on oleft.hash = a.match_left \
           left join orders as oright on oright.hash = a.match_right where \
           main and position(order_activity_type in $types) > 0 and \
           ((o.make_asset_type_contract = $contract and o.make_asset_type_token_id = ${Z.to_string token_id}) or \
           (o.take_asset_type_contract = $contract and o.take_asset_type_token_id = ${Z.to_string token_id}) or \
           (oleft.make_asset_type_contract = $contract and \
           oleft.make_asset_type_token_id = ${Z.to_string token_id}) or \
           (oleft.take_asset_type_contract = $contract and \
           oleft.take_asset_type_token_id = ${Z.to_string token_id}) or \
           (oright.make_asset_type_contract = $contract and \
           oright.make_asset_type_token_id = ${Z.to_string token_id}) or \
           (oright.take_asset_type_contract = $contract and \
           oright.take_asset_type_token_id = ${Z.to_string token_id})) and \
           ($no_continuation or \
           (date = $ts and id < $h) or \
           (date < $ts)) \
           order by date desc, \
           id desc \
           limit $size64"]
    | EARLIEST_FIRST ->
      [%pgsql.object dbh
          "select a.id as id, order_activity_type, \
           o.make_asset_type_class, o.make_asset_type_contract, \
           o.make_asset_type_token_id, o.make_asset_value, o.make_asset_decimals, \
           o.take_asset_type_class, o.take_asset_type_contract, \
           o.take_asset_type_token_id, o.take_asset_value, o.take_asset_decimals, \
           o.maker, o.hash as o_hash, \
           match_left, match_right, \
           transaction, block, level, date, \
           \
           oleft.hash as oleft_hash, oleft.maker as oleft_maker, \
           oleft.salt as oleft_salt, \
           oleft.taker as oleft_taker, \
           oleft.make_asset_type_class as oleft_make_asset_type_class, \
           oleft.make_asset_type_contract as oleft_make_asset_type_contract, \
           oleft.make_asset_type_token_id as oleft_make_asset_type_token_id, \
           oleft.make_asset_value as oleft_make_asset_value, \
           oleft.make_asset_decimals as oleft_make_asset_decimals, \
           oleft.take_asset_type_class as oleft_take_asset_type_class, \
           oleft.take_asset_type_contract as oleft_take_asset_type_contract, \
           oleft.take_asset_type_token_id as oleft_take_asset_type_token_id, \
           oleft.take_asset_value as oleft_take_asset_value, \
           oleft.take_asset_decimals as oleft_take_asset_decimals, \
           \
           oright.hash as oright_hash, oright.maker as oright_maker, \
           oright.salt as oright_salt, \
           oright.taker as oright_taker, \
           oright.make_asset_type_class as oright_make_asset_type_class, \
           oright.make_asset_type_contract as oright_make_asset_type_contract, \
           oright.make_asset_type_token_id as oright_make_asset_type_token_id, \
           oright.make_asset_value as oright_make_asset_value, \
           oright.make_asset_decimals as oright_make_asset_decimals, \
           oright.take_asset_type_class as oright_take_asset_type_class, \
           oright.take_asset_type_contract as oright_take_asset_type_contract, \
           oright.take_asset_type_token_id as oright_take_asset_type_token_id, \
           oright.take_asset_value as oright_take_asset_value, \
           oright.take_asset_decimals as oright_take_asset_decimals \
           \
           from order_activities as a \
           left join orders as o on o.hash = a.hash \
           left join orders as oleft on oleft.hash = a.match_left \
           left join orders as oright on oright.hash = a.match_right where \
           main and position(order_activity_type in $types) > 0 and \
           ((o.make_asset_type_contract = $contract and o.make_asset_type_token_id = ${Z.to_string token_id}) or \
           (o.take_asset_type_contract = $contract and o.take_asset_type_token_id = ${Z.to_string token_id}) or \
           (oleft.make_asset_type_contract = $contract and \
           oleft.make_asset_type_token_id = ${Z.to_string token_id}) or \
           (oleft.take_asset_type_contract = $contract and \
           oleft.take_asset_type_token_id = ${Z.to_string token_id}) or \
           (oright.make_asset_type_contract = $contract and \
           oright.make_asset_type_token_id = ${Z.to_string token_id}) or \
           (oright.take_asset_type_contract = $contract and \
           oright.take_asset_type_token_id = ${Z.to_string token_id})) and \
           ($no_continuation or \
           (date = $ts and id > $h) or \
           (date > $ts)) \
           order by date asc, \
           id asc \
           limit $size64"] in
  let>? activities = map_rp (fun r ->
      let|>? a, decs = Get.mk_order_activity ~dbh r in
      (a, r), decs) l in
  let len = List.length activities in
  let activities, decs = List.split activities in
  let order_activities_continuation =
    if len <> size then None
    else Some
        (mk_order_activity_continuation @@ snd @@ List.hd (List.rev activities)) in
  Lwt.return_ok
    ({ order_activities_items = List.map fst activities ; order_activities_continuation }, decs)

let get_order_activities_all ?dbh ?(sort=LATEST_FIRST) ?continuation ?(size=50) types =
  let types = Utils.filter_order_all_type_to_string types in
  Format.eprintf "get_order_activities_all [%s] %s %d@."
    types
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size ;
  use dbh @@ fun dbh ->
  let size64 = Int64.of_int size in
  let no_continuation, (ts, h) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  let>? l =
    match sort with
    | LATEST_FIRST ->
      [%pgsql.object dbh
          "select a.id as id, order_activity_type, \
           o.make_asset_type_class, o.make_asset_type_contract, \
           o.make_asset_type_token_id, o.make_asset_value, o.make_asset_decimals, \
           o.take_asset_type_class, o.take_asset_type_contract, \
           o.take_asset_type_token_id, o.take_asset_value, o.take_asset_decimals, \
           o.maker, o.hash as o_hash, \
           match_left, match_right, \
           transaction, block, level, date, \
           \
           oleft.hash as oleft_hash, oleft.maker as oleft_maker, \
           oleft.salt as oleft_salt, \
           oleft.taker as oleft_taker, \
           oleft.make_asset_type_class as oleft_make_asset_type_class, \
           oleft.make_asset_type_contract as oleft_make_asset_type_contract, \
           oleft.make_asset_type_token_id as oleft_make_asset_type_token_id, \
           oleft.make_asset_value as oleft_make_asset_value, \
           oleft.make_asset_decimals as oleft_make_asset_decimals, \
           oleft.take_asset_type_class as oleft_take_asset_type_class, \
           oleft.take_asset_type_contract as oleft_take_asset_type_contract, \
           oleft.take_asset_type_token_id as oleft_take_asset_type_token_id, \
           oleft.take_asset_value as oleft_take_asset_value, \
           oleft.take_asset_decimals as oleft_take_asset_decimals, \
           \
           oright.hash as oright_hash, oright.maker as oright_maker, \
           oright.salt as oright_salt, \
           oright.taker as oright_taker, \
           oright.make_asset_type_class as oright_make_asset_type_class, \
           oright.make_asset_type_contract as oright_make_asset_type_contract, \
           oright.make_asset_type_token_id as oright_make_asset_type_token_id, \
           oright.make_asset_value as oright_make_asset_value, \
           oright.make_asset_decimals as oright_make_asset_decimals, \
           oright.take_asset_type_class as oright_take_asset_type_class, \
           oright.take_asset_type_contract as oright_take_asset_type_contract, \
           oright.take_asset_type_token_id as oright_take_asset_type_token_id, \
           oright.take_asset_value as oright_take_asset_value, \
           oright.take_asset_decimals as oright_take_asset_decimals \
           \
           from order_activities as a \
           left join orders as o on o.hash = a.hash \
           left join orders as oleft on oleft.hash = a.match_left \
           left join orders as oright on oright.hash = a.match_right where \
           main and position(order_activity_type in $types) > 0 and \
           ($no_continuation or \
           (date = $ts and id < $h) or \
           (date < $ts)) \
           order by date desc, \
           id desc \
           limit $size64"]
    | EARLIEST_FIRST ->
      [%pgsql.object dbh
          "select a.id as id, order_activity_type, \
           o.make_asset_type_class, o.make_asset_type_contract, \
           o.make_asset_type_token_id, o.make_asset_value, o.make_asset_decimals, \
           o.take_asset_type_class, o.take_asset_type_contract, \
           o.take_asset_type_token_id, o.take_asset_value, o.take_asset_decimals, \
           o.maker, o.hash as o_hash, \
           match_left, match_right, \
           transaction, block, level, date, \
           \
           oleft.hash as oleft_hash, oleft.maker as oleft_maker, \
           oleft.salt as oleft_salt, \
           oleft.taker as oleft_taker, \
           oleft.make_asset_type_class as oleft_make_asset_type_class, \
           oleft.make_asset_type_contract as oleft_make_asset_type_contract, \
           oleft.make_asset_type_token_id as oleft_make_asset_type_token_id, \
           oleft.make_asset_value as oleft_make_asset_value, \
           oleft.make_asset_decimals as oleft_make_asset_decimals, \
           oleft.take_asset_type_class as oleft_take_asset_type_class, \
           oleft.take_asset_type_contract as oleft_take_asset_type_contract, \
           oleft.take_asset_type_token_id as oleft_take_asset_type_token_id, \
           oleft.take_asset_value as oleft_take_asset_value, \
           oleft.take_asset_decimals as oleft_take_asset_decimals, \
           \
           oright.hash as oright_hash, oright.maker as oright_maker, \
           oright.salt as oright_salt, \
           oright.taker as oright_taker, \
           oright.make_asset_type_class as oright_make_asset_type_class, \
           oright.make_asset_type_contract as oright_make_asset_type_contract, \
           oright.make_asset_type_token_id as oright_make_asset_type_token_id, \
           oright.make_asset_value as oright_make_asset_value, \
           oright.make_asset_decimals as oright_make_asset_decimals, \
           oright.take_asset_type_class as oright_take_asset_type_class, \
           oright.take_asset_type_contract as oright_take_asset_type_contract, \
           oright.take_asset_type_token_id as oright_take_asset_type_token_id, \
           oright.take_asset_value as oright_take_asset_value, \
           oright.take_asset_decimals as oright_take_asset_decimals \
           \
           from order_activities as a \
           left join orders as o on o.hash = a.hash \
           left join orders as oleft on oleft.hash = a.match_left \
           left join orders as oright on oright.hash = a.match_right where \
           main and position(order_activity_type in $types) > 0 and \
           ($no_continuation or \
           (date = $ts and id > $h) or \
           (date > $ts)) \
           order by date asc, \
           id asc limit $size64"] in
  let>? activities = map_rp (fun r ->
      let|>? a, decs = Get.mk_order_activity ~dbh r in
      (a, r), decs) l in
  let len = List.length activities in
  let activities, decs = List.split activities in
  let order_activities_continuation =
    if len <> size then None
    else Some
        (mk_order_activity_continuation @@ snd @@ List.hd (List.rev activities)) in
  Lwt.return_ok
    ({ order_activities_items = List.map fst activities ; order_activities_continuation }, decs)

let get_order_activities_by_user ?dbh ?(sort=LATEST_FIRST) ?continuation ?(size=50) filter =
  Format.eprintf "get_order_activities_by_user [%s] [%s] %s %d@."
    (String.concat " " filter.order_activity_by_user_users)
    (String.concat " " @@
     List.map (EzEncoding.construct order_activity_filter_user_type_enc)
       filter.order_activity_by_user_types)
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size ;
  use dbh @@ fun dbh ->
  let users = String.concat ";" filter.order_activity_by_user_users in
  let types = Utils.filter_order_user_type_to_string filter.order_activity_by_user_types in
  let size64 = Int64.of_int size in
  let no_continuation, (ts, h) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  let>? l =
    match sort with
    | LATEST_FIRST ->
      [%pgsql.object dbh
          "select a.id as id, order_activity_type, \
           o.make_asset_type_class, o.make_asset_type_contract, \
           o.make_asset_type_token_id, o.make_asset_value, o.make_asset_decimals, \
           o.take_asset_type_class, o.take_asset_type_contract, \
           o.take_asset_type_token_id, o.take_asset_value, o.take_asset_decimals, \
           o.maker, o.hash as o_hash, \
           match_left, match_right, \
           transaction, block, level, date, \
           \
           oleft.hash as oleft_hash, oleft.maker as oleft_maker, \
           oleft.salt as oleft_salt, \
           oleft.taker as oleft_taker, \
           oleft.make_asset_type_class as oleft_make_asset_type_class, \
           oleft.make_asset_type_contract as oleft_make_asset_type_contract, \
           oleft.make_asset_type_token_id as oleft_make_asset_type_token_id, \
           oleft.make_asset_value as oleft_make_asset_value, \
           oleft.make_asset_decimals as oleft_make_asset_decimals, \
           oleft.take_asset_type_class as oleft_take_asset_type_class, \
           oleft.take_asset_type_contract as oleft_take_asset_type_contract, \
           oleft.take_asset_type_token_id as oleft_take_asset_type_token_id, \
           oleft.take_asset_value as oleft_take_asset_value, \
           oleft.take_asset_decimals as oleft_take_asset_decimals, \
           \
           oright.hash as oright_hash, oright.maker as oright_maker, \
           oright.salt as oright_salt, \
           oright.taker as oright_taker, \
           oright.make_asset_type_class as oright_make_asset_type_class, \
           oright.make_asset_type_contract as oright_make_asset_type_contract, \
           oright.make_asset_type_token_id as oright_make_asset_type_token_id, \
           oright.make_asset_value as oright_make_asset_value, \
           oright.make_asset_decimals as oright_make_asset_decimals, \
           oright.take_asset_type_class as oright_take_asset_type_class, \
           oright.take_asset_type_contract as oright_take_asset_type_contract, \
           oright.take_asset_type_token_id as oright_take_asset_type_token_id, \
           oright.take_asset_value as oright_take_asset_value, \
           oright.take_asset_decimals as oright_take_asset_decimals \
           \
           from order_activities as a \
           left join orders as o on o.hash = a.hash \
           left join orders as oleft on oleft.hash = a.match_left \
           left join orders as oright on oright.hash = a.match_right where \
           main and position(order_activity_type in $types) > 0 and \
           ((position(o.maker in $users) > 0 or position(o.taker in $users) > 0) or \
           (position(oleft.maker in $users) > 0 or position(oleft.taker in $users) > 0) or \
           (position(oright.maker in $users) > 0 or position(oright.taker in $users) > 0)) and \
           ($no_continuation or \
           (date = $ts and id < $h) or \
           (date < $ts)) \
           order by date desc, \
           id desc \
           limit $size64"]
    | EARLIEST_FIRST ->
      [%pgsql.object dbh
          "select a.id as id, order_activity_type, \
           o.make_asset_type_class, o.make_asset_type_contract, \
           o.make_asset_type_token_id, o.make_asset_value, o.make_asset_decimals, \
           o.take_asset_type_class, o.take_asset_type_contract, \
           o.take_asset_type_token_id, o.take_asset_value, o.take_asset_decimals, \
           o.maker, o.hash as o_hash, \
           match_left, match_right, \
           transaction, block, level, date, \
           \
           oleft.hash as oleft_hash, oleft.maker as oleft_maker, \
           oleft.salt as oleft_salt, \
           oleft.taker as oleft_taker, \
           oleft.make_asset_type_class as oleft_make_asset_type_class, \
           oleft.make_asset_type_contract as oleft_make_asset_type_contract, \
           oleft.make_asset_type_token_id as oleft_make_asset_type_token_id, \
           oleft.make_asset_value as oleft_make_asset_value, \
           oleft.make_asset_decimals as oleft_make_asset_decimals, \
           oleft.take_asset_type_class as oleft_take_asset_type_class, \
           oleft.take_asset_type_contract as oleft_take_asset_type_contract, \
           oleft.take_asset_type_token_id as oleft_take_asset_type_token_id, \
           oleft.take_asset_value as oleft_take_asset_value, \
           oleft.take_asset_decimals as oleft_take_asset_decimals, \
           \
           oright.hash as oright_hash, oright.maker as oright_maker, \
           oright.salt as oright_salt, \
           oright.taker as oright_taker, \
           oright.make_asset_type_class as oright_make_asset_type_class, \
           oright.make_asset_type_contract as oright_make_asset_type_contract, \
           oright.make_asset_type_token_id as oright_make_asset_type_token_id, \
           oright.make_asset_value as oright_make_asset_value, \
           oright.make_asset_decimals as oright_make_asset_decimals, \
           oright.take_asset_type_class as oright_take_asset_type_class, \
           oright.take_asset_type_contract as oright_take_asset_type_contract, \
           oright.take_asset_type_token_id as oright_take_asset_type_token_id, \
           oright.take_asset_value as oright_take_asset_value, \
           oright.take_asset_decimals as oright_take_asset_decimals \
           \
           from order_activities as a \
           left join orders as o on o.hash = a.hash \
           left join orders as oleft on oleft.hash = a.match_left \
           left join orders as oright on oright.hash = a.match_right where \
           main and position(order_activity_type in $types) > 0 and \
           ((position(o.maker in $users) > 0 or position(o.taker in $users) > 0) or \
           (position(oleft.maker in $users) > 0 or position(oleft.taker in $users) > 0) or \
           (position(oright.maker in $users) > 0 or position(oright.taker in $users) > 0)) and \
           ($no_continuation or \
           (date = $ts and id > $h) or \
           (date > $ts)) \
           order by date asc, \
           id asc \
           limit $size64"] in
  let>? activities = map_rp (fun r ->
      let|>? a, decs = Get.mk_order_activity ~dbh r in
      (a, r), decs) l in
  let len = List.length activities in
  let activities, decs = List.split activities in
  let order_activities_continuation =
    if len <> size then None
    else Some
        (mk_order_activity_continuation @@ snd @@ List.hd (List.rev activities)) in
  Lwt.return_ok
    ({ order_activities_items = List.map fst activities ; order_activities_continuation }, decs)

let get_order_activities ?dbh ?sort ?continuation ?size = function
  | OrderActivityFilterByCollection filter ->
    get_order_activities_by_collection ?dbh ?sort ?continuation ?size filter
  | OrderActivityFilterByItem filter ->
    get_order_activities_by_item ?dbh ?sort ?continuation ?size filter
  | OrderActivityFilterByUser filter ->
    get_order_activities_by_user ?dbh ?sort ?continuation ?size filter
  | OrderActivityFilterAll types ->
    get_order_activities_all ?dbh ?sort ?continuation ?size types

let status () =
  Format.eprintf "get status@.";
  use None @@ fun dbh ->
  let>? state =
    [%pgsql.object dbh
        "select p.level, tsp, chain_id from state, predecessors p \
         where main order by level desc limit 1"] in
  match state with
  | [ r ] ->
    Lwt.return_ok {
      status_level = r#level; status_timestamp = CalendarLib.Calendar.now ();
      status_chain_id = r#chain_id; status_chain_timestamp = r#tsp }
  | _ -> Lwt.return_error (`hook_error "no status information")
