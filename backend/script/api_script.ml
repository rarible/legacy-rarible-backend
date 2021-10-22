open Rtypes
open Let
open Common.Utils

let cwd = Sys.getcwd ()
let exe = Sys.argv.(0)

let api = ref "http://localhost:8080"
let sdk = ref false
let endpoint = ref "http://granada.tz.functori.com"

let validator = "KT1JrWXMuHp7nkX7j3trtxckVBiTyggDNnU1"
let exchange_v2 = "KT1CfvTiEz9EVBLBLLYYFvRTwqyLsCvoZtWm"
let royalties = "KT1JPYtEMv8PHXfmLoMuWRLsVykoEou5AqKG"
let lugh_contract = "KT1HT3EbSPFA1MM2ZiMThB6P6Kky5jebNgAx"

let config = {
  admin_wallet = "" ;
  exchange_v2 ;
  validator ;
  royalties = "" ;
  contracts = SMap.empty;
  ft_contracts = SMap.empty;
}

let api_pid = ref None
let crawler_pid = ref None

(* ALIAS * EDPK * EDSK *)
let accounts = [
  "rarible5",
  "edpktjwGH2VwKJkAVztZvr5Gkifg5bKx99GT6wDCctQL6xgRHB3pRc",
  "edsk4XzV1K3Td1fVUhRv33iduTdNCxmHidUsCKRkvK2NgnersFdEUY" ;
  "rarible4",
  "edpkuiqLaC3YvwMQTKezCV9pJs2vjqPxoonMJDBdNqnwQxiMx3ag8h",
  "edsk3LVprL8yNHpVcbLrbaFm25njKkyjJrZEGCweuxqkCh7SiEyH4L" ;
  "rarible3",
  "edpkuDUy4h4y2qqSHDgdid8WxESu3YwaPmWZ42p4G3ZCnE5epgtXhH",
  "edsk49SC61Sb1QYRQQRW7M6SRmWMvjoaVsfCftkdoERv8BENe7ssV4" ;
  "rarible2",
  "edpktoPwmCz9Wbr8BKByJPnasrPq1BfoAVURtAhxpw7WafbktMnkrp",
  "edsk35jq62PmRmRB5vH1rUE5W6wzE7P6sn3r58C3TKcDtnwx6MpFUU" ;
  "rarible1",
  "edpku7dXXEdSPb2nMJMEbGSuPZtPcfRZ8RLpX5FGKZ629ezW1YjaWa" ,
  "edsk2kPLkNyYQi9kqQnh6VTip9MS7c6rEnUastw1BMb1hf9FgDfRBu";
]
let accounts_len = List.length accounts

let fa1_2_contracts = [
  "KT1ENHtWh8umKktxT3wC3HbDjwopuuVmXJvD"
]
let fa1_2_contracts_len = List.length fa1_2_contracts

let fa2_contracts = [
  "KT1BRQ73L3admx2NATrEHuPyy986g8wfgMqp" ;
  "KT1Ch6PstAQG32uNfQJUSL2bf2WvimvY5umk" ;
  "KT1McsKK4Y2GK369M9QQSzjux52EsSkfjcMJ" ;
]
let fa2_contracts_len = List.length fa2_contracts

let origins = [
  "tz1f6TuKe38VPURr6gA1xiQq9dzuVuzNZoP6" ;
  "tz1KiZygjrVaS1fjs9iW4YSKNiqoopHK8Hdj"
]
let origins_len = List.length origins

let royalties_contracts = [
  "KT1JPYtEMv8PHXfmLoMuWRLsVykoEou5AqKG"
]
let royalties_contracts_len = List.length royalties_contracts

let exchange_contracts = [
]
let exchange_contracts_len = List.length exchange_contracts

let validator_contracts = [
]
let validator_contracts_len = List.length exchange_contracts

let set_opt_string r = Arg.String (fun s -> r := Some s)
let set_opt_float r = Arg.Float (fun f -> r := Some f)
let set_opt_int r = Arg.Int (fun i -> r := Some i)

let arg_parse ~spec ~usage f =
  Arg.parse spec f usage

let js = ref false

let spec = [
  "--api", Arg.Set_string api, "api address (default: http://localhost:8080)";
  "--endpoint", Arg.Set_string endpoint, "node endpoint (default: http://granada.tz.functori.com)";
  "--client", Arg.Set_string Script.client, "tezos client" ;
  "--sdk", Arg.Set sdk, "use sdk to make tezos operations (default: false, uses tezos-client)";
  "--verbose", Arg.Set_int Script.verbose, "verbosity";
  "--js", Arg.Set js, "use js sdk";
]

let by_pk i =
  try
    List.find (fun (_, pk, _) -> pk = i) accounts
  with Not_found ->
    Printf.eprintf "Not_found by_alias %s\n%!" i ;
    raise Not_found

let by_sk i =
  try
    List.find (fun (_, _, sk) -> sk = i) accounts
  with Not_found ->
    Printf.eprintf "Not_found by_sk %s\n%!" i ;
    raise Not_found
let by_alias i =
  try
    List.find (fun (alias, _, _) -> alias = i) accounts
  with Not_found ->
    Printf.eprintf "Not_found by_alias %s\n%!" i ;
    raise Not_found

let rec sys_command ?(verbose=0) ?(retry=0) c =
  if verbose > 0 then Printf.eprintf "cmd: %s\n%!" c ;
  let oldstdout = Unix.dup Unix.stdout in
  let oldstderr = Unix.dup Unix.stderr in
  let temp_fn = Filename.temp_file "sys_command_" "" in
  let out_temp_fn = temp_fn ^ "_redirect_stdout" in
  let err_temp_fn = temp_fn ^ "_redirect_stderr" in
  let newstdout = open_out out_temp_fn in
  let newstderr = open_out err_temp_fn in
  Unix.dup2 (Unix.descr_of_out_channel newstdout) Unix.stdout;
  Unix.dup2 (Unix.descr_of_out_channel newstderr) Unix.stderr;
  let code = Sys.command c in
  flush newstdout ;
  flush newstderr ;
  Unix.dup2 oldstdout Unix.stdout ;
  Unix.dup2 oldstderr Unix.stderr ;
  close_out newstdout ;
  close_out newstderr ;
  if code <> 0 && retry > 0 then
    begin
    Printf.eprintf "Failure on Sys.command (%s)... retrying in 2sec\n%!" err_temp_fn ;
    Unix.sleep 2 ;
    sys_command ~verbose ~retry:(retry-1) c
  end
  else
    code, out_temp_fn, err_temp_fn

let pk_to_pkh_exn pk =
  match Tzfunc.Crypto.pk_to_pkh pk with
  | Error _ -> assert false
  | Ok pkh -> pkh

let generate_option f =
  if Random.bool () then
    Some (f ())
  else None

let generate_origin () =
  List.nth origins (Random.int origins_len)

let rec generate_address ?alias ?(diff=None) () =
  match alias with
  | Some a -> by_alias a
  | None ->
    match diff with
    | None ->
      List.nth accounts (Random.int accounts_len)
    | Some a ->
      let (_, pk, _) as r = List.nth accounts (Random.int accounts_len) in
      let tz1 = pk_to_pkh_exn pk in
      if a = tz1 then generate_address ~diff ()
      else r

let generate_maker () =
  generate_address ()

let generate_taker () =
  generate_option generate_address

let tezos_asset () = ATXTZ, Random.int64 10000000000L

let generate_fa1_2_asset () =
  let contract = List.nth fa1_2_contracts (Random.int fa1_2_contracts_len) in
  ATFA_1_2 contract, Random.int64 100L

let generate_fa2_asset () =
  let asset_fa2_contract = List.nth fa2_contracts (Random.int fa2_contracts_len) in
  let asset_fa2_token_id = string_of_int @@ (Random.int 1000) + 1 in
  ATFA_2 { asset_fa2_contract ; asset_fa2_token_id }, 1L

let generate_asset () =
  let kind = Random.int 3 in
  let at, value =
    match kind with
    | 0 -> tezos_asset ()
    | 1 -> generate_fa1_2_asset ()
    | 2 -> generate_fa2_asset ()
    | _ -> assert false in
  { asset_type = at; asset_value = Int64.to_string value }

let generate_salt () =
  string_of_int @@ (Random.int 10000) + 1

let generate_amount ?(max=100_000) () = Random.int max

let generate_token_id () = string_of_int @@ generate_amount ~max:1_000_000 ()

let generate_part () =
  let part_account = generate_origin () in
  let part_value = Int32.mul (Random.int32 50l) 100l in
  { part_account ; part_value }

let generate_parts () =
  [ generate_part () ]

let pick_royalties () =
  List.nth royalties_contracts (Random.int royalties_contracts_len)

let generate_alias prefix =
  Printf.sprintf "%s_%d" prefix (Random.int 100000)

let generate_royalties () =
  let rec aux royalties =
    let total =
      List.fold_left (fun acc (_addr, v) -> acc + v) 0 royalties in
    if total = 5000 then royalties
    else
      let _, addr_pk, _ = generate_address () in
      let v = (Random.int 4999) + 1 in
      try
        let old = List.assoc addr_pk royalties in
        aux ((addr_pk, v + old) :: (List.remove_assoc addr_pk royalties))
      with Not_found ->
        (addr_pk, v) :: royalties in
  List.map (fun (addr, v) -> pk_to_pkh_exn addr, Int64.of_int v) @@ aux []

let mk_order_form
    maker maker_edpk taker taker_edpk make take salt start_date end_date signature data_type payouts origin_fees =
  let elt = {
    order_form_elt_maker = maker ;
    order_form_elt_maker_edpk = maker_edpk ;
    order_form_elt_taker = taker ;
    order_form_elt_taker_edpk = taker_edpk ;
    order_form_elt_make = make ;
    order_form_elt_take = take ;
    order_form_elt_salt = salt ;
    order_form_elt_start = start_date ;
    order_form_elt_end = end_date ;
    order_form_elt_signature = signature ;
  } in
  let data = {
    order_rarible_v2_data_v1_data_type = data_type ;
    order_rarible_v2_data_v1_payouts = payouts ;
    order_rarible_v2_data_v1_origin_fees = origin_fees ;
  } in {
    order_form_elt = elt ;
    order_form_data = data ;
    order_form_type = ()
  }

let generate_order () =
  let _alias, maker_pk, maker_sk = generate_maker () in
  let maker = pk_to_pkh_exn maker_pk in
  let taker, taker_pk = match generate_taker () with
    | None -> None, None
    | Some (_, pk, _) -> Some (pk_to_pkh_exn pk), Some pk in
  let make = generate_asset () in
  let take = generate_asset () in
  let salt = generate_salt () in
  let start_date = None in
  let end_date = None in
  let data_type = "V1" in
  let payouts = [] in
  let origin_fees = generate_parts () in
  let$ to_sign =
    hash_order_form
      maker_pk make taker_pk take salt start_date end_date data_type payouts origin_fees in
  let$ signature = Tzfunc.Crypto.Ed25519.sign ~edsk:maker_sk to_sign in
  let order_form =
    mk_order_form
      maker maker_pk taker taker_pk make take salt start_date end_date signature data_type payouts origin_fees in
  Ok order_form

let maker_from_item ((_owner, owner_sk), _am, _token_id, _royalties, _metadata) =
  by_sk owner_sk

let asset_from_item collection ((_owner, _owner_sk), am, token_id, _royalties, _metadata) =
  let asset_type = ATFA_2 { asset_fa2_contract = collection ; asset_fa2_token_id = token_id } in
  { asset_type ; asset_value = string_of_int am }

let order_form_from_items ?(salt=0) collection item1 item2 =
  let _maker, maker_pk, maker_sk = maker_from_item item1 in
  let maker = pk_to_pkh_exn maker_pk in
  let taker, taker_pk = None, None in
  let make = asset_from_item collection item1 in
  let take = asset_from_item collection item2 in
  let salt = string_of_int salt in
  let start_date = None in
  let end_date = None in
  let data_type = "V1" in
  let payouts = [] in
  let origin_fees = [] in
  let$ to_sign =
    hash_order_form
      maker_pk make taker_pk take salt start_date end_date data_type payouts origin_fees in
  let$ signature = Tzfunc.Crypto.Ed25519.sign ~edsk:maker_sk to_sign in
  let order_form =
    mk_order_form
      maker maker_pk taker taker_pk make take salt start_date end_date signature data_type payouts origin_fees in
  Ok order_form

let sell_order_form_from_item ?(salt=0) collection item1 take =
  let _maker, maker_pk, maker_sk = maker_from_item item1 in
  let maker = pk_to_pkh_exn maker_pk in
  let taker, taker_pk = None, None in
  let make = asset_from_item collection item1 in
  let salt = string_of_int salt in
  let start_date = None in
  let end_date = None in
  let data_type = "V1" in
  let payouts = [] in
  let origin_fees = [] in
  let$ to_sign =
    hash_order_form
      maker_pk make taker_pk take salt start_date end_date data_type payouts origin_fees in
  let$ signature = Tzfunc.Crypto.Ed25519.sign ~edsk:maker_sk to_sign in
  let order_form =
    mk_order_form
      maker maker_pk taker taker_pk make take salt start_date end_date signature data_type payouts origin_fees in
  Ok order_form

