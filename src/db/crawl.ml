open Let
open Proto
open Rtypes
open Common
open Hooks
open Misc

module SSet = Set.Make(String)
module SMap = Map.Make(String)

let short = Common.Utils.short

let insert_nft_activity dbh index timestamp nft_activity =
  let act_type, act_from, elt =  match nft_activity with
    | NftActivityMint elt -> "mint", None, elt
    | NftActivityBurn elt -> "burn", None, elt
    | NftActivityTransfer {elt; from} -> "transfer", Some from, elt in
  let token_id = Z.to_string elt.nft_activity_token_id in
  let value = elt.nft_activity_value in
  let level = Int64.to_int32 elt.nft_activity_block_number in
  [%pgsql dbh
      "insert into nft_activities(\
       activity_type, transaction, index, block, level, date, contract, token_id, \
       owner, amount, tr_from) values ($act_type, \
       ${elt.nft_activity_transaction_hash}, $index, \
       ${elt.nft_activity_block_hash}, \
       $level, $timestamp, \
       ${elt.nft_activity_contract}, \
       $token_id, \
       ${elt.nft_activity_owner}, $value, $?act_from) \
       on conflict do nothing"] >>=? fun () ->
  Lwt.return_ok ()

let create_nft_activity_elt op contract token_id owner amount = {
  nft_activity_owner = owner ;
  nft_activity_contract = contract ;
  nft_activity_token_id = token_id ;
  nft_activity_value = amount ;
  nft_activity_transaction_hash = op.bo_hash ;
  nft_activity_block_hash = op.bo_block ;
  nft_activity_block_number = Int64.of_int32 op.bo_level ;
}

let insert_nft_activity_mint dbh op kt1 token_id owner amount =
  let nft_activity_elt = create_nft_activity_elt op kt1 token_id owner amount in
  let nft_activity_type = NftActivityMint nft_activity_elt in
  insert_nft_activity dbh op.bo_index op.bo_tsp nft_activity_type

let insert_nft_activity_burn dbh op kt1 token_id owner amount =
  let nft_activity_elt = create_nft_activity_elt op kt1 token_id owner amount in
  let nft_activity_type = NftActivityBurn nft_activity_elt in
  insert_nft_activity dbh op.bo_index op.bo_tsp nft_activity_type

let insert_nft_activity_transfer dbh op kt1 from owner token_id amount =
  let elt = {
    nft_activity_owner = owner ;
    nft_activity_contract = kt1;
    nft_activity_token_id = token_id ;
    nft_activity_value = amount ;
    nft_activity_transaction_hash = op.bo_hash ;
    nft_activity_block_hash = op.bo_block ;
    nft_activity_block_number = Int64.of_int32 op.bo_level ;
  } in
  let nft_activity_type = NftActivityTransfer {from; elt} in
  insert_nft_activity dbh op.bo_index op.bo_tsp nft_activity_type

let insert_metadata_update ~dbh ~op ~contract ~token_id ?(update_index=0l) ?(forward=false) ?source ?timeout l =
  let token_meta = Ezjsonm.value_to_string (`O l) in
  if not forward then
    let|>? () = [%pgsql dbh
        "insert into token_updates(transaction, index, block, level, tsp, \
         source, contract, token_id, metadata, transfer_index) \
         values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
         ${op.bo_tsp}, ${op.bo_op.source}, $contract, \
         ${Z.to_string token_id}, $token_meta, $update_index) \
         on conflict do nothing"] in
    Int32.succ update_index
  else
    let block, level, tsp, transaction = op.bo_block, op.bo_level, op.bo_tsp, op.bo_hash in
    let id = Printf.sprintf "%s:%s" contract (Z.to_string token_id) in
    let uri = match List.assoc_opt "" l with
      | None -> None
      | Some (`String s) -> Metadata.parse_uri s
      | Some _json -> None in
    let>? royalties = match uri with
      | Some _ -> Lwt.return_ok None
      | None ->
        let>? _meta, _uri, royalties =
          Metadata.insert_token_metadata ?source ?timeout ~dbh ~forward ~block ~level ~tsp ~contract (token_id, l) in
        Lwt.return_ok royalties in
    let royalties = Option.map (EzEncoding.construct parts_enc) royalties in
    let|>? () = [%pgsql dbh
        "insert into token_info(id, contract, token_id, block, level, tsp, \
         last_block, last_level, last, transaction, metadata, metadata_uri, \
         royalties_metadata, main) \
         values($id, $contract, ${Z.to_string token_id}, $block, $level, $tsp, \
         $block, $level, $tsp, $transaction, $token_meta, $?uri, $?royalties, true) \
         on conflict (id) do update \
         set metadata = $token_meta, metadata_uri = $?uri, royalties_metadata = $?royalties, \
         last_block = $block, \
         last_level = $level, last = $tsp"] in
    update_index

let insert_mint ~dbh ~op ~nft ~contract ?source ?timeout m =
  let block = op.bo_block in
  let level = op.bo_level in
  let tsp = op.bo_tsp in
  let>? r = match nft.nft_kind, m with
    | `rarible, NFTMint m ->
      Lwt.return_ok @@ Some (m.fa2m_token_id, m.fa2m_owner, Z.one, m.fa2m_royalties, 0l)
    | `rarible, MTMint m ->
      Lwt.return_ok @@ Some (m.fa2m_token_id, m.fa2m_owner, m.fa2m_amount, m.fa2m_royalties, 0l)
    | `ubi, UbiMint m ->
      let>? pattern = Metadata.get_uri_pattern ~dbh contract in
      let meta = Option.fold ~none:[] ~some:(fun pattern -> ["", `String (Common.Utils.replace_token_id ~pattern (Z.to_string m.ubim_token_id))]) pattern in
      let|>? update_index = insert_metadata_update ~dbh ~op ~contract ~token_id:m.ubim_token_id ?source ?timeout meta in
      Some (m.ubim_token_id, m.ubim_owner, Z.one, [], update_index)
    | `ubi, UbiMint2 m ->
      Lwt.return_ok @@ Some (m.ubi2m_token_id, m.ubi2m_owner, m.ubi2m_amount, [], 0l)
    | `fa2, HENMint m ->
      Lwt.return_ok @@ Some (m.fa2m_token_id, m.fa2m_owner, m.fa2m_amount, m.fa2m_royalties, 0l)
    | _ -> Lwt.return_ok None in
  match r with
  | None -> Lwt.return_ok 0l
  | Some (token_id, owner, amount, royalties, update_index) ->
    let royalties = EzEncoding.construct parts_enc royalties in
    let id = Printf.sprintf "%s:%s" contract (Z.to_string token_id) in
    let>? () =
      [%pgsql dbh
          "insert into token_info(id, contract, token_id, block, level, tsp, \
           last_block, last_level, last, transaction, royalties) \
           values($id, $contract, ${Z.to_string token_id}, $block, $level, $tsp, $block, $level, \
           $tsp, ${op.bo_hash}, $royalties) \
           on conflict (id) do update \
           set block = case when token_info.main then token_info.block else $block end, \
           level = case when token_info.main then token_info.level else $level end, \
           tsp = case when token_info.main then token_info.tsp else $tsp end"] in
    let mint = EzEncoding.construct mint_enc m in
    let>? () =
      [%pgsql dbh
          "insert into contract_updates(transaction, index, block, level, tsp, \
           contract, mint) \
           values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
           ${op.bo_tsp}, $contract, $mint) \
           on conflict do nothing"] in
    let|>? () = insert_nft_activity_mint dbh op contract token_id owner amount in
    update_index

let insert_metadatas ~dbh ~op ~contract ?(forward=false) ~update_index ?source ?timeout l =
  fold_rp (fun update_index m -> match m with
      | `nat token_id, Some (`tuple [`nat _; `assoc l]) ->
        let meta = Parameters.parse_metadata l in
        insert_metadata_update ~dbh ~op ~contract ~token_id ~forward ~update_index ?source ?timeout meta
      | _ -> Lwt.return_ok update_index) update_index l

let insert_burn ~dbh ~op ~contract m =
  let burn = EzEncoding.construct Json_encoding.(tup2 burn_enc string) (m, op.bo_op.source) in
  let token_id, owner, amount = match m with
    | MTBurn { amount; token_id } -> token_id, op.bo_op.source, amount
    | NFTBurn token_id -> token_id, op.bo_op.source, Z.one in
  let>? () =
    [%pgsql dbh
        "insert into contract_updates(transaction, index, block, level, tsp, \
         contract, burn) \
         values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
         ${op.bo_tsp}, $contract, $burn) on conflict do nothing"] in
  insert_nft_activity_burn dbh op contract token_id owner amount

let insert_transfer ~dbh ~op ~contract lt =
  fold_rp (fun transfer_index {tr_source; tr_txs} ->
      fold_rp (fun transfer_index {tr_destination; tr_token_id; tr_amount} ->
          let tid = Printf.sprintf "%s:%s" contract (Z.to_string tr_token_id) in
          let sid = Printf.sprintf "%s:%s:%s" contract (Z.to_string tr_token_id) tr_source in
          let did = Printf.sprintf "%s:%s:%s" contract (Z.to_string tr_token_id) tr_destination in
          let>? () = [%pgsql dbh
              "insert into tokens(tid, oid, contract, token_id, owner, amount) \
               values($tid, $sid, $contract, ${Z.to_string tr_token_id}, \
               $tr_source, 0) on conflict do nothing"] in
          let>? () = [%pgsql dbh
              "insert into tokens(tid, oid, contract, token_id, owner, amount) \
               values($tid, $did, $contract, ${Z.to_string tr_token_id}, $tr_destination, 0) \
               on conflict do nothing"] in
          let>? () = [%pgsql dbh
              "insert into token_updates(transaction, index, block, level, tsp, \
               source, destination, contract, token_id, amount, transfer_index) \
               values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
               ${op.bo_tsp}, $tr_source, $tr_destination, $contract, \
               ${Z.to_string tr_token_id}, $tr_amount, $transfer_index) \
               on conflict do nothing"] in
          let|>? () = insert_nft_activity_transfer
              dbh op contract tr_source tr_destination tr_token_id tr_amount in
          Int32.succ transfer_index
        ) transfer_index tr_txs) 0l lt

let insert_creators ~dbh ~contract ~token_id ~block ?(forward=false) creators =
  let token_id = Z.to_string token_id in
  let tid = contract ^ ":" ^ token_id in
  let>? l = [%pgsql dbh "select id from token_info where id = $tid and creators <> '{}'"] in
  match l with
  | [] ->
    let creators_json = List.map (fun c -> Some (EzEncoding.construct part_enc c)) creators in
    let>? () = [%pgsql dbh "update token_info set creators = $creators_json where id = $tid"]  in
    iter_rp (fun {part_account; part_value} ->
        [%pgsql dbh
            "insert into creators(id, contract, token_id, account, value, block, main) \
             values($tid, $contract, $token_id, $part_account, $part_value, $block, $forward) \
             on conflict do nothing"]) creators
  | _ -> Lwt.return_ok ()

