open Let
open Tzfunc.Proto
open Rtypes
open Hooks
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

let get_contracts ?dbh () =
  use dbh @@ fun dbh ->
  [%pgsql dbh "select address from contracts where main"]

let get_extra_config ?dbh () =
  use dbh @@ fun dbh ->
  let>? r = [%pgsql.object dbh
      "select admin_wallet, exchange_v2_contract, royalties_contract, \
       validator_contract, ft_fa2, ft_fa1 from state"] in
  match r with
  | [ r ] ->  Lwt.return_ok (Some {
      admin_wallet = r#admin_wallet;
      exchange_v2 = r#exchange_v2_contract;
      royalties = r#royalties_contract;
      validator = r#validator_contract;
      ft_fa2 = List.filter_map (fun x -> x) r#ft_fa2;
      ft_fa1 = List.filter_map (fun x -> x) r#ft_fa1;
    })
  | [] -> Lwt.return_ok None
  | _ -> Lwt.return_error (`hook_error "wrong_state")

let update_extra_config ?dbh e =
  use dbh @@ fun dbh ->
  let>? r = [%pgsql.object dbh "select * from state"] in
  let ft_fa1 = List.map Option.some e.ft_fa1 in
  let ft_fa2 = List.map Option.some e.ft_fa2 in
  match r with
  | [] ->
    [%pgsql dbh
        "insert into state(exchange_v2_contract, royalties_contract, \
         validator_contract, ft_fa2, ft_fa1) \
         values (${e.exchange_v2}, ${e.royalties}, ${e.validator}, \
         $ft_fa2, $ft_fa1)"]
  | _ ->
    [%pgsql dbh
        "update state set exchange_v2_contract = ${e.exchange_v2}, \
         royalties_contract = ${e.royalties}, validator_contract = ${e.validator}, \
         ft_fa1 = $ft_fa1, ft_fa2 = $ft_fa2"]

(* Normalize here in case of ERC20 like asset *)
let price left right =
  if Int64.of_string left.asset_value > 0L then
    Lwt.return_ok @@
    Int64.(to_string (div (of_string left.asset_value) (of_string right.asset_value)))
  else Lwt.return_ok "0"

let nft_price left right =
  match left.asset_type with
  | ATFA_2 _ -> price left right
  | _ -> price right left

let mk_side_type asset = match asset.asset_type with
  | ATFA_2 _ -> STBID
  | _ -> STSELL

let mk_asset asset_class contract token_id asset_value =
  match asset_class with
  (* For testing purposes*)
  (* | "ERC721" ->
   *   begin
   *     match contract, token_id with
   *     | Some c, Some id ->
   *       let asset_type =
   *         ATERC721
   *           { asset_type_nft_contract = c ; asset_type_nft_token_id = id } in
   *       Lwt.return_ok { asset_type; asset_value }
   *     | _, _ ->
   *       Lwt.return_error (`hook_error ("no contract addr or tokenId for ERC721 asset"))
   *   end
   * | "ETH" ->
   *   begin
   *     match contract, token_id with
   *     | None, None ->
   *       Lwt.return_ok { asset_type = ATETH ; asset_value }
   *     | _, _ ->
   *       Lwt.return_error (`hook_error ("contract addr or tokenId for ETH asset"))
   *   end *)
    (* Tezos assets*)
  | "XTZ" ->
    begin
      match contract, token_id with
      | None, None ->
        Lwt.return_ok { asset_type = ATXTZ ; asset_value }
      | _, _ ->
        Lwt.return_error (`hook_error ("contract addr or tokenId for XTZ asset"))
    end
  | "FA_1_2" ->
    begin
      match contract, token_id with
      | Some c, None ->
        let asset_type = ATFA_1_2 c in
        Lwt.return_ok { asset_type; asset_value }
      | _, _ ->
        Lwt.return_error (`hook_error ("need contract and no tokenId for FA1.2 asset"))
    end
  | "FA_2" ->
    begin
      match contract, token_id with
      | Some c, Some id ->
        let asset_type =
          ATFA_2
            { asset_fa2_contract = c ; asset_fa2_token_id = id } in
        Lwt.return_ok { asset_type; asset_value }
      | _, _ ->
        Lwt.return_error (`hook_error ("no contract addr for FA2 asset"))
    end
  | _ ->
    Lwt.return_error (`hook_error ("invalid asset class " ^ asset_class))

let db_from_asset asset =
  match asset.asset_type with
  (* For testing purposes*)
  (* | ATERC721 data ->
   *   Lwt.return_ok
   *     (string_of_asset_type asset.asset_type,
   *      Some data.asset_type_nft_contract,
   *      Some data.asset_type_nft_token_id,
   *      asset_value)
   * | ATETH ->
   *   Lwt.return_ok
   *     (string_of_asset_type asset.asset_type, None, None, asset_value) *)
  (* Tezos assets*)
  | ATXTZ ->
    Lwt.return_ok
      (string_of_asset_type asset.asset_type, None, None, asset.asset_value)
  | ATFA_1_2 c ->
    Lwt.return_ok
      (string_of_asset_type asset.asset_type,
       Some c,
       None,
       asset.asset_value)
  | ATFA_2 fa2 ->
    Lwt.return_ok
      (string_of_asset_type asset.asset_type,
       Some fa2.asset_fa2_contract,
       Some fa2.asset_fa2_token_id,
       asset.asset_value)

let mk_order_activity_bid obj =
  mk_asset
    obj#make_asset_type_class
    obj#make_asset_type_contract
    obj#make_asset_type_token_id
    obj#make_asset_value
  >>=? fun make ->
  mk_asset
    obj#take_asset_type_class
    obj#take_asset_type_contract
    obj#take_asset_type_token_id
    obj#take_asset_value
  >>=? fun take ->
  nft_price make take >>=? fun price ->
  Lwt.return_ok
    {
      order_activity_bid_hash = obj#o_hash;
      order_activity_bid_maker = obj#maker ;
      order_activity_bid_make = make ;
      order_activity_bid_take = take ;
      order_activity_bid_price = price ;
    }

let mk_left_side obj =
  mk_asset
    obj#oleft_make_asset_type_class
    obj#oleft_make_asset_type_contract
    obj#oleft_make_asset_type_token_id
    obj#oleft_make_asset_value
  >|=? fun asset ->
  {
    order_activity_match_side_maker = obj#oleft_maker ;
    order_activity_match_side_hash = obj#oleft_hash ;
    order_activity_match_side_asset = asset ;
    order_activity_match_side_type = mk_side_type asset ;
  }

let mk_right_side obj =
  mk_asset
    obj#oright_take_asset_type_class
    obj#oright_take_asset_type_contract
    obj#oright_take_asset_type_token_id
    obj#oright_take_asset_value
  >|=? fun asset ->
  {
    order_activity_match_side_maker = Option.get obj#oright_taker ;
    order_activity_match_side_hash = obj#oright_hash ;
    order_activity_match_side_asset = asset ;
    order_activity_match_side_type = mk_side_type asset ;
  }

let mk_order_activity_match obj =
  let>? left = mk_left_side obj in
  let>? right = mk_right_side obj in
  nft_price
    left.order_activity_match_side_asset
    right.order_activity_match_side_asset
  >|=? fun price ->
  {
    order_activity_match_left = left ;
    order_activity_match_right = right ;
    order_activity_match_price = price ;
    order_activity_match_transaction_hash = Option.get obj#transaction ;
    order_activity_match_block_hash = Option.get obj#block ;
    order_activity_match_block_number = Int64.of_int32 @@ Option.get obj#level ;
    order_activity_match_log_index = 0 ;
  }

let mk_order_activity_cancel obj =
  mk_asset
    obj#make_asset_type_class
    obj#make_asset_type_contract
    obj#make_asset_type_token_id
    obj#make_asset_value
  >>=? fun make ->
  mk_asset
    obj#take_asset_type_class
    obj#take_asset_type_contract
    obj#take_asset_type_token_id
    obj#take_asset_value
  >>=? fun take ->
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
  Lwt.return_ok @@
  match make.asset_type with
  | ATFA_2 _ ->
    OrderActivityCancelList bid
  | _ ->
    OrderActivityCancelBid bid

let mk_order_activity obj = match obj#order_activity_type with
  | "list" ->
    let|>? listing = mk_order_activity_bid obj in
    OrderActivityList listing
  | "bid" ->
    let|>? listing = mk_order_activity_bid obj in
    OrderActivityBid listing
  | "match" ->
    let|>? matched = mk_order_activity_match obj in
    OrderActivityMatch matched
  | "cancel" ->
    mk_order_activity_cancel obj
  | _ as t -> Lwt.return_error (`hook_error ("unknown order activity type " ^ t))