let buy_order_form_from_item ?(salt=0) collection item1 (maker_pk, maker_sk) make =
  let taker, taker_pk = None, None in
  let maker = pk_to_pkh_exn maker_pk in
  let take = asset_from_item collection item1 in
  let salt = string_of_int salt in
  let start_date = None in
  let end_date = None in
  let data_type = "V1" in
  let payouts = [] in
  let origin_fees = [] in
  let$ to_sign =
    hash_order_form
      maker_pk make taker_pk take salt start_date end_date data_type payouts origin_fees in
  let$ signature = Tzfunc.Crypto.Ed25519.sign ~edsk:maker_sk to_sign in
  let order_form =
    mk_order_form
      maker maker_pk taker taker_pk make take salt start_date end_date signature data_type payouts origin_fees in
  Ok order_form

let handle_ezreq_result = function
  | Ok x -> Ok x
  | Error (EzReq_lwt_S.UnknownError {msg; _}) ->
    Error (`UNKNOWN (match msg with None -> "" | Some s -> s))
  | Error (EzReq_lwt_S.KnownError {error; _}) -> Error error

let call_upsert_order order_form =
  let url = EzAPI.BASE !api in
  let|> r = EzReq_lwt.post0 ~input:order_form url Api.upsert_order_s in
  handle_ezreq_result r

let call_generate_token_id collection =
  let url = EzAPI.BASE !api in
  let|> r = EzReq_lwt.get1 url Api.generate_nft_token_id_s collection in
  handle_ezreq_result r

let call_get_nft_collection_by_id collection =
  let url = EzAPI.BASE !api in
  let|> r = EzReq_lwt.get1 url Api.get_nft_collection_by_id_s collection in
  handle_ezreq_result r

let call_search_nft_collections_by_owner owner =
  let open EzAPI in
  let url = BASE !api in
  let rec aux ?continuation acc =
    let params = match continuation with
      | None -> [ Api.owner_param , S owner ]
      | Some c -> [ Api.owner_param , S owner ; Api.continuation_param, S c ] in
    let> r = EzReq_lwt.get0 url ~params Api.search_nft_collections_by_owner_s in
    let>? collections = Lwt.return @@ handle_ezreq_result r in
    match collections.nft_collections_continuation with
    | None -> Lwt.return_ok @@ collections.nft_collections_collections @ acc
    | Some continuation ->
      aux ~continuation (collections.nft_collections_collections @ acc) in
  aux []

let call_search_nft_all_collections () =
  let open EzAPI in
  let url = BASE !api in
  let rec aux ?continuation acc =
    let params = match continuation with
      | None -> []
      | Some c -> [ Api.continuation_param, S c ] in
    let> r = EzReq_lwt.get0 url ~params Api.search_nft_all_collections_s in
    let>? collections = Lwt.return @@ handle_ezreq_result r in
    match collections.nft_collections_continuation with
    | None -> Lwt.return_ok @@ collections.nft_collections_collections @ acc
    | Some continuation ->
      aux ~continuation (collections.nft_collections_collections @ acc) in
  aux []

let call_get_nft_item_by_id collection tid =
  let url = EzAPI.BASE !api in
  let|> r = EzReq_lwt.get1 url Api.get_nft_item_by_id_s
      (Printf.sprintf "%s:%s" collection tid) in
  handle_ezreq_result r
  (*  >>= fun res ->
   * begin match res with
   *   | Ok item ->
   *     Printf.eprintf "%s\n%!" @@ EzEncoding.construct nft_item_enc item ;
   *   | _ -> ()
   * end ;
   * Lwt.return res *)

let call_get_nft_items_by_owner owner =
  let open EzAPI in
  let url = BASE !api in
  let rec aux ?continuation acc =
    let params = match continuation with
      | None -> [ Api.owner_param , S owner ]
      | Some c -> [ Api.owner_param , S owner ; Api.continuation_param, S c ] in
    let> r = EzReq_lwt.get0 url ~params Api.get_nft_items_by_owner_s in
    let>? items = Lwt.return @@ handle_ezreq_result r in
    match items.nft_items_continuation with
    | None -> Lwt.return_ok @@ items.nft_items_items @ acc
    | Some continuation ->
      aux ~continuation (items.nft_items_items @ acc) in
  aux []

let call_get_nft_items_by_collection collection =
  let open EzAPI in
  let url = BASE !api in
  let rec aux ?continuation acc =
    let params = match continuation with
      | None -> [ Api.collection_param , S collection ]
      | Some c -> [ Api.collection_param , S collection ; Api.continuation_param, S c ] in
    let> r = EzReq_lwt.get0 url ~params Api.get_nft_items_by_collection_s in
    let>? items = Lwt.return @@ handle_ezreq_result r in
    match items.nft_items_continuation with
    | None -> Lwt.return_ok @@ items.nft_items_items @ acc
    | Some continuation ->
      aux ~continuation (items.nft_items_items @ acc) in
  aux []

let call_get_nft_all_items () =
  let open EzAPI in
  let url = BASE !api in
  let rec aux ?continuation acc =
    let params = match continuation with
      | None -> [ ]
      | Some c -> [ Api.continuation_param, S c ] in
    let> r = EzReq_lwt.get0 url ~params Api.get_nft_all_items_s in
    let>? items = Lwt.return @@ handle_ezreq_result r in
    match items.nft_items_continuation with
    | None -> Lwt.return_ok @@ items.nft_items_items @ acc
    | Some continuation ->
      aux ~continuation (items.nft_items_items @ acc) in
  aux []

let call_get_nft_ownership_by_id collection tid owner  =
  let url = EzAPI.BASE !api in
  let|> r = EzReq_lwt.get1 url Api.get_nft_ownership_by_id_s
      (Printf.sprintf "%s:%s:%s" collection tid owner) in
  handle_ezreq_result r

let call_get_nft_ownerships_by_item contract tid =
  let open EzAPI in
  let url = BASE !api in
  let params = [ Api.contract_param, S contract ; Api.token_id_param, S tid  ] in
  let rec aux ?continuation acc =
    let params = match continuation with
      | None -> params
      | Some c -> params @ [ Api.continuation_param, S c ] in
    let> r = EzReq_lwt.get0 url ~params Api.get_nft_ownerships_by_item_s in
    let>? ownerships = Lwt.return @@ handle_ezreq_result r in
    match ownerships.nft_ownerships_continuation with
    | None -> Lwt.return_ok @@ ownerships.nft_ownerships_ownerships @ acc
    | Some continuation ->
      aux ~continuation (ownerships.nft_ownerships_ownerships @ acc) in
  aux []

let call_get_nft_all_ownerships () =
  let open EzAPI in
  let url = BASE !api in
  let rec aux ?continuation acc =
    let params = match continuation with
      | None -> [ ]
      | Some c -> [ Api.continuation_param, S c ] in
    let> r = EzReq_lwt.get0 url ~params Api.get_nft_all_ownerships_s in
    let>? ownerships = Lwt.return @@ handle_ezreq_result r in
    match ownerships.nft_ownerships_continuation with
    | None -> Lwt.return_ok @@ ownerships.nft_ownerships_ownerships @ acc
    | Some continuation ->
      aux ~continuation (ownerships.nft_ownerships_ownerships @ acc) in
  aux []

let call_get_activities filter =
  (* Format.eprintf "%s\n%!" (EzEncoding.construct nft_activity_filter_enc filter) ; *)
  let open EzAPI in
  let url = BASE !api in
  let rec aux ?continuation acc =
    let params = match continuation with
      | None -> [ ]
      | Some c -> [ Api.continuation_param, S c ] in
    let> r = EzReq_lwt.post0 ~input:filter ~params url Api.get_nft_activities_s in
    let>? activities = Lwt.return @@ handle_ezreq_result r in
    match activities.nft_activities_continuation with
    | None -> Lwt.return_ok @@ activities.nft_activities_items @ acc
    | Some continuation ->
      aux ~continuation (activities.nft_activities_items @ acc) in
  aux []
 (* >>= fun res ->
  *  begin match res with
  *    | Ok a ->
  *      Printf.eprintf "%s\n%!" @@ EzEncoding.construct (Json_encoding.list nft_activity_enc) a ;
  *    | _ -> ()
  *  end ;
  *  Lwt.return res *)

let call_get_nft_all_activities types =
  call_get_activities @@ ActivityFilterAll types

let call_get_nft_activities_by_user types user =
  call_get_activities @@
  ActivityFilterByUser {
    nft_activity_by_user_types = types ;
    nft_activity_by_user_users = [ user ] ;
}

let call_get_nft_activities_by_item types contract token_id =
  call_get_activities @@
  ActivityFilterByItem {
    nft_activity_by_item_types = types ;
    nft_activity_by_item_contract = contract ;
    nft_activity_by_item_token_id = token_id ;
}

let call_get_nft_activities_by_collection types collection =
  call_get_activities @@
  ActivityFilterByCollection {
    nft_activity_by_collection_types = types ;
    nft_activity_by_collection_contract = collection ;
}

let call_get_nft_all_activities_all () =
  call_get_nft_all_activities [ ALLTRANSFER; ALLMINT; ALLBURN ]

let call_get_nft_activities_by_user_all user =
  call_get_nft_activities_by_user
    [ USERMINT; USERBURN ; USERTRANSFER_FROM ; USERTRANSFER_TO ]
    user

let call_get_nft_activities_by_item_all contract token_id =
  call_get_nft_activities_by_item [ ALLTRANSFER; ALLMINT; ALLBURN ] contract token_id

let call_get_nft_activities_by_collection_all collection =
  call_get_nft_activities_by_collection [ ALLTRANSFER; ALLMINT; ALLBURN ] collection

let call_get_nft_all_activities_mint () =
  call_get_nft_all_activities [ ALLMINT ]

let call_get_nft_activities_by_user_mint user =
  call_get_nft_activities_by_user [ USERMINT ] user

let call_get_nft_activities_by_item_mint contract token_id =
  call_get_nft_activities_by_item [ ALLMINT ] contract token_id

let call_get_nft_activities_by_collection_mint collection =
  call_get_nft_activities_by_collection [ ALLMINT ] collection

let call_get_nft_all_activities_burn () =
  call_get_nft_all_activities [ ALLBURN ]

let call_get_nft_activities_by_user_burn user =
  call_get_nft_activities_by_user [ USERBURN ] user

let call_get_nft_activities_by_item_burn contract token_id =
  call_get_nft_activities_by_item [ ALLBURN ] contract token_id

let call_get_nft_activities_by_collection_burn collection =
  call_get_nft_activities_by_collection [ ALLBURN ] collection

let call_get_nft_all_activities_transfer () =
  call_get_nft_all_activities [ ALLTRANSFER ]

let call_get_nft_activities_by_user_transfer user =
  call_get_nft_activities_by_user [ USERTRANSFER_FROM ; USERTRANSFER_TO ] user

let call_get_nft_activities_by_item_transfer contract token_id =
  call_get_nft_activities_by_item [ ALLTRANSFER ] contract token_id

let call_get_nft_activities_by_collection_transfer collection =
  call_get_nft_activities_by_collection [ ALLTRANSFER ] collection

let upsert_order () =
  match generate_order () with
  | Ok order_form ->
    call_upsert_order order_form
  | Error err ->
    Lwt.fail_with (Printf.sprintf "error : %s" @@ Let.string_of_error err)

let call_get_order hash =
  let url = EzAPI.BASE !api in
  let|> r = EzReq_lwt.get1 url Api.get_order_by_hash_s hash in
  handle_ezreq_result r

(* let update_order_make_value hash make_value =
 *   Db.get_order hash >|= function
 *   | Error err -> Format.eprintf "ERROR %s\n%!" @@ Crp.string_of_error err ;
 *   | Ok None -> Format.eprintf "get_order None"
 *   | Ok (Some order) ->
 *     let order_form = order_form_from_order order in
 *     let maker = order_form.order_form_elt.order_form_elt_maker in
 *     let _, _, maker_sk = by_pk maker in
 *     let taker = order_form.order_form_elt.order_form_elt_taker in
 *     let make = order_form.order_form_elt.order_form_elt_make in
 *     let make = { make with asset_value = make_value } in
 *     let take = order_form.order_form_elt.order_form_elt_take in
 *     let salt = order_form.order_form_elt.order_form_elt_salt in
 *     let start_date = order_form.order_form_elt.order_form_elt_start in
 *     let end_date = order_form.order_form_elt.order_form_elt_end in
 *     match order_form.order_form_data with
 *     | RaribleV2Order data ->
 *       let data_type = data.order_rarible_v2_data_v1_data_type in
 *       let payouts = data.order_rarible_v2_data_v1_payouts in
 *       let origin_fees = data.order_rarible_v2_data_v1_origin_fees in
 *       begin match
 *           hash_order_form
 *             maker make taker take salt start_date end_date data_type payouts origin_fees with
 *       | Ok to_sign ->
 *         let signature = sign ~edsk:maker_sk ~bytes:to_sign in
 *         let order_form =
 *           mk_order_form
 *             maker taker make take salt start_date end_date signature data_type payouts origin_fees in
 *         call_upsert_order order_form
 *       | Error err -> Lwt.return_error err
 *       end
 *     | _ ->
 *       Format.eprintf "Wrong order type \n%!" *)

(* let update_order_take_value hash take_value =
 *   Db.get_order hash >|= function
 *   | Error err -> Format.eprintf "ERROR %s\n%!" @@ Crp.string_of_error err ;
 *   | Ok None -> Format.eprintf "get_order None"
 *   | Ok (Some order) ->
 *     let order_form = order_form_from_order order in
 *     let maker = order_form.order_form_elt.order_form_elt_maker in
 *     let _, _, maker_sk = by_pk maker in
 *     let taker = order_form.order_form_elt.order_form_elt_taker in
 *     let make = order_form.order_form_elt.order_form_elt_make in
 *     let take = order_form.order_form_elt.order_form_elt_take in
 *     let take = { take with asset_value = take_value } in
 *     let salt = order_form.order_form_elt.order_form_elt_salt in
 *     let start_date = order_form.order_form_elt.order_form_elt_start in
 *     let end_date = order_form.order_form_elt.order_form_elt_end in
 *     match order_form.order_form_data with
 *     | RaribleV2Order data ->
 *       let data_type = data.order_rarible_v2_data_v1_data_type in
 *       let payouts = data.order_rarible_v2_data_v1_payouts in
 *       let origin_fees = data.order_rarible_v2_data_v1_origin_fees in
 *       begin match
 *           hash_order_form
 *             maker make taker take salt start_date end_date data_type payouts origin_fees with
 *       | Ok to_sign ->
 *         let signature = sign ~edsk:maker_sk ~bytes:to_sign in
 *         let order_form =
 *           mk_order_form
 *             maker taker make take salt start_date end_date signature data_type payouts origin_fees in
 *         call_upsert_order order_form
 *       | Error err -> Format.eprintf "Error %s\n%!" @@ string_of_error err
 *       end
 *     | _ ->
 *       Format.eprintf "Wrong order type \n%!" *)

(* let update_order_taker hash taker =
 *   Db.get_order hash >|= function
 *   | Error err -> Format.eprintf "ERROR %s\n%!" @@ Crp.string_of_error err ;
 *   | Ok None -> Format.eprintf "get_order None"
 *   | Ok (Some order) ->
 *     let order_form = order_form_from_order order in
 *     let maker = order_form.order_form_elt.order_form_elt_maker in
 *     let _, _, maker_sk = by_pk maker in
 *     let taker = taker in
 *     let make = order_form.order_form_elt.order_form_elt_make in
 *     let take = order_form.order_form_elt.order_form_elt_take in
 *     let salt = order_form.order_form_elt.order_form_elt_salt in
 *     let start_date = order_form.order_form_elt.order_form_elt_start in
 *     let end_date = order_form.order_form_elt.order_form_elt_end in
 *     match order_form.order_form_data with
 *     | RaribleV2Order data ->
 *       let data_type = data.order_rarible_v2_data_v1_data_type in
 *       let payouts = data.order_rarible_v2_data_v1_payouts in
 *       let origin_fees = data.order_rarible_v2_data_v1_origin_fees in
 *       begin match
 *           hash_order_form
 *             maker make taker take salt start_date end_date data_type payouts origin_fees with
 *       | Ok to_sign ->
 *         let signature = sign ~edsk:maker_sk ~bytes:to_sign in
 *         let order_form =
 *           mk_order_form
 *             maker taker make take salt start_date end_date signature data_type payouts origin_fees in
 *         call_upsert_order order_form
 *       | Error err -> Format.eprintf "Error %s\n%!" @@ string_of_error err
 *       end
 *     | _ ->
 *       Format.eprintf "Wrong order type \n%!" *)

let may_import_key ?(verbose=0) alias sk =
  let cmd = Script.import_key ~verbose alias sk in
  ignore @@ sys_command cmd

let read_whole_file filename =
  let ch = open_in filename in
  let s = really_input_string ch (in_channel_length ch) in
  close_in ch;
  s

let create_descr prefix suffix =
  let temp_fn = Filename.temp_file prefix suffix in
  let c = open_out temp_fn in
  Unix.descr_of_out_channel c, temp_fn

let create_descr2 prefix =
  let out_temp_fn = Filename.temp_file prefix "out" in
  let err_temp_fn = Filename.temp_file prefix "err" in
  let c_out = open_out out_temp_fn in
  let c_err = open_out err_temp_fn in
  Unix.descr_of_out_channel c_out, out_temp_fn,
  Unix.descr_of_out_channel c_err, err_temp_fn

let create_process ?(stdin=Unix.stdin) ?(stdout=Unix.stdout) ?(stderr=Unix.stderr) prog args =
  Unix.create_process prog args stdin stdout stderr

let show_address alias =
  let prog = !Script.client in
  let args = Array.of_list [prog ; "show" ; "address" ; alias ; "-S" ] in
  let stdout, temp_fn = create_descr "tezos-client" "show_address" in
  let pid = create_process ~stdout prog args in
  let _, status = Unix.waitpid [] pid in
  Unix.close stdout ;
  match status with
  | Unix.WEXITED code ->
    if code <> 0 then failwith "show address failure"
    else
      let content = read_whole_file temp_fn in
      begin match String.split_on_char ':' content with
      | _before :: tz1 :: pk :: _unencrypted :: sk :: [] ->
        String.sub tz1 1 36,
        String.sub pk 1 36,
        sk
      | _ -> failwith "show address : can't parse result"
      end
  | Unix.WSIGNALED _ | Unix.WSTOPPED _ -> failwith "show address failure"

let find_kt1 contract_alias =
  if !js then contract_alias
  else
    let prog = !Script.client in
    let args =
      Array.of_list
        [ prog ; "-E"; !endpoint; "list" ; "known" ; "contracts" ] in
    let stdout, out_temp_fn, stderr, _err_temp_fn =
      create_descr2 "tezos-client-list_known_contracts" in
    let pid = create_process ~stdout ~stderr prog args in
    let _, status = Unix.waitpid [] pid in
    Unix.close stdout ;
    Unix.close stderr ;
    match status with
    | Unix.WEXITED code ->
      begin if code <> 0 then failwith "list_known_contracts failure"
        else
          let contract = ref None in
          let ch = open_in out_temp_fn in
          begin try
              while true; do
                let line = input_line ch in
                match String.split_on_char ':' line with
                | alias :: kt1 :: [] ->
                  if alias = contract_alias then
                    begin
                      contract := Some (String.sub kt1 1 36) ;
                      raise End_of_file
                    end
                | _ -> ()
              done
            with End_of_file -> ()
          end ;
          close_in ch ;
          match !contract with
          | None -> failwith "can't find kt1"
          | Some kt1 -> kt1
      end
    | Unix.WSIGNALED _ | Unix.WSTOPPED _ -> failwith "list_known_address failure"

let deploy ?verbose ?burn_cap filename storage source alias =
  ignore verbose;
  let cmd =
    Script.deploy_aux
      ~verbose:!Script.verbose
      ~endpoint:!endpoint
      ~force:true
      ?burn_cap
      ~filename
      storage
      source
      alias in
  let code, out, err = sys_command ~verbose:!Script.verbose ~retry:1 cmd in
  if code <> 0 then
    failwith (Printf.sprintf "deploy failure : out %S err %S" out err)

let create_collection ?(royalties=pick_royalties ()) ?alias () =
  let alias_new = generate_alias "collection" in
  let alias_admin, pk_admin, sk_admin =
    match alias with None -> generate_address () | Some a -> by_alias a in
  may_import_key alias_admin sk_admin ;
  let alias_source, _pk_source, sk_source = generate_address () in
  let admin = pk_to_pkh_exn pk_admin in
  may_import_key alias_source sk_source ;
  let name = Filename.basename @@ Filename.temp_file "collection" "name" in
  let symbol =
    if Random.bool () then None
    else
      Some (String.init 3 (fun _ -> Char.chr @@ Random.int 26 + 97)) in
  let uri =
    EzEncoding.construct
      Json_encoding.(obj2 (req "name" string) (opt "symbol" string))
      (name, symbol) in
  (admin, sk_admin), alias_source, alias_new, royalties, uri

let create_collections ?royalties nb =
  let rec aux acc cpt =
    if cpt = 0 then acc
    else aux ((create_collection ?royalties ()) :: acc) (cpt - 1) in
  aux [] nb

let set_metadata_uri uri source contract =
  if !js then
    Script_js.set_metadata_uri ~endpoint:!endpoint ~source:(snd source) ~contract uri
  else
    let cmd = Script.set_metadata_uri_aux ~endpoint:!endpoint uri (fst source) contract in
    let code, out, err = sys_command cmd in
    if code <> 0 then
      Printf.eprintf "set_metadata_uri failure (log %s err %s)\n%!" out err;
    Lwt.return_unit

let set_token_metadata id metadata source contract =
  if !js then
    let metadata = List.filter_map (fun s ->
      match String.index_opt s '=' with
      | None -> None
      | Some i -> Some (String.sub s 0 i, String.sub s (i+1) (String.length s - i - 1))) metadata in
    Script_js.set_token_metadata ~endpoint:!endpoint ~token_id:id ~source:(snd source) ~contract metadata
  else
    let cmd = Script.set_token_metadata_aux ~endpoint:!endpoint id metadata (fst source) contract in
    let code, out, err = sys_command cmd in
    if code <> 0 then
      Lwt.return @@ Printf.eprintf "set_token_metadata failure (log %s err %s)\n%!" out err
    else Lwt.return_unit

let deploy_collection admin alias_source alias_new royalties uri =
  Printf.eprintf "Deploying new collection\n%!" ;
  if !js then
    let kt1 = Script_js.deploy_collection ~endpoint:!endpoint
        ~source:admin ~royalties_contract:royalties () in
    Lwt.return (kt1, kt1, admin, royalties)
  else
    let filename = "contracts/arl/fa2.arl" in
    let storage = Script.storage_fa2 ~admin:(fst admin) ~royalties in
    deploy filename storage alias_source alias_new ;
    Printf.eprintf "  deployed collection %s\n%!" alias_new ;
    let kt1 = find_kt1 alias_new in
    let> () = set_metadata_uri uri admin kt1 in
    Printf.eprintf "  --> %s:%s\n%!" alias_new kt1 ;
    Lwt.return (alias_new, kt1, admin, royalties)

let deploy_ubi_collection admin alias_source alias_new royalties uri =
  Printf.eprintf "Deploying new collection\n%!" ;
  if !js then Lwt.fail_with "TODO"
  else
    let filename = "contracts/mich/ubi.tz" in
    let storage = Script.storage_ubi (fst admin) in
    deploy filename storage alias_source alias_new ;
    Printf.eprintf "  deployed collection %s\n%!" alias_new ;
    let kt1 = find_kt1 alias_new in
    let> () = set_metadata_uri uri admin kt1 in
    Printf.eprintf "  --> %s:%s\n%!" alias_new kt1 ;
    Lwt.return (alias_new, kt1, admin, royalties)

let create_royalties () =
  Printf.eprintf "Creating new royalties\n%!" ;
  let alias_admin, pk_admin, sk_admin = generate_address () in
  let admin = pk_to_pkh_exn pk_admin in
  if !js then
    let kt1 = Script_js.deploy_royalties ~endpoint:!endpoint (admin, sk_admin) in
    kt1, alias_admin
  else
    let alias_new = generate_alias "royalties" in
    may_import_key alias_admin sk_admin ;
    let alias_source, _pk_source, sk_source = generate_address () in
    may_import_key alias_source sk_source ;
    let filename = "contracts/arl/royalties.arl" in
    let storage = Script.storage_royalties ~admin:admin in
    deploy filename storage alias_source alias_new ;
    alias_new, alias_admin

let create_validator ~exchange ~royalties =
  Printf.eprintf "Creating new validator\n%!" ;
  let alias_source, _pk_source, sk_source = generate_address () in
  if !js then
    let kt1_validator =
      Script_js.deploy_validator ~endpoint:!endpoint ~exchange ~royalties sk_source in
    kt1_validator, alias_source
  else
    let alias_new = generate_alias "validator" in
    may_import_key alias_source sk_source ;
    let filename = "contracts/arl/validator.arl" in
    let storage = Script.storage_validator ~exchange ~royalties in
    deploy ~burn_cap:4.67575 filename storage alias_source alias_new ;
    alias_new, alias_source

let create_exchange () =
  Printf.eprintf "Creating new exchange\n%!" ;
  let alias_admin, pk_admin, sk_admin = generate_address () in
  let admin = pk_to_pkh_exn pk_admin in
  may_import_key alias_admin sk_admin ;
  let alias_source, _pk_source, sk_source = generate_address () in
  may_import_key alias_source sk_source ;
  let alias_receiver, pk_receiver, sk_receiver = generate_address () in
  may_import_key alias_receiver sk_receiver ;
  let receiver = pk_to_pkh_exn pk_receiver in
  if !js then
    let kt1_exchange = Script_js.deploy_exchange ~endpoint:!endpoint ~owner:admin
        ~receiver ~fee:300L sk_source in
    kt1_exchange, (alias_admin, sk_admin), alias_receiver
  else
    let filename = "contracts/arl/exchangeV2.arl" in
    let storage = Script.storage_exchange ~admin:admin ~receiver ~fee:300L in
    let alias_new = generate_alias "exchange" in
    deploy ~burn_cap:42.1 filename storage alias_source alias_new ;
    alias_new, (alias_admin, sk_admin), alias_receiver

let set_validator validator source contract =
  if !js then
    Script_js.set_validator ~endpoint:!endpoint ~source:(snd source) ~contract validator
  else
    let cmd = Script.set_validator_aux ~endpoint:!endpoint validator (fst source) contract in
    let code, out, err = sys_command cmd in
    if code <> 0 then
      Lwt.return @@
      Printf.eprintf "set_validator failure (log %s err %s)\n%!" out err
    else Lwt.return_unit

let set_royalties token_addr royalties source contract =
  if !js then
    Lwt.fail_with "TODO"
  else
    let cmd =
      Script.set_royalties_aux ~endpoint:!endpoint token_addr royalties (fst source) contract in
    let code, out, err = sys_command cmd in
    if code <> 0 then
      Lwt.return @@
      Printf.eprintf "set_validator failure (log %s err %s)\n%!" out err
    else Lwt.return_unit

let update_operators_for_all operator source contract =
  Printf.eprintf "update_operators_for_all %s for %s on %s\n%!" operator (fst source) contract ;
  if !js then
    Script_js.update_operators_for_all ~endpoint:!endpoint ~contract ~operator (snd source)
  else
    let operator = "+" ^ operator in
    let cmd =
      Script.update_operators_for_all_aux ~endpoint:!endpoint [ operator ] (fst source) contract in
    let code, out, err = sys_command cmd in
    if code <> 0 then
      Lwt.return @@
      Printf.eprintf "update_operator_for_all failure (log %s err %s)\n%!" out err
    else Lwt.return_unit

let update_operators token_id owner operator source contract =
  Printf.eprintf "update_operators %s for %s on %s\n%!" operator (fst source) contract ;
  if !js then
    Lwt.fail_with "TODO"
  else
    let operator = Printf.sprintf "%Ld=%s+%s" token_id owner operator in
    let cmd =
      Script.update_operators_aux ~endpoint:!endpoint [ operator ] (fst source) contract in
    let code, out, err = sys_command cmd in
    if code <> 0 then
      Lwt.return @@
      Printf.eprintf "update_operator failure (log %s err %s)\n%!" out err
    else Lwt.return_unit

let mint_tokens id owner amount royalties source contract =
  if !js then
    Script_js.mint_tokens ~endpoint:!endpoint ~amount ~royalties ~contract ~source id
  else
    let cmd = Script.mint_tokens_aux ~endpoint:!endpoint id owner amount
        royalties (fst source) contract in
    let code, out, err = sys_command cmd in
    if code <> 0 then
      Lwt.return @@
      Printf.eprintf "mint failure (log %s err %s)\n%!" out err
    else Lwt.return_unit

let mint_ubi_tokens id owner source contract =
  if !js then
    Lwt.fail_with "TODO"
  else
    let cmd =
      Script.mint_ubi_tokens_aux ~endpoint:!endpoint id owner (fst source) contract in
    let code, out, err = sys_command cmd in
    if code <> 0 then
      Lwt.return @@
      Printf.eprintf "mint failure (log %s err %s)\n%!" out err
    else Lwt.return_unit

let burn_tokens id amount source contract =
  if !js then
    Script_js.burn_tokens ~endpoint:!endpoint ~amount ~contract ~source id
  else
    let cmd = Script.burn_tokens_aux ~endpoint:!endpoint id amount (fst source) contract in
    let code, out, err = sys_command ~retry:1 cmd in
    if code <> 0 then
      Lwt.fail_with ("burn failure : log " ^ out ^ " & " ^ err)
    else Lwt.return_unit

let transfer_tokens id amount source contract new_owner =
  if !js then
    Script_js.transfer_tokens ~endpoint:!endpoint ~amount ~contract ~source ~token_id:id new_owner
  else
    let param = [ fst source ; Printf.sprintf "%s*%s=%s" id amount new_owner ] in
    let cmd = Script.transfer_aux ~endpoint:!endpoint param (fst source) contract in
    let code, out, err = sys_command ~retry:1 cmd in
    if code <> 0 then
      Lwt.fail_with ("transfer failure : log " ^ out ^ " & " ^ err)
    else Lwt.return_unit

let mint_with_random_token_id ~source ~contract =
  Printf.eprintf "mint_with_random_token_id for %s on %s\n%!" (fst source) contract ;
  let _owner_alias, owner_pk, owner_sk = generate_address () in
  let owner =  pk_to_pkh_exn owner_pk in
  let tid = generate_token_id () in
  let amount = string_of_int @@ (generate_amount ~max:10 () + 1) in
  let royalties = generate_royalties () in
  let metadata = [] in
  mint_tokens tid owner amount royalties source contract >|= fun () ->
  ((owner, owner_sk), amount, tid, royalties, metadata)

let mint_one_with_token_id_from_api ?diff ?alias ~source ~contract () =
  Printf.eprintf "mint_one_with_token_id_from_api for %s on %s\n%!" (fst source) contract ;
  let _owner_alias, owner_pk, owner_sk =
    match alias with None -> generate_address ?diff () | Some a -> by_alias a in
  let owner =  pk_to_pkh_exn owner_pk in
  let amount = "1" in
  let royalties = generate_royalties () in
  let name = Filename.basename @@ Filename.temp_file "item" "name" in
  let metadata = [ Printf.sprintf "name=%s" name ] in
  let>? tid = call_generate_token_id contract in
  let> () = mint_tokens tid.nft_token_id owner amount royalties source contract in
  (* let> () = set_token_metadata tid.nft_token_id metadata source contract in *)
  Lwt.return_ok ((owner, owner_sk), 1, tid.nft_token_id, royalties, metadata)

let mint_ubi_with_token_id_from_api ?diff ?alias ~source ~contract () =
  Printf.eprintf "mint_one_with_token_id_from_api for %s on %s\n%!" (fst source) contract ;
  let _owner_alias, owner_pk, owner_sk =
    match alias with None -> generate_address ?diff () | Some a -> by_alias a in
  let owner =  pk_to_pkh_exn owner_pk in
  let name = Filename.basename @@ Filename.temp_file "item" "name" in
  let metadata = [ Printf.sprintf "name=%s" name ] in
  let>? tid = call_generate_token_id contract in
  let> () = mint_ubi_tokens tid.nft_token_id owner source contract in
  (* let> () = set_token_metadata tid.nft_token_id metadata source contract in *)
  Lwt.return_ok ((owner, owner_sk), 1, tid.nft_token_id, royalties, metadata)

let mint_with_token_id_from_api ~source ~contract =
  Printf.eprintf "mint_with_token_id_from_api for %s on %s\n%!" (fst source) contract ;
  let _owner_alias, owner_pk, owner_sk = generate_address () in
  let owner =  pk_to_pkh_exn owner_pk in
  let amount = string_of_int @@ generate_amount ~max:10 () in
  let royalties = generate_royalties () in
  let metadata = [] in
  let>? tid = call_generate_token_id contract in
  let> () = mint_tokens tid.nft_token_id owner amount royalties source contract in
  Lwt.return_ok ((owner, owner_sk), amount, tid.nft_token_id, royalties, metadata)

let burn_with_token_id ~source ~contract tid amount =
  Printf.eprintf "burn_with_token_id for %s on %s\n%!" (fst source) contract ;
  burn_tokens tid amount source contract

let transfer_with_token_id ~source ~contract tid amount new_owner =
  Printf.eprintf "transfer_with_token_id for %s on %s\n%!" (fst source) contract ;
  transfer_tokens tid amount source contract new_owner

let mint ~source ~contract =
  let random = Random.bool () in
  if random then
    let> r = mint_with_random_token_id ~source ~contract in
    Lwt.return_ok r
  else
    mint_with_token_id_from_api ~source ~contract

let burn ~source ~contract tid max_amount =
  let full = Random.bool () in
  let amount =
    if full then max_amount else Random.int max_amount + 1 in
  let|> () = burn_with_token_id ~source ~contract tid (string_of_int amount) in
  max_amount - amount

let transfer ~source ~contract tid max_amount =
  let full = Random.bool () in
  let _alias, pk, sk = generate_address ~diff:(Some (fst source)) () in
  let new_owner = pk_to_pkh_exn pk in
  let new_owner_amount =
    if full then max_amount else generate_amount ~max:max_amount () + 1 in
  let|> () = transfer_with_token_id ~source ~contract tid (string_of_int new_owner_amount) new_owner in
  (new_owner_amount, (new_owner, sk))

let make_tr ?entrypoint ?(fee= -1L) ?(gas_limit=Z.minus_one)
    ?(storage_limit=Z.minus_one) ?(counter=Z.zero) ?(amount=0L) ~source ~contract p =
  let open Tzfunc.Proto in
  let entrypoint = EPnamed (Option.get entrypoint) in
  let parameters = Some {entrypoint; value = Micheline p} in
  {
    man_info = {source; kind = Transaction {amount; destination=contract; parameters}};
    man_numbers = {fee; gas_limit; storage_limit; counter};
    man_metadata = None
  }

let forge_tr ?entrypoint ?fee ?gas_limit ?storage_limit ?counter
    ?amount ?remove_failed ?local_forge ~base ~get_pk ~source ~contract p =
  let op = make_tr ?entrypoint ?fee ?gas_limit ?storage_limit
      ?counter ?amount ~source ~contract p in
  Tzfunc.Node.forge_manager_operations ?remove_failed ?local_forge ~base
    ~get_pk ~src:source [ op ]

let call ?entrypoint ?fee ?gas_limit ?storage_limit ?counter
    ?amount ?remove_failed ?local_forge ~base ~get_pk ~source ~contract ~sign p =
  Lwt.bind (forge_tr ?entrypoint ?fee ?gas_limit ?storage_limit
              ?counter ?amount ?remove_failed ?local_forge ~base ~get_pk ~source ~contract p) @@ function
  | Error e ->
    Printf.eprintf "forge_tr error %s" @@ Tzfunc.Rp.string_of_error e ;
    Lwt.return_error e
  | Ok (bytes, protocol, branch, ops) ->
    Tzfunc.Node.inject ~base ~sign ~bytes ~branch ~protocol ops

let mich_order order =
  let maker = order.order_elt.order_elt_maker in
  let make = order.order_elt.order_elt_make in
  let taker = order.order_elt.order_elt_taker in
  let take = order.order_elt.order_elt_take in
  let salt = order.order_elt.order_elt_salt in
  let start_date = order.order_elt.order_elt_start in
  let end_date = order.order_elt.order_elt_end in
  mich_order_form
    ~maker ~make ~taker ~take ~salt ~start_date ~end_date
    ~data_type:"V1"
    ~payouts:order.order_data.order_rarible_v2_data_v1_payouts
    ~origin_fees:order.order_data.order_rarible_v2_data_v1_origin_fees

let match_orders ?amount ~source ~contract order_left order_right =
  let open Tzfunc.Crypto in
  let r =
    Result.bind (Sk.b58dec @@ snd source) @@ fun sk ->
    Result.bind (Sk.to_public_key sk) @@ fun pk ->
    Ok (sk, Pk.b58enc ~curve:`ed25519 pk) in
  match r with
  | Error _ -> assert false
  | Ok (sk, edpk) ->
    match flat_order order_left with
    | Error err -> Lwt.fail_with @@ Printf.sprintf "mich order %s" @@ string_of_error err
    | Ok m_left ->
      match flat_order order_right with
      | Error err -> Lwt.fail_with @@ Printf.sprintf "mich order %s" @@ string_of_error err
      | Ok m_right ->
        let signature_left =
          prim `Some ~args:[Proto.Mstring order_left.order_elt.order_elt_signature] in
        let signature_right =
          prim `Some ~args:[Proto.Mstring order_right.order_elt.order_elt_signature] in
        let mich = prim `Pair ~args:[m_left; signature_left; m_right; signature_right] in
        call
          ?amount
          ~local_forge:false
          ~entrypoint:"matchOrders"
          ~base:(EzAPI.BASE !endpoint)
          ~get_pk:(fun () -> Lwt.return_ok edpk)
          ~source:(fst source)
          ~contract
          ~sign:(fun b -> match Ed25519.sign_bytes ~watermark:Watermark.generic ~sk b with
              | Error e -> Lwt.return_error e
              | Ok b -> Lwt.return_ok (b :> Raw.t))
          mich

let cancel_order ~source ~contract order =
  let open Tzfunc.Crypto in
  let r =
    Result.bind (Sk.b58dec @@ snd source) @@ fun sk ->
    Result.bind (Sk.to_public_key sk) @@ fun pk ->
    Ok (sk, Pk.b58enc ~curve:`ed25519 pk) in
  match r with
  | Error _ -> assert false
  | Ok (sk, edpk) ->
  match flat_order order with
  | Error err -> Lwt.fail_with @@ Printf.sprintf "mich order %s" @@ string_of_error err
  | Ok m ->
    call
      ~local_forge:false
      ~entrypoint:"cancel"
      ~base:(EzAPI.BASE !endpoint)
      ~get_pk:(fun () -> Lwt.return_ok edpk)
      ~source:(fst source)
      ~contract
      ~sign:(fun b -> match Ed25519.sign_bytes ~watermark:Watermark.generic ~sk b with
          | Error e -> Lwt.return_error e
          | Ok b -> Lwt.return_ok (b :> Raw.t))
      m