let insert_token_balances ~dbh ~op ~contract ?(forward=false) balances =
  iter_rp (fun (k, v) ->
      let r = match k, v with
        | `nat id, Some (`address a) ->
          Some ("nft", id, Some a, Z.one)
        | `nat id, None ->
          Some ("nft", id, None, Z.zero)
        | `tuple [`nat id; `address a], Some (`nat bal)
        | `tuple [`address a; `nat id], Some (`nat bal) ->
          Some ("mt", id, Some a, bal)
        | `tuple [`nat id; `address a], None
        | `tuple [`address a; `nat id], None ->
          Some ("mt", id, Some a, Z.zero)
        | _ -> None in
      match r with
      | None -> Lwt.return_ok ()
      | Some (kind, token_id, account, balance) ->
        let tid = Printf.sprintf "%s:%s" contract (Z.to_string token_id) in
        let>? () = [%pgsql dbh
            "insert into token_balance_updates(transaction, index, block, level, \
             tsp, kind, contract, token_id, account, balance, main) \
             values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
             ${op.bo_tsp}, $kind, $contract, ${Z.to_string token_id}, $?account, $balance, $forward) \
             on conflict do nothing"] in
        match account, forward with
        | None, true ->
          [%pgsql dbh "update tokens set amount = 0, balance = 0 where tid = $tid and balance <> 0"]
        | Some a, false ->
          let oid = Printf.sprintf "%s:%s" tid a in
          let>? () = [%pgsql dbh
              "insert into tokens(tid, oid, contract, token_id, owner, amount) \
               values($tid, $oid, $contract, ${Z.to_string token_id}, $a, 0) \
               on conflict do nothing"] in
          insert_creators ~dbh ~contract ~token_id ~forward ~block:op.bo_block
            [ {part_account=a; part_value=10000l} ]
        | Some a, true ->
          let>? () =
            if balance <> Z.zero then
              let creator = { part_account=a; part_value = 10000l } in
              let creators = [ Some (EzEncoding.construct part_enc creator) ] in
              let>? () = [%pgsql dbh
                  "insert into token_info(id, contract, token_id, transaction, block, \
                   level, tsp, main, last_block, last_level, last, creators, supply) \
                   values($tid, $contract, ${Z.to_string token_id}, ${op.bo_hash}, \
                   ${op.bo_block}, ${op.bo_level}, ${op.bo_tsp}, true, \
                   ${op.bo_block}, ${op.bo_level}, ${op.bo_tsp}, $creators, $balance) \
                   on conflict do nothing"] in
              insert_creators ~dbh ~contract ~token_id ~forward ~block:op.bo_block [ creator ]
            else Lwt.return_ok () in
          let>? () =
            if kind = "nft" then
              [%pgsql dbh "update tokens set balance = 0, amount = 0 where tid = $tid and balance <> 0"]
            else Lwt.return_ok () in
          let oid = Printf.sprintf "%s:%s" tid a in
          [%pgsql dbh
              "insert into tokens(tid, oid, contract, token_id, owner, amount, balance) \
               values($tid, $oid, $contract, ${Z.to_string token_id}, $a, $balance, $balance) \
               on conflict (contract, token_id, owner) do update \
               set amount = $balance, balance = $balance \
               where tokens.oid = $oid"]
        | _ -> Lwt.return_ok ()
    ) balances

let insert_ft_token_balances ~dbh ~op ~contract ?token_id ?(forward=false) balances =
  iter_rp (fun (k, v) ->
      let r = match k, v with
        | `tuple [`nat id; `address a], Some (`nat bal)
        | `tuple [`address a; `nat id], Some (`nat bal) ->
          begin match token_id with
            | Some tid when tid <> id -> None
            | _ -> Some ("ft_multi", id, a, bal)
          end
        | `tuple [`nat id; `address a], None
        | `tuple [`address a; `nat id], None ->
          begin match token_id with
            | Some tid when id <> tid -> None
            | _ -> Some ("ft_multi", id, a, Z.zero)
          end
        | `address a, Some (`nat bal) ->
          Some ("ft", Z.minus_one, a, bal)
        | `address a, None ->
          Some ("ft", Z.minus_one, a, Z.zero)
        | `tuple [`address a; `nat id], Some (`tuple (`nat bal :: _)) ->
          begin match token_id with
            | Some tid when id <> tid -> None
            | _ -> Some ("ft", id, a, bal)
          end
        | _ -> None in
      match r with
      | None -> Lwt.return_ok ()
      | Some (kind, token_id, account, balance) ->
        [%pgsql dbh
            "insert into ft_token_balance_updates(transaction, index, block, level, \
             tsp, kind, contract, token_id, account, balance, main) \
             values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
             ${op.bo_tsp}, $kind, $contract, ${Z.to_string token_id}, $account, $balance, $forward) \
             on conflict do nothing"]) balances

(* let insert_update_operator ~dbh ~op ~contract lt =
 *   iter_rp (fun {op_owner; op_operator; op_token_id; op_add} ->
 *       [%pgsql dbh
 *           "insert into token_updates(transaction, index, block, level, tsp, \
 *            source, operator, add, contract, token_id) \
 *            values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
 *            ${op.bo_tsp}, $op_owner, $op_operator, $op_add, \
 *            $contract, ${Z.to_string op_token_id}) on conflict do nothing"]) lt
 *
 * let insert_update_operator_all ~dbh ~op ~contract lt =
 *   let source = op.bo_op.source in
 *   iter_rp (fun (operator, add) ->
 *       [%pgsql dbh
 *           "insert into token_updates(transaction, index, block, level, tsp, \
 *            source, operator, add, contract) \
 *            values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
 *            ${op.bo_tsp}, $source, $operator, $add, $contract) on conflict do nothing"]) lt *)

let metadata_update dbh ~main ~contract ~block ~level ~tsp ?value key =
  if main then
    let>? metadata =
      let>? l = [%pgsql dbh "select metadata from contracts where address = $contract"] in
      one l in
    let metadata = match value with
      | None ->
        Ezjsonm.value_to_string @@
        Json_query.(replace [`Field key] `Null (Ezjsonm.value_from_string metadata))
      | Some value ->
        Ezjsonm.value_to_string @@
        Json_query.(replace [`Field key] value (Ezjsonm.value_from_string metadata)) in
    [%pgsql dbh
        "update contracts set metadata = $metadata, \
         last_block = $block, last_level = $level, last = $tsp where address = $contract"]
  else Lwt.return_ok ()

let insert_metadata ?(forward=false) ~dbh ~op ~contract ?value key =
  if not forward then
    let value = Option.map Ezjsonm.value_to_string value in
    [%pgsql dbh
        "insert into contract_updates(transaction, index, block, level, tsp, \
         contract, metadata_key, metadata_value) \
         values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
         ${op.bo_tsp}, $contract, $key, $?value) \
         on conflict do nothing"]
  else
    metadata_update dbh ~main:true ~contract ~block:op.bo_block ~level:op.bo_level
      ~tsp:op.bo_tsp ?value key

let insert_minter ~dbh ~op ~contract ~add a =
  let a = EzEncoding.construct Json_encoding.(obj1 (req (if add then "add" else "remove") string)) a in
  [%pgsql dbh
      "insert into contract_updates(transaction, index, block, level, tsp, \
       contract, minter) \
       values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
       ${op.bo_tsp}, $contract, $a) \
       on conflict do nothing"]

let insert_uri_pattern ~dbh ~op ~contract s =
  [%pgsql dbh
      "insert into contract_updates(transaction, index, block, level, tsp, \
       contract, uri_pattern) \
       values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
       ${op.bo_tsp}, $contract, $s) \
       on conflict do nothing"]

let insert_royalties ~dbh ~op ?(forward=false) ?(update_index=0l) roy =
  let royalties = EzEncoding.construct parts_enc roy.roy_royalties in
  let source = op.bo_op.source in
  if not forward then
    let|>? () = [%pgsql dbh
        "insert into token_updates(transaction, index, block, level, tsp, \
         source, token_id, contract, royalties, transfer_index) \
         values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
         ${op.bo_tsp}, $source, $?{Option.map Z.to_string roy.roy_token_id}, \
         ${roy.roy_contract}, $royalties, $update_index) \
         on conflict do nothing"] in
    Int32.succ update_index
  else
    let no_token_id = Option.is_none roy.roy_token_id in
    let|>? () = [%pgsql dbh
        "update token_info set royalties = $royalties, \
         last_block = ${op.bo_block},
         last_level = ${op.bo_level}, \
         last = ${op.bo_tsp} \
         where contract = ${roy.roy_contract} and \
         ($no_token_id or token_id = $?{Option.map Z.to_string roy.roy_token_id})"] in
    update_index

let insert_royalties_bms ~dbh ~op ~contract ?forward ~update_index royalties =
  let royalties = List.filter_map (function
      | `nat token_id, Some (`seq l) ->
        let roy_royalties = List.filter_map (function
            | `tuple [ `address part_account; `nat v ] ->
              Some { part_account; part_value = Z.to_int32 v }
            | _ -> None) l in
        Some { roy_contract = contract; roy_token_id = Some token_id;
               roy_royalties }
      | `nat token_id, None ->
        Some { roy_contract = contract; roy_token_id = Some token_id;
               roy_royalties = [] }
      | _ -> None) royalties in
  fold_rp (fun update_index -> insert_royalties ~dbh ~op ?forward ~update_index) update_index royalties

let insert_order_activity ?(main=false)
    dbh id match_left match_right hash transaction block level date order_activity_type =
  [%pgsql dbh
      "insert into order_activities(id, main, match_left, match_right, hash, transaction, \
       block, level, date, order_activity_type) \
       values ($id, $main, $?match_left, $?match_right, $?hash, $?transaction, \
       $?block, $?level, $date, $order_activity_type) \
       on conflict do nothing"]

(* only produce listing events here, match and cancel events will be fired on set main *)
let insert_order_activity ~decs ?main dbh activity =
  match activity.order_act_type with
  | OrderActivityList act ->
    let hash = Some act.order_activity_bid_hash in
    let>? () = insert_order_activity ~main:true
        dbh activity.order_act_id None None hash None None None activity.order_act_date "list" in
    let activity = { at_nft_type = None ; at_order_type = Some activity } in
    Rarible_kafka.produce_activity ~decs activity >>= fun () ->
    Lwt.return_ok ()
  | OrderActivityBid act ->
    let hash = Some act.order_activity_bid_hash in
    let>? () = insert_order_activity ~main:true
        dbh activity.order_act_id None None hash None None None activity.order_act_date "bid" in
    let activity = { at_nft_type = None ; at_order_type = Some activity } in
    Rarible_kafka.produce_activity ~decs activity >>= fun () ->
    Lwt.return_ok ()
  | OrderActivityCancelList act ->
    let hash = Some act.order_activity_cancel_bid_hash in
    let transaction = Some act.order_activity_cancel_bid_transaction_hash in
    let block = Some act.order_activity_cancel_bid_block_hash in
    let level = Some (Int64.to_int32 act.order_activity_cancel_bid_block_number) in
    insert_order_activity ?main
      dbh activity.order_act_id None None hash transaction block
      level activity.order_act_date "cancel_l"
  | OrderActivityCancelBid act ->
    let hash = Some act.order_activity_cancel_bid_hash in
    let transaction = Some act.order_activity_cancel_bid_transaction_hash in
    let block = Some act.order_activity_cancel_bid_block_hash in
    let level = Some (Int64.to_int32 act.order_activity_cancel_bid_block_number) in
    insert_order_activity ?main
      dbh activity.order_act_id None None hash transaction block
      level activity.order_act_date "cancel_b"
  | OrderActivityMatch act ->
    let left = Some act.order_activity_match_left.order_activity_match_side_hash in
    let right = Some act.order_activity_match_right.order_activity_match_side_hash in
    let transaction = Some act.order_activity_match_transaction_hash in
    let block = Some act.order_activity_match_block_hash in
    let level = Some (Int64.to_int32 act.order_activity_match_block_number) in
    insert_order_activity ?main
      dbh activity.order_act_id left right left transaction block
      level activity.order_act_date "match"

let insert_order_activity_new ~decs dbh date order =
  let id = Hex.show @@ Hex.of_bigstring @@ Hacl.Rand.gen 128 in
  let make = order.order_elt.order_elt_make in
  let take = order.order_elt.order_elt_take in
  let>? price = Lwt.return @@ Get.nft_price make take in
  let activity = {
    order_activity_bid_hash = order.order_elt.order_elt_hash ;
    order_activity_bid_maker = order.order_elt.order_elt_maker ;
    order_activity_bid_make = make ;
    order_activity_bid_take = take ;
    order_activity_bid_price = price ;
  } in
  let order_activity_type =
    match order.order_elt.order_elt_make.asset_type,
          order.order_elt.order_elt_take.asset_type with
    | ATNFT _, _ | ATMT _, _ -> OrderActivityList activity
    | _, _ -> OrderActivityBid activity in
  let order_act = {
    order_act_id = id ;
    order_act_date = date ;
    order_act_source = "RARIBLE" ;
    order_act_type = order_activity_type ;
  } in
  insert_order_activity ~decs dbh order_act

let insert_order_activity_cancel dbh ?main transaction block index level date hash =
  let>? order = Get.get_order ~dbh hash in
  let id = Printf.sprintf "%s_%ld" block index in
  match order with
  | Some (order, decs) ->
    let activity = {
      order_activity_cancel_bid_hash = order.order_elt.order_elt_hash ;
      order_activity_cancel_bid_maker = order.order_elt.order_elt_maker ;
      order_activity_cancel_bid_make = order.order_elt.order_elt_make.asset_type ;
      order_activity_cancel_bid_take = order.order_elt.order_elt_take.asset_type ;
      order_activity_cancel_bid_transaction_hash = transaction ;
      order_activity_cancel_bid_block_hash = block ;
      order_activity_cancel_bid_block_number = Int64.of_int32 level ;
      order_activity_cancel_bid_log_index = 0 ;
    } in
  let order_activity_type =
    match order.order_elt.order_elt_make.asset_type,
          order.order_elt.order_elt_take.asset_type with
    | ATNFT _, _ | ATMT _, _ -> OrderActivityCancelList activity
    | _, _ -> OrderActivityCancelBid activity in
    let order_act = {
      order_act_id = id ;
      order_act_date = date ;
      order_act_source = "RARIBLE" ;
      order_act_type = order_activity_type ;
    } in
    insert_order_activity ~decs ?main dbh order_act
  | None ->
    Lwt.return_ok ()

let insert_order_activity_match
    dbh ?main transaction block index level date
    hash_left left_maker left_asset left_salt
    hash_right right_maker right_asset right_salt =
  let id = Printf.sprintf "%s_%ld" block index in
  let match_left = {
    order_activity_match_side_maker = (match left_maker with Some s -> s | None -> "");
    order_activity_match_side_hash = hash_left ;
    order_activity_match_side_asset = left_asset ;
    order_activity_match_side_type = Get.mk_side_type left_asset ;
  } in
  let match_right = {
    order_activity_match_side_maker = (match right_maker with Some s -> s | None -> "") ;
    order_activity_match_side_hash = hash_right ;
    order_activity_match_side_asset = right_asset ;
    order_activity_match_side_type = Get.mk_side_type right_asset ;
  } in
  let>? price = Lwt.return @@ Get.nft_price left_asset right_asset in
  let order_activity_type =
    OrderActivityMatch {
      order_activity_match_left = match_left ;
      order_activity_match_right = match_right ;
      order_activity_match_price = price ;
      order_activity_match_type =
        if left_salt <> Z.zero then
          begin match left_asset.asset_type with
            | ATNFT _ | ATMT _ -> MTSELL
            | _ -> MTACCEPT_BID
          end
        else if right_salt <> Z.zero then
          begin match right_asset.asset_type with
            | ATNFT _ | ATMT _ -> MTSELL
            | _ -> MTACCEPT_BID
          end
        else MTSELL ;
      order_activity_match_transaction_hash = transaction ;
      order_activity_match_block_hash = block ;
      order_activity_match_block_number = Int64.of_int32 level ;
      order_activity_match_log_index = 0 ;
    } in
  let order_act = {
    order_act_id = id ;
    order_act_date = date ;
    order_act_source = "RARIBLE" ;
    order_act_type = order_activity_type ;
  } in
  let>? maked = Get.get_decimals left_asset.asset_type in
  let>? taked = Get.get_decimals right_asset.asset_type in
  insert_order_activity ~decs:(maked, taked) ?main dbh order_act

let insert_cancel ~dbh ~op ~maker_edpk ~maker ~make ~take ~salt ?(forward=false) (hash : Tzfunc.H.t) =
  let hash = ( hash :> string ) in
  let source = op.bo_op.source in
  let>? () =
    match maker_edpk with
    | None -> Lwt.return_ok ()
    | Some maker_edpk ->
      let signature = "NO_SIGNATURE" in
      let>? make_class, make_contract, make_token_id, make_asset_value, make_decimals =
        Get.db_from_asset make in
      let>? take_class, take_contract, take_token_id, take_asset_value, take_decimals =
        Get.db_from_asset take in
      let created_at = CalendarLib.Calendar.now () in
      [%pgsql dbh
          "insert into orders(maker, maker_edpk, \
           make_asset_type_class, make_asset_type_contract, make_asset_type_token_id, \
           make_asset_value, make_asset_decimals, \
           take_asset_type_class, take_asset_type_contract, take_asset_type_token_id, \
           take_asset_value, take_asset_decimals, \
           salt, signature, created_at, last_update_at, hash) \
           values($?maker, $maker_edpk, \
           $make_class, $?make_contract, $?{Option.map Z.to_string make_token_id}, \
           $make_asset_value, $?make_decimals, \
           $take_class, $?take_contract, $?{Option.map Z.to_string take_token_id}, \
           $take_asset_value, $?take_decimals, \
           ${Z.to_string salt}, $signature, $created_at, $created_at, $hash) \
           on conflict do nothing"] in
  [%pgsql dbh
      "insert into order_cancel(transaction, index, block, level, tsp, source, cancel, main) \
       values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
       ${op.bo_tsp}, $source, $hash, $forward) \
       on conflict do nothing"] >>=? fun () ->
  insert_order_activity_cancel ~main:forward
    dbh op.bo_hash op.bo_block op.bo_index op.bo_level op.bo_tsp hash

let insert_do_transfers ~dbh ~op ?(forward=false)
    ~(left : Tzfunc.H.t) ~left_maker_edpk ~left_maker ~left_make_asset
    ~left_take_asset ~left_salt
    ~(right : Tzfunc.H.t) ~right_maker_edpk ~right_maker ~right_make_asset
    ~right_take_asset ~right_salt
    ~fill_make_value ~fill_take_value () =
  let left = ( left :> string ) in
  let right = ( right :> string ) in
  let source = op.bo_op.source in
  let>? left_order_opt = Get.get_order ~dbh left in
  let>? right_order_opt = Get.get_order ~dbh right in
  let created_at = CalendarLib.Calendar.now () in
  let signature = "NO_SIGNATURE" in
  let>? () =
    match left_order_opt, right_order_opt with
    | Some _, Some _ -> Lwt.return_ok ()
    | None, None ->
      let left_maker_edpk = match left_maker_edpk with Some s -> s | None -> "None" in
      let right_maker_edpk = match right_maker_edpk with Some s -> s | None -> "None" in
      let>? left_make_class, left_make_contract,
            left_make_token_id, left_make_asset_value, left_make_decimals =
        Get.db_from_asset left_make_asset in
      let>? left_take_class, left_take_contract,
            left_take_token_id, left_take_asset_value, left_take_decimals =
        Get.db_from_asset left_take_asset in
      let>? right_make_class, right_make_contract,
            right_make_token_id, right_make_asset_value, right_make_decimals =
        Get.db_from_asset right_make_asset in
      let>? right_take_class, right_take_contract,
            right_take_token_id, right_take_asset_value, right_take_decimals =
        Get.db_from_asset right_take_asset in
      let>? () =
        [%pgsql dbh
            "insert into orders(maker, maker_edpk, \
             make_asset_type_class, make_asset_type_contract, make_asset_type_token_id, \
             make_asset_value, make_asset_decimals, \
             take_asset_type_class, take_asset_type_contract, take_asset_type_token_id, \
             take_asset_value, take_asset_decimals, \
             salt, signature, created_at, last_update_at, hash) \
             values($?left_maker, $left_maker_edpk, \
             $left_make_class, $?left_make_contract, $?{Option.map Z.to_string left_make_token_id}, \
             $left_make_asset_value, $?left_make_decimals, \
             $left_take_class, $?left_take_contract, $?{Option.map Z.to_string left_take_token_id}, \
             $left_take_asset_value, $?left_take_decimals, \
             ${Z.to_string left_salt}, $signature, $created_at, $created_at, $left) \
             on conflict do nothing"] in
      [%pgsql dbh
          "insert into orders(maker, maker_edpk, \
           make_asset_type_class, make_asset_type_contract, make_asset_type_token_id, \
           make_asset_value, make_asset_decimals, \
           take_asset_type_class, take_asset_type_contract, take_asset_type_token_id, \
           take_asset_value, take_asset_decimals, \
           salt, signature, created_at, last_update_at, hash) \
           values($?right_maker, $right_maker_edpk, \
           $right_make_class, $?right_make_contract, $?{Option.map Z.to_string right_make_token_id}, \
           $right_make_asset_value, $?right_make_decimals, \
           $right_take_class, $?right_take_contract, $?{Option.map Z.to_string right_take_token_id}, \
           $right_take_asset_value, $?right_take_decimals, \
           ${Z.to_string right_salt}, $signature, $created_at, $created_at, $right) \
           on conflict do nothing"]
    | None, Some (o, _decs) ->
      let left_maker_edpk = match left_maker_edpk with Some s -> s | None -> "None" in
      let>? _left_make_class, left_make_contract,
            left_make_token_id, left_make_asset_value, left_make_decimals =
        Get.db_from_asset left_make_asset in
      let>? right_take_class, _right_take_contract,
            _right_take_token_id, _right_take_asset_value, _right_take_decimals =
        Get.db_from_asset o.order_elt.order_elt_take in
      let left_make_class = right_take_class in
      let>? _left_take_class, left_take_contract,
            left_take_token_id, left_take_asset_value, left_take_decimals =
        Get.db_from_asset left_take_asset in
      let>? right_make_class, _right_make_contract,
            _right_make_token_id, _right_make_asset_value, _right_make_decimals =
        Get.db_from_asset o.order_elt.order_elt_make in
      let left_take_class = right_make_class in
      [%pgsql dbh
          "insert into orders(maker, maker_edpk, \
           make_asset_type_class, make_asset_type_contract, make_asset_type_token_id, \
           make_asset_value, make_asset_decimals, \
           take_asset_type_class, take_asset_type_contract, take_asset_type_token_id, \
           take_asset_value, take_asset_decimals, \
           salt, signature, created_at, last_update_at, hash) \
           values($?left_maker, $left_maker_edpk, \
           $left_make_class, $?left_make_contract, $?{Option.map Z.to_string left_make_token_id}, \
           $left_make_asset_value, $?left_make_decimals, \
           $left_take_class, $?left_take_contract, $?{Option.map Z.to_string left_take_token_id}, \
           $left_take_asset_value, $?left_take_decimals, \
           ${Z.to_string left_salt}, $signature, $created_at, $created_at, $left) \
           on conflict do nothing"]
    | Some (o, _decs), None ->
      let right_maker_edpk = match right_maker_edpk with Some s -> s | None -> "None" in
      let>? _right_make_class, right_make_contract,
            right_make_token_id, right_make_asset_value, right_make_decimals =
        Get.db_from_asset right_make_asset in
      let>? left_take_class, _left_take_contract,
            _left_take_token_id, _left_take_asset_value, _left_take_decimals =
        Get.db_from_asset o.order_elt.order_elt_take in
      let right_make_class = left_take_class in
      let>? _right_take_class, right_take_contract,
            right_take_token_id, right_take_asset_value, right_take_decimals =
        Get.db_from_asset right_take_asset in
      let>? left_make_class, _left_make_contract,
            _left_make_token_id, _left_make_asset_value, _left_make_decimals =
        Get.db_from_asset o.order_elt.order_elt_make in
      let right_take_class = left_make_class in
      [%pgsql dbh
          "insert into orders(maker, maker_edpk, \
           make_asset_type_class, make_asset_type_contract, make_asset_type_token_id, \
           make_asset_value, make_asset_decimals, \
           take_asset_type_class, take_asset_type_contract, take_asset_type_token_id, \
           take_asset_value, take_asset_decimals, \
           salt, signature, created_at, last_update_at, hash) \
           values($?right_maker, $right_maker_edpk, \
           $right_make_class, $?right_make_contract, $?{Option.map Z.to_string right_make_token_id}, \
           $right_make_asset_value, $?right_make_decimals, \
           $right_take_class, $?right_take_contract, $?{Option.map Z.to_string right_take_token_id}, \
           $right_take_asset_value, $?right_take_decimals, \
           ${Z.to_string right_salt}, $signature, $created_at, $created_at, $right) \
           on conflict do nothing"] in
  [%pgsql dbh
      "insert into order_match(transaction, index, block, level, tsp, source, \
       hash_left, hash_right, fill_make_value, fill_take_value) \
       values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
       ${op.bo_tsp}, $source, $left, $right, \
       $fill_make_value, $fill_take_value) \
       on conflict do nothing"] >>=? fun () ->
  insert_order_activity_match ~main:forward
    dbh op.bo_hash op.bo_block op.bo_index op.bo_level op.bo_tsp
    left left_maker left_make_asset left_salt
    right right_maker right_make_asset right_salt

let insert_hen_royalties ~dbh ~op ?forward ~info l =
  let f update_index = function
    | `nat token_id, Some (`tuple [ `address part_account; `nat v ]) ->
      insert_royalties ~dbh ~op ?forward ~update_index {
        roy_contract = info.hen_contract; roy_token_id = Some token_id;
        roy_royalties = [ { part_account; part_value = Z.(to_int32 @@ v * ~$10) } ]}
    | _ -> Lwt.return_ok update_index in
  fold_rp f 0l l

let insert_versum_royalties ~dbh ~op ?forward ~contract ~update_index l =
  let f update_index = function
    | `nat token_id, Some (
        `tuple [ _; _; _; `nat royalty; `seq l ]) ->
      insert_royalties ~dbh ~op ?forward ~update_index {
        roy_contract = contract; roy_token_id = Some token_id;
        roy_royalties = List.filter_map (function
            | `tuple [ `address part_account; `nat pct ] ->
              Some {
                part_account;
                part_value = Z.(to_int32 @@ royalty * pct / ~$100) }
            | _ -> None
          ) l }
    | _ -> Lwt.return_ok update_index in
  fold_rp f update_index l

let insert_fxhash_royalties ~dbh ~op ?forward ~info ~config ~update_index l =
  let f update_index = function
    | `nat token_id, Some (`tuple [ `tuple [_; `nat issuer_id ]; _; _ ]) ->
      let base = Option.map (fun s -> EzAPI.BASE s) @@ List.nth_opt config.Crawlori.Config.nodes 0 in
      let> r = Tzfunc.Node.(get_bigmap_value ?base ~typ:(prim `nat) info.fxhash_issuer_id (Proto.Mint issuer_id)) in
      begin match r with
        | Ok (Some m) ->
          begin match Mtyped.parse_value Contract_spec.fxhash_issuer_field.bmt_value m with
            | Ok (`tuple [`tuple [ `tuple [ `address part_account; _ ]; _; _; _ ]; _; `nat royalties; _; _ ]) ->
              insert_royalties ~dbh ~op ?forward ~update_index {
                roy_contract = info.fxhash_contract; roy_token_id = Some token_id;
                roy_royalties = [ { part_account; part_value = Z.(to_int32 @@ royalties * ~$10) } ]}
            | _ -> Lwt.return_ok update_index
          end
        | _ -> Lwt.return_ok update_index
      end
    | _ -> Lwt.return_ok update_index in
  fold_rp f update_index l

let insert_tezos_domains ~dbh ~op ?(forward=false) l =
  let f = function
    | `bytes key, Some (
        `tuple [
          `tuple [ `tuple [ address; `assoc data ];
                   `tuple [ expiry_key; `assoc internal ] ];
          `tuple [ `tuple [ `nat level; `address owner ]; token_id ] ]) ->
      let address = match address with `some (`address a) -> Some a | _ -> None in
      let expiry_key = match expiry_key with
        | `some (`bytes b) -> Some (Tzfunc.Crypto.hex_to_raw b :> string)
        | _ -> None in
      let token_id = match token_id with `some (`nat id) -> Some (Z.to_string id) | _ -> None in
      let level = Z.to_int32 level in
      let key = (Tzfunc.Crypto.hex_to_raw key :> string) in
      let data = EzEncoding.construct Json_encoding.(assoc string) @@
        List.filter_map (function (`string k, `bytes (v : hex)) -> Some (k, (v :> string)) | _ -> None) data in
      let internal = EzEncoding.construct Json_encoding.(assoc string) @@
        List.filter_map (function (`string k, `bytes (v : hex)) -> Some (k, (v :> string)) | _ -> None) internal in
      if Parameters.decode key then
        [%pgsql dbh
            "insert into tezos_domains(key, owner, level, address, expiry_key, \
             token_id, data, internal_data, block, blevel, index, tsp, main) \
             values($key, $owner, $level, $?address, $?expiry_key, $?token_id, \
             $data, $internal, ${op.bo_block}, ${op.bo_level}, ${op.bo_index}, \
             ${op.bo_tsp}, $forward) \
             on conflict (key, main) do update set \
             owner = $owner, level = $level, address = $?address, \
             expiry_key = $?expiry_key, token_id = $?token_id, data = $data, \
             internal_data = $internal, block = ${op.bo_block}, \
             blevel = ${op.bo_level}, index = ${op.bo_index}, tsp = ${op.bo_tsp} \
             where tezos_domains.key = $key and tezos_domains.main = $forward"]
      else Lwt.return_ok ()
    | _ -> Lwt.return_ok () in
  iter_rp f l

