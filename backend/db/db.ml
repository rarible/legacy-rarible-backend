open Let
open Tzfunc.Proto
open Rtypes
open Hooks
open Common
open Utils

module Rarible_kafka = Rarible_kafka

module SSet = Set.Make(String)

module PGOCaml = Pg.PGOCaml

let () = Pg.PG.Pool.init ~database:Cconfig.database ()

let use dbh f = match dbh with
  | None -> Pg.PG.Pool.use f
  | Some dbh -> f dbh

let one ?(err="expected unique row not found") l = match l with
  | [ x ] -> Lwt.return_ok x
  | _ -> Lwt.return_error (`hook_error err)

let is_op_included ?dbh hash =
  use dbh @@ fun dbh ->
  let>? t =
    [%pgsql.object dbh
        "select hash from transactions where hash = $hash and main"] in
  let>? o =
    [%pgsql.object dbh
        "select hash from originations where hash = $hash and main"] in
  Lwt.return_ok (o <> [] || t <> [])

let is_collection_crawled ?dbh hash =
  use dbh @@ fun dbh ->
  let>? o =
    [%pgsql.object dbh
        "select address from contracts where address = $hash and main"] in
  Lwt.return_ok (o <> [])

let db_contracts =
  List.fold_left (fun acc r ->
      match r#ledger_key, r#ledger_value with
      | Some k, Some v ->
        let bmt_key = EzEncoding.destruct micheline_type_short_enc k in
        let bmt_value = EzEncoding.destruct micheline_type_short_enc v in
        let v = {
          nft_ledger = {bm_types = {bmt_key; bmt_value}; bm_id = Z.of_string r#ledger_id};
          nft_meta_id=Option.map Z.of_string r#metadata_id;
          nft_token_meta_id=Option.map Z.of_string r#token_metadata_id;
          nft_royalties_id=Option.map Z.of_string r#royalties_id;
        } in
        SMap.add r#address v acc
      | _ -> acc) SMap.empty

let db_ft_contract r =
  let v = match r#kind, r#ledger_key, r#ledger_value with
    | "fa2_single", _, _ -> Some Fa2_single
    | "fa1", _, _ -> Some Fa1
    | "fa2_multiple", _, _ -> Some Fa2_multiple
    | "lugh", _, _ -> Some Lugh
    | "fa2_multiple_inversed", _, _ -> Some Fa2_multiple_inversed
    | "custom", Some k, Some v ->
      let bmt_key = EzEncoding.destruct micheline_type_short_enc k in
      let bmt_value = EzEncoding.destruct micheline_type_short_enc v in
      Some (Custom {bmt_key; bmt_value})
    | _ -> None in
  match v with
  | None -> None
  | Some ft_kind -> Some {
      ft_kind; ft_ledger_id = Z.of_string r#ledger_id; ft_decimals = r#decimals;
      ft_crawled=r#crawled; ft_token_id = Option.map Z.of_string r#token_id}

let db_ft_contracts =
  List.fold_left (fun acc r ->
      match db_ft_contract r with
      | None -> acc
      | Some ft -> SMap.add r#address ft acc) SMap.empty

let get_extra_config ?dbh () =
  use dbh @@ fun dbh ->
  let>? contracts =
    [%pgsql.object dbh
        "select address, ledger_id, ledger_key, ledger_value, metadata_id, \
         token_metadata_id, royalties_id \
         from contracts where main"] in
  let>? ft_contracts =
    [%pgsql.object dbh
        "select address, kind, ledger_id, ledger_key, ledger_value, crawled, \
         token_id, decimals from ft_contracts"] in
  let>? r = [%pgsql.object dbh
      "select exchange, royalties, transfer_manager from state"] in
  match r with
  | [ r ] ->
    let contracts = db_contracts contracts in
    let ft_contracts = db_ft_contracts ft_contracts in
    Lwt.return_ok (Some {
      exchange = r#exchange;
      royalties = r#royalties;
      transfer_manager = r#transfer_manager;
      ft_contracts; contracts
    })
  | [] -> Lwt.return_ok None
  | _ -> Lwt.return_error (`hook_error "wrong_state")

let update_extra_config ?dbh e =
  use dbh @@ fun dbh ->
  let>? r = [%pgsql.object dbh "select * from state"] in
  let>? () = match r with
    | [] ->
      [%pgsql dbh
          "insert into state(exchange, royalties, transfer_manager) \
           values (${e.exchange}, ${e.royalties}, ${e.transfer_manager})"]
    | _ ->
      [%pgsql dbh
          "update state set exchange = ${e.exchange}, \
           royalties = ${e.royalties}, transfer_manager = ${e.transfer_manager}"] in
  iter_rp (fun (address, lk) ->
      let id = Z.to_string lk.ft_ledger_id in
      let token_id = Option.map Z.to_string lk.ft_token_id in
      let kind, k, v = match lk.ft_kind with
        | Fa2_single -> "fa2_single", None, None
        | Fa2_multiple -> "fa2_multiple", None, None
        | Fa2_multiple_inversed -> "fa2_multiple_inversed", None, None
        | Fa1 -> "fa1", None, None
        | Lugh -> "lugh", None, None
        | Custom {bmt_key; bmt_value} ->
          "custom",
          Some (EzEncoding.construct micheline_type_short_enc bmt_key),
          Some (EzEncoding.construct micheline_type_short_enc bmt_value) in
      [%pgsql dbh
          "insert into ft_contracts(address, kind, ledger_id, ledger_key, ledger_value, crawled, token_id, decimals) \
           values($address, $kind, $id, $?k, $?v, ${lk.ft_crawled}, $?token_id, ${lk.ft_decimals}) on conflict do nothing"])
    (SMap.bindings e.ft_contracts)

(* Normalize here in case of ERC20 like asset *)
let price left right =
  if left.asset_value > Z.zero then
    if Z.rem right.asset_value left.asset_value <> Z.zero then
      Ok Z.zero
    else
      Ok (Z.div right.asset_value left.asset_value)
  else Ok Z.zero

let nft_price left right =
  match left.asset_type with
  | ATNFT _ | ATMT _ -> price left right
  | _ -> price right left

let mk_side_type asset = match asset.asset_type with
  | ATNFT _ | ATMT _ -> STBID
  | _ -> STSELL

let mk_asset asset_class contract token_id asset_value =
  match asset_class with
  | "XTZ" ->
    begin
      match contract, token_id with
      | None, None ->
        Ok { asset_type = ATXTZ ; asset_value }
      | _, _ ->
        Error (`hook_error ("contract addr or tokenId for XTZ asset"))
    end
  | "FT" ->
    begin match contract with
      | Some contract ->
        let asset_type = ATFT {contract; token_id} in
        Ok { asset_type; asset_value }
      | _ ->
        Error (`hook_error ("need contract and for FT asset"))
    end
  | "NFT" ->
    begin
      match contract, token_id with
      | Some asset_contract, Some asset_token_id ->
        let asset_type = ATNFT { asset_contract; asset_token_id } in
        Ok { asset_type; asset_value }
      | _, _ ->
        Error (`hook_error ("no contract addr for NFT asset"))
    end
  | "MT" ->
    begin
      match contract, token_id with
      | Some asset_contract, Some asset_token_id ->
        let asset_type = ATMT { asset_contract; asset_token_id } in
        Ok { asset_type; asset_value }
      | _, _ ->
        Error (`hook_error ("no contract addr for MT asset"))
    end
  | _ ->
    Error (`hook_error ("invalid asset class " ^ asset_class))

let get_order_price_history ?dbh hash_key =
  use dbh @@ fun dbh ->
  let|>? l = [%pgsql dbh
      "select date, make_value, take_value \
       from order_price_history where hash = $hash_key \
       order by date desc"] in
  List.map
    (fun (date, make_value, take_value) ->
       {
         order_price_history_record_date = date ;
         order_price_history_record_make_value = make_value ;
         order_price_history_record_take_value = take_value ;
       }) l

let mk_order_activity_bid ~dbh obj =
  let|> ph = get_order_price_history ~dbh obj#o_hash in
  let make_value, take_value = match ph with
    | Ok [] | Error _ -> obj#make_asset_value, obj#take_asset_value
    | Ok ph ->
      begin match List.find_opt (fun p -> p.order_price_history_record_date = obj#date) ph with
        | None -> obj#make_asset_value, obj#take_asset_value
        | Some p ->
          p.order_price_history_record_make_value, p.order_price_history_record_take_value
      end
  in
  let$ make = mk_asset
      obj#make_asset_type_class
      obj#make_asset_type_contract
      (Option.map Z.of_string obj#make_asset_type_token_id)
      make_value in
  let$ take = mk_asset
      obj#take_asset_type_class
      obj#take_asset_type_contract
      (Option.map Z.of_string obj#take_asset_type_token_id)
      take_value in
  let|$ price = nft_price make take in
  {
    order_activity_bid_hash = obj#o_hash;
    order_activity_bid_maker = obj#maker ;
    order_activity_bid_make = make ;
    order_activity_bid_take = take ;
    order_activity_bid_price = price ;
  }, (obj#make_asset_decimals, obj#take_asset_decimals)

let mk_left_side obj value =
  let|$ asset =
    mk_asset
      obj#oleft_make_asset_type_class
      obj#oleft_make_asset_type_contract
      (Option.map Z.of_string obj#oleft_make_asset_type_token_id)
      value in
  {
    order_activity_match_side_maker = obj#oleft_maker ;
    order_activity_match_side_hash = obj#oleft_hash ;
    order_activity_match_side_asset = asset ;
    order_activity_match_side_type = mk_side_type asset ;
  }, obj#oleft_make_asset_decimals

let mk_right_side obj value =
  let|$ asset = mk_asset
      obj#oright_make_asset_type_class
      obj#oright_make_asset_type_contract
      (Option.map Z.of_string obj#oright_make_asset_type_token_id)
      value in
  {
    order_activity_match_side_maker = obj#oright_maker ;
    order_activity_match_side_hash = obj#oright_hash ;
    order_activity_match_side_asset = asset ;
    order_activity_match_side_type = mk_side_type asset ;
  }, obj#oright_make_asset_decimals

let mk_order_activity_match ~dbh obj =
  let|> r =
    [%pgsql.object dbh
        "select fill_make_value, fill_take_value \
         from order_match where transaction = $?{obj#transaction}"] in
  let left_value, right_value = match r with
    | Ok [ r ] ->
      if r#fill_make_value = Z.zero || r#fill_take_value = Z.zero then
        obj#oleft_make_asset_value, obj#oright_make_asset_value
      else
        let price1 = Z.div r#fill_make_value r#fill_take_value in
        let price2 = Z.div r#fill_take_value r#fill_make_value in
        if price1 = Z.div obj#oleft_make_asset_value obj#oleft_take_asset_value ||
           price1 = Z.div obj#oright_take_asset_value obj#oright_make_asset_value then
          r#fill_make_value, r#fill_take_value
        else
        if price2 = Z.div obj#oleft_take_asset_value obj#oleft_make_asset_value ||
           price2 = Z.div obj#oright_take_asset_value obj#oright_make_asset_value then
          r#fill_take_value, r#fill_make_value
        else obj#oleft_make_asset_value, obj#oright_make_asset_value
    | _ -> obj#oleft_make_asset_value, obj#oright_make_asset_value
  in
  let$ left, left_decimals = mk_left_side obj left_value in
  let$ right, right_decimals = mk_right_side obj right_value in
  let|$ price =
    nft_price
      left.order_activity_match_side_asset
      right.order_activity_match_side_asset in
  OrderActivityMatch
    {
      order_activity_match_left = left ;
      order_activity_match_right = right ;
      order_activity_match_price = price ;
      order_activity_match_type =
        if Z.of_string obj#oleft_salt <> Z.zero then
          begin match left.order_activity_match_side_asset.asset_type with
            | ATNFT _ | ATMT _ -> MTSELL
            | _ -> MTACCEPT_BID
          end
        else if Z.of_string obj#oright_salt <> Z.zero then
          begin match right.order_activity_match_side_asset.asset_type with
            | ATNFT _ | ATMT _ -> MTSELL
            | _ -> MTACCEPT_BID
          end
        else MTSELL ;
      order_activity_match_transaction_hash = Option.get obj#transaction ;
      order_activity_match_block_hash = Option.get obj#block ;
      order_activity_match_block_number = Int64.of_int32 @@ Option.get obj#level ;
      order_activity_match_log_index = 0 ;
    }, (left_decimals, right_decimals)

let mk_order_activity_cancel_list obj =
  let$ make = mk_asset
      obj#make_asset_type_class
      obj#make_asset_type_contract
      (Option.map Z.of_string obj#make_asset_type_token_id)
      obj#make_asset_value in
  let|$ take = mk_asset
      obj#take_asset_type_class
      obj#take_asset_type_contract
      (Option.map Z.of_string obj#take_asset_type_token_id)
      obj#take_asset_value in
  let bid = {
    order_activity_cancel_bid_hash = obj#o_hash;
    order_activity_cancel_bid_maker = obj#maker ;
    order_activity_cancel_bid_make = make.asset_type ;
    order_activity_cancel_bid_take = take.asset_type ;
    order_activity_cancel_bid_transaction_hash = Option.get obj#transaction ;
    order_activity_cancel_bid_block_hash = Option.get obj#block ;
    order_activity_cancel_bid_block_number = Int64.of_int32 @@ Option.get obj#level ;
    order_activity_cancel_bid_log_index = 0
  } in
  let decs = (obj#make_asset_decimals, obj#take_asset_decimals) in
  OrderActivityCancelList bid, decs

let mk_order_activity_cancel_bid obj =
  let$ make = mk_asset
      obj#make_asset_type_class
      obj#make_asset_type_contract
      (Option.map Z.of_string obj#make_asset_type_token_id)
      obj#make_asset_value in
  let$ take = mk_asset
      obj#take_asset_type_class
      obj#take_asset_type_contract
      (Option.map Z.of_string obj#take_asset_type_token_id)
      obj#take_asset_value in
  let bid = {
    order_activity_cancel_bid_hash = obj#o_hash;
    order_activity_cancel_bid_maker = obj#maker ;
    order_activity_cancel_bid_make = make.asset_type ;
    order_activity_cancel_bid_take = take.asset_type ;
    order_activity_cancel_bid_transaction_hash = Option.get obj#transaction ;
    order_activity_cancel_bid_block_hash = Option.get obj#block ;
    order_activity_cancel_bid_block_number = Int64.of_int32 @@ Option.get obj#level ;
    order_activity_cancel_bid_log_index = 0
  } in
  let decs = (obj#make_asset_decimals, obj#take_asset_decimals) in
  Ok (OrderActivityCancelBid bid, decs)

let mk_order_activity ~dbh obj =
  let|>? act, decs =
    match obj#order_activity_type with
    | "list" ->
      let>? act, decs = mk_order_activity_bid ~dbh obj in
      Lwt.return_ok (OrderActivityList act, decs)
    | "bid" ->
      let>? act, decs = mk_order_activity_bid ~dbh obj in
      Lwt.return_ok (OrderActivityBid act, decs)
    | "match" ->
      let>? act, decs = mk_order_activity_match ~dbh obj in
      Lwt.return_ok (act, decs)
    | "cancel_l" -> Lwt.return @@ mk_order_activity_cancel_list obj
    | "cancel_b" -> Lwt.return @@ mk_order_activity_cancel_bid obj
    | _ as t -> Lwt.return_error (`hook_error ("unknown order activity type " ^ t)) in
  {
    order_act_id = obj#id ;
    order_act_date = obj#date ;
    order_act_source = "RARIBLE";
    order_act_type = act ;
  }, decs

let get_order_origin_fees ?dbh hash_key =
  use dbh @@ fun dbh ->
  let|>? l = [%pgsql dbh
      "select account, value from origin_fees where hash = $hash_key"] in
  to_parts l

let get_order_payouts ?dbh hash_key =
  use dbh @@ fun dbh ->
  let|>? l = [%pgsql dbh
      "select account, value from payouts where hash = $hash_key"] in
  to_parts l