let random_mint collections =
  let _alias_collection, kt1, admin, _owner =
    List.nth collections (Random.int @@ List.length collections) in
  mint ~source:admin ~contract:kt1
  >|=? fun infos -> kt1, infos

let random_burn items =
  let selected = Random.int @@ List.length items in
  let (kt1, (owner, amount, tid, royalties, metadata)) = List.nth items selected in
  let|> new_amount = burn ~source:owner ~contract:kt1 tid (int_of_string amount) in
  let new_item = kt1, (owner, string_of_int new_amount, tid, royalties, metadata) in
  List.mapi (fun i itm -> if i = selected then new_item else itm) items,
  new_item

let random_transfer items =
  let selected = Random.int @@ List.length items in
  let (kt1, (owner, amount_str, tid, royalties, metadata)) = List.nth items selected in
  let|> (new_owner_amount_i, new_owner) =
    transfer ~source:owner ~contract:kt1 tid (int_of_string amount_str) in
  let new_owner_amount_str = string_of_int new_owner_amount_i in
  let amount_i = int_of_string amount_str in
  let new_item = kt1, (new_owner, new_owner_amount_str, tid, royalties, metadata) in
  let updated_source_item =
    kt1, (owner, string_of_int (amount_i - new_owner_amount_i), tid, royalties, metadata) in
  if amount_i = new_owner_amount_i then
    (* full transfer *)
    List.mapi (fun i itm -> if i = selected then new_item else itm) items,
    updated_source_item, new_item
  else
    new_item :: (List.mapi (fun i itm -> if i = selected then updated_source_item else itm) items),
    updated_source_item, new_item