let check_ft_status ~dbh ~config ?crawled contract =
  match crawled with
  | Some true -> Lwt.return_ok true
  | _ ->
    let>? l = [%pgsql dbh "select crawled from ft_contracts where address = $contract"] in
    match l with
    | [ c ] ->
      if c then (
        let ft_contracts = SMap.update contract (function
            | None -> None
            | Some ft -> Some {ft with ft_crawled=Some true}) config.Crawlori.Config.extra.ft_contracts in
        config.Crawlori.Config.extra.ft_contracts <- ft_contracts);
      Lwt.return_ok c
    | _ -> Lwt.return_ok false

let insert_ft ~dbh ~config ~op ~contract ?(forward=false) ft =
  Format.printf "\027[0;35mFT update %s %ld %s\027[0m@."
    (short op.bo_hash) op.bo_index (short contract);
  let>? crawled = check_ft_status ~dbh ~config ?crawled:ft.ft_crawled contract in
  match crawled, op.bo_meta with
  | false, _ | _, None ->
    Lwt.return_ok ()
  | _, Some meta ->
    let bm_id = ft.ft_ledger_id in
    let bm_types = match ft.ft_kind with
      | Fa2_single -> Contract_spec.ledger_fa2_single_field
      | Fa2_multiple -> Contract_spec.ledger_fa2_multiple_field
      | Lugh -> Contract_spec.ledger_lugh_field
      | Fa1 -> Contract_spec.ledger_fa1_field
      | Fa2_multiple_inversed -> Contract_spec.ledger_fa2_multiple_inversed_field
      | Custom bm -> bm in
    let balances = Storage_diff.get_big_map_updates {bm_id; bm_types} meta.op_lazy_storage_diff in
    insert_ft_token_balances ~dbh ~op ~contract ?token_id:ft.ft_token_id ~forward balances