let get_order_price_history ?dbh hash_key =
  use dbh @@ fun dbh ->
  let|>? l = [%pgsql dbh
      "select date, make_value, take_value \
       from order_price_history where hash = $hash_key \
       order by date desc"] in
  List.map
    (fun (date, make_value, take_value) -> {
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
        | _ -> 0L in
      Int64.add acc_fill fill)
    0L rows

let get_cancelled hash l =
  List.exists (fun r -> r#cancel = Some hash) l

let get_make_balance ?dbh make owner = match make.asset_type with
  | ATXTZ -> Lwt.return_ok 0L
  | ATFA_1_2 _addr ->
    Printf.eprintf "TODO : get_make_balance FA1.2\n%!" ;
    Lwt.return_ok 0L
  | ATFA_2 { asset_fa2_contract ; asset_fa2_token_id }->
    let contract = asset_fa2_contract in
    let token_id = asset_fa2_token_id in
    use dbh @@ fun dbh ->
    let|>? l = [%pgsql.object dbh
        "select amount from tokens where \
         main and \
         contract = $contract and token_id = $token_id and \
         owner = $owner"] in
    match l with
    | [ r ] -> r#amount
    | _ -> 0L

let calculate_make_stock make take data fill make_balance cancelled =
  (* TODO : protocol commission *)
  let make_value = Int64.of_string make.asset_value in
  let take_value = Int64.of_string take.asset_value in
  let protocol_commission = 0L in
  let fee_side = get_fee_side make take in
  calculate_make_stock
    make_value take_value fill data make_balance
    protocol_commission fee_side cancelled

let get_order_updates ?dbh obj make maker take data =
  let hash = obj#hash in
  use dbh @@ fun dbh ->
  let>? cancel = [%pgsql.object dbh
      "select * from order_cancel \
       where main and (cancel = $hash) order by tsp"] in
  match cancel with
  | [ cancel ] ->
    Lwt.return_ok (0L, 0L, true, cancel#tsp, 0L)
  | _ ->
    let>? matches = [%pgsql.object dbh
        "select * from order_match \
         where main and \
         (hash_left = $hash or hash_right = $hash) order by tsp"] in
    let fill = get_fill hash matches in
    let>? owner = Lwt.return @@ Tzfunc.Crypto.pk_to_pkh maker in
    let|>? make_balance = get_make_balance make owner in
    let cancelled = false in
    let make_stock = calculate_make_stock make take data fill make_balance cancelled in
    let last_update_at = match matches with hd :: _ -> hd#tsp | [] -> obj#created_at in
    fill, make_stock, cancelled, last_update_at, make_balance

let mk_order ?dbh order_obj =
  mk_asset
    order_obj#make_asset_type_class
    order_obj#make_asset_type_contract
    order_obj#make_asset_type_token_id
    order_obj#make_asset_value
  >>=? fun order_elt_make ->
  mk_asset
    order_obj#take_asset_type_class
    order_obj#take_asset_type_contract
    order_obj#take_asset_type_token_id
    order_obj#take_asset_value
  >>=? fun order_elt_take ->
  get_order_price_history ?dbh order_obj#hash >>=? fun price_history ->
  get_order_origin_fees ?dbh order_obj#hash >>=? fun origin_fees ->
  get_order_payouts ?dbh order_obj#hash >>=? fun payouts ->
  let data = {
    order_rarible_v2_data_v1_data_type = "RARIBLE_V2_DATA_V1" ;
    order_rarible_v2_data_v1_payouts = payouts ;
    order_rarible_v2_data_v1_origin_fees = origin_fees ;
  } in
  let>? (fill, make_stock, cancelled, last_update_at, make_balance) =
    get_order_updates ?dbh order_obj order_elt_make order_obj#maker order_elt_take data in
  let order_elt = {
    order_elt_maker = order_obj#maker ;
    order_elt_taker = order_obj#taker ;
    order_elt_make ;
    order_elt_take ;
    order_elt_fill = Int64.to_string fill ;
    order_elt_start = order_obj#start_date ;
    order_elt_end = order_obj#end_date ;
    order_elt_make_stock = Int64.to_string make_stock ;
    order_elt_cancelled = cancelled ;
    order_elt_salt = order_obj#salt ;
    order_elt_signature = order_obj#signature ;
    order_elt_created_at = order_obj#created_at ;
    order_elt_last_update_at = last_update_at ;
    order_elt_pending = None ;
    order_elt_hash = order_obj#hash ;
    order_elt_make_balance = Option.some @@ Int64.to_string make_balance ;
    order_elt_price_history = price_history ;
    order_elt_status = None (* todo *)
  } in
  let rarible_v2_order = {
    order_elt = order_elt ;
    order_data = data ;
    order_type = ();
  } in
  Lwt.return_ok rarible_v2_order

let get_order ?dbh hash_key =
  Printf.eprintf "get_order %s\n%!" hash_key ;
  use dbh @@ fun dbh ->
  let>? l = [%pgsql.object dbh
      "select maker, taker, \
       make_asset_type_class, make_asset_type_contract, make_asset_type_token_id, \
       make_asset_value, \
       take_asset_type_class, take_asset_type_contract, take_asset_type_token_id, \
       take_asset_value, \
       start_date, end_date, salt, signature, created_at, hash \
       from orders where hash = $hash_key"] in
  match l with
  | [] -> Lwt.return_ok None
  | _ ->
    one l >>=? fun r ->
    mk_order r >>=? fun order ->
    Lwt.return_ok @@ Some order

let get_nft_item_creators_from_metadata r =
  try EzEncoding.destruct (Json_encoding.list part_enc) r#creators
  with _ -> []

let get_nft_item_owners ?dbh contract token_id =
  use dbh @@ fun dbh ->
  [%pgsql dbh
      "select owner FROM tokens where main and \
       amount <> 0 and contract = $contract and token_id = $token_id"]

let mk_nft_ownership obj =
  let creators = get_nft_item_creators_from_metadata obj in
  (* TODO : pending *)
  (* TODO : last <> mint date ? *)
  Lwt.return_ok {
    nft_ownership_id = Option.get obj#id ;
    nft_ownership_contract = obj#contract ;
    nft_ownership_token_id = obj#token_id ;
    nft_ownership_owner = obj#owner ;
    nft_ownership_creators = creators ;
    nft_ownership_value = Int64.to_string obj#amount ;
    nft_ownership_lazy_value = "0" ;
    nft_ownership_date = obj#last ;
    nft_ownership_pending = [] ;
  }

let get_nft_ownership_by_id ?dbh ?(old=false) contract token_id owner =
  (* TODO : OWNERSHIP NOT FOUND *)
  Format.eprintf "get_nft_ownership_by_id %s %s %s@." contract token_id owner ;
  use dbh @@ fun dbh ->
  let>? l = [%pgsql.object dbh
      "select concat(contract, ':', token_id, ':', owner) as id, \
       contract, token_id, owner, last, amount, supply, metadata, \
       name, creators, description, attributes, image, animation \
       from tokens where \
       main and contract = $contract and token_id = $token_id and \
       owner = $owner and (amount <> 0 or $old)"] in
  let>? obj = one l in
  let>? nft_ownership = mk_nft_ownership obj in
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

(* let get_nft_item_pending ?dbh id =
 *   use dbh @@ fun dbh ->
 *   let>? l =
 *     [%pgsql.object dbh
 *         "select owner, value, transfer_from from item_transfers where id = $id "] in
 *   map_rp (fun r -> mk_item_transfer r) l *)

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

(* let get_nft_item_meta ?dbh id =
 *   use dbh @@ fun dbh ->
 *   let>? meta = [%pgsql.object dbh
 *       "select name, description from nft_item_meta where id = $id "] in
 *   let>? meta = one meta in
 *   let>? medias = [%pgsql.object dbh
 *       "select url, media_type, width, height from nft_media where id = $id "] in
 *   let>? media = one medias in
 *   let>? attributes = [%pgsql.object dbh
 *       "select key, value from nft_item_attributes where id = $id "] in
 *   let>? image =
 *     if media#media_type = "image/png" then
 *       let|>? m = mk_nft_media media in
 *       Some m
 *     else Lwt.return_ok None in
 *   let>? animation =
 *     if media#media_type = "image/gif" then
 *       let|>? m = mk_nft_media media in
 *       Some m
 *     else Lwt.return_ok None in
 *   map_rp (fun r -> mk_item_attribute r) attributes >>=? fun attributes ->
 *   let attrs = match attributes with [] -> None | _ -> Some attributes in
 *   Lwt.return_ok {
 *     nft_item_meta_name = meta#name ;
 *     nft_item_meta_description = meta#description ;
 *     nft_item_meta_attributes = attrs ;
 *     nft_item_meta_image = image ;
 *     nft_item_meta_animation = animation ;
 *   } *)

let mk_nft_media json =
  try Some (EzEncoding.destruct nft_media_enc json)
  with _ ->
  try
    let url = EzEncoding.destruct Json_encoding.string json in
    Some {
      nft_media_url = [ "", url ] ;
      nft_media_meta = [] ;
    }
  with _ -> None

let mk_nft_attributes json =
  try Some (EzEncoding.destruct (Json_encoding.list nft_item_attribute_enc) json)
  with _ -> None

let mk_nft_item_meta r =
  match r#name with
  | None -> None
  | Some nft_item_meta_name ->
    let nft_item_meta_attributes = Option.bind r#attributes mk_nft_attributes in
    let nft_item_meta_image = r#image in
    let nft_item_meta_animation = r#animation in
    Some {
      nft_item_meta_name;
      nft_item_meta_description = r#description;
      nft_item_meta_attributes;
      nft_item_meta_image;
      nft_item_meta_animation }

let mk_nft_item ?dbh ?include_meta obj =
  let creators = get_nft_item_creators_from_metadata obj in
  get_nft_item_owners ?dbh obj#contract obj#token_id >>=? fun owners ->
  (* get_nft_item_royalties  >>=? fun royalties -> *)
  let meta = match include_meta with
    | Some true -> mk_nft_item_meta obj
    | _ -> None in
  Lwt.return_ok {
    nft_item_id = Option.get obj#id ;
    nft_item_contract = obj#contract ;
    nft_item_token_id = obj#token_id ;
    nft_item_creators = creators ;
    nft_item_supply = Int64.to_string obj#supply ;
    nft_item_lazy_supply = Int64.to_string 0L ;
    nft_item_owners = owners ;
    nft_item_royalties = [] ;
    nft_item_date = obj#last ;
    nft_item_minted_at = obj#tsp ;
    nft_item_pending = None ;
    nft_item_deleted = if obj#supply > 0L then Some false else Some true ;
    nft_item_meta = meta ;
  }

let get_nft_item_by_id ?dbh ?include_meta contract token_id =
  Format.eprintf "get_nft_item_by_id %s %s %s@."
    contract
    token_id
    (match include_meta with None -> "None" | Some s -> string_of_bool s) ;
  use dbh @@ fun dbh ->
  let>? l = [%pgsql.object dbh
      "select concat(contract, ':', token_id) as id, contract, token_id, \
       last, amount, supply, metadata, name, creators, description, attributes, \
       image, animation, tsp \
       from tokens where \
       main and contract = $contract and token_id = $token_id"] in
  match l with
  | obj :: _ ->
    let>? nft_item = mk_nft_item ~dbh ?include_meta obj in
    Lwt.return_ok nft_item
  | [] -> Lwt.return_error (`hook_error "nft_item not found")

let produce_order_event_hash dbh hash =
  let>? order = get_order ~dbh hash in
  begin
    match order with
    | Some order ->
      Rarible_kafka.produce_order_event (mk_order_event order)
    | None -> Lwt.return ()
  end >>= fun () ->
  Lwt.return_ok ()

let produce_nft_item_event dbh contract token_id =
  let>? item = get_nft_item_by_id ~dbh ~include_meta:true contract token_id in
  if Int64.of_string item.nft_item_supply = 0L then
    Rarible_kafka.produce_item_event (mk_delete_item_event item)
    >>= fun () ->
    Lwt.return_ok ()
  else
    Rarible_kafka.produce_item_event (mk_update_item_event item)
    >>= fun () ->
    Lwt.return_ok ()

let produce_nft_ownership_update_event os =
  if os.nft_ownership_value = "0" then
    Rarible_kafka.produce_ownership_event (mk_delete_ownership_event os)
  else
    Rarible_kafka.produce_ownership_event (mk_update_ownership_event os)

let produce_nft_ownership_event dbh contract token_id owner =
  begin
    get_nft_ownership_by_id
      ~old:true ~dbh contract token_id owner >>= function
    | Ok os -> produce_nft_ownership_update_event os
    | Error _ -> Lwt.return_unit
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

let insert_nft_activity dbh timestamp nft_activity =
  let act_type, act_from, elt =  match nft_activity.nft_activity_type with
    | NftActivityMint elt -> "mint", None, elt
    | NftActivityBurn elt -> "burn", None, elt
    | NftActivityTransfer {elt; from} -> "transfer", Some from, elt in
  let token_id = elt.nft_activity_token_id in
  let value = Int64.of_string elt.nft_activity_value in
  let level = Int64.to_int32 elt.nft_activity_block_number in
  [%pgsql dbh
      "insert into nft_activities(\
       activity_type, transaction, block, level, date, contract, token_id, \
       owner, amount, tr_from) values ($act_type, \
       ${elt.nft_activity_transaction_hash}, \
       ${elt.nft_activity_block_hash}, \
       $level, $timestamp, \
       ${elt.nft_activity_contract}, \
       $token_id, \
       ${elt.nft_activity_owner}, $value, $?act_from) \
       on conflict do nothing"] >>=? fun () ->
  Rarible_kafka.produce_nft_activity nft_activity >>= fun () ->
  Lwt.return_ok ()

let create_nft_activity_elt op contract mi_op = {
  nft_activity_owner = mi_op.tk_owner ;
  nft_activity_contract = contract ;
  nft_activity_token_id = mi_op.tk_op.tk_token_id ;
  nft_activity_value = Int64.to_string mi_op.tk_op.tk_amount ;
  nft_activity_transaction_hash = op.bo_hash ;
  nft_activity_block_hash = op.bo_block ;
  nft_activity_block_number = Int64.of_int32 op.bo_level ;
}

let insert_nft_activity_mint dbh op kt1 mi_op =
  let nft_activity_elt = create_nft_activity_elt op kt1 mi_op in
  let nft_activity_type = NftActivityMint nft_activity_elt in
  let nft_activity = {
    nft_activity_type ;
    nft_activity_id = Printf.sprintf "%s_%ld" op.bo_block op.bo_index ;
    nft_activity_date = op.bo_tsp ;
  } in
  insert_nft_activity dbh op.bo_tsp nft_activity

let insert_nft_activity_burn dbh op kt1 mi_op =
  let nft_activity_elt = create_nft_activity_elt op kt1 mi_op in
  let nft_activity_type = NftActivityBurn nft_activity_elt in
  let nft_activity = {
    nft_activity_type ;
    nft_activity_id = Printf.sprintf "%s_%ld" op.bo_block op.bo_index ;
    nft_activity_date = op.bo_tsp ;
  } in
  insert_nft_activity dbh op.bo_tsp nft_activity

let insert_nft_activity_transfer dbh op kt1 from owner token_id amount =
  let elt = {
    nft_activity_owner = owner ;
    nft_activity_contract = kt1;
    nft_activity_token_id = token_id ;
    nft_activity_value = Int64.to_string amount ;
    nft_activity_transaction_hash = op.bo_hash ;
    nft_activity_block_hash = op.bo_block ;
    nft_activity_block_number = Int64.of_int32 op.bo_level ;
  } in
  let nft_activity_type = NftActivityTransfer {from; elt} in
  let nft_activity = {
    nft_activity_type ;
    nft_activity_id = Printf.sprintf "%s_%ld" op.bo_block op.bo_index ;
    nft_activity_date = op.bo_tsp ;
  } in
  insert_nft_activity dbh op.bo_tsp nft_activity

let insert_mint dbh op kt1 m =
  let meta = EzEncoding.construct token_metadata_enc m.mi_meta in
  let token_id = m.mi_op.tk_op.tk_token_id in
  let owner = m.mi_op.tk_owner in
  let>? () = [%pgsql dbh
      "insert into tokens(contract, token_id, block, level, tsp, \
       last_block, last_level, last, owner, \
       amount, metadata, transaction, supply) \
       values($kt1, $token_id, ${op.bo_block}, ${op.bo_level}, ${op.bo_tsp}, \
       ${op.bo_block}, ${op.bo_level}, ${op.bo_tsp}, $owner, 0, $meta, \
       ${op.bo_hash}, 0) on conflict do nothing"] in
  let>? () = insert_account dbh owner ~block:op.bo_block ~level:op.bo_level ~tsp:op.bo_tsp in
  let mint = EzEncoding.construct token_op_owner_enc m.mi_op in
  let>? () = [%pgsql dbh
      "insert into contract_updates(transaction, index, block, level, tsp, \
       contract, mint) \
       values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
       ${op.bo_tsp}, $kt1, $mint) \
       on conflict do nothing"] in
  insert_nft_activity_mint dbh op kt1 m.mi_op

let insert_burn dbh op tr m =
  let burn = EzEncoding.construct token_op_owner_enc m in
  let>? () = [%pgsql dbh
      "insert into contract_updates(transaction, index, block, level, tsp, \
       contract, burn) \
       values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
       ${op.bo_tsp}, ${tr.destination}, $burn) \
       on conflict do nothing"] in
  insert_nft_activity_burn dbh op tr.destination m

let insert_transfer dbh op tr lt =
  let kt1 = tr.destination in
  let|>? () = iter_rp (fun {tr_source; tr_txs} ->
      let|>? () = iter_rp (fun {tr_destination; tr_token_id; tr_amount} ->
          let>? () = [%pgsql dbh
              "insert into tokens(contract, token_id, block, level, tsp, \
               last_block, last_level, last, owner, amount, \
               metadata, transaction, supply) \
               values($kt1, $tr_token_id, ${op.bo_block}, ${op.bo_level}, ${op.bo_tsp}, \
               ${op.bo_block}, ${op.bo_level}, ${op.bo_tsp}, \
               $tr_destination, 0, '{}', ${op.bo_hash}, 0) on conflict do nothing"] in
          let>? () = insert_account dbh tr_destination ~block:op.bo_block ~level:op.bo_level ~tsp:op.bo_tsp in
          let>? () = [%pgsql dbh
              "insert into token_updates(transaction, index, block, level, tsp, \
               source, destination, contract, token_id, amount) \
               values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
               ${op.bo_tsp}, $tr_source, $tr_destination, ${tr.destination}, \
               $tr_token_id, $tr_amount) \
               on conflict do nothing"] in
          insert_nft_activity_transfer
            dbh op kt1 tr_source tr_destination tr_token_id tr_amount
        ) tr_txs in
      ()) lt in
  ()

let insert_update_operator dbh op tr lt =
  let kt1 = tr.destination in
  iter_rp (fun {op_owner; op_operator; op_token_id; op_add} ->
      let>? () = [%pgsql dbh
          "insert into token_updates(transaction, index, block, level, tsp, \
           source, operator, add, contract, token_id) \
           values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
           ${op.bo_tsp}, $op_owner, $op_operator, $op_add, \
           $kt1, $op_token_id) on conflict do nothing"] in
      insert_account dbh op_operator ~block:op.bo_block ~level:op.bo_level ~tsp:op.bo_tsp) lt

let insert_update_operator_all dbh op tr lt =
  let kt1 = tr.destination in
  let source = op.bo_op.source in
  iter_rp (fun (operator, add) ->
      let>? () = [%pgsql dbh
          "insert into token_updates(transaction, index, block, level, tsp, \
           source, operator, add, contract) \
           values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
           ${op.bo_tsp}, $source, $operator, $add, $kt1) on conflict do nothing"] in
      insert_account dbh operator ~block:op.bo_block ~level:op.bo_level ~tsp:op.bo_tsp) lt

let insert_metadata_uri dbh op tr s =
  [%pgsql dbh
      "insert into contract_updates(transaction, index, block, level, tsp, \
       contract, uri) \
       values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
       ${op.bo_tsp}, ${tr.destination}, $s) \
       on conflict do nothing"]

let insert_token_metadata dbh op tr (token_id, l) =
  let meta = EzEncoding.construct token_metadata_enc l in
  let source = op.bo_op.source in
  let kt1 = tr.destination in
  [%pgsql dbh
      "insert into token_updates(transaction, index, block, level, tsp, \
       source, token_id, contract, metadata) \
       values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
       ${op.bo_tsp}, $source, $token_id, $kt1, $meta) \
       on conflict do nothing"]

let insert_royalties dbh op roy =
  let royalties = EzEncoding.(construct token_royalties_enc roy.roy_royalties) in
  let source = op.bo_op.source in
  [%pgsql dbh
      "insert into token_updates(transaction, index, block, level, tsp, \
       source, token_id, contract, royalties) \
       values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
       ${op.bo_tsp}, $source, ${roy.roy_token_id}, ${roy.roy_contract}, $royalties) \
       on conflict do nothing"]

let insert_order_activity
    dbh match_left match_right hash transaction block level date order_activity_type =
  [%pgsql dbh
      "insert into order_activities(match_left, match_right, hash, transaction, \
       block, level, date, order_activity_type) \
       values ($?match_left, $?match_right, $?hash, $?transaction, \
       $?block, $?level, $date, $order_activity_type) \
       on conflict do nothing"]

let insert_order_activity dbh date activity =
  begin match activity.order_activity_type with
    | OrderActivityList act ->
      let hash = Some act.order_activity_bid_hash in
      insert_order_activity dbh None None hash None None None date "list"
    | OrderActivityBid act ->
      let hash = Some act.order_activity_bid_hash in
      insert_order_activity dbh None None hash None None None date "bid"
    | OrderActivityCancelList act ->
      let hash = Some act.order_activity_cancel_bid_hash in
      let transaction = Some act.order_activity_cancel_bid_transaction_hash in
      let block = Some act.order_activity_cancel_bid_block_hash in
      let level = Some (Int64.to_int32 act.order_activity_cancel_bid_block_number) in
      insert_order_activity dbh None None hash transaction block level date "cancel"
    | OrderActivityCancelBid act ->
      let hash = Some act.order_activity_cancel_bid_hash in
      let transaction = Some act.order_activity_cancel_bid_transaction_hash in
      let block = Some act.order_activity_cancel_bid_block_hash in
      let level = Some (Int64.to_int32 act.order_activity_cancel_bid_block_number) in
      insert_order_activity dbh None None hash transaction block level date "cancel"
    | OrderActivityMatch act ->
      let left = Some act.order_activity_match_left.order_activity_match_side_hash in
      let right = Some act.order_activity_match_right.order_activity_match_side_hash in
      let transaction = Some act.order_activity_match_transaction_hash in
      let block = Some act.order_activity_match_block_hash in
      let level = Some (Int64.to_int32 act.order_activity_match_block_number) in
      insert_order_activity dbh left right left transaction block level date "match"
  end >>=? fun () ->
  Rarible_kafka.produce_order_activity activity >>= fun () ->
  Lwt.return_ok ()

let insert_order_activity_new dbh date order =
  let make = order.order_elt.order_elt_make in
  let take = order.order_elt.order_elt_take in
  let>? price = nft_price make take in
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
    | ATFA_2 _, _ -> OrderActivityList activity
    | _, _ -> OrderActivityBid activity in
  let order_activity = {
    order_activity_id = Hex.show @@ Hex.of_bigstring @@ Hacl.Rand.gen 128 ;
    order_activity_date = date ;
    order_activity_source = "RARIBLE" ;
    order_activity_type = order_activity_type ;
  } in
  insert_order_activity dbh date order_activity

let insert_order_activity_cancel dbh transaction block index level date hash =
  let>? order = get_order ~dbh hash in
  match order with
  | Some order ->
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
    | ATFA_2 _, _ -> OrderActivityCancelList activity
    | _, _ -> OrderActivityCancelBid activity in
  let order_activity = {
    order_activity_id = Printf.sprintf "%s_%ld" block index ;
    order_activity_date = date ;
    order_activity_source = "RARIBLE" ;
    order_activity_type = order_activity_type ;
  } in
    insert_order_activity dbh date order_activity
  | None ->
    Lwt.return_ok ()

let insert_order_activity_match
    dbh transaction block index level date
    hash_left left_maker left_asset
    hash_right right_maker right_asset  =
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
  let>? price = nft_price left_asset right_asset in
  let order_activity_type =
    OrderActivityMatch {
      order_activity_match_left = match_left ;
      order_activity_match_right = match_right ;
      order_activity_match_price = price ;
      order_activity_match_transaction_hash = transaction ;
      order_activity_match_block_hash = block ;
      order_activity_match_block_number = Int64.of_int32 level ;
      order_activity_match_log_index = 0 ;
    } in
  let order_activity = {
    order_activity_id = Printf.sprintf "%s_%ld" block index ;
    order_activity_date = date ;
    order_activity_source = "RARIBLE" ;
    order_activity_type = order_activity_type ;
  } in
  insert_order_activity dbh date order_activity

let insert_cancel dbh op (hash : Tzfunc.H.t) =
  let hash = ( hash :> string ) in
  let source = op.bo_op.source in
  [%pgsql dbh
      "insert into order_cancel(transaction, index, block, level, tsp, source, cancel) \
       values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
       ${op.bo_tsp}, $source, $hash) \
       on conflict do nothing"] >>=? fun () ->
  produce_order_event_hash dbh hash >>=? fun () ->
  insert_order_activity_cancel
    dbh op.bo_hash op.bo_block op.bo_index op.bo_level op.bo_tsp hash

let insert_do_transfers dbh op
    ~(left : Tzfunc.H.t) ~left_maker ~left_asset
    ~(right : Tzfunc.H.t) ~right_maker ~right_asset
    ~fill_make_value ~fill_take_value =
  let left = ( left :> string ) in
  let right = ( right :> string ) in
  let source = op.bo_op.source in
  [%pgsql dbh
      "insert into order_match(transaction, index, block, level, tsp, source, \
       hash_left, hash_right, fill_make_value, fill_take_value) \
       values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
       ${op.bo_tsp}, $source, $left, $right, \
       $fill_make_value, $fill_take_value) \
       on conflict do nothing"] >>=? fun () ->
  produce_order_event_hash dbh left >>=? fun () ->
  produce_order_event_hash dbh right >>=? fun () ->
  insert_order_activity_match
    dbh op.bo_hash op.bo_block op.bo_index op.bo_level op.bo_tsp
    left left_maker left_asset
    right right_maker right_asset

let insert_ft_fa2 dbh op tr txs =
  iter_rp (fun tx ->
      iter_rp (fun txd ->
          [%pgsql dbh
              "insert into ft_token_updates(transaction, index, block, \
               level, tsp, source, destination, contract, amount) \
               values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
               ${op.bo_tsp}, ${tx.tr_source}, ${txd.tr_destination}, \
               ${tr.destination}, ${txd.tr_amount}) \
               on conflict do nothing"]) tx.tr_txs) txs

let insert_ft_fa1 dbh op tr (from, dst, amount) =
  [%pgsql dbh
      "insert into ft_token_updates(transaction, index, block, \
       level, tsp, source, destination, contract, amount) \
       values(${op.bo_hash}, ${op.bo_index}, ${op.bo_block}, ${op.bo_level}, \
       ${op.bo_tsp}, $from, $dst, \
       ${tr.destination}, $amount) \
       on conflict do nothing"]

let insert_transaction config dbh op tr =
  match tr.parameters with
  | None | Some { value = Other _; _ } | Some { value = Bytes _; _ } -> Lwt.return_ok ()
  | Some {entrypoint; value = Micheline m} ->
    if tr.destination = config.Crawlori.Config.extra.royalties then (* royalties *)
      match Parameters.parse_royalties entrypoint m with
      | Ok roy ->
        Format.printf "\027[0;35mset royalties %s %ld\027[0m@." (short op.bo_hash) op.bo_index;
        insert_royalties dbh op roy
      | _ -> Lwt.return_ok ()
    else if tr.destination = config.Crawlori.Config.extra.exchange_v2 then (* exchange_v2 *)
      begin match Parameters.parse_exchange entrypoint m with
        | Ok (Cancel hash) ->
          Format.printf "\027[0;35mcancel order %s %ld %s\027[0m@."
            (short op.bo_hash) op.bo_index (hash :> string);
          insert_cancel dbh op hash
        | Ok (DoTransfers
                {left; left_maker; left_asset;
                 right; right_maker; right_asset;
                 fill_make_value; fill_take_value}) ->
          Format.printf "\027[0;35mapply orders %s %ld %s %s\027[0m@."
            (short op.bo_hash) op.bo_index (left :> string) (right :> string);
          insert_do_transfers
            dbh op
            ~left ~left_maker ~left_asset
            ~right ~right_maker ~right_asset
            ~fill_make_value ~fill_take_value
        | _ ->
          (* todo : match order *)
          Lwt.return_ok ()
      end
    else if List.mem tr.destination config.Crawlori.Config.extra.ft_fa2 then
      begin match Parameters.parse_fa2 entrypoint m with
        | Ok (Transfers t) ->
          Format.printf "\027[0;35mFT transfer %s %ld %s\027[0m@."
            (short op.bo_hash) op.bo_index (short tr.destination);
          insert_ft_fa2 dbh op tr t
        | _ -> Lwt.return_ok ()
      end
    else if List.mem tr.destination config.Crawlori.Config.extra.ft_fa1 then
      begin match Parameters.parse_fa1 entrypoint m with
        | Ok t ->
          Format.printf "\027[0;35mFT transfer %s %ld %s\027[0m@."
            (short op.bo_hash) op.bo_index (short tr.destination);
          insert_ft_fa1 dbh op tr t
        | _ -> Lwt.return_ok ()
      end

    else (* nft *)
      begin match Parameters.parse_fa2 entrypoint m with
        | Ok (Mint_tokens m) ->
          Format.printf "\027[0;35mmint %s %ld %s\027[0m@."
            (short op.bo_hash) op.bo_index (short tr.destination);
          insert_mint dbh op tr.destination m
        | Ok (Burn_tokens b) ->
          Format.printf "\027[0;35mburn %s %ld %s\027[0m@."
            (short op.bo_hash) op.bo_index (short tr.destination);
          insert_burn dbh op tr b
        | Ok (Transfers t) ->
          Format.printf "\027[0;35mtransfer %s %ld %s\027[0m@."
            (short op.bo_hash) op.bo_index (short tr.destination);
          insert_transfer dbh op tr t
        | Ok (Operator_updates t) ->
          Format.printf "\027[0;35mupdate operator %s %ld %s\027[0m@."
            (short op.bo_hash) op.bo_index (short tr.destination);
          insert_update_operator dbh op tr t
        | Ok (Operator_updates_all t) ->
          Format.printf "\027[0;35mupdate operator all %s %ld %s\027[0m@."
            (short op.bo_hash) op.bo_index (short tr.destination);
          insert_update_operator_all dbh op tr t
        | Ok (Metadata_uri s) ->
          Format.printf "\027[0;35mset uri %s %ld %s\027[0m@."
            (short op.bo_hash) op.bo_index (short tr.destination);
          insert_metadata_uri dbh op tr s
        | Ok (Token_metadata x) ->
          Format.printf "\027[0;35mset metadata %s %ld %s\027[0m@."
            (short op.bo_hash) op.bo_index (short tr.destination);
          insert_token_metadata dbh op tr x
        | Error _ -> Lwt.return_ok ()
      end

let filter_contracts dbh ori =
  let|>? r = [%pgsql.object dbh "select admin_wallet, royalties_contract from state"] in
  match r with
  | [ r ] ->
    let open Utils in
    if match_entrypoints (fa2_entrypoints @ fa2_ext_entrypoints) ori.script.code then
      match match_fields [ "ledger"; "owner"; "royaltiesContract" ] ori.script with
      | Ok [ Some _; Some (Mstring owner); Some (Mstring royalties_contract) ] ->
        if r#royalties_contract = royalties_contract then
          Some (`nft (owner, (Z.to_int64 Z.zero)))
        else None
      | _ -> None
    else None
  | _ -> None

let insert_origination config dbh op ori =
  let>? r = filter_contracts dbh ori in
  match r with
  | None -> Lwt.return_ok ()
  | Some (`nft (owner, ledger_id)) ->
    let kt1 = Tzfunc.Crypto.op_to_KT1 op.bo_hash in
    let|>? () = [%pgsql dbh
        "insert into contracts(kind, address, owner, block, level, tsp, \
         last_block, last_level, last, ledger_id) \
         values('nft', $kt1, $owner, ${op.bo_block}, ${op.bo_level}, \
         ${op.bo_tsp}, ${op.bo_block}, ${op.bo_level}, ${op.bo_tsp}, $ledger_id) \
         on conflict do nothing"] in
    let open Crawlori.Config in
    match config.accounts with
    | None -> config.accounts <- Some (SSet.singleton kt1)
    | Some accs -> config.accounts <- Some (SSet.add kt1 accs)

let insert_operation config dbh op =
  let open Hooks in
  match op.bo_meta with
  | Some meta ->
    if meta.op_status = `applied then
      match op.bo_op.kind with
      | Transaction tr -> insert_transaction config dbh op tr
      (* | Origination ori -> set_origination config dbh op ori *)
      | _ -> Lwt.return_ok ()
    else Lwt.return_ok ()
  | _ -> Lwt.return_ok ()

let insert_block config dbh b =
  EzEncoding.construct Tzfunc.Proto.full_block_enc.Encoding.json b
  |> Rarible_kafka.produce_test >>= fun () ->
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
    {tk_owner; tk_op = {tk_token_id; tk_amount} } =
  let main_s = if main then 1L else -1L in
  let factor = if burn then Int64.neg main_s else main_s in
  let>? l_amount = [%pgsql dbh
      "update tokens set supply = supply + $factor * $tk_amount::bigint, \
       amount = amount + $factor * $tk_amount::bigint, \
       last_block = case when $main then $block else last_block end, \
       last_level = case when $main then $level else last_level end, \
       last = case when $main then $tsp else last end
       where token_id = $tk_token_id and contract = $contract and owner = $tk_owner \
       returning amount"] in
  let>? () = [%pgsql dbh
      "update tokens set supply = supply + $factor * $tk_amount::bigint, \
       last_block = case when $main then $block else last_block end, \
       last_level = case when $main then $level else last_level end, \
       last = case when $main then $tsp else last end
       where token_id = $tk_token_id and contract = $contract and owner <> $tk_owner"] in
  (* update account *)
  let>? new_amount = one ~err:"no amount for burn update" l_amount in
  let new_token = EzEncoding.construct account_token_enc {
      at_token_id = tk_token_id;
      at_contract = contract;
      at_amount = new_amount } in
  let old_token = EzEncoding.construct account_token_enc {
      at_token_id = tk_token_id;
      at_contract = contract;
      at_amount = Int64.(sub new_amount (mul main_s tk_amount))  } in
  [%pgsql dbh
      "update accounts set tokens = array_append(array_remove(tokens, $old_token), $new_token), \
       last_block = case when $main then $block else last_block end, \
       last_level = case when $main then $level else last_level end, \
       last = case when $main then $tsp else last end where address = $tk_owner"]


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

let contract_updates dbh main l =
  let>? contracts = fold_rp (fun acc r ->
      let contract, block, level, tsp = r#contract, r#block, r#level, r#tsp in
      let acc = SSet.add contract acc in
      let>? () = match r#mint, r#burn, r#uri with
        | Some json, _, _ ->
          let tk = EzEncoding.destruct token_op_owner_enc json in
          let>? () =
            contract_updates_base dbh ~main ~contract ~block ~level ~tsp ~burn:false tk in
          let>? () =
            produce_nft_item_event dbh contract tk.tk_op.tk_token_id in
          produce_nft_ownership_event dbh contract tk.tk_op.tk_token_id tk.tk_owner
        | _, Some json, _ ->
          let tk = EzEncoding.destruct token_op_owner_enc json in
          let>? () =
            contract_updates_base dbh ~main ~contract ~block ~level ~tsp ~burn:true tk in
          let>? () =
            produce_nft_item_event dbh contract tk.tk_op.tk_token_id in
          produce_nft_ownership_event dbh contract tk.tk_op.tk_token_id tk.tk_owner
        | _, _, Some uri ->
          metadata_uri_update dbh ~main ~contract ~block ~level ~tsp uri
        | _ -> Lwt.return_ok () in
      Lwt.return_ok (SSet.add contract acc)) SSet.empty l in
  (* update contracts *)
  iter_rp (fun c ->
      [%pgsql dbh
          "with tmp(count, last) as ( \
           select count(distinct token_id), max(token_id) from tokens where contract = $c)
           update contracts set \
           tokens_number = tmp.count, \
           next_token_id = coalesce((tmp.last::bigint + 1)::varchar, '0') \
           from tmp where contracts.address = $c"]) (SSet.elements contracts)

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
  let amount = if main then amount else Int64.neg amount in
  let>? info = [%pgsql dbh
      "update tokens set amount = amount - $amount, \
       last_block = case when $main then $block else last_block end, \
       last_level = case when $main then $level else last_level end, \
       last = case when $main then $tsp else last end where token_id = $token_id and \
       owner = $source and contract = $contract \
       returning amount, metadata, supply, transaction, tsp, name, royalties, \
       creators, description, attributes, image, animation"] in
  let>? new_src_amount, meta, supply, transaction, tsp, name, royalties,
        creators, description, attributes, image, animation =
    one ~err:"source token not found for transfer update" info in
  let>? l_new_dst_amount =
    [%pgsql dbh
        "update tokens set amount = amount + $amount, \
         metadata = case when amount = 0 then $meta else metadata end, \
         name = case when amount = 0 then $?name else name end, \
         royalties = case when amount = 0 then $royalties else royalties end, \
         creators = case when amount = 0 then $creators else creators end, \
         description = case when amount = 0 then $?description else description end, \
         attributes = case when amount = 0 then $?attributes else attributes end, \
         image = case when amount = 0 then $?image else image end, \
         animation = case when amount = 0 then $?animation else image end, \
         supply = case when amount = 0 then $supply else supply end, \
         transaction = case when amount = 0 then $transaction else transaction end, \
         last_block = case when $main then $block else block end, \
         last_level = case when $main then $level else level end, \
         last = case when $main then $tsp else last end where token_id = $token_id and \
         owner = $destination and contract = $contract returning amount"] in
  let>? new_dst_amount =
    one ~err:"destination token not found for transfer update" l_new_dst_amount in
  begin
    if main then
      begin
        let>? () = produce_nft_item_event dbh contract token_id in
        let>? () = produce_nft_ownership_event dbh contract token_id source in
        produce_nft_ownership_event dbh contract token_id destination
      end
    else Lwt.return_ok ()
  end >>=? fun () ->
  let at = { at_token_id = token_id; at_contract = contract; at_amount = new_src_amount } in
  let new_token_src = EzEncoding.construct account_token_enc at in
  let old_token_src = EzEncoding.construct account_token_enc {at with at_amount = Int64.add new_src_amount amount} in
  let new_token_dst = EzEncoding.construct account_token_enc {at with at_amount = new_dst_amount} in
  let old_token_dst = EzEncoding.construct account_token_enc {at with at_amount = Int64.sub new_dst_amount amount} in
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

let token_metadata_enc =
  let open Json_encoding in
  EzEncoding.ignore_enc @@
  obj6
    (req "name" string)
    (dft "creators" (list any_ezjson_value) [])
    (opt "description" string)
    (opt "attributes" any_ezjson_value)
    (opt "image" string)
    (opt "animation" string)

let token_metadata_update dbh ~main ~contract ~block ~level ~tsp ~token_id meta =
  if main then
    let name, creators, description, attributes, image, animation =
      try
        let n, c, d, at, i, an = EzEncoding.destruct token_metadata_enc meta in
        let at = Option.map (EzEncoding.construct Json_encoding.any_ezjson_value) at in
        let c = EzEncoding.construct Json_encoding.(list any_ezjson_value) c in
        Some n, Some c, d, at, i, an
      with _ -> None, None, None, None, None, None in
    let>? () =
      [%pgsql dbh
          "update tokens set metadata = $meta, \
           name = $?name, description = $?description, attributes = $?attributes, \
           image = $?image, animation = $?animation, creators = $?creators,\
           last_block = case when $main then $block else last_block end, \
           last_level = case when $main then $level else last_level end, \
           last = case when $main then $tsp else last end \
           where contract = $contract and \
           token_id = $token_id"] in
    produce_nft_item_event dbh contract token_id
  else Lwt.return_ok ()

let token_updates dbh main l =
  iter_rp (fun r ->
      let contract, block, level, tsp, source =
        r#contract, r#block, r#level, r#tsp, r#source in
      match r#destination, r#token_id, r#amount, r#operator, r#add, r#metadata, r#royalties  with
      | Some destination, Some token_id, Some amount, _, _, _, _ ->
        transfer_updates dbh main ~contract ~block ~level ~tsp ~token_id ~source amount destination
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

let ft_token_updates dbh main l =
  iter_rp (fun r ->
      let amount = if main then r#amount else Int64.neg r#amount in
      let>? () = [%pgsql dbh
          "update ft_tokens set balance = balance + $amount \
           where contract = ${r#contract} and account = ${r#destination}"] in
      [%pgsql dbh
          "update ft_tokens set balance = balance - $amount \
           where contract = ${r#contract} and account = ${r#source}"]) l

let set_main _config dbh {Hooks.m_main; m_hash} =
  let sort l = List.sort (fun r1 r2 ->
      if m_main then Int32.compare r1#index r2#index
      else Int32.compare r2#index r1#index) l in
  use (Some dbh) @@ fun dbh ->
  let>? () = [%pgsql dbh "update contracts set main = $m_main where block = $m_hash"] in
  let>? () = [%pgsql dbh "update tokens set main = $m_main where block = $m_hash"] in
  let>? () = [%pgsql dbh "update nft_activities set main = $m_main where block = $m_hash"] in
  let>? () =
    [%pgsql dbh "update order_activities set main = $m_main where block = $m_hash"] in
  let>? t_updates =
    [%pgsql.object dbh
        "update token_updates set main = $m_main where block = $m_hash returning *"] in
  let>? c_updates =
    [%pgsql.object dbh
        "update contract_updates set main = $m_main where block = $m_hash returning *"] in

  let>? () = [%pgsql dbh "update order_cancel set main = $m_main where block = $m_hash"] in
  let>? () = [%pgsql dbh "update order_match set main = $m_main where block = $m_hash"] in
  let>? ft_updates =
    [%pgsql.object dbh
        "update ft_token_updates set main = $m_main where block = $m_hash returning *"] in
  let>? () = contract_updates dbh m_main @@ sort c_updates in
  let>? () = token_updates dbh m_main @@ sort t_updates in
  let>? () = ft_token_updates dbh m_main @@ sort ft_updates in
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
    (Int64.of_float @@ CalendarLib.Calendar.to_unixfloat nft_item.nft_item_date)
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
      "select concat(contract, ':', token_id) as id, contract, token_id, \
       last, amount, supply, metadata, name, creators, description, attributes, \
       image, animation, tsp from tokens where \
       main and owner = $owner and amount <> 0 and \
       ($no_continuation or \
       (last = $ts and concat(contract, ':', token_id) > $id) or \
       (last < $ts)) \
       order by last desc, id asc limit $size64"] in
  let>? nft_items_total = [%pgsql dbh
      "select count(owner) from tokens where main"] in
  let>? nft_items_total = match nft_items_total with
    | [ None ] -> Lwt.return_ok 0L
    | [ Some i64 ] -> Lwt.return_ok i64
    | _ -> Lwt.return_error (`hook_error "count with more then one row") in
  map_rp (fun r -> mk_nft_item ?include_meta r) l >>=? fun nft_items_items ->
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
      "select concat(contract, ':', token_id) as id, contract, token_id, \
       last, amount, supply, metadata, name, creators, description, attributes, \
       image, animation, tsp \
       from tokens, \
       jsonb_to_recordset((metadata -> 'creators')) as creators(account varchar, value int) \
       where creators.account = $creator and name is not null and \
       main and amount <> 0 and \
       ($no_continuation or \
       (last = $ts and concat(contract, ':', token_id) > $id) or \
       (last < $ts)) \
       order by last desc, id asc limit $size64"] in
  let>? nft_items_total = [%pgsql dbh
      "select count(owner) from tokens where main"] in
  let>? nft_items_total = match nft_items_total with
    | [ None ] -> Lwt.return_ok 0L
    | [ Some i64 ] -> Lwt.return_ok i64
    | _ -> Lwt.return_error (`hook_error "count with more then one row") in
  let>? nft_items_items = map_rp (fun r -> mk_nft_item ?include_meta r) l in
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
      "select concat(contract, ':', token_id) as id, contract, token_id, \
       last, amount, supply, metadata, name, creators, description, attributes, \
       image, animation, tsp \
       from tokens where \
       main and contract = $contract and amount <> 0 and name is not null and \
       ($no_continuation or \
       (last = $ts and concat(contract, ':', token_id) > $id) or \
       (last < $ts)) \
       order by last desc, id asc limit $size64"] in
  let>? nft_items_total = [%pgsql dbh
      "select count(owner) from tokens where main"] in
  let>? nft_items_total = match nft_items_total with
    | [ None ] -> Lwt.return_ok 0L
    | [ Some i64 ] -> Lwt.return_ok i64
    | _ -> Lwt.return_error (`hook_error "count with more then one row") in
  let>? nft_items_items = map_rp (fun r -> mk_nft_item ?include_meta r) l in
  let len = List.length nft_items_items in
  let nft_items_continuation =
    if len <> size then None
    else Some
        (mk_nft_items_continuation @@ List.hd (List.rev nft_items_items)) in
  Lwt.return_ok
    { nft_items_items ; nft_items_continuation ; nft_items_total }

let get_nft_item_meta_by_id ?dbh contract token_id =
  Format.eprintf "get_nft_meta_by_id %s %s@." contract token_id ;
  use dbh @@ fun dbh ->
  let>? l = [%pgsql.object dbh
      "select metadata, name, creators, description, attributes, \
       image, animation from tokens \
       where contract = $contract and token_id = $token_id and main and name is not null"] in
  let>? r = one l in
  match mk_nft_item_meta r with
  | None -> Lwt.return_error (`hook_error "no_metadata")
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
      "select concat(contract, ':', token_id) as id, contract, token_id, \
       last, amount, supply, metadata, name, creators, description, attributes, \
       image, animation, tsp \
       from tokens where \
       main and \
       (supply > 0 and amount <> 0 or (not $no_show_deleted and $show_deleted_v)) and \
       ($no_last_updated_to or (last <= $last_updated_to_v)) and \
       ($no_last_updated_from or (last >= $last_updated_from_v)) and \
       ($no_continuation or \
       (last = $ts and concat(contract, ':', token_id) > $id) or \
       (last < $ts)) \
       order by last desc, id asc limit $size64"] in
  let>? nft_items_total = [%pgsql dbh
      "select count(owner) from tokens where main"] in
  let>? nft_items_total = match nft_items_total with
    | [ None ] -> Lwt.return_ok 0L
    | [ Some i64 ] -> Lwt.return_ok i64
    | _ -> Lwt.return_error (`hook_error "count with more then one row") in
  let>? nft_items_items = map_rp (fun r -> mk_nft_item ?include_meta r) l in
  let len = List.length nft_items_items in
  let nft_items_continuation =
    if len <> size then None
    else Some
        (mk_nft_items_continuation @@ List.hd (List.rev nft_items_items)) in
  Lwt.return_ok
    { nft_items_items ; nft_items_continuation ; nft_items_total }

let mk_nft_activity_continuation obj =
  Printf.sprintf "%Ld_%s"
    (Int64.of_float @@ CalendarLib.Calendar.to_unixfloat obj#date)
    obj#transaction

let mk_nft_activity_elt obj = {
  nft_activity_owner = obj#owner ;
  nft_activity_contract = obj#contract ;
  nft_activity_token_id = obj#token_id ;
  nft_activity_value = Int64.to_string obj#amount ;
  nft_activity_transaction_hash = obj#transaction ;
  nft_activity_block_hash = obj#block ;
  nft_activity_block_number = Int64.of_int32 obj#level ;
}

let mk_nft_activity obj = match obj#activity_type with
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
  | _ as t -> Lwt.return_error (`hook_error ("unknown nft activity type " ^ t))

let get_nft_activities_by_collection ?dbh ?continuation ?(size=50) filter =
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
  let>? l = [%pgsql.object dbh
      "select activity_type, transaction, block, level, date, contract, \
       token_id, owner, amount, tr_from from nft_activities where \
       main and contract = $contract and \
       position(activity_type in $types) > 0 and \
       ($no_continuation or \
       (date = $ts and transaction > $h) or (date < $ts)) \
       order by date desc, transaction asc limit $size64"] in
  map_rp (fun r -> let|>? a = mk_nft_activity r in a, r) l >>=? fun activities ->
  let len = List.length activities in
  let nft_activities_continuation =
    if len <> size then None
    else Some
        (mk_nft_activity_continuation @@ snd @@ List.hd (List.rev activities)) in
  Lwt.return_ok
    { nft_activities_items = List.map fst activities ; nft_activities_continuation }

let get_nft_activities_by_item ?dbh ?continuation ?(size=50) filter =
  Format.eprintf "get_nft_activities_by_item %s %s [%s] %s %d@."
    filter.nft_activity_by_item_contract
    filter.nft_activity_by_item_token_id
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
  let>? l = [%pgsql.object dbh
      "select activity_type, transaction, block, level, date, contract, \
       token_id, owner, amount, tr_from from nft_activities where \
       main and contract = $contract and token_id = $token_id and \
       position(activity_type in $types) > 0 and \
       ($no_continuation or \
       (date = $ts and transaction > $h) or (date < $ts)) \
       order by date desc, transaction asc limit $size64"] in
  map_rp (fun r -> let|>? a = mk_nft_activity r in a, r) l >>=? fun activities ->
  let len = List.length activities in
  let nft_activities_continuation =
    if len <> size then None
    else Some
        (mk_nft_activity_continuation @@ snd @@ List.hd (List.rev activities)) in
  Lwt.return_ok
    { nft_activities_items = List.map fst activities ; nft_activities_continuation }

let get_nft_activities_by_user ?dbh ?continuation ?(size=50) filter =
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
  let>? l = [%pgsql.object dbh
      "select activity_type, transaction, block, level, date, contract, \
       token_id, owner, amount, tr_from from nft_activities where \
       main and \
       (position(owner in $users) > 0 or position(tr_from in $users) > 0) and \
       position(activity_type in $types) > 0 and \
       ($no_continuation or \
       (date = $ts and transaction > $h) or (date < $ts)) \
       order by date desc, transaction asc limit $size64"] in
  map_rp (fun r -> let|>? a = mk_nft_activity r in a, r) l >>=? fun activities ->
  let len = List.length activities in
  let nft_activities_continuation =
    if len <> size then None
    else Some
        (mk_nft_activity_continuation @@ snd @@ List.hd (List.rev activities)) in
  Lwt.return_ok
    { nft_activities_items = List.map fst activities ; nft_activities_continuation }

let get_nft_activities_all ?dbh ?continuation ?(size=50) types =
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
  let>? l = [%pgsql.object dbh "show"
      "select activity_type, transaction, block, level, date, contract, \
       token_id, owner, amount, tr_from from nft_activities where \
       main and position(activity_type in $types) > 0 and \
       ($no_continuation or \
       (date = $ts and transaction > $h) or (date < $ts)) \
       order by date desc, transaction asc limit $size64"] in
  map_rp (fun r -> let|>? a = mk_nft_activity r in a, r) l >>=? fun activities ->
  let len = List.length activities in
  let nft_activities_continuation =
    if len <> size then None
    else Some
        (mk_nft_activity_continuation @@ snd @@ List.hd (List.rev activities)) in
  Lwt.return_ok
    { nft_activities_items = List.map fst activities ; nft_activities_continuation }

let get_nft_activities ?dbh ?continuation ?size = function
  | ActivityFilterByCollection filter ->
    get_nft_activities_by_collection ?dbh ?continuation ?size filter
  | ActivityFilterByItem filter ->
    get_nft_activities_by_item ?dbh ?continuation ?size filter
  | ActivityFilterByUser filter ->
    get_nft_activities_by_user ?dbh ?continuation ?size filter
  | ActivityFilterAll filter ->
    get_nft_activities_all ?dbh ?continuation ?size filter

let mk_nft_ownerships_continuation nft_ownership =
  Printf.sprintf "%Ld_%s"
    (Int64.of_float @@ CalendarLib.Calendar.to_unixfloat nft_ownership.nft_ownership_date)
    nft_ownership.nft_ownership_id

let get_nft_ownerships_by_item ?dbh ?continuation ?(size=50) contract token_id =
  Format.eprintf "get_nft_ownerships_by_item %s %s %s %d@."
    contract
    token_id
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
       contract, token_id, owner, last, amount, supply, metadata, \
       name, creators, description, attributes, image, animation \
       from tokens where \
       main and contract = $contract and token_id = $token_id and amount <> 0 and \
       ($no_continuation or \
       (last = $ts and concat(contract, ':', token_id, ':', owner) > $id) or \
       (last < $ts)) \
       order by last desc, id asc limit $size64"] in
  let>? nft_ownerships_total = [%pgsql dbh
      "select count(owner) from tokens where \
       main and contract = $contract and token_id = $token_id and \
       amount <> 0"] in
  let>? nft_ownerships_total = match nft_ownerships_total with
    | [ None ] -> Lwt.return_ok 0L
    | [ Some i64 ] -> Lwt.return_ok i64
    | _ -> Lwt.return_error (`hook_error "count with more then one row") in
  let>? nft_ownerships_ownerships = map_rp (fun r -> mk_nft_ownership r) l in
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
       contract, token_id, owner, last, amount, supply, metadata, \
       name, creators, description, attributes, image, animation \
       from tokens where \
       main and amount <> 0 and \
       ($no_continuation or \
       (last = $ts and concat(contract, ':', token_id, ':', owner) > $id) or \
       (last < $ts)) \
       order by last desc, id asc limit $size64"] in
  let>? nft_ownerships_total = [%pgsql dbh
      "select count(owner) from tokens where main and amount <> 0"] in
  let>? nft_ownerships_total = match nft_ownerships_total with
    | [ None ] -> Lwt.return_ok 0L
    | [ Some i64 ] -> Lwt.return_ok i64
    | _ -> Lwt.return_error (`hook_error "count with more then one row") in
  let>? nft_ownerships_ownerships = map_rp (fun r -> mk_nft_ownership r) l in
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
  let>? r = [%pgsql dbh "select next_token_id from contracts where address = $contract"] in
  match r with
  | [ i ] -> Lwt.return_ok {
      nft_token_id = i;
      nft_token_id_signature = None ;
    }
  | _ -> Lwt.return_error (`hook_error "no contracts entry for this contract")

let mk_nft_collection_name_symbol r =
  match r#name with
  | None -> "NO NAME", r#symbol
  | Some n -> n, r#symbol

let mk_nft_collection obj =
  let name, symbol = mk_nft_collection_name_symbol obj in
  {
    nft_collection_id = obj#address ;
    nft_collection_owner = Some (obj#owner) ;
    nft_collection_type = CTFA_2 ;
    nft_collection_name = name ;
    nft_collection_symbol = symbol ;
    nft_collection_features = [] ;
    nft_collection_supports_lazy_mint = false ;
    nft_collection_minters = Some [ obj#owner ]
  }

let get_nft_collection_by_id ?dbh collection =
  Format.eprintf "get_nft_collection_by_id %s@." collection ;
  use dbh @@ fun dbh ->
  let>? l = [%pgsql.object dbh
      "select address, owner, metadata, name, symbol \
       from contracts where address = $collection and main"] in
  let>? obj = one l in
  let nft_item = mk_nft_collection obj in
  Lwt.return_ok nft_item

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
      "select address, owner, metadata, name, symbol \
       from contracts where \
       main and owner = $owner and \
       ($no_continuation or (address > $collection)) \
       order by address asc limit $size64"] in
  let>? nft_collections_total = [%pgsql dbh
      "select count(distinct address) from contracts where main and owner = $owner "] in
  let>? nft_collections_total = match nft_collections_total with
    | [ None ] -> Lwt.return_ok 0L
    | [ Some i64 ] -> Lwt.return_ok i64
    | _ -> Lwt.return_error (`hook_error "count with more then one row") in
  let nft_collections_collections = List.map  (fun r -> mk_nft_collection r) l in
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
      "select address, owner, metadata, name, symbol \
       from contracts where main and \
       ($no_continuation or (address > $collection)) \
       order by address asc limit $size64"] in
  let>? nft_collections_total = [%pgsql dbh
      "select count(distinct address) from contracts where main "] in
  let>? nft_collections_total = match nft_collections_total with
    | [ None ] -> Lwt.return_ok 0L
    | [ Some i64 ] -> Lwt.return_ok i64
    | _ -> Lwt.return_error (`hook_error "count with more then one row") in
  let nft_collections_collections = List.map (fun r -> mk_nft_collection r) l in
  let len = List.length nft_collections_collections in
  let nft_collections_continuation =
    if len <> size then None
    else Some (List.hd (List.rev nft_collections_collections)).nft_collection_id in
  Lwt.return_ok
    { nft_collections_collections ; nft_collections_continuation ; nft_collections_total }

let mk_order_continuation order =
  Printf.sprintf "%Ld_%s"
    (Int64.of_float @@ CalendarLib.Calendar.to_unixfloat order.order_elt.order_elt_last_update_at)
    order.order_elt.order_elt_hash

let filter_orders ?origin orders =
  List.filter (fun order ->
      (int_of_string order.order_elt.order_elt_make_stock) > 0 &&
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
      [%pgsql.object dbh "select hash, last_update_at from orders \
                   where \
                   ($no_continuation or \
                   (last_update_at < $ts) or \
                   (last_update_at = $ts and hash < $h)) \
                   order by last_update_at desc, hash desc limit $size"] in
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
  let orders_pagination_contination =
    if len = 0L || len < size then None
    else Some
        (mk_order_continuation @@ List.hd @@ List.rev orders) in
  Lwt.return_ok
    { orders_pagination_orders = orders ; orders_pagination_contination }

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
      [%pgsql.object dbh "select hash, last_update_at from orders \
                   where \
                   maker = $maker and \
                   ($no_continuation or \
                   (last_update_at < $ts) or \
                   (last_update_at = $ts and hash < $h)) \
                   order by last_update_at desc, hash desc limit $size"] in
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
  let orders_pagination_contination =
    if len = 0L || len < size then None
    else Some
        (mk_order_continuation @@ List.hd @@ List.rev orders) in
  Lwt.return_ok
    { orders_pagination_orders = orders ; orders_pagination_contination }

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
    ?dbh ?origin ?continuation ?maker ?currency ~size contract token_id acc =
  Format.eprintf "get_orders_all_aux %s %s %Ld %s %s %d@."
    (match origin with None -> "None" | Some s -> s)
    (match continuation with
     | None -> "None"
     | Some (p, s) -> p ^ "_" ^ s)
    size
    contract
    token_id
    (List.length acc) ;
  let no_continuation, (p, h) =
    continuation = None,
    (match continuation with None -> "0", "" | Some (ts, h) -> (ts, h)) in
  let no_maker, maker_v = maker = None, (match maker with None -> "" | Some m -> m) in
  let no_currency = currency = None in
  let currency_tezos = currency = Some ATXTZ in
  let currency_fa1_2, currency_fa1_2_contract =
    (match currency with Some (ATFA_1_2 _) -> true | _ -> false),
    match currency with Some ATFA_1_2 c -> c | _ -> ""  in
  let currency_fa2, (currency_fa2_contract, currency_fa2_token_id) =
    (match currency with Some (ATFA_2 _) -> true | _ -> false),
    match currency with
    | Some ATFA_2 {asset_fa2_contract ; asset_fa2_token_id } ->
      asset_fa2_contract, asset_fa2_token_id
    | _ -> "", ""  in
  let len = Int64.of_int @@ List.length acc in
  if len < size  then
    use dbh @@ fun dbh ->
    let>? l =
      [%pgsql.object dbh "select hash, make_asset_value from orders \
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
                   ($no_continuation or \
                   (make_asset_value > $p) or \
                   (make_asset_value = $p and hash < $h)) \
                   order by make_asset_value asc, hash desc limit $size"] in
    let continuation = match List.rev l with
      | [] -> None
      | hd :: _ -> Some (hd#make_asset_value, hd#hash) in
    map_rp (fun r -> get_order ~dbh r#hash) l >>=? fun orders ->
    match orders with
    | [] -> Lwt.return_ok acc
    | _ ->
      let orders = List.filter_map (fun x -> x) orders in
      let orders = filter_orders ?origin orders in
      get_sell_orders_by_item_aux
        ~dbh ?origin ?continuation ?maker ~size contract token_id (acc @ orders)
  else
  if len = size then Lwt.return_ok acc
  else
    Lwt.return_ok @@
    List.filter_map (fun x -> x) @@
    List.mapi (fun i order -> if i < Int64.to_int size then Some order else None) acc

let get_sell_orders_by_item
    ?dbh ?origin ?continuation ?(size=50) ?maker ?currency contract token_id =
  Format.eprintf "get_sell_orders_by_item %s %s %d@."
    (match origin with None -> "None" | Some s -> s)
    (match continuation with
     | None -> "None"
     | Some (f, s) -> f ^ "_" ^ s)
    size ;
  let size = Int64.of_int size in
  let>? orders =
    get_sell_orders_by_item_aux
      ?dbh ?origin ?continuation ?maker ?currency ~size contract token_id [] in
  let len = Int64.of_int @@ List.length orders in
  let orders_pagination_contination =
    if len = 0L || len < size then None
    else Some
        (mk_order_continuation @@ List.hd @@ List.rev orders) in
  Lwt.return_ok
    { orders_pagination_orders = orders ; orders_pagination_contination }

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
      [%pgsql.object dbh "select hash, last_update_at from orders \
                   where make_asset_type_contract = $collection and \
                   make_asset_type_class = 'FA_2' and \
                   ($no_continuation or \
                   (last_update_at < $ts) or \
                   (last_update_at = $ts and hash < $h)) \
                   order by last_update_at desc, hash desc limit $size"] in
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
  let orders_pagination_contination =
    if len = 0L || len < size then None
    else Some
        (mk_order_continuation @@ List.hd @@ List.rev orders) in
  Lwt.return_ok
    { orders_pagination_orders = orders ; orders_pagination_contination }

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
      [%pgsql.object dbh "select hash, last_update_at from orders \
                   where make_asset_type_class = 'FA_2' and \
                   ($no_continuation or \
                   (last_update_at < $ts) or \
                   (last_update_at = $ts and hash < $h)) \
                   order by last_update_at desc, hash desc limit $size"] in
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
  let orders_pagination_contination =
    if len = 0L || len < size then None
    else Some
        (mk_order_continuation @@ List.hd @@ List.rev orders) in
  Lwt.return_ok
    { orders_pagination_orders = orders ; orders_pagination_contination }

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
      [%pgsql.object dbh "select hash, last_update_at from orders \
                   where \
                   maker = $maker and \
                   take_asset_type_class = 'FA_2' and \
                   ($no_continuation or \
                   (last_update_at < $ts) or \
                   (last_update_at = $ts and hash < $h)) \
                   order by last_update_at desc, hash desc limit $size"] in
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
  let orders_pagination_contination =
    if len = 0L || len < size then None
    else Some
        (mk_order_continuation @@ List.hd @@ List.rev orders) in
  Lwt.return_ok
    { orders_pagination_orders = orders ; orders_pagination_contination }

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
    ?dbh ?origin ?continuation ?maker ?currency ~size contract token_id acc =
  Format.eprintf "get_bid_orders_by_item_aux %s %s %Ld %s %s %d@."
    (match origin with None -> "None" | Some s -> s)
    (match continuation with
     | None -> "None"
     | Some (p, s) -> p ^ "_" ^ s)
    size
    contract
    token_id
    (List.length acc) ;
  let no_continuation, (p, h) =
    continuation = None,
    (match continuation with None -> "0", "" | Some (ts, h) -> (ts, h)) in
  let no_maker, maker_v = maker = None, (match maker with None -> "" | Some m -> m) in
  let no_currency = currency = None in
  let currency_tezos = currency = Some ATXTZ in
  let currency_fa1_2, currency_fa1_2_contract =
    (match currency with Some (ATFA_1_2 _) -> true | _ -> false),
    match currency with Some ATFA_1_2 c -> c | _ -> ""  in
  let currency_fa2, (currency_fa2_contract, currency_fa2_token_id) =
    (match currency with Some (ATFA_2 _) -> true | _ -> false),
    match currency with
    | Some ATFA_2 {asset_fa2_contract ; asset_fa2_token_id } ->
      asset_fa2_contract, asset_fa2_token_id
    | _ -> "", ""  in
  let len = Int64.of_int @@ List.length acc in
  if len < size  then
    use dbh @@ fun dbh ->
    let>? l =
      [%pgsql.object dbh "select hash, take_asset_value from orders \
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
                   ($no_continuation or \
                   (take_asset_value < $p) or \
                   (take_asset_value = $p and hash < $h)) \
                   order by take_asset_value desc, hash desc limit $size"] in
    let continuation = match List.rev l with
      | [] -> None
      | hd :: _ -> Some (hd#take_asset_value, hd#hash) in
    map_rp (fun r -> get_order ~dbh r#hash) l >>=? fun orders ->
    match orders with
    | [] -> Lwt.return_ok acc
    | _ ->
      let orders = List.filter_map (fun x -> x) orders in
      let orders = filter_orders ?origin orders in
      get_bid_orders_by_item_aux
        ~dbh ?origin ?continuation ?maker ~size contract token_id (acc @ orders)
  else
  if len = size then Lwt.return_ok acc
  else
    Lwt.return_ok @@
    List.filter_map (fun x -> x) @@
    List.mapi (fun i order -> if i < Int64.to_int size then Some order else None) acc

let get_bid_orders_by_item
    ?dbh ?origin ?continuation ?(size=50) ?maker ?currency contract token_id =
  Format.eprintf "get_bid_orders_by_item %s %s %d@."
    (match origin with None -> "None" | Some s -> s)
    (match continuation with
     | None -> "None"
     | Some (f, s) -> f ^ "_" ^ s)
    size ;
  let size = Int64.of_int size in
  let>? orders =
    get_bid_orders_by_item_aux
      ?dbh ?origin ?continuation ?maker ?currency ~size contract token_id [] in
  let len = Int64.of_int @@ List.length orders in
  let orders_pagination_contination =
    if len = 0L || len < size then None
    else Some
        (mk_order_continuation @@ List.hd @@ List.rev orders) in
  Lwt.return_ok
    { orders_pagination_orders = orders ; orders_pagination_contination }

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
  let>? make_class, make_contract, make_token_id, make_asset_value =
    db_from_asset order_elt.order_elt_make in
  let>? take_class, take_contract, take_token_id, take_asset_value =
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
      "insert into orders(maker, taker, \
       make_asset_type_class, make_asset_type_contract, make_asset_type_token_id, \
       make_asset_value, \
       take_asset_type_class, take_asset_type_contract, take_asset_type_token_id, \
       take_asset_value, \
       start_date, end_date, salt, signature, created_at, last_update_at, hash) \
       values($maker, $?taker, \
       $make_class, $?make_contract, $?make_token_id, $make_asset_value, \
       $take_class, $?take_contract, $?take_token_id, $take_asset_value, \
       $?start_date, $?end_date, $salt, $signature, $created_at, $last_update_at, $hash_key) \
       on conflict (hash) do update set (\
       make_asset_value, take_asset_value, last_update_at, signature) = \
       ($make_asset_value, $take_asset_value, $last_update_at, $signature)"] in
  insert_order_activity_new dbh created_at order >>=? fun () ->
  insert_price_history dbh last_update_at make_asset_value take_asset_value hash_key >>=? fun () ->
  begin
    if last_update_at = created_at then insert_origin_fees dbh origin_fees hash_key
    else Lwt.return_ok ()
  end >>=? fun () ->
  insert_payouts dbh payouts hash_key >>=? fun () ->
  produce_order_event_hash dbh order.order_elt.order_elt_hash

let mk_order_activity_continuation _obj =
  Printf.sprintf "TODO"
    (* (Int64.of_float @@ CalendarLib.Calendar.to_unixfloat obj#date)
     * obj#transaction *)

let get_order_activities_by_collection ?dbh ?continuation ?(size=50) filter =
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
  let>? l = [%pgsql.object dbh
      "select order_activity_type, \
       o.make_asset_type_class, o.make_asset_type_contract, \
       o.make_asset_type_token_id, o.make_asset_value, \
       o.take_asset_type_class, o.take_asset_type_contract, \
       o.take_asset_type_token_id, o.take_asset_value, \
       o.maker, o.hash as o_hash, \
       match_left, match_right, \
       transaction, block, level, date, \

       oleft.hash as oleft_hash, oleft.maker as oleft_maker, \
       oleft.taker as oleft_taker, \
       oleft.make_asset_type_class as oleft_make_asset_type_class, \
       oleft.make_asset_type_contract as oleft_make_asset_type_contract, \
       oleft.make_asset_type_token_id as oleft_make_asset_type_token_id, \
       oleft.make_asset_value as oleft_make_asset_value, \
       oleft.take_asset_type_class as oleft_take_asset_type_class, \
       oleft.take_asset_type_contract as oleft_take_asset_type_contract, \
       oleft.take_asset_type_token_id as oleft_take_asset_type_token_id, \
       oleft.take_asset_value as oleft_take_asset_value, \

       oright.hash as oright_hash, oright.maker as oright_maker, \
       oright.taker as oright_taker, \
       oright.make_asset_type_class as oright_make_asset_type_class, \
       oright.make_asset_type_contract as oright_make_asset_type_contract, \
       oright.make_asset_type_token_id as oright_make_asset_type_token_id, \
       oright.make_asset_value as oright_make_asset_value, \
       oright.take_asset_type_class as oright_take_asset_type_class, \
       oright.take_asset_type_contract as oright_take_asset_type_contract, \
       oright.take_asset_type_token_id as oright_take_asset_type_token_id, \
       oright.take_asset_value as oright_take_asset_value \

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
       (date = $ts and transaction > $h) or (date < $ts)) \
       order by date desc, transaction asc limit $size64"] in
  map_rp (fun r -> let|>? a = mk_order_activity r in a, r) l >>=? fun activities ->
  let len = List.length activities in
  let order_activities_continuation =
    if len <> size then None
    else Some
        (mk_order_activity_continuation @@ snd @@ List.hd (List.rev activities)) in
  Lwt.return_ok
    { order_activities_items = List.map fst activities ; order_activities_continuation }

let get_order_activities_by_item ?dbh ?continuation ?(size=50) filter =
  Format.eprintf "get_order_activities_by_item %s %s [%s] %s %d@."
    filter.order_activity_by_item_contract
    filter.order_activity_by_item_token_id
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
  let>? l = [%pgsql.object dbh
      "select order_activity_type, \
       o.make_asset_type_class, o.make_asset_type_contract, \
       o.make_asset_type_token_id, o.make_asset_value, \
       o.take_asset_type_class, o.take_asset_type_contract, \
       o.take_asset_type_token_id, o.take_asset_value, \
       o.maker, o.hash as o_hash, \
       match_left, match_right, \
       transaction, block, level, date, \

       oleft.hash as oleft_hash, oleft.maker as oleft_maker, \
       oleft.taker as oleft_taker, \
       oleft.make_asset_type_class as oleft_make_asset_type_class, \
       oleft.make_asset_type_contract as oleft_make_asset_type_contract, \
       oleft.make_asset_type_token_id as oleft_make_asset_type_token_id, \
       oleft.make_asset_value as oleft_make_asset_value, \
       oleft.take_asset_type_class as oleft_take_asset_type_class, \
       oleft.take_asset_type_contract as oleft_take_asset_type_contract, \
       oleft.take_asset_type_token_id as oleft_take_asset_type_token_id, \
       oleft.take_asset_value as oleft_take_asset_value, \

       oright.hash as oright_hash, oright.maker as oright_maker, \
       oright.taker as oright_taker, \
       oright.make_asset_type_class as oright_make_asset_type_class, \
       oright.make_asset_type_contract as oright_make_asset_type_contract, \
       oright.make_asset_type_token_id as oright_make_asset_type_token_id, \
       oright.make_asset_value as oright_make_asset_value, \
       oright.take_asset_type_class as oright_take_asset_type_class, \
       oright.take_asset_type_contract as oright_take_asset_type_contract, \
       oright.take_asset_type_token_id as oright_take_asset_type_token_id, \
       oright.take_asset_value as oright_take_asset_value \

       from order_activities as a \
       left join orders as o on o.hash = a.hash \
       left join orders as oleft on oleft.hash = a.match_left \
       left join orders as oright on oright.hash = a.match_right where \
       main and position(order_activity_type in $types) > 0 and \
       ((o.make_asset_type_contract = $contract and o.make_asset_type_token_id = $token_id) or \
        (o.take_asset_type_contract = $contract and o.take_asset_type_token_id = $token_id) or \
        (oleft.make_asset_type_contract = $contract and
         oleft.make_asset_type_token_id = $token_id) or \
        (oleft.take_asset_type_contract = $contract and
         oleft.take_asset_type_token_id = $token_id) or \
        (oright.make_asset_type_contract = $contract and
         oright.make_asset_type_token_id = $token_id) or \
        (oright.take_asset_type_contract = $contract and
         oright.take_asset_type_token_id = $token_id)) and \
       ($no_continuation or \
       (date = $ts and transaction > $h) or (date < $ts)) \
       order by date desc, transaction asc limit $size64"] in
  map_rp (fun r -> let|>? a = mk_order_activity r in a, r) l >>=? fun activities ->
  let len = List.length activities in
  let order_activities_continuation =
    if len <> size then None
    else Some
        (mk_order_activity_continuation @@ snd @@ List.hd (List.rev activities)) in
  Lwt.return_ok
    { order_activities_items = List.map fst activities ; order_activities_continuation }

let get_order_activities_all ?dbh ?continuation ?(size=50) types =
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
  let>? l = [%pgsql.object dbh
      "select order_activity_type, \
       o.make_asset_type_class, o.make_asset_type_contract, \
       o.make_asset_type_token_id, o.make_asset_value, \
       o.take_asset_type_class, o.take_asset_type_contract, \
       o.take_asset_type_token_id, o.take_asset_value, \
       o.maker, o.hash as o_hash, \
       match_left, match_right, \
       transaction, block, level, date, \

       oleft.hash as oleft_hash, oleft.maker as oleft_maker, \
       oleft.taker as oleft_taker, \
       oleft.make_asset_type_class as oleft_make_asset_type_class, \
       oleft.make_asset_type_contract as oleft_make_asset_type_contract, \
       oleft.make_asset_type_token_id as oleft_make_asset_type_token_id, \
       oleft.make_asset_value as oleft_make_asset_value, \
       oleft.take_asset_type_class as oleft_take_asset_type_class, \
       oleft.take_asset_type_contract as oleft_take_asset_type_contract, \
       oleft.take_asset_type_token_id as oleft_take_asset_type_token_id, \
       oleft.take_asset_value as oleft_take_asset_value, \

       oright.hash as oright_hash, oright.maker as oright_maker, \
       oright.taker as oright_taker, \
       oright.make_asset_type_class as oright_make_asset_type_class, \
       oright.make_asset_type_contract as oright_make_asset_type_contract, \
       oright.make_asset_type_token_id as oright_make_asset_type_token_id, \
       oright.make_asset_value as oright_make_asset_value, \
       oright.take_asset_type_class as oright_take_asset_type_class, \
       oright.take_asset_type_contract as oright_take_asset_type_contract, \
       oright.take_asset_type_token_id as oright_take_asset_type_token_id, \
       oright.take_asset_value as oright_take_asset_value \

       from order_activities as a \
       left join orders as o on o.hash = a.hash \
       left join orders as oleft on oleft.hash = a.match_left \
       left join orders as oright on oright.hash = a.match_right where \
       main and position(order_activity_type in $types) > 0 and \
       ($no_continuation or \
       (date = $ts and transaction > $h) or (date < $ts)) \
       order by date desc, transaction asc limit $size64"] in
  map_rp (fun r -> let|>? a = mk_order_activity r in a, r) l >>=? fun activities ->
  let len = List.length activities in
  let order_activities_continuation =
    if len <> size then None
    else Some
        (mk_order_activity_continuation @@ snd @@ List.hd (List.rev activities)) in
  Lwt.return_ok
    { order_activities_items = List.map fst activities ; order_activities_continuation }

let get_order_activities_by_user ?dbh ?continuation ?(size=50) filter =
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
  let>? l = [%pgsql.object dbh
      "select order_activity_type, \
       o.make_asset_type_class, o.make_asset_type_contract, \
       o.make_asset_type_token_id, o.make_asset_value, \
       o.take_asset_type_class, o.take_asset_type_contract, \
       o.take_asset_type_token_id, o.take_asset_value, \
       o.maker, o.hash as o_hash, \
       match_left, match_right, \
       transaction, block, level, date, \

       oleft.hash as oleft_hash, oleft.maker as oleft_maker, \
       oleft.taker as oleft_taker, \
       oleft.make_asset_type_class as oleft_make_asset_type_class, \
       oleft.make_asset_type_contract as oleft_make_asset_type_contract, \
       oleft.make_asset_type_token_id as oleft_make_asset_type_token_id, \
       oleft.make_asset_value as oleft_make_asset_value, \
       oleft.take_asset_type_class as oleft_take_asset_type_class, \
       oleft.take_asset_type_contract as oleft_take_asset_type_contract, \
       oleft.take_asset_type_token_id as oleft_take_asset_type_token_id, \
       oleft.take_asset_value as oleft_take_asset_value, \

       oright.hash as oright_hash, oright.maker as oright_maker, \
       oright.taker as oright_taker, \
       oright.make_asset_type_class as oright_make_asset_type_class, \
       oright.make_asset_type_contract as oright_make_asset_type_contract, \
       oright.make_asset_type_token_id as oright_make_asset_type_token_id, \
       oright.make_asset_value as oright_make_asset_value, \
       oright.take_asset_type_class as oright_take_asset_type_class, \
       oright.take_asset_type_contract as oright_take_asset_type_contract, \
       oright.take_asset_type_token_id as oright_take_asset_type_token_id, \
       oright.take_asset_value as oright_take_asset_value \

       from order_activities as a \
       left join orders as o on o.hash = a.hash \
       left join orders as oleft on oleft.hash = a.match_left \
       left join orders as oright on oright.hash = a.match_right where \
       main and position(order_activity_type in $types) > 0 and \
       ((position(o.maker in $users) > 0 or position(o.taker in $users) > 0) or \
        (position(oleft.maker in $users) > 0 or position(oleft.taker in $users) > 0) or \
        (position(oright.maker in $users) > 0 or position(oright.taker in $users) > 0)) and \
       ($no_continuation or \
       (date = $ts and transaction > $h) or (date < $ts)) \
       order by date desc, transaction asc limit $size64"] in
  map_rp (fun r -> let|>? a = mk_order_activity r in a, r) l >>=? fun activities ->
  let len = List.length activities in
  let order_activities_continuation =
    if len <> size then None
    else Some
        (mk_order_activity_continuation @@ snd @@ List.hd (List.rev activities)) in
  Lwt.return_ok
    { order_activities_items = List.map fst activities ; order_activities_continuation }

let get_order_activities ?dbh ?continuation ?size = function
  | OrderActivityFilterByCollection filter ->
    get_order_activities_by_collection ?dbh ?continuation ?size filter
  | OrderActivityFilterByItem filter ->
    get_order_activities_by_item ?dbh ?continuation ?size filter
  | OrderActivityFilterByUser filter ->
    get_order_activities_by_user ?dbh ?continuation ?size filter
  | OrderActivityFilterAll types ->
    get_order_activities_all ?dbh ?continuation ?size types

  (* ORDER UPDATE field = fill, make_stock, cancelled, last_update, make_balance, make_price_usd, take_price_usd, assets values ?? *)
