open Let
open Rtypes
open Common
open Misc

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
  Utils.to_parts l

let get_order_payouts ?dbh hash_key =
  use dbh @@ fun dbh ->
  let|>? l = [%pgsql dbh
      "select account, value from payouts where hash = $hash_key"] in
  Utils.to_parts l

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

let db_from_asset ?dbh asset =
  let>? decimals = get_decimals ?dbh asset.asset_type in
  match asset.asset_type with
  | ATXTZ ->
    Lwt.return_ok (Utils.string_of_asset_type asset.asset_type, None, None,
                   asset.asset_value, decimals)
  | ATFT {contract; token_id} ->
    Lwt.return_ok
      (Utils.string_of_asset_type asset.asset_type, Some contract, token_id,
       asset.asset_value, decimals)
  | ATNFT fa2 | ATMT fa2 ->
    Lwt.return_ok (Utils.string_of_asset_type asset.asset_type, Some fa2.asset_contract,
                   Some fa2.asset_token_id, asset.asset_value, None)

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
  let fee_side = Utils.get_fee_side make take in
  Utils.calculate_make_stock
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

let filter_creators =
  List.filter (fun {part_account; _} -> Utils.check_address part_account)

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
  match String.split_on_char ':' obj#id with
  | contract :: token_id :: owner :: [] ->
    let token_id = Z.of_string token_id in
    let creators = List.filter_map (function
        | None -> None
        | Some json -> Some (EzEncoding.destruct part_enc json)) obj#creators in
    Lwt.return_ok @@ {
      nft_ownership_id = obj#id ;
      nft_ownership_contract = contract ;
      nft_ownership_token_id = token_id ;
      nft_ownership_owner = owner ;
      nft_ownership_creators = creators;
      nft_ownership_value = Option.value ~default:obj#amount obj#balance ;
      nft_ownership_lazy_value = Z.zero ;
      nft_ownership_date = obj#last ;
      nft_ownership_created_at = obj#tsp ;
    }
  | _ ->
    Lwt.return_error (`hook_error "can't split id")

let get_nft_ownership_by_id ?dbh ?(old=false) contract token_id owner =
  (* TODO : OWNERSHIP NOT FOUND *)
  Format.eprintf "get_nft_ownership_by_id %s %s %s@." contract (Z.to_string token_id) owner ;
  use dbh @@ fun dbh ->
  let>? l = [%pgsql.object dbh
      "select oid as id, last, tsp, amount, balance, supply, metadata, creators \
       from tokens t inner join token_info i on i.id = t.tid \
       where main and i.contract = $contract and i.token_id = ${Z.to_string token_id} and \
       owner = $owner and (balance is not null and balance > 0 or amount > 0 or $old)"] in
  match l with
  | [] -> Lwt.return_error (`hook_error "ownership not found")
  | _ ->
    let>? obj = one l in
    mk_nft_ownership obj

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
       is_transferable, should_prefer_symbol, royalties from tzip21_metadata where \
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
      tzip21_tm_royalties = Option.map (fun ro -> EzEncoding.destruct parts_enc ro) r#royalties ;
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
    let nft_item_royalties =
      match EzEncoding.destruct parts_enc obj#royalties, Option.map (EzEncoding.destruct parts_enc) obj#royalties_metadata with
      | [], Some ((_ :: _) as nft_item_roy_list) -> { nft_item_roy_onchain = Some false; nft_item_roy_list }
      | [], _ -> { nft_item_roy_onchain = None; nft_item_roy_list = [] }
      | nft_item_roy_list, _ -> { nft_item_roy_onchain = Some true; nft_item_roy_list } in
    Lwt.return_ok {
      nft_item_id = obj#id ;
      nft_item_contract = contract ;
      nft_item_token_id = token_id ;
      nft_item_creators = creators ;
      nft_item_supply = obj#supply ;
      nft_item_lazy_supply = Z.zero ;
      nft_item_owners = List.filter_map (fun x -> x) @@ Option.value ~default:[] obj#owners ;
      nft_item_royalties ;
      nft_item_date = obj#last ;
      nft_item_minted_at = obj#tsp ;
      nft_item_deleted = obj#supply = Z.zero ;
      nft_item_meta = Utils.rarible_meta_of_tzip21_meta meta ;
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
       last, supply, metadata, tsp, creators, royalties, royalties_metadata, \
       array_agg(case when (balance is not null and balance <> 0 or amount <> 0) then owner end) as owners \
       from tokens t \
       inner join token_info i on i.id = t.tid \
       where main and i.contract = $contract and i.token_id = ${Z.to_string token_id} \
       group by i.id"] in
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