let check_nft_status ~dbh ~config ?crawled contract =
  match crawled with
  | Some true -> Lwt.return_ok true
  | _ ->
    let>? l = [%pgsql dbh "select crawled from contracts where address = $contract"] in
    match l with
    | [ c ] ->
      if c then (
        let contracts = SMap.update contract (function
            | None -> None
            | Some nft -> Some {nft with nft_crawled=Some true}) config.Crawlori.Config.extra.contracts in
        config.Crawlori.Config.extra.contracts <- contracts);
      Lwt.return_ok c
    | _ -> Lwt.return_ok false

let crawled_entrypoints = List.map (fun s -> EPnamed s) [
    "mint"; "burn"; "transfer"; "set_metadata"; "add_minter"; "remove_minter";
    "set_token_metadata_uri" ]

let string_of_entrypoint = function
  | EPdefault -> "default"
  | EProot -> "root"
  | EPdo -> "do"
  | EPset -> "set"
  | EPremove -> "remove"
  | EPnamed s -> s

let insert_nft ~dbh ~config ~meta ~op ~contract ~nft ~entrypoint ?(forward=false) param =
  if List.mem entrypoint crawled_entrypoints then
    Format.printf "\027[0;35mNFT %s %s[%ld] %s\027[0m@."
      (string_of_entrypoint entrypoint) (short op.bo_hash) op.bo_index (short contract);
  let>? crawled = check_nft_status ~dbh ~config ?crawled:nft.nft_crawled contract in
  if not crawled then Lwt.return_ok ()
  else
    let>? update_index =
      if forward then Lwt.return_ok 0l
      else match Parameters.parse_fa2 entrypoint param with
        | Ok (Mint_tokens m) ->
          insert_mint ~dbh ~op ~contract ~nft
            ?source:config.Cconfig.extra.ipfs_source ?timeout:config.Cconfig.extra.ipfs_timeout m
        | Ok (Burn_tokens b) ->
          let|>? () = insert_burn ~dbh ~op ~contract b in 0l
        | Ok (Transfers t) -> insert_transfer ~dbh ~op ~contract t
        | Ok (Metadata (key, value)) ->
          let|>? () = insert_metadata ~dbh ~op ~contract ~value ~forward key in 0l
        | Ok (Add_minter a) ->
          let|>? () = insert_minter ~dbh ~op ~contract ~add:true a in 0l
        | Ok (Remove_minter a) ->
          let|>? () = insert_minter ~dbh ~op ~contract ~add:false a in 0l
        | Ok (Token_uri_pattern s) ->
          let|>? () = insert_uri_pattern ~dbh ~op ~contract s in 0l
        | _ -> Lwt.return_ok 0l in
    let balances = Storage_diff.get_big_map_updates nft.nft_ledger
        meta.op_lazy_storage_diff in
    let>? () = insert_token_balances ~dbh ~op ~contract ~forward balances in
    let>? update_index = match nft.nft_token_meta_id with
      | None -> Lwt.return_ok update_index
      | Some bm_id ->
        let bm = {bm_id; bm_types = Contract_spec.token_metadata_field} in
        let metadata = Storage_diff.get_big_map_updates bm meta.op_lazy_storage_diff in
        insert_metadatas ~dbh ~op ~contract ~forward ~update_index
          ?source:config.Cconfig.extra.ipfs_source ?timeout:config.Cconfig.extra.ipfs_timeout metadata in
    let>? update_index = match nft.nft_royalties_id with
      | None -> Lwt.return_ok update_index
      | Some bm_id ->
        let bm = { bm_id; bm_types = Contract_spec.royalties_field } in
        let royalties = Storage_diff.get_big_map_updates bm meta.op_lazy_storage_diff in
        insert_royalties_bms ~dbh ~op ~contract ~forward ~update_index royalties in
    let>? () = match nft.nft_meta_id with
      | None -> Lwt.return_ok ()
      | Some bm_id ->
        let bm = {bm_id; bm_types = Contract_spec.metadata_field} in
        let metadata = Storage_diff.get_big_map_updates bm meta.op_lazy_storage_diff in
        iter_rp (function
            | `string key, Some (`bytes h) ->
              begin match Parameters.get_string_bytes ~key h with
                | None -> Lwt.return_ok ()
                | Some value -> insert_metadata ~dbh ~op ~contract ~forward ~value key
              end
            | `string key, None -> insert_metadata ~dbh ~op ~contract ~forward key
            | _ -> Lwt.return_ok ()) metadata in
    let>? update_index = match config.Crawlori.Config.extra.versum_info with
      | Some (c, bm_id) when c = contract ->
        let bm = { bm_id; bm_types = Contract_spec.versum_royalties_field } in
        let l = Storage_diff.get_big_map_updates bm meta.op_lazy_storage_diff in
        insert_versum_royalties ~dbh ~op ~forward ~contract ~update_index l
      | _ -> Lwt.return_ok update_index in
    let>? _ = match config.Crawlori.Config.extra.fxhash_info with
      | Some info when info.fxhash_contract = contract ->
        let bm = { bm_id = info.fxhash_data_id; bm_types = Contract_spec.fxhash_data_field } in
        let l = Storage_diff.get_big_map_updates bm meta.op_lazy_storage_diff in
        insert_fxhash_royalties ~dbh ~op ~forward ~config ~info ~update_index l
      | _ -> Lwt.return_ok update_index in
    Lwt.return_ok ()

let insert_transaction ~config ~dbh ~op ?(forward=false) tr =
  let contract = tr.destination in
  match tr.parameters, op.bo_meta with
  | None, _ | _, None -> Lwt.return_ok ()
  | Some {entrypoint; value}, Some meta ->
    if contract = config.Crawlori.Config.extra.royalties then (* royalties *)
      match Parameters.parse_royalties entrypoint value with
      | Ok roy ->
        Format.printf "\027[0;35mset royalties %s %ld\027[0m@." (short op.bo_hash) op.bo_index;
        let|>? _ = insert_royalties ~dbh ~op ~forward roy in
        ()
      | _ -> Lwt.return_ok ()
    else if contract = config.Crawlori.Config.extra.exchange then (* exchange *)
      begin match Parameters.parse_cancel entrypoint value with
        | Ok { cc_hash; cc_maker_edpk; cc_maker; cc_make ; cc_take; cc_salt } ->
          Format.printf "\027[0;35mcancel order %s %ld %s\027[0m@."
            (short op.bo_hash) op.bo_index (short (cc_hash :> string));
          insert_cancel ~dbh ~op ~maker_edpk:cc_maker_edpk ~maker:cc_maker
            ~make:cc_make ~take:cc_take ~salt:cc_salt ~forward cc_hash
        | _ -> Lwt.return_ok ()
      end
    else if contract = config.Crawlori.Config.extra.transfer_manager then (* transfer_manager *)
      begin match Parameters.parse_do_transfers entrypoint value with
        | Ok {dt_left; dt_left_maker_edpk; dt_left_maker; dt_left_make_asset;
              dt_left_take_asset; dt_left_salt;
              dt_right; dt_right_maker_edpk; dt_right_maker; dt_right_make_asset;
              dt_right_take_asset; dt_right_salt;
              dt_fill_make_value; dt_fill_take_value} ->
          Format.printf "\027[0;35mdo transfers %s %ld %s %s\027[0m@."
            (short op.bo_hash) op.bo_index (short (dt_left :> string)) (short (dt_right :> string));
          insert_do_transfers ~forward
            ~dbh ~op
            ~left:dt_left ~left_maker_edpk:dt_left_maker_edpk
            ~left_maker:dt_left_maker ~left_make_asset:dt_left_make_asset
            ~left_take_asset:dt_left_take_asset ~left_salt:dt_left_salt
            ~right:dt_right ~right_maker_edpk:dt_right_maker_edpk
            ~right_maker:dt_right_maker ~right_make_asset:dt_right_make_asset
            ~right_take_asset:dt_right_take_asset ~right_salt:dt_right_salt
            ~fill_make_value:dt_fill_make_value ~fill_take_value:dt_fill_take_value ()
        | _ -> Lwt.return_ok ()
      end
    else match
        config.Crawlori.Config.extra.hen_info,
        config.Crawlori.Config.extra.tezos_domains,
        SMap.find_opt contract config.Crawlori.Config.extra.ft_contracts,
        SMap.find_opt contract config.Crawlori.Config.extra.contracts with
    | Some info, _, _, _ when info.hen_minter = contract ->
      let bm = { bm_id = info.hen_minter_id;
                 bm_types = Contract_spec.hen_royalties_field } in
      let royalties = Storage_diff.get_big_map_updates bm meta.op_lazy_storage_diff in
      if royalties <> [] then
        Format.printf "\027[0;35mhen_royalties %s %ld\027[0m@." (short op.bo_hash) op.bo_index;
      let|>? _ = insert_hen_royalties ~dbh ~forward ~op ~info royalties in
      ()
    | _, Some (c, bm_id), _, _ when c = contract ->
      let bm = { bm_id; bm_types = Contract_spec.tezos_domains_field } in
      let l = Storage_diff.get_big_map_updates bm meta.op_lazy_storage_diff in
      if l <> [] then
        Format.printf "\027[0;35mtezos_domains %s %ld\027[0m@." (short op.bo_hash) op.bo_index;
      insert_tezos_domains ~dbh ~op ~forward l
    | _, _, Some ft, _ -> insert_ft ~dbh ~config ~op ~contract ~forward ft
    | _, _, _, Some nft ->
      insert_nft ~dbh ~config ~meta ~op ~contract ~nft ~entrypoint ~forward value
    | _ -> Lwt.return_ok ()

let ledger_kind types =
  if types = Contract_spec.ledger_nft_field then `nft
  else if types = Contract_spec.ledger_fa2_multiple_field ||
          types = Contract_spec.ledger_fa2_multiple_inversed_field then `multiple
  else `unknown