let get_fill hash rows =
  List.fold_left (fun acc_fill r ->
      let fill =
        match r#hash_left, r#hash_right with
        | hl, _hr when hl = hash -> r#fill_take_value
        | _hl, hr when hr = hash -> r#fill_make_value
        | _ -> Z.zero in
      Z.add acc_fill fill)
    Z.zero rows

let get_cancelled hash l =
  List.exists (fun r -> r#cancel = Some hash) l

let get_decimals ?dbh ?(do_error=false) = function
  | ATXTZ -> Lwt.return_ok (Some 6l)
  | ATNFT _ | ATMT _ -> Lwt.return_ok None
  | ATFT {contract; token_id} ->
    let no_token_id = Option.is_none token_id in
    use dbh @@ fun dbh ->
    let>? l = [%pgsql dbh
        "select decimals from ft_contracts where address = $contract \
         and ($no_token_id or token_id = $?{Option.map Z.to_string token_id})"] in
    match l with
    | [] | _ :: _ :: _ ->
      if do_error then Lwt.return_error (`hook_error "ft_contract_not_found")
      else Lwt.return_ok None
    | [ i ] -> Lwt.return_ok (Some i)

let get_ft_balance ?dbh ?token_id ?(do_error=false) ~contract account =
  let>? decimals = get_decimals ?dbh ~do_error (ATFT {contract; token_id}) in
  let no_token_id = Option.is_none token_id in
  use dbh @@ fun dbh ->
  let>? l = [%pgsql dbh
      "select balance from token_balance_updates where contract = $contract \
       and account = $account and main and ($no_token_id or token_id = $?{Option.map Z.to_string token_id}) \
       order by level desc limit 1"] in
  match l with
  | [] | _ :: _ :: _ | [ None ] -> Lwt.return_ok (Z.zero, None)
  | [ Some b ] -> Lwt.return_ok (b, decimals)

let get_make_balance ?dbh make owner = match make.asset_type with
  | ATXTZ -> Lwt.return_ok Z.zero
  | ATFT {contract; token_id} ->
    let|>? b, _dec = get_ft_balance ?dbh ?token_id ~contract owner in
    b
  | ATNFT { asset_contract ; asset_token_id } | ATMT { asset_contract ; asset_token_id } ->
    use dbh @@ fun dbh ->
    let|>? l = [%pgsql.object dbh
        "select case when balance is not null then balance else amount end from tokens where \
         contract = $asset_contract and token_id = ${Z.to_string asset_token_id} and \
         owner = $owner"] in
    match l with
    | [ r ] -> Option.value ~default:Z.zero r#amount
    | _ -> Z.zero

let calculate_make_stock make take data fill make_balance cancelled =
  (* TODO : protocol commission *)
  let protocol_commission = Z.zero in
  let fee_side = get_fee_side make take in
  calculate_make_stock
    make.asset_value take.asset_value fill data make_balance
    protocol_commission fee_side cancelled

let get_order_updates ?dbh obj make maker take data =
  let hash = obj#hash in
  use dbh @@ fun dbh ->
  let>? cancel = [%pgsql.object dbh
      "select * from order_cancel where (cancel = $hash) order by tsp"] in
  match cancel with
  | cancel :: _ ->
    Lwt.return_ok (Z.zero, Z.zero, true, cancel#tsp, Z.zero)
  | _ ->
    let>? matches = [%pgsql.object dbh
        "select * from order_match \
         where (hash_left = $hash or hash_right = $hash) order by tsp"] in
    let fill = get_fill hash matches in
    let|>? make_balance = get_make_balance ~dbh make maker in
    let cancelled = false in
    let make_stock =
      calculate_make_stock make take data fill make_balance cancelled in
    let last_update_at = match matches with hd :: _ -> hd#tsp | [] -> obj#created_at in
    fill, make_stock, cancelled, last_update_at, make_balance

let calculate_status fill take make_stock cancelled =
  if cancelled then OCANCELLED
  else if make_stock > Z.zero then OACTIVE
  else if fill = take.asset_value then OFILLED
  else OINACTIVE

let mk_order ?dbh order_obj =
  let>? order_elt_make = Lwt.return @@ mk_asset
      order_obj#make_asset_type_class
      order_obj#make_asset_type_contract
      (Option.map Z.of_string order_obj#make_asset_type_token_id)
      order_obj#make_asset_value in
  let>? order_elt_take = Lwt.return @@ mk_asset
      order_obj#take_asset_type_class
      order_obj#take_asset_type_contract
      (Option.map Z.of_string order_obj#take_asset_type_token_id)
      order_obj#take_asset_value in
  let>? price_history = get_order_price_history ?dbh order_obj#hash in
  let>? origin_fees = get_order_origin_fees ?dbh order_obj#hash in
  let>? payouts = get_order_payouts ?dbh order_obj#hash in
  let data = {
    order_rarible_v2_data_v1_data_type = "V1" ;
    order_rarible_v2_data_v1_payouts = payouts ;
    order_rarible_v2_data_v1_origin_fees = origin_fees ;
  } in
  let>? (fill, make_stock, cancelled, last_update_at, make_balance) =
    get_order_updates ?dbh order_obj order_elt_make order_obj#maker order_elt_take data in
  let status = calculate_status fill order_elt_take make_stock cancelled in
  let order_elt = {
    order_elt_maker = order_obj#maker;
    order_elt_maker_edpk = order_obj#maker_edpk ;
    order_elt_taker = order_obj#taker;
    order_elt_taker_edpk = order_obj#taker_edpk ;
    order_elt_make ;
    order_elt_take ;
    order_elt_fill = fill ;
    order_elt_start = order_obj#start_date ;
    order_elt_end = order_obj#end_date ;
    order_elt_make_stock = make_stock ;
    order_elt_cancelled = cancelled ;
    order_elt_salt = Z.of_string order_obj#salt ;
    order_elt_signature = order_obj#signature ;
    order_elt_created_at = order_obj#created_at ;
    order_elt_last_update_at = last_update_at ;
    order_elt_hash = order_obj#hash ;
    order_elt_make_balance = Some make_balance ;
    order_elt_price_history = price_history ;
    order_elt_status = status
  } in
  let rarible_v2_order = {
    order_elt = order_elt ;
    order_data = data ;
    order_type = ();
  } in
  Lwt.return_ok (rarible_v2_order, (order_obj#make_asset_decimals, order_obj#take_asset_decimals))

let get_order ?dbh hash_key =
  Printf.eprintf "get_order %s\n%!" hash_key ;
  use dbh @@ fun dbh ->
  let>? l = [%pgsql.object dbh
      "select maker, taker, maker_edpk, taker_edpk, \
       make_asset_type_class, make_asset_type_contract, make_asset_type_token_id, \
       make_asset_value, make_asset_decimals, \
       take_asset_type_class, take_asset_type_contract, take_asset_type_token_id, \
       take_asset_value, take_asset_decimals, \
       start_date, end_date, salt, signature, created_at, hash \
       from orders where hash = $hash_key"] in
  match l with
  | [] -> Lwt.return_ok None
  | _ ->
    let>? r = one l in
    let>? order, decs = mk_order ~dbh r in
    Lwt.return_ok @@ Some (order, decs)

let check_address a =
  match Tzfunc.Crypto.Pkh.b58dec a with
  | Ok _ -> true
  | Error _ ->
    try
      let _ = Tzfunc.Crypto.(Base58.decode ~prefix:Prefix.contract_public_key_hash a) in
      true
    with _ -> false

let filter_creators =
  List.filter (fun {part_account; _} -> check_address part_account)

let token_metadata_enc = EzEncoding.ignore_enc tzip21_token_metadata_enc

let get_nft_item_creators dbh ~contract ~token_id =
  let|>? r =
    [%pgsql.object dbh
        "select account, value FROM tzip21_creators where main and \
         contract = $contract and token_id = ${Z.to_string token_id}"] in
  filter_creators @@
  List.map (fun r -> { part_account = r#account ; part_value = r#value} ) r

let get_nft_item_owners dbh ~contract ~token_id =
  [%pgsql dbh
      "select owner FROM tokens where \
       (balance is not null and balance > 0 or amount > 0) and \
       contract = $contract and token_id = ${Z.to_string token_id}"]

let mk_nft_ownership obj =
  let contract = obj#contract in
  let token_id = Z.of_string obj#token_id in
  let creators = List.filter_map (function
      | None -> None
      | Some json -> Some (EzEncoding.destruct part_enc json)) obj#creators in
  (* TODO : last <> mint date ? *)
  {
    nft_ownership_id = Option.get obj#id ;
    nft_ownership_contract = contract ;
    nft_ownership_token_id = token_id ;
    nft_ownership_owner = obj#owner ;
    nft_ownership_creators = creators;
    nft_ownership_value = Option.value ~default:obj#amount obj#balance ;
    nft_ownership_lazy_value = Z.zero ;
    nft_ownership_date = obj#last ;
    nft_ownership_created_at = obj#tsp ;
  }

let get_nft_ownership_by_id ?dbh ?(old=false) contract token_id owner =
  (* TODO : OWNERSHIP NOT FOUND *)
  Format.eprintf "get_nft_ownership_by_id %s %s %s@." contract (Z.to_string token_id) owner ;
  use dbh @@ fun dbh ->
  let>? l = [%pgsql.object dbh
      "select concat(i.contract, ':', i.token_id, ':', t.owner) as id, \
       i.contract, i.token_id, owner, last, tsp, amount, balance, supply, metadata, creators \
       from tokens t inner join token_info i on i.contract = t.contract and i.token_id = t.token_id \
       where main and i.contract = $contract and i.token_id = ${Z.to_string token_id} and \
       owner = $owner and (balance is not null and balance > 0 or amount > 0 or $old)"] in
  match l with
  | [] -> Lwt.return_error (`hook_error "ownership not found")
  | _ ->
    let>? obj = one l in
    let nft_ownership = mk_nft_ownership obj in
    Lwt.return_ok nft_ownership

(* let get_nft_item_royalties ?dbh id =
 *   use dbh @@ fun dbh ->
 *   let|>? l =
 *     [%pgsql dbh
 *         "select account, value FROM royalties where id = $id"] in
 *   to_parts l *)

(* let mk_item_transfer it_obj =
 *   Lwt.return_ok {
 *     item_transfer_type_ = "TRANSFER";
 *     item_transfer_owner = it_obj#owner ;
 *     item_transfer_value = Int64.to_string it_obj#value;
 *     item_transfer_from = it_obj#transfer_from;
 *   } *)

(* let mk_media_meta obj =
 *   Lwt.return_ok
 *     (MediaSizeOriginal {
 *         meta_type = obj#media_type ;
 *         meta_width = Option.map Int32.to_int obj#width ;
 *         meta_height = Option.map Int32.to_int obj#height ;
 *       })
 *
 * let mk_nft_media obj =
 *   let|>? nft_media_meta = mk_media_meta obj in
 *   {
 *     nft_media_url = MediaSizeOriginal obj#url ;
 *     nft_media_meta ;
 *   } *)

(* let mk_item_attribute obj =
 *   Lwt.return_ok {
 *     nft_item_attribute_key = obj#key ;
 *     nft_item_attribute_value = obj#value ;
 *   } *)

let mk_tzip21_format r =
  let dim =
    match r#dimensions_value, r#dimensions_unit with
    | Some dv, Some du -> Some { format_dim_value = dv ; format_dim_unit = du }
    | _, _ -> None in
  let data_rate =
    match r#data_rate_value, r#data_rate_unit with
    | Some dv, Some du -> Some { format_dim_value = dv ; format_dim_unit = du }
    | _, _ -> None in
  {
    format_uri = r#uri ;
    format_hash = r#hash ;
    format_mime_type = r#mime_type ;
    format_file_size = Option.bind r#file_size (fun i -> Some (Int32.to_int i)) ;
    format_file_name = r#file_name ;
    format_duration = r#duration ;
    format_dimensions = dim ;
    format_data_rate = data_rate }

let get_metadata_formats dbh ~contract ~token_id =
  let>? l =
    [%pgsql.object dbh
        "select uri, hash, mime_type, file_size, file_name, duration, \
         dimensions_value, dimensions_unit, data_rate_value, data_rate_unit \
         from tzip21_formats where \
         contract = $contract and token_id = ${Z.to_string token_id} and main"] in
  match l with
  | [] -> Lwt.return_ok None
  | _ ->
    let formats = List.map (fun r -> mk_tzip21_format r) l in
    Lwt.return_ok (Some formats)

let mk_tzip21_attribute r =
  Lwt.return_ok @@ {
    attribute_name = r#name ;
    attribute_type = r#typ ;
    attribute_value = Ezjsonm.value_from_string r#value ;
  }

let get_metadata_attributes dbh ~contract ~token_id =
  let>? l =
    [%pgsql.object dbh
        "select name, value, type as typ from tzip21_attributes where \
         contract = $contract and token_id = ${Z.to_string token_id} and main"] in
  match l with
  | [] -> Lwt.return_ok None
  | _ ->
    map_rp (fun r -> mk_tzip21_attribute r) l >>=? fun attributes ->
    Lwt.return_ok (Some attributes)

let mk_nft_item_meta dbh ~contract ~token_id =
  let>? creators = get_nft_item_creators dbh ~contract ~token_id in
  let>? formats = get_metadata_formats dbh ~contract ~token_id in
  let>? attributes = get_metadata_attributes dbh ~contract ~token_id in
  let>? l = [%pgsql.object dbh
      "select contract, token_id, block, level, tsp, \
       name, symbol, decimals, artifact_uri, display_uri, thumbnail_uri, \
       description, minter, is_boolean_amount, tags, contributors, \
       publishers, date, block_level, genres, language, rights, right_uri, \
       is_transferable, should_prefer_symbol from tzip21_metadata where \
       contract = $contract and token_id = ${Z.to_string token_id} and main"] in
  match l with
  | [] ->
    Format.eprintf "metadata not found for %s:%s@." contract (Z.to_string token_id) ;
    Lwt.return_ok None
  | r :: _ ->
    let tags =
      Option.bind r#tags (fun l -> Some (List.filter_map (fun x -> x) l)) in
    let contributors =
      Option.bind r#contributors (fun l -> Some (List.filter_map (fun x -> x) l)) in
    let publishers =
      Option.bind r#publishers (fun l -> Some (List.filter_map (fun x -> x) l)) in
    let genres =
      Option.bind r#genres (fun l -> Some (List.filter_map (fun x -> x) l)) in
    let block_level =
      Option.bind r#block_level (fun i -> Option.some @@ Int32.to_int i) in
    Lwt.return_ok @@ Option.some {
      tzip21_tm_name = r#name ;
      tzip21_tm_symbol = r#symbol ;
      tzip21_tm_decimals = Option.bind r#decimals (fun i -> Some (Int32.to_int i)) ;
      tzip21_tm_artifact_uri = r#artifact_uri ;
      tzip21_tm_display_uri = r#display_uri ;
      tzip21_tm_thumbnail_uri = r#thumbnail_uri ;
      tzip21_tm_description = r#description ;
      tzip21_tm_minter = r#minter ;
      tzip21_tm_creators = Some (CParts creators) ;
      tzip21_tm_is_boolean_amount = r#is_boolean_amount ;
      tzip21_tm_formats = formats ;
      tzip21_tm_attributes = attributes ;
      tzip21_tm_tags = tags ;
      tzip21_tm_contributors = contributors ;
      tzip21_tm_publishers = publishers ;
      tzip21_tm_date = r#date ;
      tzip21_tm_block_level = block_level ;
      tzip21_tm_genres = genres ;
      tzip21_tm_language = r#language ;
      tzip21_tm_rights = r#rights ;
      tzip21_tm_right_uri = r#right_uri ;
      tzip21_tm_is_transferable = r#is_transferable ;
      tzip21_tm_should_prefer_symbol = r#should_prefer_symbol ;
    }

let mk_nft_item dbh ?include_meta obj =
  match String.split_on_char ':' obj#id with
  | contract :: token_id :: [] ->
    let token_id = Z.of_string token_id in
    let creators = List.filter_map (function
        | None -> None
        | Some json -> Some (EzEncoding.destruct part_enc json)) obj#creators in
    let>? meta = match include_meta with
      | Some true -> mk_nft_item_meta dbh ~contract ~token_id
      | _ -> Lwt.return_ok None in
    Lwt.return_ok {
      nft_item_id = obj#id ;
      nft_item_contract = contract ;
      nft_item_token_id = token_id ;
      nft_item_creators = creators ;
      nft_item_supply = obj#supply ;
      nft_item_lazy_supply = Z.zero ;
      nft_item_owners = List.filter_map (fun x -> x) @@ Option.value ~default:[] obj#owners ;
      nft_item_royalties = EzEncoding.destruct Json_encoding.(list part_enc) obj#royalties ;
      nft_item_date = obj#last ;
      nft_item_minted_at = obj#tsp ;
      nft_item_deleted = obj#supply = Z.zero ;
      nft_item_meta = rarible_meta_of_tzip21_meta meta ;
    }
  | _ ->
    Lwt.return_error (`hook_error "can't split id")

let get_nft_item_by_id ?dbh ?include_meta contract token_id =
  Format.eprintf "get_nft_item_by_id %s %s %s@."
    contract
    (Z.to_string token_id)
    (match include_meta with None -> "None" | Some s -> string_of_bool s) ;
  use dbh @@ fun dbh ->
  let>? l = [%pgsql.object dbh
      "select i.id, i.contract, i.token_id, \
       last, supply, metadata, tsp, creators, royalties, \
       array_agg(case when (balance is not null and balance <> 0 or amount <> 0) then owner end) as owners \
       from tokens t \
       inner join token_info i on i.contract = t.contract and i.token_id = t.token_id \
       where main and i.contract = $contract and i.token_id = ${Z.to_string token_id} \
       group by (i.id, i.contract, i.token_id)"] in
  match l with
  | obj :: _ ->
    let>? nft_item = mk_nft_item dbh ?include_meta obj in
    Lwt.return_ok nft_item
  | [] -> Lwt.return_error (`hook_error "item not found")

let mk_nft_collection_name_symbol r =
  match r#name with
  | None -> "Unnamed Collection", r#symbol
  | Some n -> n, r#symbol

let mk_nft_collection obj =
  let name, symbol = mk_nft_collection_name_symbol obj in
  let$ nft_collection_type = match obj#ledger_key, obj#ledger_value with
    | None, _ | _, None -> Error (`hook_error "unknown_token_kind")
    | Some k, Some v -> match
        EzEncoding.destruct micheline_type_short_enc k,
        EzEncoding.destruct micheline_type_short_enc v with
    | `nat, `address -> Ok CTNFT
    | `tuple [`nat; `address], `nat
    | `tuple [`address; `nat], `nat -> Ok CTMT
    | _ -> Error (`hook_error "unknown_token_kind") in
  let nft_collection_minters = match obj#minters, obj#owner with
    | None, None -> None
    | None, Some owner -> Some [ owner ]
    | Some a, owner -> Some (List.filter_map (fun x -> x) (owner :: a)) in
  let nft_collection_features = match obj#kind with
    | "rarible" -> [ NCFSECONDARY_SALE_FEES ; NCFBURN ]
    | "ubi" -> []
    | "fa2" -> []
    | _ ->
      Format.eprintf "warning: can't get features for unknow kind %s@." obj#kind;
      [] in
  Ok {
    nft_collection_id = obj#address ;
    nft_collection_owner = obj#owner ;
    nft_collection_type ;
    nft_collection_name = name ;
    nft_collection_symbol = symbol ;
    nft_collection_features ;
    nft_collection_supports_lazy_mint = false ;
    nft_collection_minters
  }

let get_nft_collection_by_id ?dbh collection =
  Format.eprintf "get_nft_collection_by_id %s@." collection ;
  use dbh @@ fun dbh ->
  let>? l = [%pgsql.object dbh
      "select address, owner, metadata, name, symbol, kind, ledger_key, \
       ledger_value, minters \
       from contracts where address = $collection and main and \
       ((ledger_key = '\"nat\"' and ledger_value = '\"address\"') \
       or (ledger_key = '[ \"address\", \"nat\"]' and ledger_value = '\"nat\"') \
       or (ledger_key = '[\"nat\", \"address\"]' and ledger_value = '\"nat\"'))"] in
  match l with
  | [] -> Lwt.return_error (`hook_error "collection not found")
  | obj :: _ ->
    Lwt.return @@ mk_nft_collection obj

let produce_order_event_hash dbh hash =
  match !Rarible_kafka.kafka_config with
  | None -> Lwt.return_ok ()
  | Some _ ->
    let>? order = get_order ~dbh hash in
    begin
      match order with
      | Some (order, decs) ->
        Rarible_kafka.produce_order_event ~decs (mk_order_event order)
      | None -> Lwt.return ()
    end >>= fun () ->
    Lwt.return_ok ()

let produce_order_event_item dbh old_owner contract token_id =
  match !Rarible_kafka.kafka_config with
  | None -> Lwt.return_ok ()
  | Some _ ->
    let>? l =
      [%pgsql.object dbh
          "select hash from orders \
           where make_asset_type_contract = $contract and \
           make_asset_type_token_id = ${Z.to_string token_id} and \
           maker = $old_owner"] in
    iter_rp (fun r ->
        let>? order = get_order ~dbh r#hash in
        match order with
        | None -> Lwt.return_ok ()
        | Some (order, decs) ->
          match order.order_elt.order_elt_status with
          | OINACTIVE | OACTIVE ->
            Rarible_kafka.produce_order_event ~decs (mk_order_event order) >>= fun () ->
            Lwt.return_ok ()
          | _ -> Lwt.return_ok ())
      l

let produce_nft_item_event dbh contract token_id =
  match !Rarible_kafka.kafka_config with
  | None -> Lwt.return_ok ()
  | Some _ ->
    let> item = get_nft_item_by_id ~dbh ~include_meta:true contract token_id in
    match item with
    | Ok item ->
      if item.nft_item_supply = Z.zero then
        Rarible_kafka.produce_item_event (mk_delete_item_event item)
        >>= fun () ->
        Lwt.return_ok ()
      else
        Rarible_kafka.produce_item_event (mk_update_item_event item)
        >>= fun () ->
        Lwt.return_ok ()
    | Error err ->
      Printf.eprintf "couldn't produce nft event %S\n%!" @@ Crp.string_of_error err ;
      Lwt.return_ok ()

let produce_nft_collection_event c =
  match !Rarible_kafka.kafka_config with
  | None -> Lwt.return_ok ()
  | Some _ ->
    Rarible_kafka.produce_collection_event (mk_nft_collection_event c)
    >>= fun () ->
    Lwt.return_ok ()

let produce_update_collection_event dbh contract =
  match !Rarible_kafka.kafka_config with
  | None -> Lwt.return_ok ()
  | Some _ ->
    let> c = get_nft_collection_by_id ~dbh contract in
    match c with
    | Ok c -> produce_nft_collection_event c
    | Error e ->
      Printf.eprintf "couldn't produce collection event %S\n%!" @@ Crp.string_of_error e ;
      Lwt.return_ok ()

let produce_nft_ownership_update_event os =
  if os.nft_ownership_value = Z.zero then
    Rarible_kafka.produce_ownership_event (mk_delete_ownership_event os)
  else
    Rarible_kafka.produce_ownership_event (mk_update_ownership_event os)

let produce_nft_ownership_event dbh contract token_id owner =
  match !Rarible_kafka.kafka_config with
  | None -> Lwt.return_ok ()
  | Some _ ->
    begin
      get_nft_ownership_by_id
        ~old:true ~dbh contract token_id owner >>= function
      | Ok os -> produce_nft_ownership_update_event os
      | Error err ->
        Printf.eprintf "Couldn't produce ownership event %S\n%!" @@ Crp.string_of_error err ;
        Lwt.return_unit
    end >>= fun () ->
    Lwt.return_ok ()

let insert_fake ?dbh address =
  use dbh @@ fun dbh ->
  [%pgsql dbh
      "insert into contracts(kind, address, owner, block, level, tsp, \
       last_block, last_level, last, main) \
       values('', $address, '', '', 0, now(), '', 0, now(), true) \
       on conflict do nothing"]

let get_balance ?dbh ~contract ~owner token_id =
  use dbh @@ fun dbh ->
  let|>? l =
    [%pgsql dbh
        "select case when balance is not null then balance else amount end \
         from tokens where contract = $contract and \
         owner = $owner and token_id = $token_id"] in
  match l with
  | [ amount ] -> amount
  | _ -> None

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

let mk_nft_activity_elt obj = {
  nft_activity_owner = obj#owner ;
  nft_activity_contract = obj#contract ;
  nft_activity_token_id = Z.of_string obj#token_id ;
  nft_activity_value = obj#amount ;
  nft_activity_transaction_hash = obj#transaction ;
  nft_activity_block_hash = obj#block ;
  nft_activity_block_number = Int64.of_int32 obj#level ;
}

let mk_nft_activity obj =
  let>? act =
    match obj#activity_type with
    | "mint" ->
      let nft_activity_elt = mk_nft_activity_elt obj in
      Lwt.return_ok @@ NftActivityMint nft_activity_elt
    | "burn" ->
      let nft_activity_elt = mk_nft_activity_elt obj in
      Lwt.return_ok @@ NftActivityBurn nft_activity_elt
    | "transfer" ->
      let elt = mk_nft_activity_elt obj in
      let from = Option.get obj#tr_from in
      Lwt.return_ok @@ NftActivityTransfer {elt; from}
    | _ as t -> Lwt.return_error (`hook_error ("unknown nft activity type " ^ t)) in
  let id = Printf.sprintf "%s_%ld" obj#block obj#index in
  Lwt.return_ok @@ {
    nft_act_id = id ;
    nft_act_date = obj#date ;
    nft_act_source = "RARIBLE";
    nft_act_type = act ;
  }

let get_metadata meta =
  try
    let tzip21_meta = EzEncoding.destruct token_metadata_enc meta in
    tzip21_meta.tzip21_tm_name,
    Option.bind tzip21_meta.tzip21_tm_creators
      (fun c -> Some (EzEncoding.construct ext_creators_enc c)),
    tzip21_meta.tzip21_tm_description,
    Option.bind tzip21_meta.tzip21_tm_attributes
      (fun a -> Some (EzEncoding.construct tzip21_attributes_enc a)),
    tzip21_meta.tzip21_tm_display_uri
  with _ ->
    None, None, None, None, None

let get_or_timeout ?(timeout=30.) ?msg url =
  let timeout = Lwt_unix.sleep timeout >>= fun () -> Lwt.return_error (-1, Some "timeout") in
  Lwt.pick [ timeout ; EzReq_lwt.get ?msg url ]

let get_metadata_uri s =
  let proto = try String.sub s 0 6 with _ -> "" in
  if proto = "https:" || proto = "http:/" then Some s
  else if proto = "ipfs:/" then Some s
  else None

let get_metadata_json ?(source="https://rarible.mypinata.cloud/") ?(quiet=false) ?timeout meta =
  if not quiet then Format.eprintf "get_metadata_json %s@." meta ;
  let msg = if not quiet then Some "get_metadata_json" else None in
  (* 3 ways to recovers metadata :directly json, ipfs link and http(s) link *)
  try
    Lwt.return_ok (meta, EzEncoding.destruct token_metadata_enc meta, None)
  with _ ->
    begin
      let proto = try String.sub meta 0 6 with _ -> "" in
      if proto = "https:" || proto = "http:/" then
        let|>? json = get_or_timeout ?timeout (EzAPI.URL meta) in
        json, meta
      else if proto = "ipfs:/" then
        let url = try String.sub meta 7 ((String.length meta) - 7) with _ -> "" in
        let fs, url = try
            let may_fs = String.sub url 0 5 in
            if may_fs = "ipfs/" then
              "ipfs/", String.sub url 5 ((String.length meta) - 5)
            else if may_fs = "ipns/" then
              "ipns/", String.sub url 5 ((String.length meta) - 5)
            else "ipfs/", url
          with _ -> "", url in
        let uri = Printf.sprintf "%s%s%s" source fs url in
        let|>? json = get_or_timeout ?timeout ?msg (EzAPI.URL uri) in
        json, uri
      else Lwt.return_error (0, Some (Printf.sprintf "unknow scheme %S" proto))
    end >>= function
    | Ok (json, uri) ->
      begin try
          let metadata = EzEncoding.destruct token_metadata_enc json in
          Lwt.return_ok (json, metadata, Some uri)
        with exn ->
          Format.eprintf "%s@." @@ Printexc.to_string exn ;
          Lwt.return_error (-1, None)
      end
    | Error (c, str) -> Lwt.return_error (c, str)

let reset_mint_metadata_creators  dbh ~contract ~token_id ~metadata =
  match metadata.tzip21_tm_creators with
  | Some (CParts l) ->
    iter_rp (fun p ->
        try
          ignore @@
          Tzfunc.Crypto.(Base58.decode ~prefix:Prefix.contract_public_key_hash p.part_account) ;
          [%pgsql dbh
              "update tzip21_creators set \
               account = ${p.part_account}, \
               value = ${p.part_value} \
               where contract = $contract and token_id = $token_id"]
        with _ -> Lwt.return_ok ())
      l
  | Some (CAssoc l) ->
    iter_rp (fun (part_account, part_value) ->
        try
          ignore @@
          Tzfunc.Crypto.(Base58.decode ~prefix:Prefix.contract_public_key_hash part_account) ;
          [%pgsql dbh
              "update tzip21_creators set \
               account = $part_account, \
               value = $part_value \
               where contract = $contract and token_id = $token_id"]
        with _ -> Lwt.return_ok ())
      l
  | Some (CTZIP12 l) ->
    let len = List.length l in
    if len > 0 then
      let value = Int32.of_int (10000 / len) in
      iter_rp (fun part_account ->
          try
            ignore @@
            Tzfunc.Crypto.(Base58.decode ~prefix:Prefix.contract_public_key_hash part_account) ;
            [%pgsql dbh
                "update tzip21_creators set \
                 account = $part_account, \
                 value = $value \
                 where contract = $contract and token_id = $token_id"]
          with _ -> Lwt.return_ok ())
        l
    else Lwt.return_ok ()
  | Some (CNull l) ->
    let l = List.filter_map (fun x -> x) l in
    let len = List.length l in
    if len > 0 then
      let value = Int32.of_int (10000 / len) in
      iter_rp (fun part_account ->
          try
            ignore @@
            Tzfunc.Crypto.(Base58.decode ~prefix:Prefix.contract_public_key_hash part_account) ;
            [%pgsql dbh
                "update tzip21_creators set \
                 account = $part_account, \
                 value = $value \
                 where contract = $contract and token_id = $token_id"]
          with _ -> Lwt.return_ok ())
        l
    else Lwt.return_ok ()
  | None -> Lwt.return_ok ()

let insert_mint_metadata_creators dbh ?(forward=false) ~contract ~token_id ~block ~level ~tsp metadata =
  match metadata.tzip21_tm_creators with
  | Some (CParts l) ->
    iter_rp (fun p ->
        try
          ignore @@
          Tzfunc.Crypto.(Base58.decode ~prefix:Prefix.contract_public_key_hash p.part_account) ;
          [%pgsql dbh
              "insert into tzip21_creators(contract, token_id, block, level, \
               tsp, account, value, main) \
               values($contract, ${Z.to_string token_id}, $block, $level, $tsp, \
               ${p.part_account}, ${p.part_value}, $forward) \
               on conflict do nothing"]
        with _ -> Lwt.return_ok ())
      l
  | Some (CAssoc l) ->
    iter_rp (fun (part_account, part_value) ->
        try
          ignore @@
          Tzfunc.Crypto.(Base58.decode ~prefix:Prefix.contract_public_key_hash part_account) ;
          [%pgsql dbh
              "insert into tzip21_creators(contract, token_id, block, level, \
               tsp, account, value, main) \
               values($contract, ${Z.to_string token_id}, $block, $level, $tsp, $part_account, \
               $part_value, $forward) \
               on conflict do nothing"]
        with _ -> Lwt.return_ok ())
      l
  | Some (CTZIP12 l) ->
    let len = List.length l in
    if len > 0 then
      let value = Int32.of_int (10000 / len) in
      iter_rp (fun part_account ->
          try
            ignore @@
            Tzfunc.Crypto.(Base58.decode ~prefix:Prefix.contract_public_key_hash part_account) ;
            [%pgsql dbh
                "insert into tzip21_creators(contract, token_id, block, level, \
                 tsp, account, value, main) \
                 values($contract, ${Z.to_string token_id}, $block, $level, $tsp, \
                 $part_account, $value, $forward) \
                 on conflict do nothing"]
          with _ -> Lwt.return_ok ())
        l
    else Lwt.return_ok ()
  | Some (CNull l) ->
    let l = List.filter_map (fun x -> x) l in
    let len = List.length l in
    if len > 0 then
      let value = Int32.of_int (10000 / len) in
      iter_rp (fun part_account ->
          try
            ignore @@
            Tzfunc.Crypto.(Base58.decode ~prefix:Prefix.contract_public_key_hash part_account) ;
            [%pgsql dbh
                "insert into tzip21_creators(contract, token_id, block, level, \
                 tsp, account, value, main) \
                 values($contract, ${Z.to_string token_id}, $block, $level, $tsp, \
                 $part_account, $value, $forward) \
                 on conflict do nothing"]
          with _ -> Lwt.return_ok ())
        l
    else Lwt.return_ok ()

  | None -> Lwt.return_ok ()

let insert_mint_metadata_formats dbh ?(forward=false) ~contract ~token_id ~block ~level ~tsp metadata =
  match metadata.tzip21_tm_formats with
  | Some formats ->
  iter_rp (fun f ->
      let size = Option.bind f.format_file_size (fun i -> Some (Int32.of_int i))  in
      let dim_value, dim_unit =
        match f.format_dimensions with
        | None -> None, None
        | Some d -> Some d.format_dim_value, Some d.format_dim_unit in
      let dr_value, dr_unit =
        match f.format_data_rate with
        | None -> None, None
        | Some d -> Some d.format_dim_value, Some d.format_dim_unit in
      [%pgsql dbh
          "insert into tzip21_formats(contract, token_id, block, level, \
           tsp, uri, hash, mime_type, file_size, file_name, duration, \
           dimensions_value, dimensions_unit, data_rate_value, data_rate_unit, main) \
           values($contract, ${Z.to_string token_id}, $block, $level, $tsp, ${f.format_uri}, \
           $?{f.format_hash}, $?{f.format_mime_type}, $?size, \
           $?{f.format_file_name}, $?{f.format_duration}, $?dim_value, \
           $?dim_unit, $?dr_value, $?dr_unit, $forward) \
           on conflict (uri, contract, token_id) do update set \
           uri = ${f.format_uri}, hash = $?{f.format_hash}, \
           mime_type = $?{f.format_mime_type}, file_size = $?size, \
           file_name = $?{f.format_file_name}, \
           duration = $?{f.format_duration}, \
           dimensions_value = $?dim_value, \
           dimensions_unit = $?dim_unit, \
           data_rate_value = $?dr_value, \
           data_rate_unit = $?dr_unit, \
           main = $forward \
           where tzip21_formats.contract = $contract and \
           tzip21_formats.token_id = ${Z.to_string token_id} and \
           tzip21_formats.uri = ${f.format_uri}"])
    formats
  | None -> Lwt.return_ok ()

let insert_mint_metadata_attributes dbh ?(forward=false) ~contract ~token_id ~block ~level ~tsp metadata =
  match metadata.tzip21_tm_attributes with
  | Some attributes ->
    iter_rp (fun a ->
        let value = Ezjsonm.value_to_string a.attribute_value in
        [%pgsql dbh
            "insert into tzip21_attributes(contract, token_id, block, level, \
             tsp, name, value, type, main) \
             values($contract, ${Z.to_string token_id}, $block, $level, $tsp, \
             ${a.attribute_name}, $value, $?{a.attribute_type}, $forward) \
             on conflict (name, contract, token_id) do update set \
             value = $value, \
             type = $?{a.attribute_type}, \
             main = $forward \
             where tzip21_attributes.contract = $contract and \
             tzip21_attributes.token_id = ${Z.to_string token_id} and \
             tzip21_attributes.name = ${a.attribute_name}"])
      attributes
  | None -> Lwt.return_ok ()

let insert_mint_metadata dbh ?(forward=false) ~contract ~token_id ~block ~level ~tsp metadata =
  let>? () =
    insert_mint_metadata_creators dbh ~forward ~contract ~token_id ~block ~level ~tsp metadata in
  let>? () =
    insert_mint_metadata_formats dbh ~forward ~contract ~token_id ~block ~level ~tsp metadata in
  let>? () =
    insert_mint_metadata_attributes dbh ~forward ~contract ~token_id ~block ~level ~tsp metadata in
  let name = match metadata.tzip21_tm_name with
    | None -> None
    | Some n -> if Parameters.decode n then Some n else None in
  let symbol = match metadata.tzip21_tm_symbol with
    | None -> None
    | Some n -> if Parameters.decode n then Some n else None in
  let decimals = Option.bind metadata.tzip21_tm_decimals (fun i -> Some (Int32.of_int i))  in
  let artifact_uri = metadata.tzip21_tm_artifact_uri in
  let display_uri = metadata.tzip21_tm_display_uri in
  let thumbnail_uri = metadata.tzip21_tm_thumbnail_uri in
  let description = match metadata.tzip21_tm_description with
    | None -> None
    | Some n -> if Parameters.decode n then Some n else None in
  let minter = metadata.tzip21_tm_minter in
  let is_boolean_amount = metadata.tzip21_tm_is_boolean_amount in
   let tags = match metadata.tzip21_tm_tags with
     | None -> None
     | Some t -> Some (List.map (fun tag ->
         if Parameters.decode tag then
           Option.some tag
         else None) t) in
  let contributors = match metadata.tzip21_tm_contributors with
    | None -> None
    | Some c -> Some (List.map Option.some c) in
  let publishers = match metadata.tzip21_tm_publishers with
    | None -> None
    | Some p -> Some (List.map Option.some p) in
  let date = metadata.tzip21_tm_date in
  let block_level = match metadata.tzip21_tm_block_level with
    | None -> None
    | Some i -> Some (Int32.of_int i) in
  let genres = match metadata.tzip21_tm_genres with
    | None -> None
    | Some g -> Some (List.map Option.some g) in
  let language = metadata.tzip21_tm_language in
  let rights = metadata.tzip21_tm_rights in
  let right_uri = metadata.tzip21_tm_right_uri in
  let is_transferable = metadata.tzip21_tm_is_transferable in
  let should_prefer_symbol = metadata.tzip21_tm_should_prefer_symbol in
  [%pgsql dbh
      "insert into tzip21_metadata(contract, token_id, block, level, tsp, \
       name, symbol, decimals, artifact_uri, display_uri, thumbnail_uri, \
       description, minter, is_boolean_amount, tags, contributors, \
       publishers, date, block_level, genres, language, rights, right_uri, \
       is_transferable, should_prefer_symbol, main) \
       values ($contract, ${Z.to_string token_id}, $block, $level, $tsp, $?name, $?symbol, \
       $?decimals, $?artifact_uri, $?display_uri, $?thumbnail_uri, \
       $?description, $?minter, $?is_boolean_amount, $?tags, $?contributors, \
       $?publishers, $?date, $?block_level, $?genres, $?language, $?rights, \
       $?right_uri, $?is_transferable, $?should_prefer_symbol, $forward) \
       on conflict (contract, token_id) do update set \
       name = $?name, symbol = $?symbol, decimals = $?decimals, \
       artifact_uri = $?artifact_uri, display_uri = $?display_uri, \
       thumbnail_uri = $?thumbnail_uri, description = $?description, \
       minter = $?minter, is_boolean_amount = $?is_boolean_amount, \
       tags = $?tags, contributors = $?contributors, publishers = $?publishers, \
       date = $?date, block_level = $?block_level, genres = $?genres, \
       language = $?language, rights = $?rights, right_uri = $?right_uri, \
       is_transferable = $?is_transferable, \
       should_prefer_symbol = $?should_prefer_symbol, \
       main = $forward \
       where tzip21_metadata.contract = $contract and \
       tzip21_metadata.token_id = ${Z.to_string token_id}"]

let get_uri_pattern ~dbh contract =
  let>? l =
    [%pgsql dbh
        "select uri_pattern from contracts \
         where main and address = $contract order by level desc"] in
  match l with
  | [] -> Lwt.return_ok None
  | p :: _ -> Lwt.return_ok p

let insert_token_metadata ?forward ~dbh ~block ~level ~tsp ~contract (token_id, l) =
  let>? json, tzip21_meta, uri =
    match List.assoc_opt "" l with
    | Some meta ->
      begin
        get_metadata_json meta >>= function
        | Ok (_json, metadata, uri) ->
          Lwt.return_ok (EzEncoding.construct Rtypes.token_metadata_enc l, Some metadata, uri)
        | Error (code, str) ->
          Printf.eprintf "Cannot get metadata from url: %d %s\n%!"
            code (match str with None -> "None" | Some s -> s);
          Lwt.return_ok (EzEncoding.construct Rtypes.token_metadata_enc l, None, None)
      end
    | None ->
      Lwt.return_ok (EzEncoding.construct Rtypes.token_metadata_enc l, None, None) in
  let>? () = match tzip21_meta with
    | None -> Lwt.return_ok ()
    | Some metadata -> insert_mint_metadata dbh ?forward ~contract ~token_id ~block ~level ~tsp metadata in
  Lwt.return_ok (json, uri)

let insert_metadata_update ~dbh ~op ~contract ~token_id ?(forward=false) l =
  let token_meta = EzEncoding.construct Json_encoding.(assoc string) l in
  if not forward then
    [%pgsql dbh
        "insert into token_updates(transaction, index, block, level, tsp, \
         source, contract, token_id, metadata) \
         values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
         ${op.bo_tsp}, ${op.bo_op.source}, $contract, \
         ${Z.to_string token_id}, $token_meta) \
         on conflict do nothing"]
  else
    let block, level, tsp, transaction = op.bo_block, op.bo_level, op.bo_tsp, op.bo_hash in
    let id = Printf.sprintf "%s:%s" contract (Z.to_string token_id) in
    let uri = match List.assoc_opt "" l with
      | None -> None
      | Some s -> get_metadata_uri s in
    [%pgsql dbh
        "insert into token_info(id, contract, token_id, block, level, tsp, \
         last_block, last_level, last, transaction, metadata, metadata_uri, main) \
         values($id, $contract, ${Z.to_string token_id}, $block, $level, $tsp, \
         $block, $level, $tsp, $transaction, $token_meta, $?uri, true) \
         on conflict (id) do update \
         set metadata = $token_meta, metadata_uri = $?uri, \
         last_block = $block, \
         last_level = $level, last = $tsp \
         where token_info.contract = $contract and \
         token_info.token_id = ${Z.to_string token_id}"]

let insert_mint ~dbh ~op ~contract m =
  let block = op.bo_block in
  let level = op.bo_level in
  let tsp = op.bo_tsp in
  let>? token_id, owner, amount, royalties = match m with
    | NFTMint m ->
      Lwt.return_ok (m.fa2m_token_id, m.fa2m_owner, Z.one, m.fa2m_royalties)
    | MTMint m ->
      Lwt.return_ok (m.fa2m_token_id, m.fa2m_owner, m.fa2m_amount, m.fa2m_royalties)
    | UbiMint m ->
      let>? pattern = get_uri_pattern ~dbh contract in
      let meta = Option.fold ~none:[] ~some:(fun pattern -> ["", replace_token_id ~pattern (Z.to_string m.ubim_token_id)]) pattern in
      let|>? () = insert_metadata_update ~dbh ~op ~contract ~token_id:m.ubim_token_id meta in
      m.ubim_token_id, m.ubim_owner, Z.one, []
    | UbiMint2 m ->
      Lwt.return_ok (m.ubi2m_token_id, m.ubi2m_owner, m.ubi2m_amount, [])
    | HENMint m ->
      Lwt.return_ok (m.fa2m_token_id, m.fa2m_owner, m.fa2m_amount, m.fa2m_royalties) in
  let royalties = EzEncoding.construct Json_encoding.(list part_enc) royalties in
  let id = Printf.sprintf "%s:%s" contract (Z.to_string token_id) in
  let>? () =
    [%pgsql dbh
        "insert into token_info(id, contract, token_id, block, level, tsp, \
         last_block, last_level, last, transaction, royalties) \
         values($id, $contract, ${Z.to_string token_id}, $block, $level, $tsp, $block, $level, \
         $tsp, ${op.bo_hash}, $royalties) \
         on conflict do nothing"] in
  let mint = EzEncoding.construct mint_enc m in
  let>? () =
    [%pgsql dbh
        "insert into contract_updates(transaction, index, block, level, tsp, \
         contract, mint) \
         values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
         ${op.bo_tsp}, $contract, $mint) \
         on conflict do nothing"] in
  insert_nft_activity_mint dbh op contract token_id owner amount

let insert_metadatas ~dbh ~op ~contract ?(forward=false) l =
  iter_rp (function
      | `nat token_id, Some (`tuple [`nat _; `assoc l]) ->
        let meta = List.filter_map (function
            | `string k, `bytes v ->
              let s = (Tzfunc.Crypto.hex_to_raw v :> string) in
              if Parameters.decode s then Some (k, s)
              else None
            | _ -> None) l in
        insert_metadata_update ~dbh ~op ~contract ~token_id ~forward meta
      | _ -> Lwt.return_ok ()) l

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
  let|>? _ = fold_rp (fun transfer_index {tr_source; tr_txs} ->
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
        ) transfer_index tr_txs) 0l lt in
  ()

