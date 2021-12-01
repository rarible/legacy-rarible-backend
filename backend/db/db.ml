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
        let ledger_key = EzEncoding.destruct micheline_type_short_enc k in
        let ledger_value = EzEncoding.destruct micheline_type_short_enc v in
        let v = {nft_type = {ledger_key; ledger_value}; nft_id=r#ledger_id} in
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
      let ledger_key = EzEncoding.destruct micheline_type_short_enc k in
      let ledger_value = EzEncoding.destruct micheline_type_short_enc v in
      Some (Custom {ledger_key; ledger_value})
    | _ -> None in
  match v with
  | None -> None
  | Some ft_kind -> Some {
      ft_kind; ft_ledger_id = r#ledger_id;
      ft_crawled=r#crawled; ft_token_id = r#token_id}

let db_ft_contracts =
  List.fold_left (fun acc r ->
      match db_ft_contract r with
      | None -> acc
      | Some ft -> SMap.add r#address ft acc) SMap.empty

let get_extra_config ?dbh () =
  use dbh @@ fun dbh ->
  let>? contracts =
    [%pgsql.object dbh "select address, ledger_id, ledger_key, ledger_value \
                 from contracts where main"] in
  let>? ft_contracts =
    [%pgsql.object dbh
        "select address, kind, ledger_id, ledger_key, ledger_value, crawled, token_id \
         from ft_contracts"] in
  let>? r = [%pgsql.object dbh
      "select admin_wallet, exchange_v2_contract, royalties_contract, \
       validator_contract from state"] in
  match r with
  | [ r ] ->
    let contracts = db_contracts contracts in
    let ft_contracts = db_ft_contracts ft_contracts in
    Lwt.return_ok (Some {
      admin_wallet = r#admin_wallet;
      exchange_v2 = r#exchange_v2_contract;
      royalties = r#royalties_contract;
      validator = r#validator_contract;
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
          "insert into state(exchange_v2_contract, royalties_contract, \
           validator_contract) \
           values (${e.exchange_v2}, ${e.royalties}, ${e.validator})"]
    | _ ->
      [%pgsql dbh
          "update state set exchange_v2_contract = ${e.exchange_v2}, \
           royalties_contract = ${e.royalties}, validator_contract = ${e.validator}"] in
  iter_rp (fun (address, lk) ->
      let id = lk.ft_ledger_id in
      let token_id = lk.ft_token_id in
      let kind, k, v = match lk.ft_kind with
        | Fa2_single -> "fa2_single", None, None
        | Fa2_multiple -> "fa2_multiple", None, None
        | Fa2_multiple_inversed -> "fa2_multiple_inversed", None, None
        | Fa1 -> "fa1", None, None
        | Lugh -> "lugh", None, None
        | Custom {ledger_key; ledger_value} ->
          "custom",
          Some (EzEncoding.construct micheline_type_short_enc ledger_key),
          Some (EzEncoding.construct micheline_type_short_enc ledger_value) in
      [%pgsql dbh
          "insert into ft_contracts(address, kind, ledger_id, ledger_key, ledger_value, crawled, token_id) \
           values($address, $kind, $id, $?k, $?v, ${lk.ft_crawled}, $?token_id) on conflict do nothing"])
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

let mk_order_activity_bid obj =
  let$ make = mk_asset
      obj#make_asset_type_class
      obj#make_asset_type_contract
      obj#make_asset_type_token_id
      obj#make_asset_value in
  let$ take = mk_asset
      obj#take_asset_type_class
      obj#take_asset_type_contract
      obj#take_asset_type_token_id
      obj#take_asset_value in

  let|$ price = nft_price make take in
  {
    order_activity_bid_hash = obj#o_hash;
    order_activity_bid_maker = obj#maker ;
    order_activity_bid_make = make ;
    order_activity_bid_take = take ;
    order_activity_bid_price = price ;
  }, (obj#make_asset_decimals, obj#take_asset_decimals)

let mk_left_side obj =
  let|$ asset =
    mk_asset
      obj#oleft_make_asset_type_class
      obj#oleft_make_asset_type_contract
      obj#oleft_make_asset_type_token_id
      obj#oleft_make_asset_value in
  {
    order_activity_match_side_maker = obj#oleft_maker ;
    order_activity_match_side_hash = obj#oleft_hash ;
    order_activity_match_side_asset = asset ;
    order_activity_match_side_type = mk_side_type asset ;
  }, obj#oleft_make_asset_decimals

let mk_right_side obj =
  let|$ asset = mk_asset
      obj#oright_take_asset_type_class
      obj#oright_take_asset_type_contract
      obj#oright_take_asset_type_token_id
      obj#oright_take_asset_value in
  {
    order_activity_match_side_maker = obj#oright_maker ;
    order_activity_match_side_hash = obj#oright_hash ;
    order_activity_match_side_asset = asset ;
    order_activity_match_side_type = mk_side_type asset ;
  }, obj#oright_take_asset_decimals

let mk_order_activity_match obj =
  let$ left, left_decimals = mk_left_side obj in
  let$ right, right_decimals = mk_right_side obj in
  let|$ price = nft_price
      left.order_activity_match_side_asset
      right.order_activity_match_side_asset in
  {
    order_activity_match_left = left ;
    order_activity_match_right = right ;
    order_activity_match_price = price ;
    order_activity_match_type =
      if obj#oleft_salt <> Z.zero then
        begin match left.order_activity_match_side_asset.asset_type with
          | ATNFT _ | ATMT _ -> MTSELL
          | _ -> MTACCEPT_BID
        end
      else if obj#oright_salt <> Z.zero then
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

let mk_order_activity_cancel obj =
  let$ make = mk_asset
      obj#make_asset_type_class
      obj#make_asset_type_contract
      obj#make_asset_type_token_id
      obj#make_asset_value in
  let|$ take = mk_asset
      obj#take_asset_type_class
      obj#take_asset_type_contract
      obj#take_asset_type_token_id
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
  match make.asset_type with
  | ATNFT _ | ATMT _ ->
    OrderActivityCancelList bid, decs
  | _ ->
    OrderActivityCancelBid bid, decs

let mk_order_activity obj =
  let|$ act, decs =
    match obj#order_activity_type with
    | "list" ->
      let|$ listing, decs = mk_order_activity_bid obj in
      OrderActivityList listing, decs
    | "bid" ->
      let|$ listing, decs = mk_order_activity_bid obj in
      OrderActivityBid listing, decs
    | "match" ->
      let|$ matched, decs = mk_order_activity_match obj in
      OrderActivityMatch matched, decs
    | "cancel" -> mk_order_activity_cancel obj
    | _ as t -> Error (`hook_error ("unknown order activity type " ^ t)) in
  {
    order_act_id = obj#id ;
    order_act_date = obj#date ;
    order_act_source = "RARIBLE";
    order_act_type = act ;
  }, decs


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
        | hl, _hr when hl = hash -> r#fill_make_value
        | _hl, hr when hr = hash -> r#fill_take_value
        | _ -> Z.zero in
      Z.add acc_fill fill)
    Z.zero rows

let get_cancelled hash l =
  List.exists (fun r -> r#cancel = Some hash) l

let get_ft_balance ?dbh ?token_id ~contract account =
  let no_token_id = Option.is_none token_id in
  use dbh @@ fun dbh ->
  let>? l = [%pgsql dbh
      "select decimals from ft_contracts where address = $contract and \
       ($no_token_id or token_id = $?token_id)"] in
  match l with
  | [] | _ :: _ :: _ -> Lwt.return_error (`hook_error "contract_not_found")
  | [ decimals ] ->
    let>? l = [%pgsql dbh
        "select balance from token_balance_updates where contract = $contract \
         and account = $account and main and ($no_token_id or token_id = $?token_id) order by level desc limit 1"] in
    match l with
    | [] | _ :: _ :: _ | [ None ] -> Lwt.return_error (`hook_error "balance_not_found")
    | [ Some b ] -> Lwt.return_ok (b, Some decimals)

let get_make_balance ?dbh make owner = match make.asset_type with
  | ATXTZ -> Lwt.return_ok Z.zero
  | ATFT {contract; token_id} ->
    let|>? b, _dec = get_ft_balance ?dbh ?token_id ~contract owner in
    b
  | ATNFT { asset_contract ; asset_token_id } | ATMT { asset_contract ; asset_token_id } ->
    use dbh @@ fun dbh ->
    let|>? l = [%pgsql.object dbh
        "select amount from tokens where \
         main and \
         contract = $asset_contract and token_id = $asset_token_id and \
         owner = $owner"] in
    match l with
    | [ r ] -> r#amount
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
      "select * from order_cancel \
       where main and (cancel = $hash) order by tsp"] in
  match cancel with
  | [ cancel ] ->
    Lwt.return_ok (Z.zero, Z.zero, true, cancel#tsp, Z.zero)
  | _ ->
    let>? matches = [%pgsql.object dbh
        "select * from order_match \
         where main and \
         (hash_left = $hash or hash_right = $hash) order by tsp"] in
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
      order_obj#make_asset_type_token_id
      order_obj#make_asset_value in
  let>? order_elt_take = Lwt.return @@ mk_asset
      order_obj#take_asset_type_class
      order_obj#take_asset_type_contract
      order_obj#take_asset_type_token_id
      order_obj#take_asset_value in
  let>? price_history = get_order_price_history ?dbh order_obj#hash in
  let>? origin_fees = get_order_origin_fees ?dbh order_obj#hash in
  let>? payouts = get_order_payouts ?dbh order_obj#hash in
  let data = {
    order_rarible_v2_data_v1_data_type = "RARIBLE_V2_DATA_V1" ;
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
    order_elt_salt = order_obj#salt ;
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
         contract = $contract and token_id = $token_id"] in
  filter_creators @@
  List.map (fun r -> { part_account = r#account ; part_value = r#value} ) r

let get_nft_item_owners dbh ~contract ~token_id =
  [%pgsql dbh
      "select owner FROM tokens where main and \
       amount > 0::mpz and contract = $contract and token_id = $token_id"]

let mk_nft_ownership dbh obj =
  let contract = obj#contract in
  let token_id = obj#token_id in
  let|>? creators = get_nft_item_creators dbh ~contract ~token_id in
  (* TODO : last <> mint date ? *)
  {
    nft_ownership_id = Option.get obj#id ;
    nft_ownership_contract = contract ;
    nft_ownership_token_id = token_id ;
    nft_ownership_owner = obj#owner ;
    nft_ownership_creators = creators ;
    nft_ownership_value = obj#amount ;
    nft_ownership_lazy_value = Z.zero ;
    nft_ownership_date = obj#last ;
    nft_ownership_created_at = obj#tsp ;
  }

let get_nft_ownership_by_id ?dbh ?(old=false) contract token_id owner =
  (* TODO : OWNERSHIP NOT FOUND *)
  Format.eprintf "get_nft_ownership_by_id %s %s %s@." contract (Z.to_string token_id) owner ;
  use dbh @@ fun dbh ->
  let>? l = [%pgsql.object dbh
      "select concat(contract, ':', token_id, ':', owner) as id, \
       contract, token_id, owner, last, tsp, amount, supply, metadata \
       from tokens where \
       main and contract = $contract and token_id = $token_id and \
       owner = $owner and (amount > 0::mpz or $old)"] in
  match l with
  | [] -> Lwt.return_error (`hook_error "not found")
  | _ ->
    let>? obj = one l in
    let>? nft_ownership = mk_nft_ownership dbh obj in
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
         contract = $contract and token_id = $token_id and main"] in
  match l with
  | [] -> Lwt.return_ok None
  | _ ->
    let formats = List.map (fun r -> mk_tzip21_format r) l in
    Lwt.return_ok (Some formats)

let mk_tzip21_attribute r =
  Lwt.return_ok {
    attribute_name = r#name ;
    attribute_value = r#value ;
    attribute_type = r#typ ;
  }

let get_metadata_attributes dbh ~contract ~token_id =
  let>? l =
    [%pgsql.object dbh
        "select name, value, type as typ from tzip21_attributes where \
         contract = $contract and token_id = $token_id and main"] in
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
       contract = $contract and token_id = $token_id and main"] in
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

let rarible_attributes_of_tzip21_attributes = function
  | None -> None
  | Some attr ->
    Option.some @@
    List.map (fun a ->
        { nft_item_attribute_key = a.attribute_name ;
          nft_item_attribute_value = Some a.attribute_value ;
          nft_item_attribute_type = a.attribute_type ;
          nft_item_attribute_format = None ;
        }) attr

let rarible_meta_of_tzip21_meta meta =
  match meta with
  | None -> None
  | Some m ->
    Some {
      nft_item_meta_name = Option.value ~default:"Unnamed item" m.tzip21_tm_name ;
      nft_item_meta_description = m.tzip21_tm_description ;
      nft_item_meta_attributes = rarible_attributes_of_tzip21_attributes m.tzip21_tm_attributes ;
      nft_item_meta_image =
        begin match m.tzip21_tm_display_uri with
          | Some _ as uri -> uri
          | None ->
            begin match m.tzip21_tm_thumbnail_uri with
              | Some _ as uri -> uri
              | None ->
                begin match m.tzip21_tm_artifact_uri with
                  | Some _ as uri -> uri
                  | None -> None
                end
            end
        end ;
      nft_item_meta_animation = None ;
    }

let mk_nft_item dbh ?include_meta obj =
  let contract = obj#contract in
  let token_id = obj#token_id in
  let>? creators = get_nft_item_creators dbh ~contract ~token_id in
  get_nft_item_owners dbh ~contract ~token_id >>=? fun owners ->
  (* get_nft_item_royalties  >>=? fun royalties -> *)
  let>? meta = match include_meta with
    | Some true -> mk_nft_item_meta dbh ~contract ~token_id
    | _ -> Lwt.return_ok None in
  Lwt.return_ok {
    nft_item_id = Option.get obj#id ;
    nft_item_contract = contract ;
    nft_item_token_id = token_id ;
    nft_item_creators = creators ;
    nft_item_supply = obj#supply ;
    nft_item_lazy_supply = Z.zero ;
    nft_item_owners = owners ;
    nft_item_royalties = [] ;
    nft_item_date = obj#last ;
    nft_item_minted_at = obj#tsp ;
    nft_item_deleted = obj#supply = Z.zero ;
    nft_item_meta = rarible_meta_of_tzip21_meta meta ;
  }

let get_nft_item_by_id ?dbh ?include_meta contract token_id =
  Format.eprintf "get_nft_item_by_id %s %s %s@."
    contract
    (Z.to_string token_id)
    (match include_meta with None -> "None" | Some s -> string_of_bool s) ;
  use dbh @@ fun dbh ->
  let>? l = [%pgsql.object dbh
      "select concat(contract, ':', token_id::varchar) as id, contract, token_id, \
       last, amount, supply, metadata, tsp \
       from tokens where \
       main and contract = $contract and token_id = $token_id"] in
  match l with
  | obj :: _ ->
    let>? nft_item = mk_nft_item dbh ?include_meta obj in
    Lwt.return_ok nft_item
  | [] -> Lwt.return_error (`hook_error "not found")

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
  let nft_collection_minters = match obj#minters with
    | None -> None
    | Some a -> Some (List.filter_map (fun x -> x) a) in
  Ok {
    nft_collection_id = obj#address ;
    nft_collection_owner = obj#owner ;
    nft_collection_type ;
    nft_collection_name = name ;
    nft_collection_symbol = symbol ;
    nft_collection_features = [] ;
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
  | [] -> Lwt.return_error (`hook_error "not found")
  | obj :: _ ->
    Lwt.return @@ mk_nft_collection obj

let produce_order_event_hash dbh hash =
  let>? order = get_order ~dbh hash in
  begin
    match order with
    | Some (order, decs) ->
      Rarible_kafka.produce_order_event ~decs (mk_order_event order)
    | None -> Lwt.return ()
  end >>= fun () ->
  Lwt.return_ok ()

let produce_order_event_item dbh old_owner contract token_id =
  let>? l =
    [%pgsql.object dbh
        "select hash from orders \
         where make_asset_type_contract = $contract and \
         make_asset_type_token_id = $token_id and \
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
  Rarible_kafka.produce_collection_event (mk_nft_collection_event c)
  >>= fun () ->
  Lwt.return_ok ()

let produce_update_collection_event dbh contract =
  let>? c = get_nft_collection_by_id ~dbh contract in
  produce_nft_collection_event c

let produce_nft_ownership_update_event os =
  if os.nft_ownership_value = Z.zero then
    Rarible_kafka.produce_ownership_event (mk_delete_ownership_event os)
  else
    Rarible_kafka.produce_ownership_event (mk_update_ownership_event os)

let produce_nft_ownership_event dbh contract token_id owner =
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
        "select amount from tokens where contract = $contract and \
         owner = $owner and token_id = $token_id"] in
  match l with
  | [ amount ] -> Some amount
  | _ -> None

let insert_account dbh addr ~block ~tsp ~level =
  [%pgsql dbh
      "insert into accounts(address, last_block, last_level, last) \
       values($addr, $block, $level, $tsp) on conflict do nothing"]

let insert_nft_activity dbh index timestamp nft_activity =
  let act_type, act_from, elt =  match nft_activity with
    | NftActivityMint elt -> "mint", None, elt
    | NftActivityBurn elt -> "burn", None, elt
    | NftActivityTransfer {elt; from} -> "transfer", Some from, elt in
  let token_id = elt.nft_activity_token_id in
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
  nft_activity_token_id = obj#token_id ;
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

let get_or_timeout url =
  let timeout = Lwt_unix.sleep 30. >>= fun () -> Lwt.return_error (-1, Some "timeout") in
  Lwt.pick [ timeout ; EzReq_lwt.get url ]

let get_metadata_json meta =
  Format.eprintf "get_metadata_json %s@." meta ;
  (* 3 ways to recovers metadata :directly json, ipfs link and http(s) link *)
  try
    Lwt.return_ok (meta, EzEncoding.destruct token_metadata_enc meta)
  with _ ->
    begin
      let proto = try String.sub meta 0 6 with _ -> "" in
      if proto = "https:" || proto = "http:/" then get_or_timeout (EzAPI.URL meta)
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
        Format.eprintf "get_metadata_json %s %s@." fs url ;
        get_or_timeout
          (EzAPI.URL (Printf.sprintf "https://cloudflare-ipfs.com/%s%s" fs url))
      else Lwt.return_error (0, Some (Printf.sprintf "unknow scheme %s"proto))
    end >>= function
    | Ok json ->
      begin try
          let metadata = EzEncoding.destruct token_metadata_enc json in
          Lwt.return_ok (json, metadata)
        with _ -> Lwt.return_error (-1, None)
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
  | None ->
    Lwt.return_ok ()

let insert_mint_metadata_creators  dbh ~contract ~token_id ~block ~level ~tsp ~metadata =
  match metadata.tzip21_tm_creators with
  | Some (CParts l) ->
    iter_rp (fun p ->
        try
          ignore @@
          Tzfunc.Crypto.(Base58.decode ~prefix:Prefix.contract_public_key_hash p.part_account) ;
          [%pgsql dbh
              "insert into tzip21_creators(contract, token_id, block, level, \
               tsp, account, value) \
               values($contract, $token_id, $block, $level, $tsp, \
               ${p.part_account}, ${p.part_value}) \
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
               tsp, account, value) \
               values($contract, $token_id, $block, $level, $tsp, $part_account, \
               $part_value) \
               on conflict do nothing"]
        with _ -> Lwt.return_ok ())
      l
  | Some (CTZIP12 l) ->
    let len = List.length l in
    let value = Int32.of_int (10000 / len) in
    iter_rp (fun part_account ->
        try
          ignore @@
          Tzfunc.Crypto.(Base58.decode ~prefix:Prefix.contract_public_key_hash part_account) ;
          [%pgsql dbh
              "insert into tzip21_creators(contract, token_id, block, level, \
               tsp, account, value) \
               values($contract, $token_id, $block, $level, $tsp, \
               $part_account, $value) \
               on conflict do nothing"]
        with _ -> Lwt.return_ok ())
      l
  | None ->
    Lwt.return_ok ()

let insert_mint_metadata_formats dbh ~contract ~token_id ~block ~level ~tsp ~metadata =
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
           dimensions_value, dimensions_unit, data_rate_value, data_rate_unit) \
           values($contract, $token_id, $block, $level, $tsp, ${f.format_uri}, \
           $?{f.format_hash}, $?{f.format_mime_type}, $?size, \
           $?{f.format_file_name}, $?{f.format_duration}, $?dim_value, \
           $?dim_unit, $?dr_value, $?dr_unit) \
           on conflict (uri, contract, token_id) do update set \
           uri = ${f.format_uri}, hash = $?{f.format_hash}, \
           mime_type = $?{f.format_mime_type}, file_size = $?size, \
           file_name = $?{f.format_file_name}, \
           duration = $?{f.format_duration}, \
           dimensions_value = $?dim_value, \
           dimensions_unit = $?dim_unit, \
           data_rate_value = $?dr_value, \
           data_rate_unit = $?dr_unit \
           where tzip21_formats.contract = $contract and \
           tzip21_formats.token_id = $token_id and \
           tzip21_formats.uri = ${f.format_uri}"])
    formats
  | None -> Lwt.return_ok ()

let insert_mint_metadata_attributes dbh ~contract ~token_id ~block ~level ~tsp ~metadata =
  match metadata.tzip21_tm_attributes with
  | Some attributes ->
    iter_rp (fun a ->
        [%pgsql dbh
            "insert into tzip21_attributes(contract, token_id, block, level, \
             tsp, name, value, type) \
             values($contract, $token_id, $block, $level, $tsp, \
             ${a.attribute_name}, ${a.attribute_value}, $?{a.attribute_type}) \
             on conflict (name, contract, token_id) do update set \
             value = ${a.attribute_value}, \
             type = $?{a.attribute_type} \
             where tzip21_attributes.contract = $contract and \
             tzip21_attributes.token_id = $token_id and \
             tzip21_attributes.name = ${a.attribute_name}"])
      attributes
  | None -> Lwt.return_ok ()

let insert_mint_metadata dbh ~contract ~token_id ~block ~level ~tsp ~metadata =
  let>? () =
    insert_mint_metadata_creators dbh ~contract ~token_id ~block ~level ~tsp ~metadata in
  let>? () =
    insert_mint_metadata_formats dbh ~contract ~token_id ~block ~level ~tsp ~metadata in
  let>? () =
    insert_mint_metadata_attributes dbh ~contract ~token_id ~block ~level ~tsp ~metadata in
  let name = metadata.tzip21_tm_name in
  let symbol = metadata.tzip21_tm_symbol in
  let decimals = Option.bind metadata.tzip21_tm_decimals (fun i -> Some (Int32.of_int i))  in
  let artifact_uri = metadata.tzip21_tm_artifact_uri in
  let display_uri = metadata.tzip21_tm_display_uri in
  let thumbnail_uri = metadata.tzip21_tm_thumbnail_uri in
  let description = metadata.tzip21_tm_description in
  let minter = metadata.tzip21_tm_minter in
  let is_boolean_amount = metadata.tzip21_tm_is_boolean_amount in
  let tags = match metadata.tzip21_tm_tags with
    | None -> None
    | Some t -> Some (List.map Option.some t) in
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
       is_transferable, should_prefer_symbol) \
       values ($contract, $token_id, $block, $level, $tsp, $?name, $?symbol, \
       $?decimals, $?artifact_uri, $?display_uri, $?thumbnail_uri, \
       $?description, $?minter, $?is_boolean_amount, $?tags, $?contributors, \
       $?publishers, $?date, $?block_level, $?genres, $?language, $?rights, \
       $?right_uri, $?is_transferable, $?should_prefer_symbol) \
       on conflict (contract, token_id) do update set \
       name = $?name, symbol = $?symbol, decimals = $?decimals, \
       artifact_uri = $?artifact_uri, display_uri = $?display_uri, \
       thumbnail_uri = $?thumbnail_uri, description = $?description, \
       minter = $?minter, is_boolean_amount = $?is_boolean_amount, \
       tags = $?tags, contributors = $?contributors, publishers = $?publishers, \
       date = $?date, block_level = $?block_level, genres = $?genres, \
       language = $?language, rights = $?rights, right_uri = $?right_uri, \
       is_transferable = $?is_transferable, \
       should_prefer_symbol = $?should_prefer_symbol \
       where tzip21_metadata.contract = $contract and \
       tzip21_metadata.token_id = $token_id"]

let get_uri_pattern ~dbh contract =
  let>? l =
    [%pgsql dbh
        "select uri_pattern from contracts \
         where main and address = $contract order by level desc"] in
  match l with
  | [] -> Lwt.return_ok None
  | p :: _ -> Lwt.return_ok p

let insert_mint ~dbh ~op ~contract m =
  let block = op.bo_block in
  let level = op.bo_level in
  let tsp = op.bo_tsp in
  let>? pattern = get_uri_pattern ~dbh contract in
  let token_id, owner, amount, uri = match m with
    | NFTMint m -> m.fa2m_token_id, m.fa2m_owner, Z.one, None
    | MTMint m -> m.fa2m_token_id, m.fa2m_owner, m.fa2m_amount, None
    | UbiMint m ->
      m.ubim_token_id, m.ubim_owner, Z.one,
      Option.map (fun pattern -> replace_token_id ~pattern (Z.to_string m.ubim_token_id)) pattern
    | UbiMint2 m ->
      m.ubi2m_token_id, m.ubi2m_owner, m.ubi2m_amount,
      List.assoc_opt "" m.ubi2m_metadata in
  let>? () = insert_account dbh owner ~block:op.bo_block ~level:op.bo_level ~tsp:op.bo_tsp in
  let>? () = match uri with
    | Some meta ->
      begin
        get_metadata_json meta >>= function
        | Ok (json, metadata) ->
          let>? () =
            insert_mint_metadata dbh ~contract ~token_id ~block ~level ~tsp ~metadata in
          [%pgsql dbh
              "insert into tokens(contract, token_id, block, level, tsp, \
               last_block, last_level, last, owner, amount, metadata, \
               transaction, supply) \
               values($contract, $token_id, $block, $level, $tsp, $block, \
               $level, $tsp, $owner, 0, $json, ${op.bo_hash}, 0) \
               on conflict (contract, owner, token_id) do update set \
               metadata = $json \
               where tokens.contract = $contract and \
               tokens.token_id = $token_id and \
               tokens.owner = $owner"]
        | Error (code, str) ->
          Printf.eprintf "Cannot get metadata from url: %d %s\n%!"
            code (match str with None -> "None" | Some s -> s);
          [%pgsql dbh
              "insert into tokens(contract, token_id, block, level, tsp, \
               last_block, last_level, last, owner, \
               amount, transaction, supply) \
               values($contract, $token_id, $block, $level, $tsp, \
               $block, $level, $tsp, $owner, 0, ${op.bo_hash}, 0) \
               on conflict do nothing"]
      end
    | None ->
      [%pgsql dbh
          "insert into tokens(contract, token_id, block, level, tsp, \
           last_block, last_level, last, owner, \
           amount, transaction, supply) \
           values($contract, $token_id, $block, $level, $tsp, $block, $level, \
           $tsp, $owner, 0, ${op.bo_hash}, 0) \
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

let insert_burn ~dbh ~op ~contract m =
  let burn = EzEncoding.construct Json_encoding.(tup2 burn_enc string) (m, op.bo_op.source) in
  let token_id, owner, amount = match m with
    | MTBurn { amount; token_id } -> token_id, "", amount
    | NFTBurn token_id -> token_id, "", Z.one in
  let>? () =
    [%pgsql dbh
        "insert into contract_updates(transaction, index, block, level, tsp, \
         contract, burn) \
         values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
         ${op.bo_tsp}, $contract, $burn) on conflict do nothing"] in
  insert_nft_activity_burn dbh op contract token_id owner amount

let insert_transfer ~dbh ~op ~contract lt =
  let|>? _ = fold_rp (fun transfer_index {tr_source; tr_txs} ->
      let>? () = insert_account dbh tr_source ~block:op.bo_block ~level:op.bo_level ~tsp:op.bo_tsp in
      fold_rp (fun transfer_index {tr_destination; tr_token_id; tr_amount} ->
          let>? () = [%pgsql dbh
              "insert into tokens(contract, token_id, block, level, tsp, \
               last_block, last_level, last, owner, amount, \
               metadata, transaction, supply) \
               values($contract, $tr_token_id, ${op.bo_block}, ${op.bo_level}, ${op.bo_tsp}, \
               ${op.bo_block}, ${op.bo_level}, ${op.bo_tsp}, \
               $tr_source, 0, '{}', ${op.bo_hash}, 0) on conflict do nothing"] in
          let>? () = [%pgsql dbh
              "insert into tokens(contract, token_id, block, level, tsp, \
               last_block, last_level, last, owner, amount, \
               metadata, transaction, supply) \
               values($contract, $tr_token_id, ${op.bo_block}, ${op.bo_level}, ${op.bo_tsp}, \
               ${op.bo_block}, ${op.bo_level}, ${op.bo_tsp}, \
               $tr_destination, 0, '{}', ${op.bo_hash}, 0) on conflict do nothing"] in
          let>? () =
            insert_account dbh tr_destination ~block:op.bo_block ~level:op.bo_level ~tsp:op.bo_tsp in
          let>? () = [%pgsql dbh
              "insert into token_updates(transaction, index, block, level, tsp, \
               source, destination, contract, token_id, amount, transfer_index) \
               values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
               ${op.bo_tsp}, $tr_source, $tr_destination, $contract, \
               $tr_token_id, $tr_amount, $transfer_index) \
               on conflict do nothing"] in
          let|>? () = insert_nft_activity_transfer
              dbh op contract tr_source tr_destination tr_token_id tr_amount in
          Int32.succ transfer_index
        ) transfer_index tr_txs) 0l lt in
  ()

let insert_token_balances ~dbh ~op ~contract ?(ft=false) balances =
  iter_rp (fun (k, v) ->
      let kind, token_id, account, balance = match k, v, ft with
        | `nat id, Some (`address a), false ->
          "nft", id, Some a, None
        | `nat id, None, false -> "nft", id, None, None
        | `tuple [`nat id; `address a], Some (`nat bal), false
        | `tuple [`address a; `nat id], Some (`nat bal), false ->
          "mt", id, Some a, Some bal
        | `tuple [`nat id; `address a], None, false
        | `tuple [`address a; `nat id], None, false ->
          "mt", id, Some a, None
        | `tuple [`nat id; `address a], Some (`nat bal), true
        | `tuple [`address a; `nat id], Some (`nat bal), true ->
          "ft_multi", id, Some a, Some bal
        | `tuple [`nat id; `address a], None, true
        | `tuple [`address a; `nat id], None, true ->
          "ft_multi", id, Some a, None
        | `address a, Some (`nat bal), true ->
          "ft", Z.minus_one, Some a, Some bal
        | `address a, None, true ->
          "ft", Z.minus_one, Some a, None
        | `tuple [`address a; `nat _], Some (`tuple (`nat bal :: _)), true ->
          "ft", Z.minus_one, Some a, Some bal
        | _ -> "", Z.minus_one, None, None in
      if kind <> "" then
        let>? () = [%pgsql dbh
            "insert into token_balance_updates(transaction, index, block, level, \
             tsp, kind, contract, token_id, account, balance) \
             values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
             ${op.bo_tsp}, $kind, $contract, $token_id, $?account, $?balance) on conflict do nothing"] in
        match account, ft with
        | None, _ | _, true -> Lwt.return_ok ()
        | Some a, _ ->
          [%pgsql dbh
              "insert into tokens(contract, token_id, block, level, tsp, \
               last_block, last_level, last, owner, amount, \
               metadata, transaction, supply) \
               values($contract, $token_id, ${op.bo_block}, ${op.bo_level}, ${op.bo_tsp}, \
               ${op.bo_block}, ${op.bo_level}, ${op.bo_tsp}, \
               $a, 0, '{}', ${op.bo_hash}, 0) on conflict do nothing"]
          (* todo: get supply from other owner *)
      else Lwt.return_ok ()) balances

let insert_update_operator ~dbh ~op ~contract lt =
  iter_rp (fun {op_owner; op_operator; op_token_id; op_add} ->
      let>? () = [%pgsql dbh
          "insert into token_updates(transaction, index, block, level, tsp, \
           source, operator, add, contract, token_id) \
           values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
           ${op.bo_tsp}, $op_owner, $op_operator, $op_add, \
           $contract, $op_token_id) on conflict do nothing"] in
      insert_account dbh op_operator ~block:op.bo_block ~level:op.bo_level ~tsp:op.bo_tsp) lt

let insert_update_operator_all ~dbh ~op ~contract lt =
  let source = op.bo_op.source in
  iter_rp (fun (operator, add) ->
      let>? () = [%pgsql dbh
          "insert into token_updates(transaction, index, block, level, tsp, \
           source, operator, add, contract) \
           values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
           ${op.bo_tsp}, $source, $operator, $add, $contract) on conflict do nothing"] in
      insert_account dbh operator ~block:op.bo_block ~level:op.bo_level ~tsp:op.bo_tsp) lt

let insert_metadata_uri ~dbh ~op ~contract s =
  [%pgsql dbh
      "insert into contract_updates(transaction, index, block, level, tsp, \
       contract, uri) \
       values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
       ${op.bo_tsp}, $contract, $s) \
       on conflict do nothing"]

let insert_token_metadata ~dbh ~op ~contract (token_id, l) =
  let>? json, tzip21_meta =
    match List.assoc_opt "" l with
    | Some meta ->
      begin
        get_metadata_json meta >>= function
        | Ok (_json, metadata) ->
          Lwt.return_ok (EzEncoding.construct Rtypes.token_metadata_enc l, Some metadata)
        | Error (code, str) ->
          Printf.eprintf "Cannot get metadata from url: %d %s\n%!"
            code (match str with None -> "None" | Some s -> s);
          Lwt.return_ok (EzEncoding.construct Rtypes.token_metadata_enc l, None)
      end
    | None ->
      Lwt.return_ok (EzEncoding.construct Rtypes.token_metadata_enc l, None) in
  let source = op.bo_op.source in
  let block = op.bo_block in
  let level = op.bo_level in
  let tsp = op.bo_tsp in
  let>? () =
    [%pgsql dbh
        "insert into token_updates(transaction, index, block, level, tsp, \
         source, token_id, contract, metadata) \
         values(${op.bo_hash}, ${op.bo_index}, $block, $level, $tsp, $source,\
         $token_id, $contract, $json) on conflict do nothing"] in
  match tzip21_meta with
  | None -> Lwt.return_ok ()
  | Some metadata -> insert_mint_metadata dbh ~contract ~token_id ~block ~level ~tsp ~metadata

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
      "select block, level, tsp, metadata from token_updates where \
       main and contract = $contract and token_id = $token_id ORDER BY block desc LIMIT 1"] in
  match l with
  | [] -> Lwt.return_error (`hook_error (Printf.sprintf "no %s:%s item" contract (Z.to_string token_id)))
  | [ _, _, _, None ] ->
    Lwt.return_error (`hook_error (Printf.sprintf "no metadata for %s:%s item" contract (Z.to_string token_id)))
  | [ block, level, tsp, Some json ] ->
    begin
      try
        let l = EzEncoding.destruct Rtypes.token_metadata_enc json in
        match List.assoc_opt "" l with
        | Some meta ->
          begin
            get_metadata_json meta >>= function
            | Ok (_json, metadata) ->
              insert_mint_metadata dbh ~contract ~token_id ~block ~level ~tsp ~metadata
            | Error (code, str) ->
              Lwt.return_error
                (`hook_error
                   (Printf.sprintf "fetch metadata error %d:%s" code @@
                    Option.value ~default:"None" str))
          end
        | None -> Lwt.return_ok ()
      with _ ->
        Lwt.return_error (`hook_error (Printf.sprintf "wrong json for %s:%s item" contract (Z.to_string token_id)))
    end
  | _ ->
    Lwt.return_error (`hook_error (Printf.sprintf "several results on LIMIT 1"))

let db_from_asset ?dbh asset =
  match asset.asset_type with
  | ATXTZ ->
    Lwt.return_ok (string_of_asset_type asset.asset_type, None, None,
                   asset.asset_value, Some 6l)
  | ATFT {contract; token_id} ->
    let no_token_id = Option.is_none token_id in
    use dbh @@ fun dbh ->
    let>? l = [%pgsql dbh "select decimals from ft_contracts where address = $contract \
                           and ($no_token_id or token_id = $?token_id)"] in
    begin match l with
      | [] | _ :: _ :: _ -> Lwt.return_error (`hook_error "ft_contract_not_found")
      | [ decimals ] ->
        Lwt.return_ok
          (string_of_asset_type asset.asset_type, Some contract, None,
           asset.asset_value, Some decimals)
    end
  | ATNFT fa2 | ATMT fa2 ->
    Lwt.return_ok (string_of_asset_type asset.asset_type, Some fa2.asset_contract,
                   Some fa2.asset_token_id, asset.asset_value, None)

let insert_royalties ~dbh ~op roy =
  let royalties = EzEncoding.(construct token_royalties_enc roy.roy_royalties) in
  let source = op.bo_op.source in
  [%pgsql dbh
      "insert into token_updates(transaction, index, block, level, tsp, \
       source, token_id, contract, royalties) \
       values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
       ${op.bo_tsp}, $source, ${roy.roy_token_id}, ${roy.roy_contract}, $royalties) \
       on conflict do nothing"]

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
        level activity.order_act_date "cancel"
    | OrderActivityCancelBid act ->
      let hash = Some act.order_activity_cancel_bid_hash in
      let transaction = Some act.order_activity_cancel_bid_transaction_hash in
      let block = Some act.order_activity_cancel_bid_block_hash in
      let level = Some (Int64.to_int32 act.order_activity_cancel_bid_block_number) in
      insert_order_activity
        dbh activity.order_act_id None None hash transaction block
        level activity.order_act_date "cancel"
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

let get_decimals ?dbh = function
  | ATXTZ -> Lwt.return_ok (Some 6l)
  | ATNFT _ | ATMT _ -> Lwt.return_ok None
  | ATFT {contract; token_id} ->
    let no_token_id = Option.is_none token_id in
    use dbh @@ fun dbh ->
    let>? l = [%pgsql dbh
        "select decimals from ft_contracts where address = $contract \
         and ($no_token_id or token_id = $?token_id)"] in
    let|>? i = one l in
    Some i

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

let insert_cancel ~dbh ~op (hash : Tzfunc.H.t) =
  let hash = ( hash :> string ) in
  let source = op.bo_op.source in
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
  let>? () = match left_maker_edpk with
    | None -> Lwt.return_ok ()
    | Some maker_edpk ->
      let signature = "NO_SIGNATURE" in
      let>? left_make_class, left_make_contract,
            left_make_token_id, left_make_asset_value, left_make_decimals =
        db_from_asset left_make_asset in
      let>? left_take_class, left_take_contract,
            left_take_token_id, left_take_asset_value, left_take_decimals =
        db_from_asset left_take_asset in
      let created_at = CalendarLib.Calendar.now () in
      [%pgsql dbh
          "insert into orders(maker, maker_edpk, \
           make_asset_type_class, make_asset_type_contract, make_asset_type_token_id, \
           make_asset_value, make_asset_decimals, \
           take_asset_type_class, take_asset_type_contract, take_asset_type_token_id, \
           take_asset_value, take_asset_decimals, \
           salt, signature, created_at, last_update_at, hash) \
           values($?left_maker, $maker_edpk, \
           $left_make_class, $?left_make_contract, $?left_make_token_id, \
           $left_make_asset_value, $?left_make_decimals, \
           $left_take_class, $?left_take_contract, $?left_take_token_id, \
           $left_take_asset_value, $?left_take_decimals, \
           $left_salt, $signature, $created_at, $created_at, $left) \
           on conflict do nothing"] in
  let>? () = match right_maker_edpk with
    | None -> Lwt.return_ok ()
    | Some maker_edpk ->
      let signature = "NO_SIGNATURE" in
      let>? right_make_class, right_make_contract,
            right_make_token_id, right_make_asset_value, right_make_decimals =
        db_from_asset right_make_asset in
      let>? right_take_class, right_take_contract,
            right_take_token_id, right_take_asset_value, right_take_decimals =
        db_from_asset right_take_asset in
      let created_at = CalendarLib.Calendar.now () in
      [%pgsql dbh
          "insert into orders(maker, maker_edpk, \
           make_asset_type_class, make_asset_type_contract, make_asset_type_token_id, \
           make_asset_value, make_asset_decimals, \
           take_asset_type_class, take_asset_type_contract, take_asset_type_token_id, \
           take_asset_value, take_asset_decimals, \
           salt, signature, created_at, last_update_at, hash) \
           values($?right_maker, $maker_edpk, \
           $right_make_class, $?right_make_contract, $?right_make_token_id, \
           $right_make_asset_value, $?right_make_decimals, \
           $right_take_class, $?right_take_contract, $?right_take_token_id, \
           $right_take_asset_value, $?right_take_decimals, \
           $right_salt, $signature, $created_at, $created_at, $right) \
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

let insert_ft ~dbh ~config ~op ~contract ft =
  Format.printf "\027[0;35mFT update %s %ld %s\027[0m@."
    (short op.bo_hash) op.bo_index (short contract);
  let>? crawled = check_ft_status ~dbh ~config ~crawled:ft.ft_crawled contract in
  match crawled, op.bo_meta with
  | false, _ | _, None ->
    Lwt.return_ok ()
  | _, Some meta ->
    let id = ft.ft_ledger_id in
    let key, value = match ft.ft_kind with
      | Fa2_single -> Contract_spec.ledger_fa2_single_field
      | Fa2_multiple -> Contract_spec.ledger_fa2_multiple_field
      | Lugh -> Contract_spec.ledger_lugh_field
      | Fa1 -> Contract_spec.ledger_fa1_field
      | Fa2_multiple_inversed -> Contract_spec.ledger_fa2_multiple_inversed_field
      | Custom {ledger_key; ledger_value} -> ledger_key, ledger_value in
    let balances = Storage_diff.get_big_map_updates ~id key value meta.op_lazy_storage_diff in
    insert_token_balances ~dbh ~op ~contract ~ft:true balances

let insert_transaction ~config ~dbh ~op tr =
  let contract = tr.destination in
  match tr.parameters, op.bo_meta with
  | None, _ | Some { value = Other _; _ }, _ | Some { value = Bytes _; _ }, _ | _, None -> Lwt.return_ok ()
  | Some {entrypoint; value = Micheline m}, Some meta ->
    if contract = config.Crawlori.Config.extra.royalties then (* royalties *)
      match Parameters.parse_royalties entrypoint m with
      | Ok roy ->
        Format.printf "\027[0;35mset royalties %s %ld\027[0m@." (Utils.short op.bo_hash) op.bo_index;
        insert_royalties ~dbh ~op roy
      | _ -> Lwt.return_ok ()
    else if contract = config.Crawlori.Config.extra.exchange_v2 then (* exchange_v2 *)
      begin match Parameters.parse_exchange entrypoint m with
        | Ok (Cancel hash) ->
          Format.printf "\027[0;35mcancel order %s %ld %s\027[0m@."
            (short op.bo_hash) op.bo_index (hash :> string);
          insert_cancel ~dbh ~op hash
        | Ok (DoTransfers
                {left; left_maker_edpk; left_maker; left_make_asset;
                 left_take_asset; left_salt;
                 right; right_maker_edpk; right_maker; right_make_asset;
                 right_take_asset; right_salt;
                 fill_make_value; fill_take_value}) ->
          Format.printf "\027[0;35mdo transfers %s %ld %s %s\027[0m@."
            (short op.bo_hash) op.bo_index (short (left :> string)) (short (right :> string));
          insert_do_transfers
            ~dbh ~op
            ~left ~left_maker_edpk ~left_maker ~left_make_asset ~left_take_asset ~left_salt
            ~right ~right_maker_edpk ~right_maker ~right_make_asset ~right_take_asset ~right_salt
            ~fill_make_value ~fill_take_value
        | _ ->
          (* todo : match order *)
          Lwt.return_ok ()
      end
    else match
        SMap.find_opt contract config.Crawlori.Config.extra.ft_contracts,
        SMap.find_opt contract config.Crawlori.Config.extra.contracts with
    | Some ft, _ -> insert_ft ~dbh ~config ~op ~contract ft
    | _, None -> Lwt.return_ok ()
    | _, Some ledger_info ->
      let balances = Storage_diff.get_big_map_updates ~id:ledger_info.nft_id
          ledger_info.nft_type.ledger_key ledger_info.nft_type.ledger_value
          meta.op_lazy_storage_diff in
      let>? () = insert_token_balances ~dbh ~op ~contract balances in
      match Parameters.parse_fa2 entrypoint m with
      | Ok (Mint_tokens m) ->
        Format.printf "\027[0;35mmint %s[%ld] %s\027[0m@."
          (short op.bo_hash) op.bo_index (short contract);
        insert_mint ~dbh ~op ~contract m
      | Ok (Burn_tokens b) ->
        Format.printf "\027[0;35mburn %s[%ld] %s\027[0m@."
          (short op.bo_hash) op.bo_index (short contract);
        insert_burn ~dbh ~op ~contract b
      | Ok (Transfers t) ->
        Format.printf "\027[0;35mtransfer %s[%ld] %s\027[0m@."
          (short op.bo_hash) op.bo_index (short contract);
        insert_transfer ~dbh ~op ~contract t
      | Ok (Operator_updates t) ->
        Format.printf "\027[0;35mupdate operator %s[%ld] %s\027[0m@."
          (short op.bo_hash) op.bo_index (short contract);
        insert_update_operator ~dbh ~op ~contract t
      | Ok (Operator_updates_all t) ->
        Format.printf "\027[0;35mupdate operator all %s[%ld] %s\027[0m@."
          (short op.bo_hash) op.bo_index (short contract);
        insert_update_operator_all ~dbh ~op ~contract t
      | Ok (Metadata_uri s) ->
        Format.printf "\027[0;35mset uri %s[%ld] %s\027[0m@."
          (short op.bo_hash) op.bo_index (short contract);
        insert_metadata_uri ~dbh ~op ~contract s
      | Ok (Token_metadata x) ->
        Format.printf "\027[0;35mset metadata %s[%ld] %s\027[0m@."
          (short op.bo_hash) op.bo_index (short contract);
        insert_token_metadata ~dbh ~op ~contract x
      | Ok (Add_minter a) ->
        Format.printf "\027[0;35madd minter %s[%ld] %s %s\027[0m@."
          (short op.bo_hash) op.bo_index (short contract) (short a);
        insert_minter ~dbh ~op ~contract ~add:true a
      | Ok (Remove_minter a) ->
        Format.printf "\027[0;35mremove minter %s[%ld] %s %s\027[0m@."
          (short op.bo_hash) op.bo_index (short contract) (short a);
        insert_minter ~dbh ~op ~contract ~add:false a
      | Ok (Token_uri_pattern s) ->
        Format.printf "\027[0;35mset token uri pattern %s[%ld] %s %s\027[0m@."
          (short op.bo_hash) op.bo_index (short contract) s;
        insert_uri_pattern ~dbh ~op ~contract s
      | Error _ -> Lwt.return_ok ()

let ledger_kind k v = match k, v with
  | `nat, `address -> `nft
  | `tuple [`nat; `address], `nat | `tuple [`address; `nat], `nat -> `multiple
  | `address, `nat -> `single
  | _ -> `unknown

let filter_contracts op ori =
  let open Contract_spec in
  match op.bo_meta, get_entrypoints ori.script with
  | Some meta, Ok entrypoints ->
    let allocs = Storage_diff.big_map_allocs meta.op_lazy_storage_diff in
    begin match
        match_entrypoints ~expected:(fa2_entrypoints @ fa2_ext_entrypoints) ~entrypoints,
        match_fields ~expected:["ledger"; "owner"; "admin"; "token_metadata_uri"] ~allocs ori.script
      with
      | [ b_balance; b_update; b_transfer; b_update_all; b_mint_nft; b_mint_mt;
          b_burn_nft; b_burn_mt; b_metadata ],
        Ok [ f_ledger; f_owner; f_admin; f_uri_pattern ] ->
        let fa2_spec = match b_balance && b_update && b_transfer, f_ledger with
          | true, (_, Some (id, k, v)) ->
            begin match ledger_kind k v with
              | `nft | `multiple -> Some (id, k, v)
              | _ -> None
            end
          | _ -> None in
        let ubi_spec = match f_admin, f_uri_pattern with
          | (Some (`address owner), _), (Some (`string uri), _) -> Some (owner, uri)
          | _ -> None in
        let rarible_spec =
          match b_update_all && (b_mint_nft || b_mint_mt)
                && (b_burn_nft || b_burn_mt) && b_metadata, f_owner with
          | true, (Some (`address owner), _) -> Some owner
          | _ -> None in
        begin match fa2_spec, rarible_spec, ubi_spec with
          | Some (id, k, v), Some owner, _ ->
            Some (`rarible (id, k, v, owner))
          | Some (id, k, v), _, Some (owner, uri) ->
            Some (`ubi (id, k, v, owner, uri))
          | Some (id, k, v), _, _ ->
            Some (`fa2 (id, k, v))
          | _ -> None
        end
      | _ -> None
    end
  | _ -> None

let insert_origination config dbh op ori =
  match filter_contracts op ori with
  | None ->
    Lwt.return_ok ()
  | Some k ->
    let kt1 = Tzfunc.Crypto.op_to_KT1 op.bo_hash in
    let kind, owner, ledger_id, ledger_key, ledger_value, contract_value, uri = match k with
      | `rarible (id, k, v, owner) ->
        "rarible", Some owner, id,
        EzEncoding.construct micheline_type_short_enc k,
        EzEncoding.construct micheline_type_short_enc v,
        {nft_id=id; nft_type={ledger_key=k; ledger_value=v}},
        None
      | `ubi (id, k, v, owner, uri) ->
        "ubi", Some owner, id,
        EzEncoding.construct micheline_type_short_enc k,
        EzEncoding.construct micheline_type_short_enc v,
        {nft_id=id; nft_type={ledger_key=k; ledger_value=v}},
        Some uri
      | `fa2 (id, k, v) ->
        "fa2", None, id,
        EzEncoding.construct micheline_type_short_enc k,
        EzEncoding.construct micheline_type_short_enc v,
        {nft_id=id; nft_type={ledger_key=k; ledger_value=v}},
        None in
    Format.printf "\027[0;93morigination %s (%s, %s)\027[0m@."
      (Utils.short kt1) kind (EzEncoding.construct nft_ledger_enc contract_value);
    let|>? () = [%pgsql dbh
        "insert into contracts(kind, address, owner, block, level, tsp, \
         last_block, last_level, last, ledger_id, ledger_key, ledger_value, uri_pattern) \
         values($kind, $kt1, $?owner, ${op.bo_block}, ${op.bo_level}, \
         ${op.bo_tsp}, ${op.bo_block}, ${op.bo_level}, ${op.bo_tsp}, $ledger_id, \
         $ledger_key, $ledger_value, $?uri) \
         on conflict do nothing"] in
    let open Crawlori.Config in
    config.extra.contracts <- SMap.add kt1 contract_value config.extra.contracts;
    match config.accounts with
    | None -> config.accounts <- Some (SSet.singleton kt1);
    | Some accs -> config.accounts <- Some (SSet.add kt1 accs)

let insert_operation config dbh op =
  let open Hooks in
  match op.bo_meta with
  | Some meta ->
    if meta.op_status = `applied then
      match op.bo_op.kind with
      | Transaction tr -> insert_transaction ~config ~dbh ~op tr
      (* | Origination ori -> set_origination config dbh op ori *)
      | _ -> Lwt.return_ok ()
    else Lwt.return_ok ()
  | _ -> Lwt.return_ok ()

let insert_block config dbh b =
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
                insert_origination config dbh op ori
              | _ -> Lwt.return_ok ()
            else Lwt.return_ok ()
        ) op.op_contents
    ) b.operations

let contract_updates_base dbh ~main ~contract ~block ~level ~tsp ~burn
    ~account ~token_id ~amount =
  let main_s = if main then Z.one else Z.minus_one in
  let factor = if burn then Z.neg main_s else main_s in
  let>? new_amount =
    let>? l = [%pgsql dbh
        "update tokens set supply = supply + $factor * $amount::mpz, \
         amount = amount + $factor * $amount::mpz, \
         last_block = case when $main then $block else last_block end, \
         last_level = case when $main then $level else last_level end, \
         last = case when $main then $tsp else last end \
         where token_id = $token_id and contract = $contract and owner = $account \
         returning amount"] in
    one l in
  let>? () = [%pgsql dbh
      "update tokens set supply = supply + $factor::mpz * $amount, \
       last_block = case when $main then $block else last_block end, \
       last_level = case when $main then $level else last_level end, \
       last = case when $main then $tsp else last end
       where token_id = $token_id and contract = $contract and owner <> $account"] in
  (* update account *)
  let new_token = EzEncoding.construct account_token_enc {
      at_token_id = token_id;
      at_contract = contract;
      at_amount = new_amount } in
  let old_token = EzEncoding.construct account_token_enc {
      at_token_id = token_id;
      at_contract = contract;
      at_amount = Z.(sub new_amount (mul main_s amount))  } in
  [%pgsql dbh
      "update accounts set tokens = array_append(array_remove(tokens, $old_token), $new_token), \
       last_block = case when $main then $block else last_block end, \
       last_level = case when $main then $level else last_level end, \
       last = case when $main then $tsp else last end where address = $account"]

let metadata_uri_enc =
  EzEncoding.ignore_enc @@ Json_encoding.(obj2 (req "name" string) (opt "symbol" string))

let metadata_uri_update dbh ~main ~contract ~block ~level ~tsp uri =
  if main then
    let name, symbol =
      try
        let name, symbol = EzEncoding.destruct metadata_uri_enc uri in
        Some name, symbol
      with _ -> None, None in
    [%pgsql dbh
        "update contracts set metadata = $uri, name = $?name, symbol = $?symbol, \
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
      let>? () = match r#mint, r#burn, r#uri, r#minter, r#uri_pattern with
        | Some json, _, _, _, _ ->
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
              (List.assoc_opt "" m.ubi2m_metadata) <> None in
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
        | _, Some json, _, _, _ ->
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
        | _, _, Some uri, _, _ ->
          let>? () = metadata_uri_update dbh ~main ~contract ~block ~level ~tsp uri in
          produce_update_collection_event dbh contract
        | _, _, _, Some minter, _ ->
          let>? () = minter_update dbh ~main ~contract ~block ~level ~tsp minter in
          produce_update_collection_event dbh contract
        | _, _, _, _, Some uri_pattern ->
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
          Option.value ~default:Z.zero last_token_id in
      [%pgsql dbh
          "update contracts set \
           tokens_number = $tokens_number, \
           last_token_id = $last_token_id \
           where address = $c"]) (SSet.elements contracts)

let operator_updates dbh ?token_id ~operator ~add ~contract ~block ~level ~tsp ~source main =
  let no_token_id = Option.is_none token_id in
  [%pgsql dbh
      "update tokens set \
       operators = case when ($main and $add) or (not $main and not $add) then \
       array_append(operators, $operator) else array_remove(operators, $operator) end, \
       last_block = case when $main then $block else last_block end, \
       last_level = case when $main then $level else last_level end, \
       last = case when $main then $tsp else last end \
       where ($no_token_id or token_id = $?token_id) and owner = $source and contract = $contract"]

let transfer_updates dbh main ~contract ~block ~level ~tsp ~token_id ~source amount destination =
  let amount = if main then amount else Z.neg amount in
  let>? info = [%pgsql dbh
      "update tokens set amount = amount - $amount::mpz, \
       last_block = case when $main then $block else last_block end, \
       last_level = case when $main then $level else last_level end, \
       last = case when $main then $tsp else last end where token_id = $token_id and \
       owner = $source and contract = $contract \
       returning amount, metadata, supply, transaction, tsp, royalties"] in
  let>? new_src_amount, meta, supply, transaction, tsp, royalties =
    one ~err:"source token not found for transfer update" info in
  let>? new_dst_amount =
    let>? l = [%pgsql dbh
        "update tokens set amount = amount + $amount::mpz, \
         metadata = case when amount = 0::mpz then $meta else metadata end, \
         royalties = case when amount = 0::mpz then $royalties else royalties end, \
         supply = case when amount = 0::mpz then $supply else supply end, \
         transaction = case when amount = 0::mpz then $transaction else transaction end, \
         last_block = case when $main then $block else block end, \
         last_level = case when $main then $level else level end, \
         last = case when $main then $tsp else last end where token_id = $token_id and \
         owner = $destination and contract = $contract returning amount"] in
    one ~err:"destination token not found for transfer update" l in
  let>? () =
    if main then
      let>? () = produce_nft_item_event dbh contract token_id in
      let>? () = produce_nft_ownership_event dbh contract token_id source in
      let>? () = produce_nft_ownership_event dbh contract token_id destination in
      produce_order_event_item dbh source contract token_id
    else Lwt.return_ok () in
  let at = { at_token_id = token_id; at_contract = contract;
             at_amount = new_src_amount } in
  let new_token_src = EzEncoding.construct account_token_enc at in
  let old_token_src = EzEncoding.construct account_token_enc {at with at_amount = Z.add new_src_amount amount} in
  let new_token_dst = EzEncoding.construct account_token_enc {at with at_amount = new_dst_amount} in
  let old_token_dst = EzEncoding.construct account_token_enc {at with at_amount = Z.sub new_dst_amount amount} in
  let>? () =
    [%pgsql dbh
        "update accounts set \
         last_block = case when $main then $block else last_block end, \
         last_level = case when $main then $level else last_level end, \
         last = case when $main then $tsp else last end, \
         tokens = array_append(array_remove(tokens, $old_token_src), $new_token_src) \
         where address = $source"] in
  [%pgsql dbh
      "update accounts set \
       last_block = case when $main then $block else last_block end, \
       last_level = case when $main then $level else last_level end, \
       last = case when $main then $tsp else last end, \
       tokens = array_append(array_remove(tokens, $old_token_dst), $new_token_dst) \
       where address = $destination"]

let token_metadata_update dbh ~main ~contract ~block ~level ~tsp ~token_id meta =
  [%pgsql dbh
      "update tokens set metadata = $meta, \
       last_block = case when $main then $block else last_block end, \
       last_level = case when $main then $level else last_level end, \
       last = case when $main then $tsp else last end \
       where contract = $contract and \
       token_id = $token_id returning supply"]
  >>=? fun supply ->
  if main then
    match supply with
    | [ s ] when s > Z.zero ->
      produce_nft_item_event dbh contract token_id
    | _ -> Lwt.return_ok ()
  else Lwt.return_ok ()

let token_updates dbh main l =
  iter_rp (fun r ->
      let contract, block, level, tsp, source =
        r#contract, r#block, r#level, r#tsp, r#source in
      match r#destination, r#token_id,
            r#amount, r#operator, r#add, r#metadata, r#royalties  with
      | Some destination, Some token_id, Some amount, _, _, _, _ ->
        transfer_updates
          dbh main ~contract ~block ~level ~tsp ~token_id ~source amount destination
      | _, token_id, _, Some operator, Some add, _, _ ->
        operator_updates dbh main ~operator ~add ~contract ~block ~level ~tsp ?token_id ~source
      | _, Some token_id, _, _, _, Some meta, _ ->
        token_metadata_update dbh ~main ~contract ~block ~level ~tsp ~token_id meta
      | _, Some token_id, _, _, _, _, Some royalties ->
        if main then
          [%pgsql dbh
              "update tokens set royalties = $royalties, \
               last_block = case when $main then $block else last_block end, \
               last_level = case when $main then $level else last_level end, \
               last = case when $main then $tsp else last end \
               where contract = $contract and \
               token_id = $token_id"]
        else Lwt.return_ok ()
      | _ -> Lwt.return_error (`hook_error "invalid token_update")) l

let token_balance_updates dbh main l =
  let>? m = fold_rp (fun acc r ->
      let l = match r#kind, r#account, r#balance with
        | "mt", Some account, Some balance ->
          let balance = if main then Some balance else None in
          [ Some account, balance, Z.zero, None ]
        | "mt", Some account, None ->
          let balance = if main then Some Z.zero else None in
          [ Some account, balance, Z.zero, None ]
        | "nft", Some account, _ ->
          let balance_src = if main then Some Z.zero else Some Z.one in
          let balance_dst = if main then Some Z.one else Some Z.zero in
          [ Some account, balance_dst, Z.one, balance_src  ]
        | "nft", None, _ ->
          let balance, supply = if main then Some Z.zero, Z.zero else Some Z.one, Z.one in
          [ None, balance, supply, None ]
        | _ -> [] in
      let>? l = fold_rp (fun acc (account, balance, supply, other) ->
          let>? l = match account with
            | Some account ->
              let>? l = [%pgsql dbh
                  "insert into tokens(contract, token_id, block, level, tsp, \
                   last_block, last_level, last, owner, amount, transaction, balance, supply) \
                   values(${r#contract}, ${r#token_id}, ${r#block}, ${r#level}, ${r#tsp}, \
                   ${r#block}, ${r#level}, ${r#tsp}, $account, 0, ${r#transaction}, $?balance, $supply) \
                   on conflict (contract, token_id, owner) \
                   do update set balance = $?balance where tokens.contract = ${r#contract} \
                   and tokens.token_id = ${r#token_id} and tokens.owner = $account \
                   returning owner, amount, balance"] in
              begin match other with
                | None -> Lwt.return_ok l
                | Some b ->
                  let|>? l2 =
                    [%pgsql dbh
                        "update tokens set balance = $b where tokens.contract = ${r#contract} \
                         and tokens.token_id = ${r#token_id} and owner <> $account \
                         returning owner, amount, balance"] in
                  l @ l2
              end
            | None ->
              [%pgsql dbh
                  "update tokens set balance = $?balance where tokens.contract = ${r#contract} \
                   and tokens.token_id = ${r#token_id} returning owner, amount, balance"]
          in
          Lwt.return_ok (acc @ l)) [] l in
      Lwt.return_ok @@
      List.fold_left (fun acc (account, amount, balance) ->
          match balance with
          | Some b when b <> amount ->
            TMap.add (r#contract, r#token_id, account) (amount, b) acc
          | _ -> acc) acc l
    ) TMap.empty l in
  iter_rp (fun ((contract, token_id, owner), (amount, balance)) ->
      Format.printf "\027[0;33mWarning: wrong aggregate amount for %s %s %s: %s, balance = %s\027[0m@."
        contract (Z.to_string token_id) owner (Z.to_string amount) (Z.to_string balance);
      [%pgsql dbh
          "update tokens set amount = $balance where contract = $contract \
           and token_id = $token_id and owner = $owner"]) @@ TMap.bindings m

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

let set_main _config dbh {Hooks.m_main; m_hash} =
  let sort l = List.sort (fun r1 r2 ->
      if m_main then Int32.compare r1#index r2#index
      else Int32.compare r2#index r1#index) l in
  use (Some dbh) @@ fun dbh ->
  let>? collections =
    [%pgsql.object dbh
        "update contracts set main = $m_main where block = $m_hash returning *"] in
  let>? () = [%pgsql dbh "update tokens set main = $m_main where block = $m_hash"] in
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
  let>? () = produce_collection_events m_main collections in
  let>? () = produce_cancel_events dbh m_main @@ sort cancels in
  let>? () = produce_match_events dbh m_main @@ sort matches in
  let>? () = produce_nft_activity_events m_main @@ sort nactivities in
  Lwt.return_ok ()

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
      "select concat(contract, ':', token_id) as id, \
       contract, token_id, \
       last, amount, supply, metadata, tsp from tokens where \
       main and metadata <> '{}' and owner = $owner and amount > 0::mpz and \
       ($no_continuation or \
       (last = $ts and \
       concat(contract, ':', token_id) collate \"C\" < $id) or \
       (last < $ts)) \
       order by last desc, \
       concat(contract, ':', token_id) collate \"C\" desc \
       limit $size64"] in
  let>? nft_items_total = [%pgsql dbh
      "select count(distinct (contract, token_id)) from tokens where \
       main and metadata <> '{}' and owner = $owner and amount > 0::mpz"] in
  let>? nft_items_total = match nft_items_total with
    | [ None ] -> Lwt.return_ok 0L
    | [ Some i64 ] -> Lwt.return_ok i64
    | _ -> Lwt.return_error (`hook_error "count with more then one row") in
  map_rp (fun r -> mk_nft_item dbh ?include_meta r) l >>=? fun nft_items_items ->
  let len = List.length nft_items_items in
  let nft_items_continuation =
    if len <> size then None
    else Some
        (mk_nft_items_continuation @@ List.hd (List.rev nft_items_items)) in
  Lwt.return_ok
    { nft_items_items ; nft_items_continuation ; nft_items_total }

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
      "select concat(t.contract, ':', t.token_id) as id, \
       t.contract, t.token_id, \
       last, amount, supply, metadata, t.tsp \
       from tokens as t \
       left join tzip21_creators as c on t.token_id = c.token_id and t.contract = c.contract \
       where c.account = $creator and \
       t.main and metadata <> '{}' and amount > 0::mpz and \
       ($no_continuation or \
       (last = $ts and \
       concat(t.contract, ':', t.token_id) collate \"C\" < $id) or \
       (last < $ts)) \
       order by last desc, \
       concat(t.contract, ':', t.token_id) collate \"C\" desc \
       limit $size64"] in
  let>? nft_items_total = [%pgsql dbh
      "select count(distinct (t.token_id, t.contract, t,owner)) from tokens as t \
       left join tzip21_creators as c on t.token_id = c.token_id and t.contract = c.contract \
       where c.account = $creator and \
       t.main and metadata <> '{}' and amount > 0::mpz"] in
  let>? nft_items_total = match nft_items_total with
    | [ None ] -> Lwt.return_ok 0L
    | [ Some i64 ] -> Lwt.return_ok i64
    | _ -> Lwt.return_error (`hook_error "count with more then one row") in
  let>? nft_items_items = map_rp (fun r -> mk_nft_item dbh ?include_meta r) l in
  let len = List.length nft_items_items in
  let nft_items_continuation =
    if len <> size then None
    else Some
        (mk_nft_items_continuation @@ List.hd (List.rev nft_items_items)) in
  Lwt.return_ok
    { nft_items_items ; nft_items_continuation ; nft_items_total }

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
      "select concat(contract, ':', token_id) as id, \
       contract, token_id, \
       last, amount, supply, metadata, tsp \
       from tokens where \
       main and metadata <> '{}' and contract = $contract and amount > 0::mpz and \
       ($no_continuation or \
       (last = $ts and \
       concat(contract, ':', token_id) collate \"C\" < $id) or \
       (last < $ts)) \
       order by last desc, \
       concat(contract, ':', token_id) collate \"C\" desc \
       limit $size64"] in
  let>? nft_items_total = [%pgsql dbh
      "select count(distinct (token_id, owner)) from tokens where \
       main and metadata <> '{}' and contract = $contract and amount > 0::mpz"] in
  let>? nft_items_total = match nft_items_total with
    | [ None ] -> Lwt.return_ok 0L
    | [ Some i64 ] -> Lwt.return_ok i64
    | _ -> Lwt.return_error (`hook_error "count with more then one row") in
  let>? nft_items_items = map_rp (fun r -> mk_nft_item dbh ?include_meta r) l in
  let len = List.length nft_items_items in
  let nft_items_continuation =
    if len <> size then None
    else Some
        (mk_nft_items_continuation @@ List.hd (List.rev nft_items_items)) in
  Lwt.return_ok
    { nft_items_items ; nft_items_continuation ; nft_items_total }

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
      "select concat(contract, ':', token_id) as id, \
       contract, token_id, \
       last, amount, supply, metadata, tsp \
       from tokens where \
       main and metadata <> '{}' and \
       (supply > 0::mpz and amount > 0::mpz or (not $no_show_deleted and $show_deleted_v)) and \
       ($no_last_updated_to or (last <= $last_updated_to_v)) and \
       ($no_last_updated_from or (last >= $last_updated_from_v)) and \
       ($no_continuation or \
       (last = $ts and \
       concat(contract, ':', token_id) collate \"C\" < $id) or \
       (last < $ts)) \
       order by last desc, \
       concat(contract, ':', token_id) collate \"C\" \
       desc limit $size64"] in
  let>? nft_items_total = [%pgsql dbh
      "select count(distinct (owner, contract, token_id)) from tokens where \
       main and metadata <> '{}' and \
       (supply > 0::mpz and amount > 0::mpz or (not $no_show_deleted and $show_deleted_v)) and \
       ($no_last_updated_to or (last <= $last_updated_to_v)) and \
       ($no_last_updated_from or (last >= $last_updated_from_v))"] in
  let>? nft_items_total = match nft_items_total with
    | [ None ] -> Lwt.return_ok 0L
    | [ Some i64 ] -> Lwt.return_ok i64
    | _ -> Lwt.return_error (`hook_error "count with more then one row") in
  let>? nft_items_items = map_rp (fun r -> mk_nft_item dbh ?include_meta r) l in
  let len = List.length nft_items_items in
  let nft_items_continuation =
    if len <> size then None
    else Some
        (mk_nft_items_continuation @@ List.hd (List.rev nft_items_items)) in
  Lwt.return_ok
    { nft_items_items ; nft_items_continuation ; nft_items_total }

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
           main and contract = $contract and token_id = $token_id and \
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
           main and contract = $contract and token_id = $token_id and \
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
           (position(owner in $users) > 0 or position(tr_from in $users) > 0) and \
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
           (position(owner in $users) > 0 or position(tr_from in $users) > 0) and \
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
      "select concat(contract, ':', token_id, ':', owner) as id, \
       contract, token_id, owner, tsp, last, amount, supply, metadata \
       from tokens where \
       main and contract = $contract and token_id = $token_id and amount > 0::mpz and \
       ($no_continuation or \
       (last = $ts and concat(contract, ':', token_id, ':', owner) collate \"C\" < $id) or \
       (last < $ts)) \
       order by last desc, \
       concat(contract, ':', token_id, ':', owner) collate \"C\" desc \
       limit $size64"] in
  let>? nft_ownerships_total = [%pgsql dbh
      "select count(distinct owner) from tokens where \
       main and contract = $contract and token_id = $token_id \
       and amount > 0::mpz"] in
  let>? nft_ownerships_total = match nft_ownerships_total with
    | [ None ] -> Lwt.return_ok 0L
    | [ Some i64 ] -> Lwt.return_ok i64
    | _ -> Lwt.return_error (`hook_error "count with more then one row") in
  let>? nft_ownerships_ownerships = map_rp (fun r -> mk_nft_ownership dbh r) l in
  let len = List.length nft_ownerships_ownerships in
  let nft_ownerships_continuation =
    if len <> size then None
    else Some
        (mk_nft_ownerships_continuation @@ List.hd (List.rev nft_ownerships_ownerships)) in
  Lwt.return_ok
    { nft_ownerships_ownerships ; nft_ownerships_continuation ; nft_ownerships_total }

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
      "select concat(contract, ':', token_id, ':', owner) as id, \
       contract, token_id, owner, tsp, last, amount, supply, metadata \
       from tokens where \
       main and amount > 0::mpz and \
       ($no_continuation or \
       (last = $ts and concat(contract, ':', token_id, ':', owner) collate \"C\" < $id) or \
       (last < $ts)) \
       order by last desc, \
       concat(contract, ':', token_id, ':', owner) collate \"C\" desc \
       limit $size64"] in
  let>? nft_ownerships_total = [%pgsql dbh
      "select count(distinct owner) from tokens where \
       main and amount > 0::mpz"] in
  let>? nft_ownerships_total = match nft_ownerships_total with
    | [ None ] -> Lwt.return_ok 0L
    | [ Some i64 ] -> Lwt.return_ok i64
    | _ -> Lwt.return_error (`hook_error "count with more then one row") in
  let>? nft_ownerships_ownerships = map_rp (fun r -> mk_nft_ownership dbh r) l in
  let len = List.length nft_ownerships_ownerships in
  let nft_ownerships_continuation =
    if len <> size then None
    else Some
        (mk_nft_ownerships_continuation @@ List.hd (List.rev nft_ownerships_ownerships)) in
  Lwt.return_ok
    { nft_ownerships_ownerships ; nft_ownerships_continuation ; nft_ownerships_total }

let generate_nft_token_id ?dbh contract =
  Format.eprintf "generate_nft_token_id %s@."
    contract ;
  use dbh @@ fun dbh ->
  let>? r = [%pgsql dbh
      "update contracts set counter = case when counter > last_token_id \
       then counter + 1::mpz else last_token_id + 1::mpz end \
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
  let>? nft_collections_total = [%pgsql dbh
      "select count(distinct address) from contracts where main and owner = $owner and \
       ((ledger_key = '\"nat\"' and ledger_value = '\"address\"') \
       or (ledger_key = '[ \"address\", \"nat\"]' and ledger_value = '\"nat\"') \
       or (ledger_key = '[\"nat\", \"address\"]' and ledger_value = '\"nat\"'))"] in
  let>? nft_collections_total = match nft_collections_total with
    | [ None ] -> Lwt.return_ok 0L
    | [ Some i64 ] -> Lwt.return_ok i64
    | _ -> Lwt.return_error (`hook_error "count with more then one row") in
  let nft_collections_collections = List.filter_map (fun r -> Result.to_option (mk_nft_collection r)) l in
  let len = List.length nft_collections_collections in
  let nft_collections_continuation =
    if len <> size then None
    else Some (List.hd (List.rev nft_collections_collections)).nft_collection_id in
  Lwt.return_ok
    { nft_collections_collections ; nft_collections_continuation ; nft_collections_total }

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
  let>? nft_collections_total = [%pgsql dbh
      "select count(distinct address) from contracts where main and \
       ((ledger_key = '\"nat\"' and ledger_value = '\"address\"') \
       or (ledger_key = '[ \"address\", \"nat\"]' and ledger_value = '\"nat\"') \
       or (ledger_key = '[\"nat\", \"address\"]' and ledger_value = '\"nat\"'))"] in
  let>? nft_collections_total = match nft_collections_total with
    | [ None ] -> Lwt.return_ok 0L
    | [ Some i64 ] -> Lwt.return_ok i64
    | _ -> Lwt.return_error (`hook_error "count with more then one row") in
  let nft_collections_collections = List.filter_map (fun r -> Result.to_option (mk_nft_collection r)) l in
  let len = List.length nft_collections_collections in
  let nft_collections_continuation =
    if len <> size then None
    else Some (List.hd (List.rev nft_collections_collections)).nft_collection_id in
  Lwt.return_ok
    { nft_collections_collections ; nft_collections_continuation ; nft_collections_total }

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
      order.order_elt.order_elt_make_stock > Z.zero &&
      match origin with
      | Some orig ->
        let origin_fees = order.order_data.order_rarible_v2_data_v1_origin_fees in
        List.exists (fun p -> p.part_account = orig) origin_fees
      | None -> true)
    orders

let rec get_orders_all_aux ?dbh ?origin ?continuation ~size acc =
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
      [%pgsql.object dbh
          "select hash, last_update_at from orders \
           where \
           ($no_continuation or \
           (last_update_at < $ts) or \
           (last_update_at = $ts and \
           hash collate \"C\"  < $h)) \
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
      get_orders_all_aux ~dbh ?origin ?continuation ~size (acc @ orders)
  else
  if len = size then Lwt.return_ok acc
  else
    Lwt.return_ok @@
    List.filter_map (fun x -> x) @@
    List.mapi (fun i order -> if i < Int64.to_int size then Some order else None) acc

let get_orders_all ?dbh ?origin ?continuation ?(size=50) () =
  Format.eprintf "get_orders_all %s %s %d@."
    (match origin with None -> "None" | Some s -> s)
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size ;
  let size = Int64.of_int size in
  let>? orders = get_orders_all_aux ?dbh ?origin ?continuation ~size [] in
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
  let currency_fa1_2, currency_fa1_2_contract =
    (match currency with Some (ATFT _) -> true | _ -> false),
    match currency with Some ATFT {contract;_} -> contract | _ -> ""  in
  let currency_fa2, (currency_fa2_contract, currency_fa2_token_id) =
    (match currency with Some (ATNFT _) | Some (ATMT _) -> true | _ -> false),
    match currency with
    | Some ATNFT {asset_contract ; asset_token_id }
    | Some ATMT {asset_contract ; asset_token_id } ->
      asset_contract, asset_token_id
    | _ -> "", Z.zero  in
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
           make_asset_type_token_id = $token_id and \
           ($no_maker or maker = $maker_v) and \
           ($no_currency or \
           ($currency_tezos and take_asset_type_class = 'XTZ') or \
           ($currency_fa1_2 and \
           take_asset_type_class = 'FA1_2' and \
           take_asset_type_contract = $currency_fa1_2_contract) or \
           ($currency_fa2 and \
           take_asset_type_class = 'FA_2' and \
           take_asset_type_contract = $currency_fa2_contract and \
           take_asset_type_token_id = $currency_fa2_token_id)) and \
           ($no_start_date or created_at >= $start_date_v) and \
           ($no_end_date or created_at <= $end_date_v) and \
           ($no_continuation or \
           (make_asset_value > $p) or \
           (make_asset_value = $p and \
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
  let currency_fa1_2, currency_fa1_2_contract =
    (match currency with Some (ATFT _) -> true | _ -> false),
    match currency with Some ATFT {contract;_} -> contract | _ -> ""  in
  let currency_fa2, (currency_fa2_contract, currency_fa2_token_id) =
    (match currency with Some (ATNFT _) | Some (ATMT _) -> true | _ -> false),
    match currency with
    | Some ATNFT {asset_contract ; asset_token_id }
    | Some ATMT {asset_contract ; asset_token_id } ->
      asset_contract, asset_token_id
    | _ -> "", Z.zero  in
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
           take_asset_type_token_id = $token_id and \
           ($no_maker or maker = $maker_v) and \
           ($no_currency or \
           ($currency_tezos and take_asset_type_class = 'XTZ') or \
           ($currency_fa1_2 and \
           take_asset_type_class = 'FA1_2' and \
           take_asset_type_contract = $currency_fa1_2_contract) or \
           ($currency_fa2 and \
           take_asset_type_class = 'FA_2' and \
           take_asset_type_contract = $currency_fa2_contract and \
           take_asset_type_token_id = $currency_fa2_token_id)) and \
           ($no_start_date or created_at >= $start_date_v) and \
           ($no_end_date or created_at <= $end_date_v) and \
           ($no_continuation or \
           (take_asset_value < $p) or \
           (take_asset_value = $p and \
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
         take_asset_type_token_id = $token_id"] in
  let>? assets = map_rp (fun r ->
      Lwt.return @@ mk_asset
        r#make_asset_type_class
        r#make_asset_type_contract
        r#make_asset_type_token_id
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
         make_asset_type_token_id = $token_id"] in
  let>? assets = map_rp (fun r ->
      Lwt.return @@ mk_asset
        r#take_asset_type_class
        r#take_asset_type_contract
        r#take_asset_type_token_id
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
       $make_class, $?make_contract, $?make_token_id, $make_asset_value, $?make_decimals, \
       $take_class, $?take_contract, $?take_token_id, $take_asset_value, $?take_decimals, \
       $?start_date, $?end_date, $salt, $signature, $created_at, $last_update_at, $hash_key) \
       on conflict (hash) do update set (\
       make_asset_value, take_asset_value, last_update_at, signature) = \
       ($make_asset_value, $take_asset_value, $last_update_at, $signature)"] in
  insert_order_activity_new ~decs:(make_decimals, take_decimals) dbh created_at order >>=? fun () ->
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
      let|>? (a, decs) = Lwt.return @@ mk_order_activity r in
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
           ((o.make_asset_type_contract = $contract and o.make_asset_type_token_id = $token_id) or \
           (o.take_asset_type_contract = $contract and o.take_asset_type_token_id = $token_id) or \
           (oleft.make_asset_type_contract = $contract and \
           oleft.make_asset_type_token_id = $token_id) or \
           (oleft.take_asset_type_contract = $contract and \
           oleft.take_asset_type_token_id = $token_id) or \
           (oright.make_asset_type_contract = $contract and \
           oright.make_asset_type_token_id = $token_id) or \
           (oright.take_asset_type_contract = $contract and \
           oright.take_asset_type_token_id = $token_id)) and \
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
           ((o.make_asset_type_contract = $contract and o.make_asset_type_token_id = $token_id) or \
           (o.take_asset_type_contract = $contract and o.take_asset_type_token_id = $token_id) or \
           (oleft.make_asset_type_contract = $contract and \
           oleft.make_asset_type_token_id = $token_id) or \
           (oleft.take_asset_type_contract = $contract and \
           oleft.take_asset_type_token_id = $token_id) or \
           (oright.make_asset_type_contract = $contract and \
           oright.make_asset_type_token_id = $token_id) or \
           (oright.take_asset_type_contract = $contract and \
           oright.take_asset_type_token_id = $token_id)) and \
           ($no_continuation or \
           (date = $ts and id collate \"C\" > $h) or \
           (date > $ts)) \
           order by date asc, \
           id collate \"C\" asc \
           limit $size64"] in
  let>? activities = map_rp (fun r ->
      let|>? a, decs = Lwt.return @@ mk_order_activity r in
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
  Format.eprintf "get_order_activities_all [%s] %s %d@."
    (String.concat " " @@
     List.map (EzEncoding.construct order_activity_filter_all_type_enc) types)
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size ;
  use dbh @@ fun dbh ->
  let types = filter_order_all_type_to_string types in
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
      let|>? a, decs = Lwt.return @@ mk_order_activity r in
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
      let|>? a, decs = Lwt.return @@ mk_order_activity r in
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