let check_royalties item_royalties royalties =
  List.for_all (fun p ->
      try
        let v = List.assoc p.part_account royalties in
        v = Int64.of_int32 p.part_value
      with Not_found ->
  false) item_royalties

let check_owners item_owners owner =
  List.exists (fun o -> owner = o) item_owners

let check_strict_owners item_owners owner = match item_owners with
  | [ o ] when o = owner -> true
  | _ -> false

let check_supply item_supply amount =
  item_supply >= amount

let check_strict_supply item_supply amount =
  item_supply = amount

let check_metadata itm_metadata metadata = match itm_metadata, metadata with
  | Some im, Some m ->
    im.nft_item_meta_name = m.nft_item_meta_name &&
    im.nft_item_meta_description = m.nft_item_meta_description &&
    im.nft_item_meta_attributes = m.nft_item_meta_attributes &&
    im.nft_item_meta_image = m.nft_item_meta_image &&
    im.nft_item_meta_animation = m.nft_item_meta_animation
  | _, _ -> false

let check_nft_item ?(verbose=0) ?(strict=true) itm kt1 owner amount tid _royalties _metadata =
  if verbose > 0 then
    Printf.eprintf "%s\n%s %s %s %s\n%!"
      (EzEncoding.construct nft_item_enc itm)
      kt1
      owner
      amount
      tid
      (* (String.concat "\n  " @@
       *  List.map (fun (acc, i64) ->
       *      Printf.sprintf "%s -> %Ld" acc i64) royalties) *) ;
  if verbose > 0 then
  Printf.eprintf "%b %b %b %b %b\n%!"
    (itm.nft_item_id = (Printf.sprintf "%s:%s" kt1 tid))
    (itm.nft_item_contract = kt1)
    (itm.nft_item_token_id = tid)
    (if strict then check_strict_owners itm.nft_item_owners owner
     else check_owners itm.nft_item_owners owner)
    (if strict then check_strict_supply itm.nft_item_supply amount
     else check_supply itm.nft_item_supply amount) ;

  itm.nft_item_id = (Printf.sprintf "%s:%s" kt1 tid) &&
  itm.nft_item_contract = kt1 &&
  itm.nft_item_token_id = tid &&
  (* check_royalties itm.nft_item_royalties royalties && *)
  (if strict then check_strict_owners itm.nft_item_owners owner
   else check_owners itm.nft_item_owners owner) &&
  (if strict then check_strict_supply itm.nft_item_supply amount
   else check_supply itm.nft_item_supply amount)(*  &&
   * check_metadata itm.nft_item_meta metadata *)