let filter_contracts op ori =
  let open Contract_spec in
  match op.bo_meta, get_entrypoints ori.script with
  | Some meta, Ok entrypoints ->
    let allocs = Storage_diff.big_map_allocs meta.op_lazy_storage_diff in
    begin match
        match_entrypoints ~expected:(fa2_entrypoints @ fa2_ext_entrypoints) ~entrypoints,
        match_fields ~expected:[
          "ledger"; "token_metadata"; "owner"; "admin";
          "token_metadata_uri"; "metadata"; "royalties"] ~allocs ori.script
      with
      | [ b_balance; b_update; b_transfer; b_update_all; b_mint_nft; b_mint_mt;
          b_burn_nft; b_burn_mt ],
        Ok [ f_ledger; f_token_metadata; f_owner; f_admin; f_uri_pattern;
             f_metadata; f_royalties ] ->
        let nft_token_meta_id = checked_field ~expected:token_metadata_field f_token_metadata in
        let nft_meta_id = checked_field ~expected:metadata_field f_metadata in
        let nft_royalties_id = checked_field ~expected:royalties_field f_royalties in
        let metadata = match f_metadata with
          | (Some (`assoc l), _) ->
            List.filter_map (function
                | (`string key, `bytes v) ->
                  Option.map (fun s -> key, s) @@ Parameters.get_string_bytes ~key v
                | _ -> None) l
          | _ -> [] in
        begin match b_balance && b_update && b_transfer, f_ledger with
          | true, (_, Some ({bm_types; _} as nft_ledger)) ->
            begin match ledger_kind bm_types with
              | `nft | `multiple ->
                let nft = { nft_ledger; nft_token_meta_id; nft_kind = `fa2;
                            nft_meta_id; nft_royalties_id; nft_crawled = Some true } in
                let owner, uri_pattern, nft = match f_admin, f_uri_pattern with
                  | (Some (`address owner), _), (Some (`string uri), _) ->
                    Some owner, Some uri, { nft with nft_kind = `ubi }
                  | _ -> None, None, nft in
                let owner, nft =
                  match b_update_all && (b_mint_nft || b_mint_mt) && (b_burn_nft || b_burn_mt), f_owner, nft.nft_kind with
                  | _, _, `ubi -> owner, nft
                  | true, (Some (`address owner), _), _ -> Some owner, { nft with nft_kind = `rarible }
                  | _ -> None, nft in
                Some (nft, owner, uri_pattern, metadata)
              | _ -> None
            end
          | _ -> None
        end
      | _ -> None
    end
  | _ -> None

let set_crawled_ft ?dbh contract =
  use dbh @@ fun dbh ->
  [%pgsql dbh "update ft_contracts set crawled = true where address = $contract"]

let set_crawled_nft ?dbh contract =
  use dbh @@ fun dbh ->
  [%pgsql dbh "update contracts set crawled = true where address = $contract"]

let insert_origination ?(forward=false) ?(crawled=true) config dbh op ori =
  let kt1 = Tzfunc.Crypto.op_to_KT1 op.bo_hash in
  match filter_contracts op ori, op.bo_meta, SMap.find_opt kt1 config.Crawlori.Config.extra.ft_contracts with
  | _, _, Some _ -> set_crawled_ft ~dbh kt1
  | None, _, _ | _, None, _ -> Lwt.return_ok ()
  | Some (nft, owner, uri, _metadata), Some meta, _ ->
    let ledger_key = EzEncoding.construct Mtyped.stype_enc.json nft.nft_ledger.bm_types.bmt_key in
    let ledger_value = EzEncoding.construct Mtyped.stype_enc.json nft.nft_ledger.bm_types.bmt_value in
    Format.printf "\027[0;93morigination %s %s\027[0m@."
      (short kt1) (EzEncoding.construct nft_ledger_enc nft);
    let>? metadata_assoc = match nft.nft_meta_id with
      | None -> Lwt.return_ok (`O [])
      | Some bm_id ->
        let bm = { bm_id; bm_types = Contract_spec.metadata_field } in
        let cmetadata = Storage_diff.get_big_map_updates bm meta.op_lazy_storage_diff in
        let cmetadata = List.filter_map (function
            | `string key, Some `bytes v ->
              Option.map (fun s -> key, s) @@ Parameters.get_string_bytes ~key v
            | _ -> None) cmetadata in
        let massoc =
          List.fold_left (fun m (k, v) ->
              Json_query.(replace [`Field k] v m)
            ) (`O []) cmetadata in
        Lwt.return_ok massoc in
    let>? () =
      match metadata_assoc with
      | `O [] -> Lwt.return_ok ()
      | `O l ->
        let insert_data json =
          try
            let tzip16_metadata = Json_encoding.destruct tzip16_metadata_enc json in
            Metadata.insert_tzip16_metadata_data
              ~dbh ~forward ~contract:kt1 ~block:op.bo_block
              ~level:op.bo_level ~tsp:op.bo_tsp tzip16_metadata
          with _ -> Lwt.return_ok () in
        let insert_uri uri =
          Metadata.insert_tzip16_metadata ?source:config.Cconfig.extra.ipfs_source
            ?timeout:config.Cconfig.extra.ipfs_timeout
            ~dbh ~forward ~contract:kt1 ~block:op.bo_block
            ~level:op.bo_level ~tsp:op.bo_tsp uri in
        begin match List.assoc_opt "" l with
          | None -> insert_data metadata_assoc
          | Some (`String uri) ->
            let storage = try String.sub uri 0 14 with _ -> "" in
            begin match storage with
              | "tezos-storage:" ->
                let key = String.sub uri 14 (String.length uri - 14) in
                begin match List.assoc_opt key l with
                  | Some (`O _ as json) -> insert_data json
                  | _ -> insert_uri uri
                end
              | _ -> insert_uri uri
            end
          | Some json -> insert_data json
        end
      | _ -> Lwt.return_ok () in
    let kind = Common.Utils.nft_kind_to_string nft.nft_kind in
    let metadata = Ezjsonm.value_to_string metadata_assoc in
    let>? () = [%pgsql dbh
        "insert into contracts(kind, address, owner, block, level, tsp, \
         last_block, last_level, last, ledger_id, ledger_key, ledger_value, \
         uri_pattern, token_metadata_id, metadata_id, royalties_id, \
         metadata, main, crawled) \
         values($kind, $kt1, $?owner, ${op.bo_block}, ${op.bo_level}, \
         ${op.bo_tsp}, ${op.bo_block}, ${op.bo_level}, ${op.bo_tsp}, \
         ${Z.to_string nft.nft_ledger.bm_id}, \
         $ledger_key, $ledger_value, $?uri, $?{Option.map Z.to_string nft.nft_token_meta_id}, \
         $?{Option.map Z.to_string nft.nft_meta_id}, $?{Option.map Z.to_string nft.nft_royalties_id}, \
         $metadata, $forward, $crawled) \
         on conflict do nothing"] in
    let open Crawlori.Config in
    config.extra.contracts <- SMap.add kt1 nft config.extra.contracts;
    let () = match config.accounts with
      | None -> config.accounts <- Some (SSet.singleton kt1)
      | Some accs -> config.accounts <- Some (SSet.add kt1 accs) in
    let balances = Storage_diff.get_big_map_updates nft.nft_ledger meta.op_lazy_storage_diff in
    let>? () = insert_token_balances ~dbh ~op ~contract:kt1 ~forward balances in
    let>? update_index = match nft.nft_token_meta_id with
      | None -> Lwt.return_ok 0l
      | Some bm_id ->
        let bm = { bm_id; bm_types = Contract_spec.token_metadata_field } in
        let metadata = Storage_diff.get_big_map_updates bm meta.op_lazy_storage_diff in
        insert_metadatas ~dbh ~op ~contract:kt1 ~forward ~update_index:0l metadata in
    match nft.nft_royalties_id with
    | None -> Lwt.return_ok ()
    | Some bm_id ->
      let bm = { bm_id; bm_types = Contract_spec.royalties_field } in
      let royalties = Storage_diff.get_big_map_updates bm meta.op_lazy_storage_diff in
      let|>? _ = insert_royalties_bms ~dbh ~op ~contract:kt1 ~forward ~update_index royalties in
      ()

let insert_operation config ?forward dbh op =
  let open Hooks in
  match op.bo_meta with
  | Some meta ->
    if meta.op_status = `applied then
      match op.bo_op.kind with
      | Transaction tr -> insert_transaction ?forward ~config ~dbh ~op tr
      (* | Origination ori -> set_origination config dbh op ori *)
      | _ -> Lwt.return_ok ()
    else Lwt.return_ok ()
  | _ -> Lwt.return_ok ()

let insert_block config ?forward dbh b =
  (* EzEncoding.construct Tzfunc.Proto.full_block_enc.Encoding.json b
   * |> Rarible_kafka.produce_test >>= fun () -> *)
  let>? _ = fold_rp (fun index op ->
      fold_rp (fun index c ->
          match c.man_metadata with
          | None -> Lwt.return_ok index
          | Some meta ->
            if meta.man_operation_result.op_status = `applied then
              let>? index = match c.man_info.kind with
                | Origination ori ->
                  let op = {
                    Hooks.bo_block = b.hash; bo_level = b.header.shell.level;
                    bo_tsp = b.header.shell.timestamp; bo_hash = op.op_hash;
                    bo_op = c.man_info; bo_index = index; bo_indexes = (0l, 0l, 0l);
                    bo_meta = Option.map (fun m -> m.man_operation_result) c.man_metadata;
                    bo_numbers = Some c.man_numbers; bo_nonce = None;
                    bo_counter = c.man_numbers.counter } in
                  let|>? () = insert_origination ?forward config dbh op ori in
                  Int32.succ index
                | _ -> Lwt.return_ok index in
              fold_rp (fun index iop ->
                  if iop.in_result.op_status = `applied then
                    match iop.in_content.kind with
                    | Origination ori ->
                      let bo_meta = Some {
                        iop.in_result with
                        op_lazy_storage_diff =
                          iop.in_result.op_lazy_storage_diff @
                          (Option.fold ~none:[] ~some:(fun m -> m.man_operation_result.op_lazy_storage_diff)
                             c.man_metadata) } in
                      let op = {
                        Hooks.bo_block = b.hash; bo_level = b.header.shell.level;
                        bo_tsp = b.header.shell.timestamp; bo_hash = op.op_hash;
                        bo_op = iop.in_content; bo_index = index; bo_indexes = (0l, 0l, 0l); bo_meta;
                        bo_numbers = Some c.man_numbers; bo_nonce = Some iop.in_nonce;
                        bo_counter = c.man_numbers.counter } in
                      let|>? () = insert_origination ?forward config dbh op ori in
                      Int32.succ index
                    | _ -> Lwt.return_ok index
                  else
                    Lwt.return_ok index
                ) index meta.man_internal_operation_results
            else Lwt.return_ok index
        ) index op.op_contents
    ) 0l b.operations in
  [%pgsql dbh
      "update state set level = ${b.header.shell.level}, \
       tsp = ${b.header.shell.timestamp}, chain_id = ${b.chain_id}"]

let recalculate_creators ~main ~burn ~supply ~amount ~account ~creators =
  let main_s = if main then Z.one else Z.minus_one in
  let factor = if burn then Z.neg main_s else main_s in
  let new_supply = Z.(add supply (mul factor amount)) in
  let creators = List.filter_map (function
      | None -> None
      | Some json -> Some (EzEncoding.destruct part_enc json)) creators in
  let creator_values_old = List.map (fun p -> p.part_account, Z.(mul (of_int32 p.part_value) supply)) creators in
  let creator_values_new =
    if main && not burn || not main && burn then
      match List.assoc_opt account creator_values_old with
      | None -> creator_values_old @ [ account, Z.(mul amount (of_int 10000)) ]
      | Some v -> (List.remove_assoc account creator_values_old) @ [ account, Z.(add v (mul amount (of_int 10000))) ]
    else
      match List.assoc_opt account creator_values_old with
      | None ->
        Format.eprintf "Error in creators during a burn or a reset mint@.";
        creator_values_old
      | Some v -> (List.remove_assoc account creator_values_old) @ [ account, max Z.(sub v (mul amount (of_int 10000))) Z.zero ] in
  let creators =
    if new_supply = Z.zero then []
    else List.map (fun (part_account, v) ->
        { part_account; part_value = Z.(to_int32 @@ div v new_supply)}
      ) creator_values_new in
  creators, new_supply, factor

let creators_update ~dbh ~contract ~token_id ~id ~block creators =
  let token_id = Z.to_string token_id in
  iter_rp (fun {part_account; part_value} ->
      [%pgsql dbh
          "insert into creators(id, contract, token_id, account, value, block, main) \
           values($id, $contract, $token_id, $part_account, $part_value, $block, true) \
           on conflict (id, account) do update set value = $part_value \
           where creators.id = $id and creators.value <> $part_value"])
    creators

let contract_updates_base dbh ~main ~contract ~block ~level ~tsp ~burn
    ~account ~token_id ~amount =
  let tid = contract ^ ":" ^ Z.to_string token_id in
  let>? old_supply, creators =
    let>? l = [%pgsql dbh
        "select supply, creators from token_info where id = $tid limit 1"] in
    one l in
  let creators, new_supply, factor =
    recalculate_creators ~main ~burn ~supply:old_supply ~amount ~account ~creators in
  let creators_json = List.map (fun p -> Some (EzEncoding.construct part_enc p)) creators in
  let>? () = [%pgsql dbh
      "update token_info set supply = $new_supply, creators = $creators_json, \
       last_block = case when $main then $block else last_block end, \
       last_level = case when $main then $level else last_level end, \
       last = case when $main then $tsp else last end \
       where id = $tid"] in
  let>? () = creators_update ~dbh ~id:tid ~contract ~token_id ~block creators in
  let oid = tid ^ ":" ^ account in
  [%pgsql dbh
      "update tokens set amount = amount + ${Z.to_string factor}::numeric * ${Z.to_string amount}::numeric \
       where oid = $oid"]

let minter_update dbh ~main ~contract ~block ~level ~tsp minter =
  let enc = Json_encoding.(union [
      case (obj1 (req "add" string)) (function `add s -> Some s | _ -> None) (fun s -> `add s);
      case (obj1 (req "remove" string)) (function `remove s -> Some s | _ -> None) (fun s -> `remove s) ]) in
  let add, a = match EzEncoding.destruct enc minter, main with
    | `add a, true | `remove a, false -> true, a
    | `add a, false | `remove a, true -> false, a in
  [%pgsql dbh
      "update contracts set minters = case when $add then \
       array_append(minters, $a) else array_remove(minters, $a) end, \
       last_block = $block, last_level = $level, last = $tsp where address = $contract"]

let uri_pattern_update dbh ~main ~contract ~block ~level ~tsp uri =
  if main then
    [%pgsql dbh
        "update contracts set uri_pattern = $uri, \
         last_block = $block, last_level = $level, last = $tsp where address = $contract"]
  else Lwt.return_ok ()

let contract_updates ?source ?timeout dbh main l =
  let>? contracts, events = fold_rp (fun (acc, events) r ->
      let contract, block, level, tsp = r#contract, r#block, r#level, r#tsp in
      let>? events, token_id =
        match r#mint, r#burn, r#metadata_key, r#metadata_value, r#minter, r#uri_pattern with
        | Some json, _, _, _, _, _ ->
          let m = EzEncoding.destruct mint_enc json in
          let token_id, owner, amount, _has_uri = match m with
            | NFTMint m ->
              m.fa2m_token_id, m.fa2m_owner, Z.one, false
            | MTMint m ->
              m.fa2m_token_id, m.fa2m_owner, m.fa2m_amount, false
            | UbiMint m ->
              m.ubim_token_id, m.ubim_owner, Z.one, m.ubim_uri <> None
            | UbiMint2 m ->
              m.ubi2m_token_id, m.ubi2m_owner, m.ubi2m_amount,
              (List.assoc_opt "" m.ubi2m_metadata) <> None
            | HENMint m ->
              m.fa2m_token_id, m.fa2m_owner, m.fa2m_amount,
              (List.assoc_opt "" m.fa2m_metadata) <> None in
          let>? () =
            contract_updates_base
              dbh ~main ~contract ~block ~level ~tsp ~burn:false
              ~account:owner ~token_id ~amount in
          Lwt.return_ok @@ ((contract, Some token_id, [ owner ]) :: events, Some token_id)
        | _, Some json, _, _, _, _ ->
          let b, account = EzEncoding.destruct Json_encoding.(tup2 burn_enc string) json in
          let token_id, amount = match b with
            | NFTBurn token_id -> token_id, Z.one
            | MTBurn {token_id; amount} -> token_id, amount in
          let>? () =
            contract_updates_base
              dbh ~main ~contract ~block ~level ~tsp ~burn:true ~account ~token_id ~amount in
          Lwt.return_ok @@
          ((contract, Some token_id, [ account ]) :: events, Some token_id)
        | _, _, Some key, Some value, _, _ ->
          begin if main then
              match key with
              | "" ->
                Metadata.insert_tzip16_metadata ?source ?timeout
                  ~dbh ~forward:main ~contract ~block ~level ~tsp value
              | "name" ->
                Metadata.insert_tzip16_metadata_name
                  ~dbh ~forward:main ~contract ~block ~level ~tsp value
              | _ -> Lwt.return_ok ()
            else Lwt.return_ok ()
          end >>=? fun () ->
          let value = Ezjsonm.value_from_string value in
          let>? () = metadata_update dbh ~main ~contract ~block ~level ~tsp ~value key in
          Lwt.return_ok @@
          ((contract, None, []) :: events, None)
        | _, _, _, _, Some minter, _ ->
          let>? () = minter_update dbh ~main ~contract ~block ~level ~tsp minter in
          Lwt.return_ok @@
          ((contract, None, []) :: events, None)
        | _, _, _, _, _, Some uri_pattern ->
          let>? () = uri_pattern_update dbh ~main ~contract ~block ~level ~tsp uri_pattern in
          Lwt.return_ok @@
          ((contract, None, []) :: events, None)
        | _ -> Lwt.return_ok (events, None) in
      let acc = match token_id with
        | None -> acc
        | Some id -> SMap.update contract (function None -> Some id | Some tid -> Some (Z.max id tid)) acc in
      Lwt.return_ok (acc, events)) (SMap.empty, []) l in
  (* update contracts *)
  let>? () =
    iter_rp (fun (c, mid) ->
        let>? l = [%pgsql dbh "select last_token_id from contracts where address = $c"] in
        match l with
        | [ mid2 ] when mid > mid2 ->
          [%pgsql dbh "update contracts set last_token_id = $mid where address = $c"]
        | _ -> Lwt.return_ok ()) (SMap.bindings contracts) in
  Lwt.return_ok @@ List.rev events

let transfer_updates dbh main ~contract ~token_id ~source amount destination =
  let oid_source = Common.Utils.oid ~contract ~token_id ~owner:source in
  let oid_destination = Common.Utils.oid ~contract ~token_id ~owner:destination in
  let amount = if main then amount else Z.neg amount in
  let>? () = [%pgsql dbh
      "update tokens set amount = amount - ${Z.to_string amount}::numeric \
       where oid = $oid_source"] in
  let>? () =
    [%pgsql dbh
        "update tokens set amount = amount + ${Z.to_string amount}::numeric \
         where oid = $oid_destination"] in
  if main then
    Lwt.return_ok @@ Some [ source ; destination ]
  else Lwt.return_ok None

let royalties_updates ~dbh ~main ~contract ~block ~level ~tsp ?token_id royalties =
  match main, token_id with
  | true, None ->
    [%pgsql dbh
        "update token_info set royalties = $royalties, \
         last_block = case when $main then $block else last_block end, \
         last_level = case when $main then $level else last_level end, \
         last = case when $main then $tsp else last end \
         where contract = $contract"]
  | true, Some token_id ->
    let tid = Common.Utils.tid ~contract ~token_id in
    [%pgsql dbh
        "update token_info set royalties = $royalties, \
         last_block = case when $main then $block else last_block end, \
         last_level = case when $main then $level else last_level end, \
         last = case when $main then $tsp else last end \
         where id = $tid"]
  | _ -> Lwt.return_ok ()

let token_metadata_updates ~dbh ~main ~contract ~block ~level ~tsp ~token_id ~transaction ?source ?timeout meta =
  let id = Printf.sprintf "%s:%s" contract (Z.to_string token_id) in
  let meta = EzEncoding.destruct Json_encoding.(assoc Json_encoding.any_ezjson_value) meta in
  let>? meta, uri, royalties =
    Metadata.insert_token_metadata ?source ?timeout ~dbh ~block ~level ~tsp ~contract ~forward:true (token_id, meta) in
  let royalties = Option.map (EzEncoding.construct parts_enc) royalties in
  [%pgsql dbh
      "insert into token_info(id, contract, token_id, block, level, tsp, \
       last_block, last_level, last, transaction, metadata, metadata_uri, \
       royalties_metadata, main) \
       values($id, $contract, ${Z.to_string token_id}, $block, $level, $tsp, \
       $block, $level, $tsp, $transaction, $meta, $?uri, $?royalties, true) \
       on conflict (id) do update \
       set metadata = $meta, metadata_uri = $?uri, royalties_metadata = $?royalties, \
       last_block = case when $main then $block else token_info.last_block end, \
       last_level = case when $main then $level else token_info.last_level end, \
       last = case when $main then $tsp else token_info.last end"]

let token_updates ?source ?timeout dbh main l =
  fold_rp (fun acc r ->
      let contract, block, level, tsp, src, transaction =
        r#contract, r#block, r#level, r#tsp, r#source, r#transaction in
      match r#destination, Option.map Z.of_string r#token_id,
            r#amount, r#operator, r#add, r#royalties, r#metadata  with
      | Some destination, Some token_id, Some amount, _, _, _, _ ->
        let>? ev =
          transfer_updates
            dbh main ~contract ~token_id ~source:src amount destination in
        begin match ev with
          | None -> Lwt.return_ok acc
          | Some owners -> Lwt.return_ok ((contract, Some token_id, owners) :: acc)
        end
      | _, token_id, _, _, _, Some royalties, _ ->
        let>? () =
          royalties_updates ~dbh ~main ~contract ~block ~level ~tsp ?token_id royalties in
        Lwt.return_ok ((contract, token_id, []) :: acc)
      | _, Some token_id, _, _, _, _, Some meta ->
        let>? () =
          token_metadata_updates ~dbh ~main ~contract ~block ~level ~tsp ~token_id ~transaction ?source ?timeout meta in
        Lwt.return_ok (((contract, Some token_id, []) :: acc))
      | _ -> Lwt.return_error (`hook_error "invalid token_update")) [] l

let token_balance_updates dbh main l =
  let agg =
    List.fold_left (fun acc r -> match r#account with
        | None -> ("", r) :: acc
        | Some owner ->
          let oid = Common.Utils.oid ~contract:r#contract ~token_id:(Z.of_string r#token_id) ~owner in
          (oid, r) :: List.remove_assoc oid acc)
      [] l in
  let _, l = List.split agg in
  let l = List.rev l in
  let>? unseen = fold_rp (fun acc r ->
      let info = match r#kind, r#account, r#balance with
        | "mt", Some account, Some balance ->
          let balance = if main then Some balance else None in
          Some (Some account, balance, None)
        | "mt", Some account, None ->
          let balance = if main then Some Z.zero else None in
          Some (Some account, balance, None)
        | "nft", Some account, _ ->
          let balance_src = if main then Some Z.zero else Some Z.one in
          let balance_dst = if main then Some Z.one else Some Z.zero in
          Some (Some account, balance_dst, balance_src)
        | "nft", None, _ ->
          let balance = if main then Some Z.zero else Some Z.one in
          Some (None, balance, None)
        | _ -> None in
      let tid = Common.Utils.tid ~contract:r#contract ~token_id:(Z.of_string r#token_id) in
      let>? l = match info with
        | None -> Lwt.return_ok []
        | Some (account, balance, other) ->
          match account with
          | None ->
            [%pgsql dbh
                "update tokens set balance = $?balance where tokens.tid = $tid \
                 returning owner, amount, balance"]
          | Some account ->
            let oid = Common.Utils.oid ~contract:r#contract ~token_id:(Z.of_string r#token_id) ~owner:account in
            let amount = Option.value ~default:Z.zero balance in
            let>? l = [%pgsql dbh
                "insert into tokens(tid, oid, contract, token_id, owner, amount, balance) \
                 values($tid, $oid, ${r#contract}, ${r#token_id}, $account, $amount, $?balance) \
                 on conflict (contract, token_id, owner) \
                 do update set balance = $?balance \
                 returning owner, amount, balance"] in
            match other, main with
            | None, _ -> Lwt.return_ok l
            | Some b, true ->
              let|>? l2 =
                [%pgsql dbh
                    "update tokens set balance = $b where tokens.tid = $tid \
                     and owner <> $account and balance <> ${Z.to_string b}::numeric \
                     returning owner, amount, balance"] in
              l @ l2
            | Some _, false ->
              let|>? () = [%pgsql dbh
                  "update tokens set balance = amount \
                   where tokens.tid = $tid and balance <> amount"] in
              l in
      Lwt.return_ok @@
      List.fold_left (fun acc (account, amount, balance) ->
          match balance with
          | Some b when b <> amount ->
            TMap.add (r#contract, Z.of_string r#token_id, account) (amount, b, r) acc
          | _ -> acc) acc l
    ) TMap.empty l in
  let>? m = fold_rp (fun acc ((contract, token_id, owner), (amount, balance, r)) ->
      Format.printf "\027[0;33mupdate amount for %s[%s][%s]: %s -> %s\027[0m@."
        (short contract) (Z.to_string token_id) (short owner) (Z.to_string amount) (Z.to_string balance);
      let oid = Format.sprintf "%s:%s:%s" contract (Z.to_string token_id) owner in
      let>? () = [%pgsql dbh "update tokens set amount = $balance where oid = $oid"] in
      let diff = Z.sub balance amount in
      Lwt.return_ok @@ match TIMap.find_opt (contract, token_id) acc with
      | None -> TIMap.add (contract, token_id) (diff, r) acc
      | Some (s, _) -> TIMap.add (contract, token_id) (Z.(add s diff), r) acc
    ) TIMap.empty (TMap.bindings unseen) in
  let>? () =
    iter_rp (fun ((contract, token_id), (supply_diff, r)) ->
        if supply_diff = Z.zero then
          Lwt.return_ok ()
        else
          begin
            Format.printf "\027[0;33mupdate supply for %s[%s]: %s\027[0m@."
              (short contract) (Z.to_string token_id) (Z.to_string supply_diff);
            let id = Common.Utils.tid ~contract ~token_id in
            let creators = match r#account with
              | None -> []
              | Some a -> [ Some (EzEncoding.construct part_enc { part_account=a; part_value = 10000l }) ] in
            [%pgsql dbh
                "insert into token_info(id, contract, token_id, block, level, tsp, \
                 last_block, last_level, last, transaction, supply, creators, main) \
                 values($id, $contract, ${Z.to_string token_id}, ${r#block}, ${r#level}, ${r#tsp}, \
                 ${r#block}, ${r#level}, ${r#tsp}, ${r#transaction}, $supply_diff, $creators, true) \
                 on conflict (id) do update \
                 set supply = token_info.supply + ${Z.to_string supply_diff}, \
                 creators = case when token_info.creators = '{}' then $creators else token_info.creators end, \
                 last_block = case when $main then ${r#block} else token_info.last_block end, \
                 last_level = case when $main then ${r#level} else token_info.last_level end, \
                 last = case when $main then ${r#tsp} else token_info.last end"]
          end) @@
    TIMap.bindings m in
  Lwt.return_ok unseen

let tezos_domain_updates dbh main l =
  iter_rp (fun r ->
      let>? l2 = [%pgsql.object dbh
          "select * from tezos_domains where key = ${r#key} and block <> ${r#block}"] in
      let>? () = [%pgsql dbh "delete from tezos_domains where key = ${r#key}"] in
      let>? () = [%pgsql dbh
          "insert into tezos_domains(key, owner, level, address, expiry_key, \
           token_id, data, internal_data, block, blevel, index, tsp, main) \
           values(${r#key}, ${r#owner}, ${r#level}, $?{r#address}, $?{r#expiry_key}, \
           $?{r#token_id}, ${r#data}, ${r#internal_data}, ${r#block}, ${r#blevel}, \
           ${r#index}, ${r#tsp}, $main)"] in
      match l2 with
      | [ r2 ] ->
        [%pgsql dbh
            "insert into tezos_domains(key, owner, level, address, expiry_key, \
             token_id, data, internal_data, block, blevel, index, tsp, main) \
             values(${r2#key}, ${r2#owner}, ${r2#level}, $?{r2#address}, \
             $?{r2#expiry_key}, $?{r2#token_id}, ${r2#data}, ${r2#internal_data}, \
             ${r2#block}, ${r2#blevel}, ${r2#index}, ${r2#tsp}, not $main)"]
      | _ -> Lwt.return_ok ()) l

let cancel_updates dbh l =
  iter_rp (fun x -> match x#cancel with
      | None -> Lwt.return_ok ()
      | Some hash ->
        [%pgsql dbh "update orders set last_update_at = ${x#tsp} where hash = $hash"]) l

let match_updates dbh l =
  iter_rp (fun x ->
      [%pgsql dbh
          "update orders set last_update_at = ${x#tsp} where hash = ${x#hash_left} \
           or hash = ${x#hash_right}"]) l

let set_main config ?(forward=false) dbh {Hooks.m_main; m_hash} =
  let sort l = List.sort (fun r1 r2 ->
      if m_main then Int32.compare r1#index r2#index
      else Int32.compare r2#index r1#index) l in
  if not forward then
    use (Some dbh) @@ fun dbh ->
    let>? collections =
      [%pgsql.object dbh
          "update contracts set main = $m_main where block = $m_hash returning *"] in
    let>? () = [%pgsql dbh "update token_info set main = $m_main where block = $m_hash"] in
    let>? nactivities =
      [%pgsql.object dbh
          "update nft_activities set main = $m_main where block = $m_hash returning *"] in
    let>? oactivities =
      [%pgsql.object dbh
          "update order_activities set main = $m_main where block = $m_hash returning *"] in
    let>? t_updates =
      [%pgsql.object dbh
          "update token_updates set main = $m_main where block = $m_hash returning *"] in
    let>? c_updates =
      [%pgsql.object dbh
          "update contract_updates set main = $m_main where block = $m_hash returning *"] in
    let>? cancels =
      [%pgsql.object
        dbh "update order_cancel set main = $m_main where block = $m_hash returning *"] in
    let>? matches =
      [%pgsql.object
        dbh "update order_match set main = $m_main where block = $m_hash returning *"] in
    let>? tb_updates =
      [%pgsql.object dbh
          "update token_balance_updates set main = $m_main where block = $m_hash returning *"] in
    let>? () =
      [%pgsql dbh
          "update ft_token_balance_updates set main = $m_main where block = $m_hash"] in
    let>? () =
      [%pgsql dbh "update creators set main = true where block = $m_hash"] in
    let>? td_updates =
      [%pgsql.object dbh "select * from tezos_domains where block = $m_hash"] in
    let>? cevents = contract_updates ?source:config.Cconfig.extra.ipfs_source
        ?timeout:config.Cconfig.extra.ipfs_timeout dbh m_main @@ sort c_updates in
    let>? tevents = token_updates ?source:config.Cconfig.extra.ipfs_source
        ?timeout:config.Cconfig.extra.ipfs_timeout dbh m_main @@ sort t_updates in
    let>? unseen = token_balance_updates dbh m_main @@ sort tb_updates in
    let>? () = tezos_domain_updates dbh m_main @@ sort td_updates in
    let>? () =
      [%pgsql dbh
          "update tzip21_metadata set main = $m_main where block = $m_hash"] in
    let>? () =
      [%pgsql dbh
          "update tzip21_formats set main = $m_main where block = $m_hash"] in
    let>? () =
      [%pgsql dbh
          "update tzip21_attributes set main = $m_main where block = $m_hash"] in
    let>? () =
      [%pgsql dbh
          "update tzip21_creators set main = $m_main where block = $m_hash"] in
    let>? collections_name =
      [%pgsql dbh
          "update tzip16_metadata set main = $m_main \
           where block = $m_hash returning contract, name"] in
    let cancels = sort cancels in
    let matches = sort matches in
    let>? () =
      if m_main then
        let>? () = match_updates dbh matches in
        cancel_updates dbh cancels
      else Lwt.return_ok () in
    Lwt.return_ok (fun () ->
        let>? () = Produce.collection_events m_main collections collections_name in
        let>? () = Produce.cancel_events dbh m_main cancels in
        let>? () = Produce.match_events dbh m_main matches in
        let unseen =
          List.map (fun ((contract, token_id, owner), _) -> (contract, Some token_id, [ owner ]))
            (TMap.bindings unseen)
        in
        let contracts, items =
          List.fold_left (fun (contracts, items) (contract, token_id, owners) ->
              SSet.add contract contracts,
              match token_id with
              | None -> items
              | Some token_id ->
                let tid = Common.Utils.tid ~contract ~token_id in
                SMap.update tid (function
                    | None -> Some (SSet.of_list owners)
                    | Some old ->
                      let o = List.fold_left (fun acc ow -> SSet.add ow acc) old owners in
                      Some o)
                  items)
            (SSet.empty, SMap.empty) (cevents @ tevents @ unseen) in
        let>? () =
          iter_rp (fun c ->
              Produce.update_collection_event dbh c ())
            (SSet.elements contracts) in
        let>? () =
          iter_rp (fun (tid, owners) ->
              let l = String.split_on_char ':' tid in
              match l with
              | contract :: token_id :: [] ->
                let token_id = Z.of_string token_id in
                let>? () = Produce.nft_item_event dbh contract token_id () in
                iter_rp (fun owner ->
                    let>? () = Produce.nft_ownership_event dbh contract token_id owner () in
                    Produce.order_event_item dbh owner contract token_id ())
                  (SSet.elements owners)
              | _ -> Format.eprintf "events : wrong tid format@." ; Lwt.return_ok ())
            (SMap.bindings items) in
        let>? () = Produce.nft_activity_events m_main @@ sort nactivities in
        Produce.order_activity_events dbh m_main oactivities)
  else
    Lwt.return_ok (fun () -> Lwt.return_ok ())