let insert_token_balances ~dbh ~op ~contract ?(ft=false) ?token_id ?(forward=false) balances =
  iter_rp (fun (k, v) ->
      let r = match k, v, ft with
        | `nat id, Some (`address a), false ->
          Some ("nft", id, Some a, Z.one)
        | `nat id, None, false ->
          Some ("nft", id, None, Z.zero)
        | `tuple [`nat id; `address a], Some (`nat bal), false
        | `tuple [`address a; `nat id], Some (`nat bal), false ->
          Some ("mt", id, Some a, bal)
        | `tuple [`nat id; `address a], None, false
        | `tuple [`address a; `nat id], None, false ->
          Some ("mt", id, Some a, Z.zero)
        | `tuple [`nat id; `address a], Some (`nat bal), true
        | `tuple [`address a; `nat id], Some (`nat bal), true ->
          begin match token_id with
            | Some tid when tid <> id -> None
            | _ -> Some ("ft_multi", id, Some a, bal)
          end
        | `tuple [`nat id; `address a], None, true
        | `tuple [`address a; `nat id], None, true ->
          begin match token_id with
            | Some tid when id <> tid -> None
            | _ -> Some ("ft_multi", id, Some a, Z.zero)
          end
        | `address a, Some (`nat bal), true ->
          Some ("ft", Z.minus_one, Some a, bal)
        | `address a, None, true ->
          Some ("ft", Z.minus_one, Some a, Z.zero)
        | `tuple [`address a; `nat id], Some (`tuple (`nat bal :: _)), true ->
          begin match token_id with
            | Some tid when id <> tid -> None
            | _ -> Some ("ft", id, Some a, bal)
          end
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
        match account, ft, forward with
        | _, true, _ -> Lwt.return_ok ()
        | None, _, true ->
          [%pgsql dbh
              "update tokens set amount = 0, balance = 0 \
               where contract = $contract and token_id = ${Z.to_string token_id}"]
        | Some a, _, false ->
          let oid = Printf.sprintf "%s:%s:%s" contract (Z.to_string token_id) a in
          [%pgsql dbh
              "insert into tokens(tid, oid, contract, token_id, owner, amount) \
               values($tid, $oid, $contract, ${Z.to_string token_id}, $a, 0) \
               on conflict do nothing"]
        | Some a, _, true ->
          let>? () =
            if balance <> Z.zero then
              let creators = [
                Some (EzEncoding.construct part_enc {
                    part_account=a; part_value = 10000l })
              ] in
              let id = Printf.sprintf "%s:%s" contract (Z.to_string token_id) in
              [%pgsql dbh
                  "insert into token_info(id, contract, token_id, transaction, block, \
                   level, tsp, main, last_block, last_level, last, creators, supply) \
                   values($id, $contract, ${Z.to_string token_id}, ${op.bo_hash}, \
                   ${op.bo_block}, ${op.bo_level}, ${op.bo_tsp}, true, \
                   ${op.bo_block}, ${op.bo_level}, ${op.bo_tsp}, $creators, $balance) \
                   on conflict do nothing"]
            else Lwt.return_ok () in
          let>? () =
            if kind = "nft" then
              [%pgsql dbh "update tokens set balance = 0, amount = 0 \
                           where contract = $contract and token_id = ${Z.to_string token_id}"]
            else Lwt.return_ok () in
          let oid = Printf.sprintf "%s:%s:%s" contract (Z.to_string token_id) a in
          [%pgsql dbh
              "insert into tokens(tid, oid, contract, token_id, owner, amount, balance) \
               values($tid, $oid, $contract, ${Z.to_string token_id}, $a, $balance, $balance) \
               on conflict (contract, token_id, owner) do update \
               set amount = $balance, balance = $balance \
               where tokens.contract = $contract and tokens.token_id = ${Z.to_string token_id}"]
        | _ -> Lwt.return_ok ()
    ) balances

let insert_update_operator ~dbh ~op ~contract lt =
  iter_rp (fun {op_owner; op_operator; op_token_id; op_add} ->
      [%pgsql dbh
          "insert into token_updates(transaction, index, block, level, tsp, \
           source, operator, add, contract, token_id) \
           values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
           ${op.bo_tsp}, $op_owner, $op_operator, $op_add, \
           $contract, ${Z.to_string op_token_id}) on conflict do nothing"]) lt

let insert_update_operator_all ~dbh ~op ~contract lt =
  let source = op.bo_op.source in
  iter_rp (fun (operator, add) ->
      [%pgsql dbh
          "insert into token_updates(transaction, index, block, level, tsp, \
           source, operator, add, contract) \
           values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
           ${op.bo_tsp}, $source, $operator, $add, $contract) on conflict do nothing"]) lt

let insert_metadata ~dbh ~op ~contract ~key ~value =
  [%pgsql dbh
      "insert into contract_updates(transaction, index, block, level, tsp, \
       contract, metadata_key, metadata_value) \
       values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
       ${op.bo_tsp}, $contract, $key, $value) \
       on conflict do nothing"]

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

let reset_nft_item_meta_by_id ?dbh contract token_id =
  Printf.eprintf "reset_nft_item_meta_by_id %s %s\n%!" contract (Z.to_string token_id) ;
  use dbh @@ fun dbh ->
  let>? l = [%pgsql dbh
      "select last_block, last_level, last, metadata, metadata_uri from token_info where \
       main and contract = $contract and token_id = ${Z.to_string token_id}"] in
  match l with
  | [] -> Lwt.return_ok ()
  | [ block, level, tsp, metadata, None ] ->
    begin
      Format.eprintf "ok@." ;
      let l = EzEncoding.destruct Rtypes.token_metadata_enc metadata in
      let>? _ =
        insert_token_metadata ~forward:true ~dbh ~block ~level ~tsp ~contract (token_id, l) in
      Lwt.return_ok ()
    end
  | [ block, level, tsp, _, Some uri ] ->
    begin
      try
        get_metadata_json uri >>= function
        | Ok (_json, metadata, _uri) ->
          insert_mint_metadata dbh ~forward:true ~contract ~token_id ~block ~level ~tsp metadata
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

let db_from_asset ?dbh asset =
  let>? decimals = get_decimals ?dbh asset.asset_type in
  match asset.asset_type with
  | ATXTZ ->
    Lwt.return_ok (string_of_asset_type asset.asset_type, None, None,
                   asset.asset_value, decimals)
  | ATFT {contract; token_id} ->
    Lwt.return_ok
      (string_of_asset_type asset.asset_type, Some contract, token_id,
       asset.asset_value, decimals)
  | ATNFT fa2 | ATMT fa2 ->
    Lwt.return_ok (string_of_asset_type asset.asset_type, Some fa2.asset_contract,
                   Some fa2.asset_token_id, asset.asset_value, None)

let insert_royalties ~dbh ~op ?(forward=false) roy =
  let royalties = EzEncoding.construct Json_encoding.(list part_enc) roy.roy_royalties in
  let source = op.bo_op.source in
  if not forward then
    [%pgsql dbh
        "insert into token_updates(transaction, index, block, level, tsp, \
         source, token_id, contract, royalties) \
         values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
         ${op.bo_tsp}, $source, $?{Option.map Z.to_string roy.roy_token_id}, ${roy.roy_contract}, $royalties) \
         on conflict do nothing"]
  else
    let no_token_id = Option.is_none roy.roy_token_id in
    [%pgsql dbh
        "update token_info set royalties = $royalties, \
         last_block = ${op.bo_block},
         last_level = ${op.bo_level}, \
         last = ${op.bo_tsp} \
         where contract = ${roy.roy_contract} and \
         ($no_token_id or token_id = $?{Option.map Z.to_string roy.roy_token_id})"]

let insert_royalties_bms ~dbh ~op ~contract ?forward royalties =
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
  iter_rp (insert_royalties ~dbh ~op ?forward) royalties

let insert_order_activity ?(main=false)
    dbh id match_left match_right hash transaction block level date order_activity_type =
  [%pgsql dbh
      "insert into order_activities(id, main, match_left, match_right, hash, transaction, \
       block, level, date, order_activity_type) \
       values ($id, $main, $?match_left, $?match_right, $?hash, $?transaction, \
       $?block, $?level, $date, $order_activity_type) \
       on conflict do nothing"]

let insert_order_activity ~decs dbh activity =
  begin match activity.order_act_type with
    | OrderActivityList act ->
      let hash = Some act.order_activity_bid_hash in
      insert_order_activity ~main:true
        dbh activity.order_act_id None None hash None None None activity.order_act_date "list"
    | OrderActivityBid act ->
      let hash = Some act.order_activity_bid_hash in
      insert_order_activity ~main:true
        dbh activity.order_act_id None None hash None None None activity.order_act_date "bid"
    | OrderActivityCancelList act ->
      let hash = Some act.order_activity_cancel_bid_hash in
      let transaction = Some act.order_activity_cancel_bid_transaction_hash in
      let block = Some act.order_activity_cancel_bid_block_hash in
      let level = Some (Int64.to_int32 act.order_activity_cancel_bid_block_number) in
      insert_order_activity
        dbh activity.order_act_id None None hash transaction block
        level activity.order_act_date "cancel_l"
    | OrderActivityCancelBid act ->
      let hash = Some act.order_activity_cancel_bid_hash in
      let transaction = Some act.order_activity_cancel_bid_transaction_hash in
      let block = Some act.order_activity_cancel_bid_block_hash in
      let level = Some (Int64.to_int32 act.order_activity_cancel_bid_block_number) in
      insert_order_activity
        dbh activity.order_act_id None None hash transaction block
        level activity.order_act_date "cancel_b"
    | OrderActivityMatch act ->
      let left = Some act.order_activity_match_left.order_activity_match_side_hash in
      let right = Some act.order_activity_match_right.order_activity_match_side_hash in
      let transaction = Some act.order_activity_match_transaction_hash in
      let block = Some act.order_activity_match_block_hash in
      let level = Some (Int64.to_int32 act.order_activity_match_block_number) in
      insert_order_activity
        dbh activity.order_act_id left right left transaction block
        level activity.order_act_date "match"
  end >>=? fun () ->
  let activity = { at_nft_type = None ; at_order_type = Some activity } in
  Rarible_kafka.produce_activity ~decs activity >>= fun () ->
  Lwt.return_ok ()

let insert_order_activity_new ~decs dbh date order =
  let id = Hex.show @@ Hex.of_bigstring @@ Hacl.Rand.gen 128 in
  let make = order.order_elt.order_elt_make in
  let take = order.order_elt.order_elt_take in
  let>? price = Lwt.return @@ nft_price make take in
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

let insert_order_activity_cancel dbh transaction block index level date hash =
  let>? order = get_order ~dbh hash in
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
    insert_order_activity ~decs dbh order_act
  | None ->
    Lwt.return_ok ()

let insert_order_activity_match
    dbh transaction block index level date
    hash_left left_maker left_asset left_salt
    hash_right right_maker right_asset right_salt =
  let id = Printf.sprintf "%s_%ld" block index in
  let match_left = {
    order_activity_match_side_maker = (match left_maker with Some s -> s | None -> "");
    order_activity_match_side_hash = hash_left ;
    order_activity_match_side_asset = left_asset ;
    order_activity_match_side_type = mk_side_type left_asset ;
  } in
  let match_right = {
    order_activity_match_side_maker = (match right_maker with Some s -> s | None -> "") ;
    order_activity_match_side_hash = hash_right ;
    order_activity_match_side_asset = right_asset ;
    order_activity_match_side_type = mk_side_type right_asset ;
  } in
  let>? price = Lwt.return @@ nft_price left_asset right_asset in
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
  let>? maked = get_decimals left_asset.asset_type in
  let>? taked = get_decimals right_asset.asset_type in
  insert_order_activity ~decs:(maked, taked) dbh order_act

let insert_cancel ~dbh ~op ~maker_edpk ~maker ~make ~take ~salt (hash : Tzfunc.H.t) =
  let hash = ( hash :> string ) in
  let source = op.bo_op.source in
  let>? () =
    match maker_edpk with
    | None -> Lwt.return_ok ()
    | Some maker_edpk ->
      let signature = "NO_SIGNATURE" in
      let>? make_class, make_contract, make_token_id, make_asset_value, make_decimals =
        db_from_asset make in
      let>? take_class, take_contract, take_token_id, take_asset_value, take_decimals =
        db_from_asset take in
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
      "insert into order_cancel(transaction, index, block, level, tsp, source, cancel) \
       values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
       ${op.bo_tsp}, $source, $hash) \
       on conflict do nothing"] >>=? fun () ->
  insert_order_activity_cancel
    dbh op.bo_hash op.bo_block op.bo_index op.bo_level op.bo_tsp hash

let insert_do_transfers ~dbh ~op
    ~(left : Tzfunc.H.t) ~left_maker_edpk ~left_maker ~left_make_asset
    ~left_take_asset ~left_salt
    ~(right : Tzfunc.H.t) ~right_maker_edpk ~right_maker ~right_make_asset
    ~right_take_asset ~right_salt
    ~fill_make_value ~fill_take_value =
  let left = ( left :> string ) in
  let right = ( right :> string ) in
  let source = op.bo_op.source in
  let>? left_order_opt = get_order ~dbh left in
  let>? right_order_opt = get_order ~dbh right in
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
        db_from_asset left_make_asset in
      let>? left_take_class, left_take_contract,
            left_take_token_id, left_take_asset_value, left_take_decimals =
        db_from_asset left_take_asset in
      let>? right_make_class, right_make_contract,
            right_make_token_id, right_make_asset_value, right_make_decimals =
        db_from_asset right_make_asset in
      let>? right_take_class, right_take_contract,
            right_take_token_id, right_take_asset_value, right_take_decimals =
        db_from_asset right_take_asset in
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
        db_from_asset left_make_asset in
      let>? right_take_class, _right_take_contract,
            _right_take_token_id, _right_take_asset_value, _right_take_decimals =
        db_from_asset o.order_elt.order_elt_take in
      let left_make_class = right_take_class in
      let>? _left_take_class, left_take_contract,
            left_take_token_id, left_take_asset_value, left_take_decimals =
        db_from_asset left_take_asset in
      let>? right_make_class, _right_make_contract,
            _right_make_token_id, _right_make_asset_value, _right_make_decimals =
        db_from_asset o.order_elt.order_elt_make in
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
        db_from_asset right_make_asset in
      let>? left_take_class, _left_take_contract,
            _left_take_token_id, _left_take_asset_value, _left_take_decimals =
        db_from_asset o.order_elt.order_elt_take in
      let right_make_class = left_take_class in
      let>? _right_take_class, right_take_contract,
            right_take_token_id, right_take_asset_value, right_take_decimals =
        db_from_asset right_take_asset in
      let>? left_make_class, _left_make_contract,
            _left_make_token_id, _left_make_asset_value, _left_make_decimals =
        db_from_asset o.order_elt.order_elt_make in
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
  insert_order_activity_match
    dbh op.bo_hash op.bo_block op.bo_index op.bo_level op.bo_tsp
    left left_maker left_make_asset left_salt
    right right_maker right_make_asset right_salt

let check_ft_status ~dbh ~config ~crawled contract =
  if crawled then Lwt.return_ok true
  else
    let>? l = [%pgsql dbh "select crawled from ft_contracts where address = $contract"] in
    match l with
    | [ c ] ->
      let ft_contracts = SMap.update contract (function
          | None -> None
          | Some ft -> Some {ft with ft_crawled=true}) config.Crawlori.Config.extra.ft_contracts in
      if c then config.Crawlori.Config.extra.ft_contracts <- ft_contracts;
      Lwt.return_ok c
    | _ -> Lwt.return_ok false

let insert_ft ~dbh ~config ~op ~contract ?(forward=false) ft =
  Format.printf "\027[0;35mFT update %s %ld %s\027[0m@."
    (short op.bo_hash) op.bo_index (short contract);
  let>? crawled = check_ft_status ~dbh ~config ~crawled:ft.ft_crawled contract in
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
    insert_token_balances ~dbh ~op ~contract ~ft:true ?token_id:ft.ft_token_id ~forward balances

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

let insert_nft ~dbh ~meta ~op ~contract ~nft ~entrypoint ?(forward=false) param =
  if List.mem entrypoint crawled_entrypoints then
    Format.printf "\027[0;35mNFT %s %s[%ld] %s\027[0m@."
      (string_of_entrypoint entrypoint) (short op.bo_hash) op.bo_index (short contract);
  let>? () =
    if forward then Lwt.return_ok ()
    else match Parameters.parse_fa2 entrypoint param with
    | Ok (Mint_tokens m) -> insert_mint ~dbh ~op ~contract m
    | Ok (Burn_tokens b) -> insert_burn ~dbh ~op ~contract b
    | Ok (Transfers t) -> insert_transfer ~dbh ~op ~contract t
    | Ok (Metadata (key, value)) -> insert_metadata ~dbh ~op ~contract ~key ~value
    | Ok (Add_minter a) -> insert_minter ~dbh ~op ~contract ~add:true a
    | Ok (Remove_minter a) -> insert_minter ~dbh ~op ~contract ~add:false a
    | Ok (Token_uri_pattern s) -> insert_uri_pattern ~dbh ~op ~contract s
    | _ -> Lwt.return_ok () in
  let balances = Storage_diff.get_big_map_updates nft.nft_ledger
      meta.op_lazy_storage_diff in
  let>? () = insert_token_balances ~dbh ~op ~contract ~forward balances in
  let>? () = match nft.nft_token_meta_id with
  | None -> Lwt.return_ok ()
  | Some bm_id ->
    let bm = {bm_id; bm_types = Contract_spec.token_metadata_field} in
    let metadata = Storage_diff.get_big_map_updates bm meta.op_lazy_storage_diff in
    insert_metadatas ~dbh ~op ~contract ~forward metadata in
  match nft.nft_royalties_id with
  | None -> Lwt.return_ok ()
  | Some bm_id ->
    let bm = { bm_id; bm_types = Contract_spec.royalties_field } in
    let royalties = Storage_diff.get_big_map_updates bm meta.op_lazy_storage_diff in
    insert_royalties_bms ~dbh ~op ~contract ~forward royalties


let insert_transaction ~config ~dbh ~op ?(forward=false) tr =
  let contract = tr.destination in
  match tr.parameters, op.bo_meta with
  | None, _ | Some { value = Other _; _ }, _ | Some { value = Bytes _; _ }, _ | _, None -> Lwt.return_ok ()
  | Some {entrypoint; value = Micheline m}, Some meta ->
    if contract = config.Crawlori.Config.extra.royalties then (* royalties *)
      match Parameters.parse_royalties entrypoint m with
      | Ok roy ->
        Format.printf "\027[0;35mset royalties %s %ld\027[0m@." (Utils.short op.bo_hash) op.bo_index;
        insert_royalties ~dbh ~op ~forward roy
      | _ -> Lwt.return_ok ()
    else if contract = config.Crawlori.Config.extra.exchange then (* exchange *)
      begin match Parameters.parse_cancel entrypoint m with
        | Ok { cc_hash; cc_maker_edpk; cc_maker; cc_make ; cc_take; cc_salt } ->
          Format.printf "\027[0;35mcancel order %s %ld %s\027[0m@."
            (short op.bo_hash) op.bo_index (short (cc_hash :> string));
          if not forward then insert_cancel ~dbh ~op ~maker_edpk:cc_maker_edpk ~maker:cc_maker
              ~make:cc_make ~take:cc_take ~salt:cc_salt cc_hash
          else Lwt.return_ok ()
        | _ -> Lwt.return_ok ()
      end
    else if contract = config.Crawlori.Config.extra.transfer_manager then (* transfer_manager *)
      begin match Parameters.parse_do_transfers entrypoint m with
        | Ok {dt_left; dt_left_maker_edpk; dt_left_maker; dt_left_make_asset;
              dt_left_take_asset; dt_left_salt;
              dt_right; dt_right_maker_edpk; dt_right_maker; dt_right_make_asset;
              dt_right_take_asset; dt_right_salt;
              dt_fill_make_value; dt_fill_take_value} ->
          Format.printf "\027[0;35mdo transfers %s %ld %s %s\027[0m@."
            (short op.bo_hash) op.bo_index (short (dt_left :> string)) (short (dt_right :> string));
          if not forward then insert_do_transfers
              ~dbh ~op
              ~left:dt_left ~left_maker_edpk:dt_left_maker_edpk
              ~left_maker:dt_left_maker ~left_make_asset:dt_left_make_asset
              ~left_take_asset:dt_left_take_asset ~left_salt:dt_left_salt
              ~right:dt_right ~right_maker_edpk:dt_right_maker_edpk
              ~right_maker:dt_right_maker ~right_make_asset:dt_right_make_asset
              ~right_take_asset:dt_right_take_asset ~right_salt:dt_right_salt
              ~fill_make_value:dt_fill_make_value ~fill_take_value:dt_fill_take_value
          else Lwt.return_ok ()
        | _ -> Lwt.return_ok ()
      end
    else match
        SMap.find_opt contract config.Crawlori.Config.extra.ft_contracts,
        SMap.find_opt contract config.Crawlori.Config.extra.contracts with
    | Some ft, _ -> insert_ft ~dbh ~config ~op ~contract ~forward ft
    | _, Some nft -> insert_nft ~dbh ~meta ~op ~contract ~nft ~entrypoint ~forward m
    | _, _ -> Lwt.return_ok ()

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
                | (`string k, `bytes v) ->
                  let s = (Tzfunc.Crypto.hex_to_raw v :> string) in
                  if Parameters.decode s then Some (k, s)
                  else None
                | _ -> None) l
          | _ -> [] in
        begin match b_balance && b_update && b_transfer, f_ledger with
          | true, (_, Some ({bm_types; _} as nft_ledger)) ->
            begin match ledger_kind bm_types with
              | `nft | `multiple ->
                let nft = { nft_ledger; nft_token_meta_id;
                            nft_meta_id; nft_royalties_id } in
                let kind = "fa2" in
                let owner, uri_pattern, kind = match f_admin, f_uri_pattern with
                  | (Some (`address owner), _), (Some (`string uri), _) ->
                    Some owner, Some uri, "ubi"
                  | _ -> None, None, kind in
                let owner, kind =
                  match b_update_all && (b_mint_nft || b_mint_mt) && (b_burn_nft || b_burn_mt), f_owner, kind with
                  | _, _, "ubi" -> owner, kind
                  | true, (Some (`address owner), _), _ -> Some owner, "rarible"
                  | _ -> None, kind in
                Some (kind, nft, owner, uri_pattern, metadata)
              | _ -> None
            end
          | _ -> None
        end
      | _ -> None
    end
  | _ -> None

let insert_origination ?(forward=false) config dbh op ori =
  match filter_contracts op ori, op.bo_meta with
  | None, _ | _, None ->
    Lwt.return_ok ()
  | Some (kind, nft, owner, uri, metadata), Some meta ->
    let kt1 = Tzfunc.Crypto.op_to_KT1 op.bo_hash in
    let ledger_key = EzEncoding.construct micheline_type_short_enc nft.nft_ledger.bm_types.bmt_key in
    let ledger_value = EzEncoding.construct micheline_type_short_enc nft.nft_ledger.bm_types.bmt_value in
    Format.printf "\027[0;93morigination %s (%s, %s)\027[0m@."
      (Utils.short kt1) kind (EzEncoding.construct nft_ledger_enc nft);
    let name = List.assoc_opt "name" metadata in
    let symbol = List.assoc_opt "symbol" metadata in
    let metadata = EzEncoding.construct Json_encoding.(assoc string) metadata in
    let>? () = [%pgsql dbh
        "insert into contracts(kind, address, owner, block, level, tsp, \
         last_block, last_level, last, ledger_id, ledger_key, ledger_value, \
         uri_pattern, token_metadata_id, metadata_id, royalties_id, \
         metadata, name, symbol, main) \
         values($kind, $kt1, $?owner, ${op.bo_block}, ${op.bo_level}, \
         ${op.bo_tsp}, ${op.bo_block}, ${op.bo_level}, ${op.bo_tsp}, \
         ${Z.to_string nft.nft_ledger.bm_id}, \
         $ledger_key, $ledger_value, $?uri, $?{Option.map Z.to_string nft.nft_token_meta_id}, \
         $?{Option.map Z.to_string nft.nft_meta_id}, $?{Option.map Z.to_string nft.nft_royalties_id}, \
         $metadata, $?name, $?symbol, $forward) \
         on conflict do nothing"] in
    let open Crawlori.Config in
    config.extra.contracts <- SMap.add kt1 nft config.extra.contracts;
    let () = match config.accounts with
      | None -> config.accounts <- Some (SSet.singleton kt1)
      | Some accs -> config.accounts <- Some (SSet.add kt1 accs) in
    let balances = Storage_diff.get_big_map_updates nft.nft_ledger meta.op_lazy_storage_diff in
    let>? () = insert_token_balances ~dbh ~op ~contract:kt1 ~forward balances in
    let>? () = match nft.nft_token_meta_id with
      | None -> Lwt.return_ok ()
      | Some bm_id ->
        let bm = { bm_id; bm_types = Contract_spec.token_metadata_field } in
        let metadata = Storage_diff.get_big_map_updates bm meta.op_lazy_storage_diff in
        insert_metadatas ~dbh ~op ~contract:kt1 ~forward metadata in
    match nft.nft_royalties_id with
    | None -> Lwt.return_ok ()
    | Some bm_id ->
      let bm = { bm_id; bm_types = Contract_spec.royalties_field } in
      let royalties = Storage_diff.get_big_map_updates bm meta.op_lazy_storage_diff in
      insert_royalties_bms ~dbh ~op ~contract:kt1 ~forward royalties

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
  iter_rp (fun op ->
      iter_rp (fun c ->
          match c.man_metadata with
          | None -> Lwt.return_ok ()
          | Some meta ->
            if meta.man_operation_result.op_status = `applied then
              match c.man_info.kind with
              | Origination ori ->
                let op = {
                  Hooks.bo_block = b.hash; bo_level = b.header.shell.level;
                  bo_tsp = b.header.shell.timestamp; bo_hash = op.op_hash;
                  bo_op = c.man_info; bo_index = 0l;
                  bo_meta = Option.map (fun m -> m.man_operation_result) c.man_metadata;
                  bo_numbers = Some c.man_numbers; bo_nonce = None;
                  bo_counter = c.man_numbers.counter } in
                insert_origination ?forward config dbh op ori
              | _ -> Lwt.return_ok ()
            else Lwt.return_ok ()
        ) op.op_contents
    ) b.operations

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
      | Some v -> (List.remove_assoc account creator_values_old) @ [ account, Z.(sub v (mul amount (of_int 10000))) ] in
  let creators =
    if new_supply = Z.zero then []
    else
      List.map (fun (part_account, v) ->
          Some (EzEncoding.construct part_enc {
              part_account;
              part_value = Z.(to_int32 @@ div v new_supply)})) creator_values_new in
  creators, new_supply, factor

let contract_updates_base dbh ~main ~contract ~block ~level ~tsp ~burn
    ~account ~token_id ~amount =
  let>? old_supply, creators =
    let>? l = [%pgsql dbh
        "select supply, creators from token_info where contract = $contract and \
         token_id = ${Z.to_string token_id} limit 1"] in
    one l in
  let creators, new_supply, factor =
    recalculate_creators ~main ~burn ~supply:old_supply ~amount ~account ~creators in
  let>? () = [%pgsql dbh
      "update token_info set supply = $new_supply, creators = $creators, \
       last_block = case when $main then $block else last_block end, \
       last_level = case when $main then $level else last_level end, \
       last = case when $main then $tsp else last end \
       where token_id = ${Z.to_string token_id} and contract = $contract"] in
  [%pgsql dbh
      "update tokens set amount = amount + ${Z.to_string factor}::numeric * ${Z.to_string amount}::numeric \
       where token_id = ${Z.to_string token_id} and contract = $contract and owner = $account"]

let metadata_enc =
  EzEncoding.ignore_enc @@ Json_encoding.(obj2 (req "name" string) (opt "symbol" string))

let metadata_update dbh ~main ~contract ~block ~level ~tsp ~key ~value =
  if main then
    let name, symbol =
      if key = "" then
        try
          let name, symbol = EzEncoding.destruct metadata_enc value in
          Some name, symbol
        with _ -> None, None
      else if key = "name" then Some value, None
      else if key = "symbol" then None, Some value
      else None, None
    in
    let>? metadata =
      let>? l = [%pgsql dbh "select metadata from contracts where address = $contract"] in
      one l in
    let metadata = Ezjsonm.value_to_string @@
      Json_query.(replace [`Field key] (`String value) (Ezjsonm.value_from_string metadata)) in
    let name_none = Option.is_none name in
    let symbol_none = Option.is_none symbol in
    [%pgsql dbh
        "update contracts set metadata = $metadata, \
         name = case when $name_none then name else $?name end, \
         symbol = case when $symbol_none then symbol else $?symbol end, \
         last_block = $block, last_level = $level, last = $tsp where address = $contract"]
  else Lwt.return_ok ()

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

let contract_updates dbh main l =
  let>? contracts = fold_rp (fun acc r ->
      let contract, block, level, tsp = r#contract, r#block, r#level, r#tsp in
      let acc = SSet.add contract acc in
      let>? () = match r#mint, r#burn, r#metadata_key, r#metadata_value, r#minter, r#uri_pattern with
        | Some json, _, _, _, _, _ ->
          let m = EzEncoding.destruct mint_enc json in
          let token_id, owner, amount, has_uri = match m with
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
          let>? () =
            if has_uri then
              (* Mint without metadata will produce this event on setMetadata call *)
              produce_nft_item_event dbh contract token_id
            else Lwt.return_ok () in
          produce_nft_ownership_event dbh contract token_id owner
        | _, Some json, _, _, _, _ ->
          let b, account = EzEncoding.destruct Json_encoding.(tup2 burn_enc string) json in
          let token_id, amount = match b with
            | NFTBurn token_id -> token_id, Z.one
            | MTBurn {token_id; amount} -> token_id, amount in
          let>? () =
            contract_updates_base
              dbh ~main ~contract ~block ~level ~tsp ~burn:true ~account ~token_id ~amount in
          let>? () =
            produce_nft_item_event dbh contract token_id in
          let>? () = produce_nft_ownership_event dbh contract token_id account in
          produce_order_event_item dbh account contract token_id
        | _, _, Some key, Some value, _, _ ->
          let>? () = metadata_update dbh ~main ~contract ~block ~level ~tsp ~key ~value in
          produce_update_collection_event dbh contract
        | _, _, _, _, Some minter, _ ->
          let>? () = minter_update dbh ~main ~contract ~block ~level ~tsp minter in
          produce_update_collection_event dbh contract
        | _, _, _, _, _, Some uri_pattern ->
          let>? () = uri_pattern_update dbh ~main ~contract ~block ~level ~tsp uri_pattern in
          produce_update_collection_event dbh contract
        | _ -> Lwt.return_ok () in
      Lwt.return_ok (SSet.add contract acc)) SSet.empty l in
  (* update contracts *)
  iter_rp (fun c ->
      let>? l =
        [%pgsql dbh
            "select count(distinct token_id), max(token_id) from tokens where contract = $c"] in
      let tokens_number, last_token_id = match l with
        | [] | _ :: _ :: _ -> 0L, Z.zero
        | [ tokens_number, last_token_id ] ->
          Option.value ~default:0L tokens_number,
          Option.fold ~none:Z.zero ~some:Z.of_string last_token_id in
      [%pgsql dbh
          "update contracts set \
           tokens_number = $tokens_number, \
           last_token_id = $last_token_id \
           where address = $c"]) (SSet.elements contracts)

let transfer_updates dbh main ~contract ~token_id ~source amount destination =
  let amount = if main then amount else Z.neg amount in
  let>? () = [%pgsql dbh
      "update tokens set amount = amount - ${Z.to_string amount}::numeric \
       where token_id = ${Z.to_string token_id} and \
       owner = $source and contract = $contract"] in
  let>? () =
    [%pgsql dbh
        "update tokens set amount = amount + ${Z.to_string amount}::numeric \
         where token_id = ${Z.to_string token_id} and \
         owner = $destination and contract = $contract"] in
  if main then
    let>? () = produce_nft_item_event dbh contract token_id in
    let>? () = produce_nft_ownership_event dbh contract token_id source in
    let>? () = produce_nft_ownership_event dbh contract token_id destination in
    produce_order_event_item dbh source contract token_id
  else Lwt.return_ok ()

let royalties_updates ~dbh ~main ~contract ~block ~level ~tsp ?token_id royalties =
  let no_token_id = Option.is_none token_id in
  (* todo set royalties for later tokens if token_id = None *)
  if main then
    [%pgsql dbh
        "update token_info set royalties = $royalties, \
         last_block = case when $main then $block else last_block end, \
         last_level = case when $main then $level else last_level end, \
         last = case when $main then $tsp else last end \
         where contract = $contract and \
         ($no_token_id or token_id = $?{Option.map Z.to_string token_id})"]
  else Lwt.return_ok ()

let token_metadata_updates ~dbh ~main ~contract ~block ~level ~tsp ~token_id ~transaction meta =
  let id = Printf.sprintf "%s:%s" contract (Z.to_string token_id) in
  let meta = EzEncoding.destruct Json_encoding.(assoc string) meta in
  let>? meta, uri = insert_token_metadata ~dbh ~block ~level ~tsp ~contract (token_id, meta) in
  [%pgsql dbh
      "insert into token_info(id, contract, token_id, block, level, tsp, \
       last_block, last_level, last, transaction, metadata, metadata_uri, main) \
       values($id, $contract, ${Z.to_string token_id}, $block, $level, $tsp, \
       $block, $level, $tsp, $transaction, $meta, $?uri, true) \
       on conflict (id) do update \
       set metadata = $meta, metadata_uri = $?uri, \
       last_block = case when $main then $block else token_info.last_block end, \
       last_level = case when $main then $level else token_info.last_level end, \
       last = case when $main then $tsp else token_info.last end \
       where token_info.contract = $contract and token_info.token_id = ${Z.to_string token_id}"]

let token_updates dbh main l =
  iter_rp (fun r ->
      let contract, block, level, tsp, source, transaction =
        r#contract, r#block, r#level, r#tsp, r#source, r#transaction in
      match r#destination, Option.map Z.of_string r#token_id,
            r#amount, r#operator, r#add, r#royalties, r#metadata  with
      | Some destination, Some token_id, Some amount, _, _, _, _ ->
        transfer_updates
          dbh main ~contract ~token_id ~source amount destination
      | _, token_id, _, _, _, Some royalties, _ ->
        royalties_updates ~dbh ~main ~contract ~block ~level ~tsp ?token_id royalties
      | _, Some token_id, _, _, _, _, Some meta ->
        token_metadata_updates ~dbh ~main ~contract ~block ~level ~tsp ~token_id ~transaction meta
      | _ -> Lwt.return_error (`hook_error "invalid token_update")) l

let token_balance_updates dbh main l =
  let>? m = fold_rp (fun acc r ->
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
      let>? l = match info with
        | None -> Lwt.return_ok []
        | Some (account, balance, other) ->
          match account with
          | None ->
            [%pgsql dbh
                "update tokens set balance = $?balance where tokens.contract = ${r#contract} \
                 and tokens.token_id = ${r#token_id} returning owner, amount, balance"]
          | Some account ->
            let tid = Printf.sprintf "%s:%s" r#contract r#token_id in
            let oid = Printf.sprintf "%s:%s:%s" r#contract r#token_id account in
            let amount = Option.value ~default:Z.zero balance in
            let>? l = [%pgsql dbh
                "insert into tokens(tid, oid, contract, token_id, owner, amount, balance) \
                 values($tid, $oid, ${r#contract}, ${r#token_id}, $account, $amount, $?balance) \
                 on conflict (contract, token_id, owner) \
                 do update set balance = $?balance where tokens.contract = ${r#contract} \
                 and tokens.token_id = ${r#token_id} and tokens.owner = $account \
                 returning owner, amount, balance"] in
            match other with
            | None -> Lwt.return_ok l
            | Some b ->
              let|>? l2 =
                [%pgsql dbh
                    "update tokens set balance = $b where tokens.contract = ${r#contract} \
                     and tokens.token_id = ${r#token_id} and owner <> $account \
                     returning owner, amount, balance"] in
              l @ l2 in
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
      let>? () = [%pgsql dbh
          "update tokens set amount = $balance where contract = $contract \
           and token_id = ${Z.to_string token_id} and owner = $owner"] in
      Lwt.return_ok @@ match TIMap.find_opt (contract, token_id) acc with
      | None -> TIMap.add (contract, token_id) (Z.sub balance amount, r) acc
      | Some (s, _) -> TIMap.add (contract, token_id) (Z.(add s (sub balance amount)), r) acc
    ) TIMap.empty (TMap.bindings m) in
  iter_rp (fun ((contract, token_id), (supply, r)) ->
      let id = contract ^ ":" ^ Z.to_string token_id in
      [%pgsql dbh
          "insert into token_info(id, contract, token_id, block, level, tsp, \
           last_block, last_level, last, transaction, supply, main) \
           values($id, $contract, ${Z.to_string token_id}, ${r#block}, ${r#level}, ${r#tsp}, \
           ${r#block}, ${r#level}, ${r#tsp}, ${r#transaction}, $supply, true) \
           on conflict (id) do update \
           set supply = $supply,
           last_block = case when $main then ${r#block} else token_info.last_block end, \
           last_level = case when $main then ${r#level} else token_info.last_level end, \
           last = case when $main then ${r#tsp} else token_info.last end \
           where token_info.contract = $contract and token_info.token_id = ${Z.to_string token_id}"]) @@
  TIMap.bindings m


let produce_cancel_events dbh main l =
  iter_rp (fun r ->
      if main then
        match r#cancel with
        | None -> Lwt.return_ok ()
        | Some h ->
          produce_order_event_hash dbh h
      else Lwt.return_ok ())
    l

let produce_match_events dbh main l =
  iter_rp (fun r ->
      if main then
        let>? () = produce_order_event_hash dbh r#hash_left in
        produce_order_event_hash dbh r#hash_right
      else Lwt.return_ok ())
    l

let produce_nft_activity_events main l =
  iter_rp (fun r ->
      if main then
        let>? ev = mk_nft_activity r in
        let activity = { at_nft_type = Some ev ; at_order_type = None } in
        Rarible_kafka.produce_activity ~decs:(None,None) activity >>= fun () ->
        Lwt.return_ok ()
      else Lwt.return_ok ())
    l

let produce_collection_events main l =
  iter_rp (fun r ->
      if main then
        match mk_nft_collection r with
        | Ok c ->
          produce_nft_collection_event c
        | Error err ->
          Printf.eprintf "couldn't produce collection event %S\n%!" @@ Crp.string_of_error err ;
          Lwt.return_ok ()
      else Lwt.return_ok ())
    l

let set_main _config ?(forward=false) dbh {Hooks.m_main; m_hash} =
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
    let>? () =
      [%pgsql dbh "update order_activities set main = $m_main where block = $m_hash"] in
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
    let>? () = contract_updates dbh m_main @@ sort c_updates in
    let>? () = token_updates dbh m_main @@ sort t_updates in
    let>? () = token_balance_updates dbh m_main @@ sort tb_updates in
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
    let>? () = produce_collection_events m_main collections in
    let>? () = produce_cancel_events dbh m_main @@ sort cancels in
    let>? () = produce_match_events dbh m_main @@ sort matches in
    let>? () = produce_nft_activity_events m_main @@ sort nactivities in
    Lwt.return_ok (fun () -> Lwt.return_ok ())
  else
    Lwt.return_ok (fun () -> Lwt.return_ok ())

let get_level ?dbh () =
  use dbh @@ fun dbh ->
  let>? res =
    [%pgsql dbh
        "select max(level) FROM blocks"] in
  let>? res = one res in
  match res with
  | Some level -> Lwt.return_ok @@ Int32.to_int level
  | None -> Lwt.return_error (`hook_error "no level")

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
  use dbh @@ fun dbh ->
  let size64 = Int64.of_int size in
  let no_continuation, (ts, id) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  let>? l = [%pgsql.object dbh
      "select i.id, \
       last, supply, metadata, tsp, creators, royalties, \
       array_agg(case when balance is not null and balance <> 0 \
       or amount <> 0 then owner end) as owners \
       from (select tid, amount, balance, owner from tokens where \
       owner = $owner and
       ((balance is not null and balance > 0 or amount > 0))) t \
       inner join token_info i on i.id = t.tid \
       where \
       main and metadata <> '{}' and owner = $owner and (balance is not null and balance > 0 or amount > 0) and \
       ($no_continuation or (last = $ts and i.id < $id) or (last < $ts)) \
       group by (i.id, i.contract, i.token_id) \
       order by last desc, id desc limit $size64"] in
  map_rp (fun r -> mk_nft_item dbh ?include_meta r) l >>=? fun nft_items_items ->
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
  use dbh @@ fun dbh ->
  let size64 = Int64.of_int size in
  let no_continuation, (ts, id) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  let>? l = [%pgsql.object dbh
      "select i.id, \
       last, supply, metadata, i.tsp, creators, royalties, \
       array_agg(case when balance is not null and balance <> 0 or amount <> 0 then owner end) as owners \
       from tokens as t, token_info i, unnest(i.creators) as c \
       where c->>'account' = $creator and \
       t.tid = i.id and \
       i.main and metadata <> '{}' and (balance is not null and balance > 0 or amount > 0) and \
       ($no_continuation or (last = $ts and i.id < $id) or (last < $ts)) \
       group by (i.id) \
       order by last desc, i.id desc limit $size64"] in
  let>? nft_items_items = map_rp (fun r -> mk_nft_item dbh ?include_meta r) l in
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
  use dbh @@ fun dbh ->
  let size64 = Int64.of_int size in
  let no_continuation, (ts, id) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  let>? l = [%pgsql.object dbh
      "select i.id, \
       last, i.supply, i.tsp, i.creators, i.royalties, \
       array_agg(case when t.balance is not null and t.balance <> 0 or \
       t.amount <> 0 then t.owner end) as owners \
       from (select tid, amount, balance, owner from tokens where \
       contract = $contract and
       ((balance is not null and balance > 0 or amount > 0))) t \
       inner join token_info i on i.id = t.tid \
       and i.id in (\
       select id from token_info where \
       main and metadata <> '{}' and \
       ($no_continuation or (last = $ts and id < $id) or (last < $ts)) \
       order by last desc, id desc limit $size64) \
       group by (i.id) \
       order by i.last desc, i.id desc limit $size64"] in
  let>? nft_items_items = map_rp (fun r -> mk_nft_item dbh ?include_meta r) l in
  let len = List.length nft_items_items in
  let nft_items_continuation =
    if len <> size then None
    else Some
        (mk_nft_items_continuation @@ List.hd (List.rev nft_items_items)) in
  Lwt.return_ok
    { nft_items_items ; nft_items_continuation ; nft_items_total = 0L }

let get_nft_item_meta_by_id ?dbh contract token_id =
  Format.eprintf "get_nft_meta_by_id %s %s@." contract (Z.to_string token_id) ;
  use dbh @@ fun dbh ->
  let>? meta = mk_nft_item_meta dbh ~contract ~token_id in
  match rarible_meta_of_tzip21_meta meta with
  | None ->
    Lwt.return_ok {
      nft_item_meta_name = "Unnamed item" ;
      nft_item_meta_description = None ;
      nft_item_meta_attributes = None ;
      nft_item_meta_image = None ;
      nft_item_meta_animation = None ;
    }
  | Some meta -> Lwt.return_ok meta

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
  let size64 = Int64.of_int size in
  let no_continuation, (ts, id) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  let no_last_updated_to, last_updated_to_v =
    last_updated_to = None,
    (match last_updated_to with None -> CalendarLib.Calendar.now () | Some ts -> ts) in
  let no_last_updated_from, last_updated_from_v =
    last_updated_from = None,
    (match last_updated_from with None -> CalendarLib.Calendar.now () | Some ts -> ts) in
  let no_show_deleted, show_deleted_v =
    show_deleted = None,
    (match show_deleted with None -> false | Some b -> b) in
  let>? l = [%pgsql.object dbh
      "select i.id, \
       last, i.supply, i.tsp, i.creators, i.royalties, \
       array_agg(case when t.balance is not null and t.balance <> 0 or t.amount <> 0 then t.owner end) as owners \
       from (select tid, amount, balance, owner from tokens where \
       ((balance is not null and balance > 0 or amount > 0) or (not $no_show_deleted and $show_deleted_v))) t \
       inner join token_info i on i.id = t.tid \
       and i.id in (\
       select id from token_info where \
       main and metadata <> '{}' and \
       ($no_last_updated_to or (last <= $last_updated_to_v)) and \
       ($no_last_updated_from or (last >= $last_updated_from_v)) and \
       ($no_continuation or (last = $ts and id < $id) or (last < $ts)) \
       order by last desc, id desc limit $size64) \
       group by (i.id) \
       order by i.last desc, i.id desc limit $size64"] in
  let>? nft_items_items = map_rp (fun r -> mk_nft_item dbh ?include_meta r) l in
  let len = List.length nft_items_items in
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
  let types = filter_all_type_to_string filter.nft_activity_by_collection_types in
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
           (date = $ts and transaction collate \"C\" < $h) or \
           (date < $ts)) \
           order by date desc, \
           transaction collate \"C\" desc \
           limit $size64"]
    | EARLIEST_FIRST ->
      [%pgsql.object dbh
          "select activity_type, transaction, index, block, level, date, contract, \
           token_id, owner, amount, tr_from from nft_activities where \
           main and contract = $contract and \
           position(activity_type in $types) > 0 and \
           ($no_continuation or \
           (date = $ts and transaction collate \"C\" > $h) or \
           (date > $ts)) \
           order by date asc, \
           transaction collate \"C\" asc \
           limit $size64"]
  in
  map_rp (fun r -> let|>? a = mk_nft_activity r in a, r) l >>=? fun activities ->
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
  let types = filter_all_type_to_string filter.nft_activity_by_item_types in
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
           (date = $ts and transaction collate \"C\" < $h) or \
           (date < $ts)) \
           order by date desc, \
           transaction collate \"C\" desc limit $size64"]
    | EARLIEST_FIRST ->
      [%pgsql.object dbh
          "select activity_type, transaction, index, block, level, date, contract, \
           token_id, owner, amount, tr_from from nft_activities where \
           main and contract = $contract and token_id = ${Z.to_string token_id} and \
           position(activity_type in $types) > 0 and \
           ($no_continuation or \
           (date = $ts and transaction collate \"C\" > $h) or \
           (date > $ts)) \
           order by date asc, \
           transaction collate \"C\" asc \
           limit $size64"] in
  map_rp (fun r -> let|>? a = mk_nft_activity r in a, r) l >>=? fun activities ->
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
  let types = filter_user_type_to_string filter.nft_activity_by_user_types in
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
           (date = $ts and transaction collate \"C\" < $h) or \
           (date < $ts)) \
           order by date desc, \
           transaction collate \"C\" desc \
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
           (date = $ts and transaction collate \"C\" > $h) or \
           (date > $ts)) \
           order by date asc, \
           transaction collate \"C\" asc \
           limit $size64"]
  in
  map_rp (fun r -> let|>? a = mk_nft_activity r in a, r) l >>=? fun activities ->
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
  let types = filter_all_type_to_string types in
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
           (date = $ts and transaction collate \"C\" < $h) or \
           (date < $ts)) \
           order by date desc, \
           transaction collate \"C\" desc limit $size64"]
    | EARLIEST_FIRST ->
      [%pgsql.object dbh "show"
          "select activity_type, transaction, index, block, level, date, contract, \
           token_id, owner, amount, tr_from from nft_activities where \
           main and position(activity_type in $types) > 0 and \
           ($no_continuation or \
           (date = $ts and transaction collate \"C\" > $h) or \
           (date > $ts)) \
           order by date asc, \
           transaction collate \"C\" asc \
           limit $size64"]
  in
  map_rp (fun r -> let|>? a = mk_nft_activity r in a, r) l >>=? fun activities ->
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
  Format.eprintf "get_nft_ownerships_by_item %s %s %s %d@."
    contract
    (Z.to_string token_id)
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
      "select concat(i.contract, ':', i.token_id, ':', owner) as id, \
       i.contract, i.token_id, owner, tsp, last, amount, balance, supply, metadata, creators \
       from tokens t inner join token_info i on t.contract = i.contract and i.token_id = t.token_id \
       where main and i.contract = $contract and i.token_id = ${Z.to_string token_id} \
       and (balance is not null and balance > 0 or amount > 0) and \
       ($no_continuation or \
       (last = $ts and concat(i.contract, ':', i.token_id, ':', owner) collate \"C\" < $id) or \
       (last < $ts)) \
       order by last desc, \
       concat(i.contract, ':', i.token_id, ':', owner) collate \"C\" desc \
       limit $size64"] in
  let nft_ownerships_ownerships = List.map mk_nft_ownership l in
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
  let size64 = Int64.of_int size in
  let no_continuation, (ts, id) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  use dbh @@ fun dbh ->
  let>? l = [%pgsql.object dbh
      "select concat(i.contract, ':', i.token_id, ':', owner) as id, \
       i.contract, i.token_id, owner, tsp, last, amount, balance, supply, metadata, creators \
       from tokens t inner join token_info i on i.contract = t.contract and i.token_id = t.token_id \
       where main and (balance is not null and balance > 0 or amount > 0) and \
       ($no_continuation or \
       (last = $ts and concat(i.contract, ':', i.token_id, ':', owner) collate \"C\" < $id) or \
       (last < $ts)) \
       order by last desc, \
       concat(i.contract, ':', i.token_id, ':', owner) collate \"C\" desc \
       limit $size64"] in
  let nft_ownerships_ownerships = List.map mk_nft_ownership l in
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
      "select address, owner, metadata, name, symbol, kind, ledger_key, \
       ledger_value, minters from contracts where \
       main and owner = $owner and \
       ((ledger_key = '\"nat\"' and ledger_value = '\"address\"') \
       or (ledger_key = '[ \"address\", \"nat\"]' and ledger_value = '\"nat\"') \
       or (ledger_key = '[\"nat\", \"address\"]' and ledger_value = '\"nat\"')) and \
       ($no_continuation or \
       (address collate \"C\" > $collection)) \
       order by address collate \"C\" asc limit $size64"] in
  let nft_collections_collections = List.filter_map (fun r -> Result.to_option (mk_nft_collection r)) l in
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
      "select address, owner, metadata, name, symbol, kind, ledger_key, \
       ledger_value, minters from contracts where main and \
       ((ledger_key = '\"nat\"' and ledger_value = '\"address\"') \
       or (ledger_key = '[ \"address\", \"nat\"]' and ledger_value = '\"nat\"') \
       or (ledger_key = '[\"nat\", \"address\"]' and ledger_value = '\"nat\"')) and \
       ($no_continuation or address collate \"C\" > $collection) \
       order by address collate \"C\" asc limit $size64"] in
  let nft_collections_collections = List.filter_map (fun r -> Result.to_option (mk_nft_collection r)) l in
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
    (decimal_balance ?decimals:d order.order_elt.order_elt_make.asset_value)
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

let rec get_orders_all_aux ?dbh ?origin ?(sort=LATEST_FIRST) ?statuses ?continuation ~size acc =
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
      | LATEST_FIRST ->
        [%pgsql.object dbh
            "select hash, last_update_at from orders \
             where \
             ($no_continuation or \
             (last_update_at < $ts) or \
             (last_update_at = $ts and \
             hash collate \"C\"  < $h)) \
             order by last_update_at desc, \
             hash collate \"C\" desc \
             limit $size"]
      | EARLIEST_FIRST ->
        [%pgsql.object dbh
            "select hash, last_update_at from orders \
             where \
             ($no_continuation or \
             (last_update_at > $ts) or \
             (last_update_at = $ts and \
             hash collate \"C\"  < $h)) \
             order by last_update_at asc, \
             hash collate \"C\" desc \
             limit $size"] in
    let continuation = match List.rev l with
      | [] -> None
      | hd :: _ -> Some (hd#last_update_at, hd#hash) in
    map_rp (fun r -> get_order ~dbh r#hash) l >>=? fun orders ->
    match orders with
    | [] -> Lwt.return_ok acc
    | _ ->
      let orders = List.filter_map (fun x -> x) orders in
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
           hash collate \"C\" < $h)) \
           order by last_update_at desc, \
           hash collate \"C\" desc \
           limit $size"] in
    let continuation = match List.rev l with
      | [] -> None
      | hd :: _ -> Some (hd#last_update_at, hd#hash) in
    map_rp (fun r -> get_order ~dbh r#hash) l >>=? fun orders ->
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
           hash collate \"C\" > $h)) \
           order by make_asset_value asc, \
           hash collate \"C\" asc \
           limit $size"] in
    let continuation = match List.rev l with
      | [] -> None
      | hd :: _ -> Some (Z.to_string hd#make_asset_value, hd#hash) in
    map_rp (fun r -> get_order ~dbh r#hash) l >>=? fun orders ->
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
           make_asset_type_class = 'FA_2' and \
           ($no_continuation or \
           (last_update_at < $ts) or \
           (last_update_at = $ts and \
           hash collate \"C\" < $h)) \
           order by last_update_at desc, \
           hash collate \"C\" desc \
           limit $size"] in
    let continuation = match List.rev l with
      | [] -> None
      | hd :: _ -> Some (hd#last_update_at, hd#hash) in
    map_rp (fun r -> get_order ~dbh r#hash) l >>=? fun orders ->
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
           hash collate \"C\" < $h)) \
           order by last_update_at desc, \
           hash collate \"C\" desc \
           limit $size"] in
    let continuation = match List.rev l with
      | [] -> None
      | hd :: _ -> Some (hd#last_update_at, hd#hash) in
    map_rp (fun r -> get_order ~dbh r#hash) l >>=? fun orders ->
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
           hash collate \"C\" < $h)) \
           order by last_update_at desc, \
           hash collate \"C\" desc \
           limit $size"] in
    let continuation = match List.rev l with
      | [] -> None
      | hd :: _ -> Some (hd#last_update_at, hd#hash) in
    map_rp (fun r -> get_order ~dbh r#hash) l >>=? fun orders ->
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
           hash collate \"C\" < $h)) \
           order by take_asset_value desc, \
           hash collate \"C\" desc \
           limit $size"] in
    let continuation = match List.rev l with
      | [] -> None
      | hd :: _ -> Some (Z.to_string hd#take_asset_value, hd#hash) in
    map_rp (fun r -> get_order ~dbh r#hash) l >>=? fun orders ->
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
    (match statuses with None -> "None" | Some ss -> order_status_to_string ss)
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
      Lwt.return @@ mk_asset
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
      Lwt.return @@ mk_asset
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
    db_from_asset order_elt.order_elt_make in
  let>? take_class, take_contract, take_token_id, take_asset_value, take_decimals =
    db_from_asset order_elt.order_elt_take in
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
  insert_order_activity_new ~decs:(make_decimals, take_decimals) dbh last_update_at order
  >>=? fun () ->
  insert_price_history dbh last_update_at make_asset_value take_asset_value hash_key >>=? fun () ->
  begin
    if last_update_at = created_at then insert_origin_fees dbh origin_fees hash_key
    else Lwt.return_ok ()
  end >>=? fun () ->
  insert_payouts dbh payouts hash_key >>=? fun () ->
  produce_order_event_hash dbh order.order_elt.order_elt_hash

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
  let types = filter_order_all_type_to_string filter.order_activity_by_collection_types in
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
           (date = $ts and id collate \"C\" < $h) or \
           (date < $ts)) \
           order by date desc, \
           id collate \"C\" desc \
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
           (date = $ts and id collate \"C\" > $h) or \
           (date > $ts)) \
           order by date asc, \
           id collate \"C\" asc \
           limit $size64"] in
  let>? activities = map_rp (fun r ->
      let|>? (a, decs) = mk_order_activity ~dbh r in
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
  let types = filter_order_all_type_to_string filter.order_activity_by_item_types in
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
           (date = $ts and id collate \"C\" < $h) or \
           (date < $ts)) \
           order by date desc, \
           id collate \"C\" desc \
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
           (date = $ts and id collate \"C\" > $h) or \
           (date > $ts)) \
           order by date asc, \
           id collate \"C\" asc \
           limit $size64"] in
  let>? activities = map_rp (fun r ->
      let|>? a, decs = mk_order_activity ~dbh r in
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
  let types = filter_order_all_type_to_string types in
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
           (date = $ts and id collate \"C\" < $h) or \
           (date < $ts)) \
           order by date desc, \
           id collate \"C\" desc \
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
           (date = $ts and id collate \"C\" > $h) or \
           (date > $ts)) \
           order by date asc, \
           id collate \"C\" asc limit $size64"] in
  let>? activities = map_rp (fun r ->
      let|>? a, decs = mk_order_activity ~dbh r in
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
  let types = filter_order_user_type_to_string filter.order_activity_by_user_types in
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
           (date = $ts and id collate \"C\" < $h) or \
           (date < $ts)) \
           order by date desc, \
           id collate \"C\" desc \
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
           (date = $ts and id collate \"C\" > $h) or \
           (date > $ts)) \
           order by date asc, \
           id collate \"C\" asc \
           limit $size64"] in
  let>? activities = map_rp (fun r ->
      let|>? a, decs = mk_order_activity ~dbh r in
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

let set_main_recrawl ?dbh hash =
  use dbh @@ fun dbh ->
  [%pgsql dbh
      "update token_balance_updates set main = true where \
       block = $hash and (kind='ft' or kind='ft_multiple')"]

let set_crawled ?dbh contract =
  use dbh @@ fun dbh ->
  [%pgsql dbh "update ft_contracts set crawled = true where address = $contract"]

let get_ft_contract ?dbh contract =
  use dbh @@ fun dbh ->
  let>? l = [%pgsql.object dbh "select * from ft_contracts where address = $contract"] in
  one @@ List.map db_ft_contract l

let get_unknown_bm_id ?dbh ?(kind=`token) () =
  use dbh @@ fun dbh ->
  match kind with
  | `token -> [%pgsql dbh "select address from contracts where token_metadata_id is null"]
  | `contract -> [%pgsql dbh "select address from contracts where metadata_id is null"]
  | `royalties -> [%pgsql dbh "select address from contracts where royalties_id is null"]

let set_bm_id ?dbh ?(kind=`token) ~contract id =
  use dbh @@ fun dbh ->
  match kind with
  | `token ->
    [%pgsql dbh "update contracts set token_metadata_id = ${Z.to_string id} where address = $contract"]
  | `contract ->
    [%pgsql dbh "update contracts set metadata_id = ${Z.to_string id} where address = $contract"]
  | `royalties ->
    [%pgsql dbh "update contracts set royalties_id = ${Z.to_string id} where address = $contract"]

let fetch_metadata_from_source ?(verbose=0) ~timeout ~source l =
  let cpt = ref 0 in
  let err = ref 0 in
  let empty = ref 0 in
  let oks = ref 0 in
  let len = List.length l in
  if verbose > 0 then
    Format.eprintf "fetching metadata for %d item(s) from %s @." (List.length l) source ;
  use None @@ fun dbh ->
  iter_rp (fun r ->
      if !cpt <> 0 then
        Format.eprintf "[%d / %d | \027[0;91mErr %d\027[0m | \
                        \027[0;93mEmpty %d\027[0m | \027[0;92mOk %d\027[0m] %s@."
          !cpt len !err !empty !oks source;
      incr cpt ;
      if verbose > 0 then
        Format.eprintf "%s %s %s@." source r#contract r#token_id;
      let metadata_uri = match r#metadata_uri with
        | None ->
          let l = EzEncoding.destruct Json_encoding.(assoc string) r#metadata in
          begin match List.assoc_opt "" l with
            | None -> None
            | Some uri -> Some uri
          end
        | Some uri -> Some uri in
      match metadata_uri with
      | None ->
        if verbose > 0 then
          Format.eprintf "  can't find uri for metadata, try to decode@." ;
        begin try
            if r#metadata <> "{}" then
              let metadata = EzEncoding.destruct token_metadata_enc r#metadata in
              let block, level, tsp, contract, token_id =
                r#block, r#level, r#tsp, r#contract, Z.of_string r#token_id in
              let>? () =
                insert_mint_metadata dbh ~forward:true ~contract ~token_id ~block ~level ~tsp metadata in
              if verbose > 0 then Format.eprintf "  OK@." ;
              incr oks ;
              Lwt.return_ok ()
            else
              begin
                if verbose > 0 then Format.eprintf "  empty metadata@." ;
                incr empty ;
                Lwt.return_ok ()
              end
          with _ ->
            if verbose > 0 then Format.eprintf "  can't decode metadata in %s@." r#metadata ;
            incr err ;
            Lwt.return_ok ()
        end
      | Some uri ->
        if uri <> "" then
          let> re = get_metadata_json ~quiet:true ~source ~timeout uri in
          match re with
          | Ok (_json, metadata, _uri) ->
            let block, level, tsp, contract, token_id =
              r#block, r#level, r#tsp, r#contract, Z.of_string r#token_id in
            let>? () = insert_mint_metadata dbh ~forward:true ~contract ~token_id ~block ~level ~tsp metadata in
            if verbose > 0 then Format.eprintf "  OK@." ;
            incr oks ;
            Lwt.return_ok ()
          | Error (code, str) ->
            incr err ;
            (if verbose > 0 then Format.eprintf "  fetch metadata error %d:%s@." code @@
               Option.value ~default:"None" str);
            if code = 429 then
              (* TOO MANY REQUESTS *)
              Lwt_unix.sleep 30. >>= fun () ->
              Lwt.return_ok ()
            else
              Lwt.return_ok ()
        else
          begin
            if verbose > 0 then Format.eprintf "  can't find uri for metadata %s@." r#metadata ;
            incr err ;
            Lwt.return_ok ()
          end)
    l

let empty_token_metadata ?dbh ?contract () =
  let no_contract = Option.is_none contract in
  use dbh @@ fun dbh ->
  [%pgsql.object dbh
      "select contract, token_id, t.block, t.level, t.tsp, t.metadata, \
       t.metadata_uri, c.token_metadata_id from token_info t \
       inner join contracts c on t.contract = c.address \
       where t.main and metadata_uri is null and t.metadata = '{}' \
       and ($no_contract or contract = $?contract) and token_metadata_id is not null"]

let unknown_token_metadata ?dbh ?contract () =
  let no_contract = Option.is_none contract in
  use dbh @@ fun dbh ->
  [%pgsql.object dbh
      "select i.contract, i.token_id, i.block, i.level, i.tsp, metadata, \
       metadata_uri, null as token_metadata_id \
       from token_info i left join tzip21_metadata t on \
       i.token_id = t.token_id and i.contract = t.contract where \
       i.main and t.contract is null and ($no_contract or i.contract = $?contract)"]

let update_metadata ?(set_metadata=false)
    ?metadata_uri ?dbh ~metadata ~contract ~token_id ~block ~level ~tsp () =
  Format.eprintf "%s[%s]@." contract token_id;
  if set_metadata then
    use dbh @@ fun dbh ->
    [%pgsql dbh "update token_info set metadata = $metadata \
                 where contract = $contract and token_id = ${token_id}"]
  else
  let metadata_uri = match metadata_uri with
    | None ->
      let l = EzEncoding.destruct Json_encoding.(assoc string) metadata in
      List.assoc_opt "" l
    | Some uri -> Some uri in
  match metadata_uri with
  | None ->
    Format.eprintf "  can't find uri for metadata, try to decode@." ;
    begin try
        let metadata_tzip = EzEncoding.destruct token_metadata_enc metadata in
        let token_id = Z.of_string token_id in
        use dbh @@ fun dbh ->
        let>? () =
          insert_mint_metadata dbh ~forward:true ~contract ~token_id ~block ~level ~tsp metadata_tzip in
        Format.eprintf "  OK@." ;
        Lwt.return_ok ()
      with _ ->
        Format.eprintf "  can't find uri or metadata in %s@." metadata ;
        Lwt.return_ok ()
    end
  | Some uri ->
    if uri <> "" then
      let> re = get_metadata_json ~quiet:true uri in
      match re with
      | Ok (_json, metadata_tzip, _uri) ->
        let token_id = Z.of_string token_id in
        use dbh @@ fun dbh ->
        let>? () =
          insert_mint_metadata dbh ~forward:true ~contract ~token_id ~block ~level ~tsp metadata_tzip in
        Format.eprintf "  OK@." ;
        Lwt.return_ok ()
      | Error (code, str) ->
        (Format.eprintf "  fetch metadata error %d:%s@." code @@
         Option.value ~default:"None" str);
        Lwt.return_ok ()
    else
      begin
        Format.eprintf "  can't find uri for metadata %s@." metadata ;
        Lwt.return_ok ()
      end

let update_supply ?dbh () =
  use dbh @@ fun dbh ->
  let>? () =
    [%pgsql dbh
        "update tokens set amount = balance \
         where balance is not null and amount <> balance"] in
  [%pgsql dbh
      "with tmp(contract, token_id, supply) as (\
       select contract, token_id, sum(amount) from tokens \
       group by contract, token_id) \
       update token_info i set supply = tmp.supply from tmp \
       where i.contract = tmp.contract and i.token_id = tmp.token_id"]

let random_tokens ?dbh ?contract ?token_id ?owner ?(number=100L) () =
  let no_contract, no_token_id, no_owner =
    Option.is_none contract, Option.is_none token_id, Option.is_none owner in
  use dbh @@ fun dbh ->
  [%pgsql.object dbh
      "select contract, token_id, t.owner, amount, balance, \
       ledger_id, ledger_key, ledger_value \
       from tokens t \
       inner join contracts on address = contract
       where ($no_contract or contract = $?contract) and \
       ($no_token_id or token_id = $?{Option.map Z.to_string token_id}) and \
       ($no_owner or t.owner = $?owner) and ledger_key is not null and \
       ledger_value is not null \
       order by random() limit $number"]

let find_hash ?dbh h =
  let h = h ^ "%s" in
  use dbh @@ fun dbh ->
  match String.get h 0 with
  | 'B' -> [%pgsql dbh "select hash from predecessors where hash like $h"]
  | 'o' -> [%pgsql dbh "select transaction from token_balance_updates where transaction like $h"]
  | 't' | 'K' ->
    [%pgsql dbh "select contract from token_balance_updates where contract like $h"]
  | _ -> Lwt.return_ok []