let check_nft_ownership ow kt1 owner amount tid _metadata =
  ow.nft_ownership_id = (Printf.sprintf "%s:%s:%s" kt1 tid owner) &&
  ow.nft_ownership_contract = kt1 &&
  ow.nft_ownership_token_id = tid &&
  ow.nft_ownership_owner = owner &&
  ow.nft_ownership_value = amount(*  &&
   * check_creators ow.nft_ownership_creators metadata *)

let check_item ?strict (kt1, (owner, amount, tid, royalties, metadata)) =
  let owner = fst owner in
  let nft_item_exists ?verbose items =
    List.exists (fun i ->
        check_nft_item ?verbose ?strict i kt1 owner amount tid royalties metadata) items in
  let nft_ownership_exists ownerships =
    List.exists (fun o ->
        check_nft_ownership o kt1 owner amount tid metadata) ownerships in
  call_get_nft_item_by_id kt1 tid >|= begin function
  | Ok nft_item ->
    if check_nft_item nft_item kt1 owner amount tid royalties metadata then
      Printf.eprintf "[OK] API: get_nft_item_by_id\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_item_by_id (no matching nft_item)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_item_by_id (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_items_by_owner owner >|= begin function
  | Ok nft_items ->
    if nft_item_exists nft_items then
      Printf.eprintf "[OK] API: get_nft_items_by_owner\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_items_by_owner (no matching nft_item)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_items_by_owner (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_items_by_collection kt1 >|= begin function
  | Ok nft_items ->
    if nft_item_exists nft_items then
      Printf.eprintf "[OK] API: get_nft_items_by_collection\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_items_by_collection (no matching nft_item)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_items_by_owner (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_all_items () >|= begin function
  | Ok nft_items ->
    if nft_item_exists nft_items then
      Printf.eprintf "[OK] API: get_nft_all_items\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_all_items (no matching nft_item)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_all_items (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_ownership_by_id kt1 tid owner >|= begin function
  | Ok nft_ownership ->
    if check_nft_ownership nft_ownership kt1 owner amount tid metadata then
      Printf.eprintf "[OK] API: get_nft_ownership_by_id\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_ownership_by_id (no matching nft_item)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_ownership_by_id (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_ownerships_by_item kt1 tid >|= begin function
  | Ok nft_ownerships ->
    if nft_ownership_exists nft_ownerships then
      Printf.eprintf "[OK] API: get_nft_ownerships_by_item\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_ownerships_by_item (no matching nft_ownership)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_ownerships_by_item (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_all_ownerships () >|= begin function
  | Ok nft_ownerships ->
    if nft_ownership_exists nft_ownerships then
      Printf.eprintf "[OK] API: get_nft_all_ownerships\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_all_ownerships (no matching nft_ownership)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_all_ownerships (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end
  (* get_nft_item_meta_by_id ;
   * get_nft_items_by_creator ; *)

let check_nft_activity ?(from=false) activity kt1 owner amount tid =
  (* Printf.eprintf "check_nft_activity %s %s %s %s\n%!" kt1 owner amount tid ; *)
  if from then
    activity.nft_activity_contract = kt1 &&
    activity.nft_activity_owner <> owner &&
    activity.nft_activity_token_id = tid
  else
    activity.nft_activity_contract = kt1 &&
    activity.nft_activity_owner = owner &&
    activity.nft_activity_value = amount &&
    activity.nft_activity_token_id = tid

let check_mint_activity (kt1, (owner, amount, tid, _royalties, _metadata)) =
  let owner = fst owner in
  let mint_activity_exists activities =
    List.exists (fun act -> match act with
        | NftActivityMint elt -> check_nft_activity elt kt1 owner amount tid
        | _ -> false) activities in
  (* MINT ONLY ACTIVITIES *)
  call_get_nft_activities_by_item_mint kt1 tid >|= begin function
  | Ok nft_activities ->
    if mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_item_mint\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_item_mint (no matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_item_mint (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_activities_by_user_mint owner >|= begin function
  | Ok nft_activities ->
    if mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_user_mint\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_user_mint (no matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_user_mint (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_activities_by_collection_mint kt1 >|= begin function
  | Ok nft_activities ->
    if mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_collection_mint\n%!"
    else
      Printf.eprintf
        "[KO] API: get_nft_activities_by_collection_mint (no matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_collection_mint (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_all_activities_mint () >|= begin function
  | Ok nft_activities ->
    if mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_all_activities_mint\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_all_activities_mint (no matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_all_activities_mint (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->

  (* ALL ACTIVITIES *)
  call_get_nft_activities_by_item_all kt1 tid >|= begin function
  | Ok nft_activities ->
    if mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_item_all\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_item_all (no matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_item_all (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_activities_by_user_all owner >|= begin function
  | Ok nft_activities ->
    if mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_user_all\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_user_all (no matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_user_all (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_activities_by_collection_all kt1 >|= begin function
  | Ok nft_activities ->
    if mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_collection_all\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_collection_all (no matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_collection_all (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_all_activities_all () >|= begin function
  | Ok nft_activities ->
    if mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_all_activities_all\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_all_activities_all (no matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_all_activities_all (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->

  (* BURN ONLY ACTIVITIES *)
  call_get_nft_activities_by_item_burn kt1 tid >|= begin function
  | Ok nft_activities ->
    if not @@ mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_item_burn\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_item_burn (matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_item_burn (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_activities_by_user_burn owner >|= begin function
  | Ok nft_activities ->
    if not @@ mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_user_burn\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_user_burn (matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_user_burn (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_activities_by_collection_burn kt1 >|= begin function
  | Ok nft_activities ->
    if not @@ mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_collection_burn\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_collection_burn (matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_collection_burn (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_all_activities_burn () >|= begin function
  | Ok nft_activities ->
    if not @@ mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_all_activities_burn\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_all_activities_burn (matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_all_activities_burn (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->

  (* TRANSFER ONLY ACTIVITIES *)
  call_get_nft_activities_by_item_transfer kt1 tid >|= begin function
  | Ok nft_activities ->
    if not @@ mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_item_transfer\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_item_transfer (matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_item_transfer (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_activities_by_user_transfer owner >|= begin function
  | Ok nft_activities ->
    if not @@ mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_user_transfer\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_user_transfer (matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_user_transfer (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_activities_by_collection_transfer kt1 >|= begin function
  | Ok nft_activities ->
    if not @@ mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_collection_transfer\n%!"
    else
      Printf.eprintf
        "[KO] API: get_nft_activities_by_collection_transfer (matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_collection_transfer (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_all_activities_transfer () >|= begin function
  | Ok nft_activities ->
    if not @@ mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_all_activities_transfer\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_all_activities_transfer (matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_all_activities_transfer (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end

let check_transfer_activity ?(from=false) (kt1, (owner, amount, tid, _royalties, _metadata)) =
  let owner = fst owner in
  let transfer_activity_exists activities =
    List.exists (fun act -> match act with
        | NftActivityTransfer {from=addr; elt} ->
          if from then
            check_nft_activity ~from elt kt1 addr amount tid
          else check_nft_activity elt kt1 owner amount tid
        | _ -> false) activities in
  (* MINT ONLY ACTIVITIES *)
  call_get_nft_activities_by_item_mint kt1 tid >|= begin function
  | Ok nft_activities ->
    if not @@ transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_item_mint\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_item_mint (matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_item_mint (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_activities_by_user_mint owner >|= begin function
  | Ok nft_activities ->
    if not @@ transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_user_mint\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_user_mint (matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_user_mint (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_activities_by_collection_mint kt1 >|= begin function
  | Ok nft_activities ->
    if not @@ transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_collection_mint\n%!"
    else
      Printf.eprintf
        "[KO] API: get_nft_activities_by_collection_mint (matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_collection_mint (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_all_activities_mint () >|= begin function
  | Ok nft_activities ->
    if not @@ transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_all_activities_mint\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_all_activities_mint (matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_all_activities_mint (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->

  (* ALL ACTIVITIES *)
  call_get_nft_activities_by_item_all kt1 tid >|= begin function
  | Ok nft_activities ->
    if transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_item_all\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_item_all (no matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_item_all (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_activities_by_user_all owner >|= begin function
  | Ok nft_activities ->
    if transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_user_all\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_user_all (no matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_user_all (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_activities_by_collection_all kt1 >|= begin function
  | Ok nft_activities ->
    if transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_collection_all\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_collection_all (no matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_collection_all (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_all_activities_all () >|= begin function
  | Ok nft_activities ->
    if transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_all_activities_all\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_all_activities_all (no matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_all_activities_all (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->

  (* BURN ONLY ACTIVITIES *)
  call_get_nft_activities_by_item_burn kt1 tid >|= begin function
  | Ok nft_activities ->
    if not @@ transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_item_burn\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_item_burn (matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_item_burn (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_activities_by_user_burn owner >|= begin function
  | Ok nft_activities ->
    if not @@ transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_user_burn\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_user_burn (matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_user_burn (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_activities_by_collection_burn kt1 >|= begin function
  | Ok nft_activities ->
    if not @@ transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_collection_burn\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_collection_burn (matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_collection_burn (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_all_activities_burn () >|= begin function
  | Ok nft_activities ->
    if not @@ transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_all_activities_burn\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_all_activities_burn (matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_all_activities_burn (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->

  (* TRANSFER ONLY ACTIVITIES *)
  call_get_nft_activities_by_item_transfer kt1 tid >|= begin function
  | Ok nft_activities ->
    if transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_item_transfer\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_item_transfer (no matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_item_transfer (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_activities_by_user_transfer owner >|= begin function
  | Ok nft_activities ->
    if transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_user_transfer\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_user_transfer (no matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_user_transfer (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_activities_by_collection_transfer kt1 >|= begin function
  | Ok nft_activities ->
    if transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_collection_transfer\n%!"
    else
      Printf.eprintf
        "[KO] API: get_nft_activities_by_collection_transfer (no matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_collection_transfer (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_all_activities_transfer () >|= begin function
  | Ok nft_activities ->
    if transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_all_activities_transfer\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_all_activities_transfer (no matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_all_activities_transfer (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end

let mint_check_random collections =
  random_mint collections >>=? fun item ->
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  Unix.sleep 6 ;
  check_item item >>= fun () ->
  check_mint_activity item >>= fun () ->
  Lwt.return_ok item

let burn_check_random items =
  let> (items, updated_item) = random_burn items in
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  Unix.sleep 6 ;
  check_item updated_item >>= fun () ->
  Lwt.return_ok items

let transfer_check_random items =
  let> (items, updated_item, new_item) = random_transfer items in
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  Unix.sleep 6 ;
  let (kt1, (owner1, owner_1_amount, token_id, royalties, metadata)) = updated_item in
  let (_, (owner2, owner_2_amount, _, _, _)) = new_item in
  let total_amount =
    string_of_int @@
    (int_of_string owner_1_amount) +
    (int_of_string owner_2_amount) in
  begin
    if owner_1_amount <> "0" then
      check_item ~strict:false (kt1, (owner1, total_amount, token_id, royalties, metadata))
    else Lwt.return_unit
  end >>= fun () ->
  check_item ~strict:false (kt1, (owner2, total_amount, token_id, royalties, metadata)) >>= fun () ->
  check_transfer_activity ~from:true updated_item >>= fun () ->
  check_transfer_activity new_item >>= fun () ->
  Lwt.return_ok items

let mints_check_random ?(max=30) collections =
  let nb = Random.int max + 1 in
  let rec aux acc cpt =
    if cpt = 0 then Lwt.return_ok acc
    else
      mint_check_random collections >>=? fun item ->
      aux (item :: acc) (cpt - 1) in
  aux [] nb

let burns_check_random ?(max=30) items =
  let nb = Random.int max + 1 in
  let rec aux acc cpt =
    if cpt = 0 then Lwt.return_ok acc
    else
      burn_check_random items >>=? fun item ->
      aux (item :: acc) (cpt - 1) in
  aux [] nb

let transfers_check_random ?(max=30) items =
  let nb = Random.int max + 1 in
  let rec aux acc cpt =
    if cpt = 0 then Lwt.return_ok acc
    else
      transfer_check_random items >>=? fun items ->
      aux (items @ acc) (cpt - 1) in
  aux [] nb

let check_collection alias kt1 owner =
  let owner = fst owner in
  Printf.eprintf "Checking new collection %s of %s\n%!" alias owner ;
  let collection_exists collections =
    List.find_all (fun c ->
        c.nft_collection_id = kt1 &&
        c.nft_collection_owner = Some owner) collections in
  call_get_nft_collection_by_id kt1 >>=? fun c ->
  begin
    if c.nft_collection_id = kt1 &&
       c.nft_collection_owner = Some owner then
      Printf.eprintf "[Ok] API: get_nft_collection_by_id %s\n%!" alias
    else
      Printf.eprintf "[KO] API: get_nft_collection_by_id %s (no matching collection)\n%!" alias
  end ;
  call_search_nft_collections_by_owner owner >>=? fun c ->
  begin match collection_exists c with
    | [ _ ] -> Printf.eprintf "[OK] API: search_nft_collection_by_owner %s\n%!" alias
    | [] ->
      Printf.eprintf "[KO] API: search_nft_collection_by_owner %s (no matching collection)\n%!" alias
    | _ ->
      Printf.eprintf
        "[KO] API: search_nft_collection_by_owner %s (more than 1 matching collection)\n%!" alias
  end ;
  call_search_nft_all_collections () >|=? fun c ->
  begin match collection_exists c with
  | [ _ ] -> Printf.eprintf "[OK] API: search_nft_all_collection %s\n%!" alias
  | [] ->
    Printf.eprintf "[KO] API: search_nft_all_collection %s (no matching collection)\n%!" alias
  | _ ->
    Printf.eprintf
      "[KO] API: search_nft_all_collection %s (more than 1 matching collection)\n%!" alias
  end

let deploy_check_random_collections ?royalties ?(max=10) () =
  let nb = Random.int max + 1 in
  Printf.eprintf "Deploying and checking %d collection(s)\n%!" nb ;
  let collections = create_collections ?royalties nb in
  let agg =
    List.fold_left (fun acc ((admin, _alias_source, _alias_new, _royalties, _uri) as collection) ->
        try
          let old = List.assoc admin acc in
          (admin, (collection :: old)) :: (List.remove_assoc admin acc)
        with Not_found ->
          (admin, [ collection ]) ::  acc)
      [] collections in
  Lwt_list.map_p (fun (admin, collections) ->
      Printf.eprintf "  deploying %d collection for %s\n%!" (List.length collections) (fst admin) ;
      Lwt_list.map_s (fun (admin, alias_source, alias_new, royalties, uri) ->
          deploy_collection admin alias_source alias_new royalties uri) collections)
    agg >>= fun new_collections ->
  let new_collections = List.flatten new_collections in
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  Lwt_unix.sleep 6. >>= fun () ->
  Lwt_list.map_p (fun (alias, kt1, admin, _) ->
      check_collection alias kt1 admin) new_collections >>= fun res ->
  Lwt_list.iter_s (function
      | Ok _ -> Lwt.return_unit
      | Error err ->
        Lwt.return @@
        Printf.eprintf "[KO] API: check_collection (error : %s)\n%!" @@
        Api.Errors.string_of_error err)
    res >>= fun () ->
  Lwt.return new_collections

let reset_db () =
  Printf.eprintf "Resetting db\n%!" ;
  let c, o, e = sys_command "make drop" in
  if c <> 0 then failwith ("failure when resetting db : log " ^ o ^ " & " ^ e)
  else
    let c, o, e =  sys_command "make" in
    if c <> 0 then failwith ("failure when resetting db : log " ^ o ^ " & " ^ e)

let start_api kafka_config =
  let prog = "./_bin/api" in
  let args =
    [ prog ] @
    match kafka_config with
    | None -> []
    | Some f ->  [ "--kafka-config" ; f ] in
  let args = Array.of_list args in
  let stdout, fn_out, stderr, fn_err = create_descr2 "api" in
  let pid = create_process ~stdout ~stderr prog args in
  Printf.eprintf "API STARTED (out %s, err %s)\n%!" fn_out fn_err ;
  pid

let get_head () =
  EzReq_lwt.get
    (EzAPI.URL "https://api.granadanet.tzkt.io/v1/blocks/count")

let make_config admin_wallet validator exchange_v2 royalties contracts ft_contracts
    kafka_broker kafka_username kafka_password =
  let open Crawlori.Config in
  get_head () >>= function
  | Error (code, str) ->
    failwith (Printf.sprintf "get_head error %d %s" code (Option.value ~default:"" str))
  | Ok level ->
    let config = {
      nodes = [ "https://granadanet.smartpy.io" ] ;
      start =  Some Int32.(sub (of_string level) 30l)  ;
      db_kind = `pg ;
      step_forward = 30 ;
      accounts = None ;
      sleep = 5. ;
      forward = None ;
      confirmations_needed = 5l ;
      verbose = 0 ;
      register_kinds = None ;
      allow_no_metadata = false ;
      extra = {
        admin_wallet ; validator ; exchange_v2 ; royalties; contracts; ft_contracts;
      } ;
    } in
    let temp_fn = Filename.temp_file "config" "" in
    let json = EzEncoding.construct (Cconfig.enc Rtypes.config_enc) config in
    Printf.eprintf "Crawler config:\n%s\n\n%!" json ;
    let c = open_out temp_fn in
    output_string c json ;
    close_out c ;
    if kafka_broker = "" || kafka_username = "" then
      Lwt.return (temp_fn, None)
    else
      let kafka_config = { kafka_broker; kafka_username; kafka_password; } in
      let kafka_temp_fn = Filename.temp_file "kafka_config" "" in
      let kafka_json = EzEncoding.construct Rtypes.kafka_config_enc kafka_config in
      Printf.eprintf "Crawler kafka config:\n%s\n\n%!" kafka_json ;
      let c = open_out kafka_temp_fn in
      output_string c kafka_json ;
      close_out c ;
      Lwt.return (temp_fn, Some kafka_temp_fn)


let start_crawler admin_wallet validator exchange_v2 royalties
    contracts ft_contracts kafka_broker kafka_username kafka_password =
  make_config
    admin_wallet validator exchange_v2 royalties contracts ft_contracts
    kafka_broker kafka_username kafka_password  >>= fun (config, kafka_config) ->
  let prog = "./_bin/crawler" in
  let args =
    [ prog ; config ] @
    match kafka_config with
    | None -> []
    | Some f ->  [ "--kafka-config" ; f ] in
  let args = Array.of_list args in
  let stdout, fn_out, stderr, fn_err = create_descr2 "crawler" in
  let pid = create_process ~stdout ~stderr prog args in
  Printf.eprintf "CRAWLER STARTED (out %S err %S)\n%!" fn_out fn_err ;
  Lwt.return (pid, kafka_config)

let random_test () =
  reset_db () ;
  (* let r_kt1 = List.hd royalties_contracts in *)
  let r_alias, _r_source = create_royalties () in
  let r_kt1 = find_kt1 r_alias in
  Printf.eprintf "New royalties %s\n%!" r_kt1 ;
  start_crawler "" validator exchange_v2 r_kt1 SMap.empty SMap.empty "" "" "" >>= fun (cpid, kafka_config) ->
  api_pid := Some (start_api kafka_config) ;
  crawler_pid := Some cpid ;
  Printf.eprintf "Waiting 6sec to let crawler catch up...\n%!" ;
  Lwt_unix.sleep 6. >>= fun () ->
  deploy_check_random_collections ~royalties:r_kt1 ~max:1 () >>= fun collections ->
  (* let collections = [ "collection_19760", "KT1MvNHPsHpHZDJ7HfkUDx71qyYvU7nLi9N7", "tz1KiZygjrVaS1fjs9iW4YSKNiqoopHK8Hdj", r_kt1 ] in *)
  mints_check_random ~max:1 collections >>= begin function
    | Error err ->
      Lwt.return @@
      Printf.eprintf "mint error %s" @@
      Api.Errors.string_of_error err
    | Ok items ->
      transfers_check_random ~max:1 items >|= begin function
        | Error err ->
          Printf.eprintf "burn error %s" @@
          Api.Errors.string_of_error err
        | Ok _items -> ()
      end
  end >>= fun () ->
  (* let (_alias, contract, source, _r) = List.hd collections in *)
  (* let source = "tz1f6TuKe38VPURr6gA1xiQq9dzuVuzNZoP6" in
   * let contract = "KT1RYUvuCP7YgoXihfEXWNKgzkZgxPYCWWUi" in
   * mint_with_token_id_from_api ~source ~contract >>= begin function
   *   | Ok infos ->
   *     Printf.eprintf "Waiting 6sec to let crawler catch up...\n%!" ;
   *     Lwt_unix.sleep 6. >>= fun () ->
   *     check_mint contract infos
   *   | Error err ->
   *     Printf.eprintf "mint error %s" @@
   *     EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err ;
   *     Lwt.return_unit
   * end >>= fun () -> *)

  begin match !api_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
  begin match !crawler_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
  Lwt.return_unit

let sell_nft_for_nft ?salt collection item1 item2 =
  match order_form_from_items ?salt collection item1 item2 with
  | Error _err -> Lwt.fail_with "order_from"
  | Ok form -> call_upsert_order form

let sell_nft_for_tezos ?(salt=0) collection item1 amount =
  let take = { asset_type = ATXTZ ; asset_value = string_of_int amount } in
  match sell_order_form_from_item ~salt collection item1 take with
  | Error _err -> Lwt.fail_with "order_from"
  | Ok form -> call_upsert_order form

let sell_nft_for_lugh ?(salt=0) collection item1 amount =
  let lugh = ATFA_2 { asset_fa2_contract = lugh_contract ; asset_fa2_token_id = "0" } in
  let take = { asset_type = lugh ; asset_value = string_of_int amount } in
  match sell_order_form_from_item ~salt collection item1 take with
  | Error _err -> Lwt.fail_with "order_from"
  | Ok form -> call_upsert_order form

let buy_nft_for_tezos ?(salt=0) collection maker item1 amount =
  let make = { asset_type = ATXTZ ; asset_value = string_of_int amount } in
  match buy_order_form_from_item ~salt collection item1 maker make with
  | Error _err -> Lwt.fail_with "order_from"
  | Ok form -> call_upsert_order form

let buy_nft_for_lugh ?(salt=0) collection maker item1 amount =
  let lugh = ATFA_2 { asset_fa2_contract = lugh_contract ; asset_fa2_token_id = "0" } in
  let make = { asset_type = lugh ; asset_value = string_of_int amount } in
  match buy_order_form_from_item ~salt collection item1 maker make with
  | Error _err -> Lwt.fail_with "order_from"
  | Ok form -> call_upsert_order form

let get_source_from_item ((owner, owner_sk), _amount, _token_id, _royalties, _metadata) =
  (owner, owner_sk)

let get_token_id_from_item (_owner, _amount, token_id, _royalties, _metadata) =
  token_id

let wait_next_block () =
  let rec aux level0 =
    Db.get_level () >>= function
    | Ok level ->
      Printf.eprintf "wait_next_block level0 %d level %d\n%!" level0 level ;
      if level <> level0 then Lwt.return_unit
      else
        Lwt_unix.sleep 20. >>= fun () ->
        aux level0
    | Error err ->
      Lwt.return @@ Format.eprintf "ERROR %s\n%!" @@ Crp.string_of_error err
  in
  Db.get_level () >>= function
  | Error err ->
    Lwt.return @@ Format.eprintf "wait_next_block error %s\n%!" @@ Crp.string_of_error err
  | Ok level ->
    aux level

let match_orders_nft () =
  reset_db () ;
  let r_alias, _r_source = create_royalties () in
  let r_kt1 = find_kt1 r_alias in
  Printf.eprintf "New royalties %s\n%!" r_kt1 ;
  let ex_alias, ex_admin, _ex_receiver = create_exchange () in
  let ex_kt1 = find_kt1 ex_alias in
  Printf.eprintf "New exchange %s\n%!" ex_kt1 ;
  let v_alias, _v_source = create_validator ~exchange:ex_kt1 ~royalties:r_kt1 in
  let v_kt1 = find_kt1 v_alias in
  Printf.eprintf "New validator %s\n%!" v_kt1 ;
  start_crawler "" v_kt1 ex_kt1 r_kt1 SMap.empty SMap.empty "" "" "" >>= fun (cpid, kafka_config) ->
  api_pid := Some (start_api kafka_config) ;
  crawler_pid := Some cpid ;
  set_validator v_kt1 ex_admin ex_kt1 >>= fun () ->
  Printf.eprintf "Waiting 6sec to let crawler catch up...\n%!" ;
  Lwt_unix.sleep 6. >>= fun () ->
  let (admin, source, contract, royalties, uri) = create_collection ~royalties:r_kt1 () in
  let> (admin, contract, source, _royalties) =
    deploy_collection admin source contract royalties uri in
  let>? () = check_collection admin contract source in
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  Lwt_unix.sleep 6. >>= fun () ->
  let>? item1 = mint_one_with_token_id_from_api ~source ~contract () in
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  Lwt_unix.sleep 6. >>= fun () ->
  let (source1, amount1, token_id1, royalties1, metadata1) = item1 in
  check_item (contract, (source1, string_of_int amount1, token_id1, royalties1, metadata1))
  >>= fun () ->
  let> () = update_operators_for_all ex_kt1 source1 contract in
  let>? item2 = mint_one_with_token_id_from_api ~diff:(Some (fst source1)) ~source ~contract () in
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  Lwt_unix.sleep 6. >>= fun () ->
  let (source2, amount2, token_id2, royalties2, metadata2) = item2 in
  check_item (contract, (source2, string_of_int amount2, token_id2, royalties2, metadata2))
  >>= fun () ->
  let> () = update_operators_for_all ex_kt1 source2 contract in
  (* let tid = get_token_id_from_item item1 in *)
  let>? order1 = sell_nft_for_nft contract item1 item2 in
  (* TODO : check order *)
  let>? order2 = sell_nft_for_nft ~salt:1 contract item2 item1 in
  (* TODO : check order *)
  begin match_orders ~source:source1 ~contract:ex_kt1 order1 order2 >>= function
    | Error err ->
      Printf.eprintf "match_orders error %s" @@ Tzfunc.Rp.string_of_error err ;
      Lwt.return_unit
  | Ok op_hash ->
      Printf.eprintf "HASH = %s\n%!" op_hash ;
      Printf.eprintf "Waiting next block...\n%!" ;
      wait_next_block () >>= fun () ->
      Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
      Lwt_unix.sleep 6. >>= fun () ->
      check_item (contract, (source1, string_of_int amount2, token_id2, royalties2, metadata2))
      >>= fun () ->
      check_item (contract, (source2, string_of_int amount1, token_id1, royalties1, metadata1))
      (* check_orders *)
  end >>= fun () ->
  begin match !api_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
  begin match !crawler_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
  Lwt.return_ok ()

let match_orders_tezos () =
  reset_db () ;
  let r_alias, _r_source = create_royalties () in
  let r_kt1 = find_kt1 r_alias in
  Printf.eprintf "New royalties %s\n%!" r_kt1 ;
  let ex_alias, ex_admin, _ex_receiver = create_exchange () in
  let ex_kt1 = find_kt1 ex_alias in
  Printf.eprintf "New exchange %s\n%!" ex_kt1 ;
  let v_alias, _v_source = create_validator ~exchange:ex_kt1 ~royalties:r_kt1 in
  let v_kt1 = find_kt1 v_alias in
  Printf.eprintf "New validator %s\n%!" v_kt1 ;
  start_crawler "" v_kt1 ex_kt1 r_kt1 SMap.empty SMap.empty "" "" "" >>= fun (cpid, kafka_config) ->
  api_pid := Some (start_api kafka_config) ;
  crawler_pid := Some cpid ;
  set_validator v_kt1 ex_admin ex_kt1 >>= fun () ->
  Printf.eprintf "Waiting 6sec to let crawler catch up...\n%!" ;
  Lwt_unix.sleep 6. >>= fun () ->
  let (admin, source, contract, royalties, uri) = create_collection ~royalties:r_kt1 () in
  let> (admin, contract, source, _royalties) =
    deploy_collection admin source contract royalties uri in
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  Lwt_unix.sleep 6. >>= fun () ->
  let>? () = check_collection admin contract source in
  let>? item1 = mint_one_with_token_id_from_api ~source ~contract () in
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  Lwt_unix.sleep 6. >>= fun () ->
  let (source1, amount1, token_id1, royalties1, metadata1) = item1 in
  check_item (contract, (source1, string_of_int amount1, token_id1, royalties1, metadata1))
  >>= fun () ->
  let> () = update_operators_for_all ex_kt1 source1 contract in
  let>? order1 = sell_nft_for_tezos ~salt:1 contract item1 1 in
  (* TODO : check order *)
  let _source2_alias, source2_pk, source2_sk = generate_address ~diff:(Some (fst source1)) () in
  let source2 = pk_to_pkh_exn source2_pk, source2_sk in
  let>? order2 = buy_nft_for_tezos contract (source2_pk, source2_sk) item1 1 in
  (* TODO : check order *)
  begin match_orders ~amount:1L ~source:source2 ~contract:ex_kt1 order2 order1 >>= function
    | Error err ->
      Printf.eprintf "match_orders error %s" @@ Tzfunc.Rp.string_of_error err ;
      Lwt.return_unit
  | Ok op_hash ->
      Printf.eprintf "HASH = %s\n%!" op_hash ;
      Printf.eprintf "Waiting next block...\n%!" ;
      wait_next_block () >>= fun () ->
      Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
      Lwt_unix.sleep 6. >>= fun () ->
      (* TODO : check_item not *)
      check_item (contract, (source2, string_of_int amount1, token_id1, royalties1, metadata1))
      (* check_orders *)
  end >>= fun () ->
  begin match !api_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
  begin match !crawler_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
  Lwt.return_ok ()

let match_orders_lugh () =
  reset_db () ;
  let r_kt1 = royalties in
  Printf.eprintf "Royalties %s\n%!" r_kt1 ;
  let ex_kt1 = exchange_v2 in
  Printf.eprintf "Exchange %s\n%!" ex_kt1 ;
  let v_kt1 = validator in
  Printf.eprintf "Validator %s\n%!" v_kt1 ;
  start_crawler "" v_kt1 ex_kt1 r_kt1 SMap.empty (SMap.singleton "KT1HT3EbSPFA1MM2ZiMThB6P6Kky5jebNgAx" Lugh) "" "" ""
  >>= fun (cpid, kafka_config) ->
  api_pid := Some (start_api kafka_config) ;
  crawler_pid := Some cpid ;
  Printf.eprintf "Waiting 30sec to let crawler catch up...\n%!" ;
  Lwt_unix.sleep 30. >>= fun () ->
  let contract =  "KT1KvxhtWWhEDQJjH6pENJA8HN5UjBLGHYSg" in
  let _source_alias, source_pk, source_sk = by_alias "rarible1" in
  let source = pk_to_pkh_exn source_pk, source_sk in
  (* let (admin, source, contract, royalties, uri) =
   *   create_collection ~royalties:r_kt1 () in
   * let> (admin, contract, source, _royalties) =
   *   deploy_ubi_collection admin source contract royalties uri in *)
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  Lwt_unix.sleep 6. >>= fun () ->
  (* let>? () = check_collection admin contract source in *)
  let>? item1 = mint_ubi_with_token_id_from_api ~source ~contract () in
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  Lwt_unix.sleep 6. >>= fun () ->
  let (source1, amount1, token_id1, royalties1, metadata1) = item1 in
  check_item (contract, (source1, string_of_int amount1, token_id1, royalties1, metadata1))
  >>= fun () ->
  let royalties = generate_royalties () in
  let> () = set_royalties contract royalties source1 r_kt1 in
  let> () = update_operators_for_all ex_kt1 source1 contract in
  let>? order1 = sell_nft_for_lugh ~salt:1 contract item1 1 in
  (* TODO : check order *)
  let _source2_alias, source2_pk, source2_sk = generate_address ~alias:"rarible1" () in
  let source2 = pk_to_pkh_exn source2_pk, source2_sk in
  let>? order2 = buy_nft_for_lugh contract (source2_pk, source2_sk) item1 1 in
  (* TODO : check order *)
  begin match_orders ~amount:1L ~source:source2 ~contract:ex_kt1 order2 order1 >>= function
    | Error err ->
      Printf.eprintf "match_orders error %s" @@ Tzfunc.Rp.string_of_error err ;
      Lwt.return_unit
  | Ok op_hash ->
      Printf.eprintf "HASH = %s\n%!" op_hash ;
      Printf.eprintf "Waiting next block...\n%!" ;
      wait_next_block () >>= fun () ->
      Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
      Lwt_unix.sleep 6. >>= fun () ->
      (* TODO : check_item not *)
      check_item (contract, (source2, string_of_int amount1, token_id1, royalties1, metadata1))
      (* check_orders *)
  end >>= fun () ->
  begin match !api_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
  begin match !crawler_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
  Lwt.return_ok ()

let fill_orders_db r_kt1 ex_kt1 =
  let (admin, source, contract, royalties, uri) = create_collection ~royalties:r_kt1 () in
  let> (admin, contract, source, _royalties) =
    deploy_collection admin source contract royalties uri in
  let>? () = check_collection admin contract source in
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  Lwt_unix.sleep 6. >>= fun () ->
  let>? item1 = mint_one_with_token_id_from_api ~source ~contract () in
  let (source1, amount1, token_id1, royalties1, metadata1) = item1 in
  let>? item2 = mint_one_with_token_id_from_api ~source ~contract () in
  let (source2, amount2, token_id2, royalties2, metadata2) = item2 in
  let>? item3 = mint_one_with_token_id_from_api ~source ~contract () in
  let (source3, amount3, token_id3, royalties3, metadata3) = item3 in
  let>? item4 = mint_one_with_token_id_from_api ~source ~contract () in
  let (source4, amount4, token_id4, royalties4, metadata4) = item4 in
  let>? item5 = mint_one_with_token_id_from_api ~source ~contract () in
  let (source5, amount5, token_id5, royalties5, metadata5) = item5 in
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  Lwt_unix.sleep 6. >>= fun () ->
  check_item (contract, (source1, string_of_int amount1, token_id1, royalties1, metadata1))
  >>= fun () ->
  check_item (contract, (source2, string_of_int amount2, token_id2, royalties2, metadata2))
  >>= fun () ->
  check_item (contract, (source3, string_of_int amount3, token_id3, royalties3, metadata3))
  >>= fun () ->
  check_item (contract, (source4, string_of_int amount4, token_id4, royalties4, metadata4))
  >>= fun () ->
  check_item (contract, (source5, string_of_int amount5, token_id5, royalties5, metadata5))
  >>= fun () ->
  let> () = update_operators_for_all ex_kt1 source1 contract in
  (* SELL ORDERS *)
  let>? _sell1_1 = sell_nft_for_tezos ~salt:1 contract item1 5 in
  Lwt_unix.sleep 1. >>= fun () ->
  let>? _sell2 = sell_nft_for_tezos ~salt:1 contract item2 1 in
  Lwt_unix.sleep 1. >>= fun () ->
  let>? _sell3 = sell_nft_for_tezos ~salt:1 contract item3 1 in
  Lwt_unix.sleep 1. >>= fun () ->
  let>? _sell4 = sell_nft_for_tezos ~salt:1 contract item4 1 in
  Lwt_unix.sleep 1. >>= fun () ->
  let>? _sell5 = sell_nft_for_tezos ~salt:1 contract item5 1 in
  (* BIDS ORDERS *)
  let _source2_alias, source2_pk, source2_sk = generate_address ~diff:(Some (fst source1)) () in
  let>? _buy1_1 = buy_nft_for_tezos contract (source2_pk, source2_sk) item1 1 in
  Lwt_unix.sleep 1. >>= fun () ->
  let _source3_alias, source3_pk, source3_sk =
    generate_address ~diff:(Some (pk_to_pkh_exn source2_pk)) () in
  let>? _buy1_2 = buy_nft_for_tezos contract (source3_pk, source3_sk) item1 1 in
  Lwt_unix.sleep 1. >>= fun () ->
  let>? _buy4 = buy_nft_for_tezos contract (source2_pk, source2_sk) item4 1 in
  Lwt_unix.sleep 1. >>= fun () ->
  Lwt.return_ok ()

let fill_orders () =
  reset_db () ;
  let r_alias, _r_source = create_royalties () in
  let r_kt1 = find_kt1 r_alias in
  Printf.eprintf "New royalties %s\n%!" r_kt1 ;
  let ex_alias, ex_admin, _ex_receiver = create_exchange () in
  let ex_kt1 = find_kt1 ex_alias in
  Printf.eprintf "New exchange %s\n%!" ex_kt1 ;
  let v_alias, _v_source = create_validator ~exchange:ex_kt1 ~royalties:r_kt1 in
  let v_kt1 = find_kt1 v_alias in
  Printf.eprintf "New validator %s\n%!" v_kt1 ;
  start_crawler "" v_kt1 ex_kt1 r_kt1 SMap.empty SMap.empty "" "" "" >>= fun (cpid, kafka_config) ->
  api_pid := Some (start_api kafka_config) ;
  crawler_pid := Some cpid ;
  set_validator v_kt1 ex_admin ex_kt1 >>= fun () ->
  Printf.eprintf "Waiting 6sec to let crawler catch up...\n%!" ;
  Lwt_unix.sleep 6. >>= fun () ->
  fill_orders_db r_kt1 ex_kt1 >>=? fun () ->
  fill_orders_db r_kt1 ex_kt1 >>=? fun () ->
  fill_orders_db r_kt1 ex_kt1 >>=? fun () ->
  (* TODO : check order *)

  begin match !api_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
  begin match !crawler_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
  Lwt.return_ok ()

let cancel_order () =
  reset_db () ;
  let r_alias, _r_source = create_royalties () in
  let r_kt1 = find_kt1 r_alias in
  Printf.eprintf "New royalties %s\n%!" r_kt1 ;
  let ex_alias, ex_admin, _ex_receiver = create_exchange () in
  let ex_kt1 = find_kt1 ex_alias in
  Printf.eprintf "New exchange %s\n%!" ex_kt1 ;
  let v_alias, _v_source = create_validator ~exchange:ex_kt1 ~royalties:r_kt1 in
  let v_kt1 = find_kt1 v_alias in
  Printf.eprintf "New validator %s\n%!" v_kt1 ;
  start_crawler "" v_kt1 ex_kt1 r_kt1 SMap.empty SMap.empty "" "" "" >>= fun (cpid, kafka_config) ->
  api_pid := Some (start_api kafka_config) ;
  crawler_pid := Some cpid ;
  set_validator v_kt1 ex_admin ex_kt1 >>= fun () ->
  Printf.eprintf "Waiting 6sec to let crawler catch up...\n%!" ;
  Lwt_unix.sleep 6. >>= fun () ->
  let (admin, source, contract, royalties, uri) = create_collection ~royalties:r_kt1 () in
  let> (admin, contract, source, _royalties) =
    deploy_collection admin source contract royalties uri in
  let>? () = check_collection admin contract source in
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  Lwt_unix.sleep 6. >>= fun () ->
  let>? item1 = mint_one_with_token_id_from_api ~source ~contract () in
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  let> () = Lwt_unix.sleep 6. in
  let (source1, amount1, token_id1, royalties1, metadata1) = item1 in
  let> () = check_item (contract, (source1, string_of_int amount1, token_id1, royalties1, metadata1)) in
  let>? order = sell_nft_for_tezos ~salt:1 contract item1 1 in
  (* TODO : check order *)
  begin cancel_order ~source:source1 ~contract:ex_kt1 order >>= function
    | Error err ->
      Printf.eprintf "cancel_order error %s" @@ Tzfunc.Rp.string_of_error err ;
      Lwt.return_unit
  | Ok op_hash ->
      Printf.eprintf "HASH = %s\n%!" op_hash ;
      Printf.eprintf "Waiting next block...\n%!" ;
      wait_next_block () >>= fun () ->
      Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
      Lwt_unix.sleep 6.
      (* check_orders *)
  end >>= fun () ->
  begin match !api_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
  begin match !crawler_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
  Lwt.return_ok ()

(** main *)

let actions = [
  ["call_upsert_order"], "call upsert endpoint with randomly generated order";
  ["update_order_make_value <order_hash> <new_make_value>"], "change order's make value";
  ["update_order_take_value <order_hash> <new_take_value>"], "change order's take value";
  (* ["update_order_date <order_hash> <start_date> <end_date>"], "change order's start date and end date"; *)
  ["update_order_taker <order_hash> <new_taker>"], "change order's taker (should fail)";
  ["create_collection <royalties_contract?>"], "create collection (optionnal royalties contract)" ;
  ["mint_nft <contract_alias> <dest>"], "mint an nft" ;
  ["mint_multi <contract_alias> <dest> <amount>"], "mint amount nfts in contract for dest" ;
  ["transfer_nft <contract_alias> <token_id> <dest>"], "transfer a nft" ;
  ["transfer_multi <contract_alias> <token_id> <dest> <amount>"], "transfer amount nft" ;
  ["run_test"], "will run some test (orig, mint, burn and trasnfer (will erase rarible db)";
  ["match_order_nft_bid"], "create sell orders then exchange the nfts (will erase rarible db)" ;
  ["match_order_tezos_bid"], "create sell orders then buy the nft for one tezos (will erase rarible db)" ;
  ["cancel_order"], "create sell orders then cancel it (will erase rarible db)" ;
  ["fill_orders"], "make random sell/bid orders (will erase rarible db)";
]

let usage =
  "usage: " ^ (Filename.basename Sys.executable_name) ^ " <options> <actions>\nactions:\n  " ^
  (String.concat "\n  " @@ List.map (fun (cmds, descr) ->
       Format.sprintf "- %s -> %s" (String.concat " | " cmds) descr) actions) ^ "\noptions:"

let main () =
  Random.self_init () ;
  let action = ref [] in
  Arg.parse spec (fun s -> action := s :: !action) usage;
  match List.rev !action with
  | [ "call_upsert_order" ] ->
    Lwt_main.run (upsert_order () >>= function
      | Ok _ -> Lwt.return_unit
      | Error err -> Lwt.fail_with @@ Api.Errors.string_of_error err)
    (* | "update_order_make_value" :: hash :: make_value :: [] ->
     *   Lwt_main.run (update_order_make_value hash make_value)
     * | "update_order_take_value" :: hash :: take_value :: [] ->
     *   Lwt_main.run (update_order_take_value hash take_value) *)
    (* | "update_order_date" :: hash :: start_date :: end_date :: [] ->
     *   update_order_date hash start_date end_date *)
    (* | "update_order_taker" :: hash :: taker :: [] ->
     *   Lwt_main.run (update_order_taker hash (Some taker))
     * | [ "create_collection" ] -> ignore @@ create_collection ()
     * | "create_collection" :: royalties :: [] -> ignore @@ create_collection ~royalties () *)
    (* | "mint_token_id" :: contract :: token_id :: [] -> mint contract token_id
     * | "mint" :: contract :: [] -> mint_with_random_token_id contract *)
    (* | "transfer_nft" :: contract :: token_id :: dest :: [] ->
     *   transfer_nft contract token_id dest
     * | "transfer_multi" :: contract :: token_id :: dest :: amount :: [] ->
     *   transfer_multi contract token_id dest amount *)
    | [ "run_nft_test" ] -> Lwt_main.run (
        Lwt.catch random_test (fun exn ->
            Printf.eprintf "CATCH %S\n%!" @@ Printexc.to_string exn ;
            begin match !api_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
            begin match !crawler_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
            Lwt.return_unit))
    | [ "match_order_nft_bid" ] ->
      Lwt_main.run (
        Lwt.catch (fun () ->
            match_orders_nft () >>= function
            | Ok _ -> Lwt.return_unit
            | Error err ->
              Lwt.fail_with @@ Api.Errors.string_of_error err)
          (fun exn ->
             Printf.eprintf "CATCH %S\n%!" @@ Printexc.to_string exn ;
             begin match !api_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
             begin match !crawler_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
             Lwt.return_unit))
    | [ "match_order_tezos_bid" ] ->
      Lwt_main.run (
        Lwt.catch (fun () ->
            match_orders_tezos () >>= function
            | Ok _ -> Lwt.return_unit
            | Error err ->
              Lwt.fail_with @@ Api.Errors.string_of_error err)
          (fun exn ->
             Printf.eprintf "CATCH %S\n%!" @@ Printexc.to_string exn ;
             begin match !api_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
             begin match !crawler_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
             Lwt.return_unit))
    | [ "match_order_lugh_bid" ] ->
      Lwt_main.run (
        Lwt.catch (fun () ->
            match_orders_lugh () >>= function
            | Ok _ -> Lwt.return_unit
            | Error err ->
              Lwt.fail_with @@ Api.Errors.string_of_error err)
          (fun exn ->
             Printf.eprintf "CATCH %S\n%!" @@ Printexc.to_string exn ;
             begin match !api_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
             begin match !crawler_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
             Lwt.return_unit))
    | [ "fill_orders" ] ->
      Lwt_main.run (
        Lwt.catch (fun () ->
            fill_orders () >>= function
            | Ok _ -> Lwt.return_unit
            | Error err ->
              Lwt.fail_with @@ Api.Errors.string_of_error err)
          (fun exn ->
             Printf.eprintf "CATCH %S\n%!" @@ Printexc.to_string exn ;
             begin match !api_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
             begin match !crawler_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
             Lwt.return_unit))
    | [ "cancel_order" ] ->
      Lwt_main.run (
        Lwt.catch (fun () ->
            cancel_order () >>= function
            | Ok _ -> Lwt.return_unit
            | Error err ->
              Lwt.fail_with @@ Api.Errors.string_of_error err)
          (fun exn ->
             Printf.eprintf "CATCH %S\n%!" @@ Printexc.to_string exn ;
             begin match !api_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
             begin match !crawler_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
             Lwt.return_unit))
    | _ -> Arg.usage spec usage

let _ = main ()
