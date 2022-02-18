open Proto
open Rtypes
open Let

let decimal_balance ?(decimals=0l) z =
  let factor = Z.(pow (of_int 10) (Int32.to_int decimals)) in
  let dec = Z.rem z factor in
  let dec_str =
    if dec = Z.zero then ""
    else
      let s = Z.to_string dec in
      Format.sprintf ".%s%s" (String.make ((Int32.to_int decimals) - (String.length s)) '0') s in
  let num = Z.(to_string @@ div z factor) in
  Format.sprintf "%s%s" num dec_str

let absolute_balance ?(decimals=0l) s =
  let factor = Z.(pow (of_int 10) (Int32.to_int decimals)) in
  let {Q.num; den} = Q.of_string s in
  Z.(mul (div factor den) num)

let unexpected_michelson = Error `unexpected_michelson_value

let prim ?(args=[]) ?(annots=[]) prim = Mprim {prim; args; annots}
let pair ?annots args = prim ?annots ~args `pair
let list ?annots arg = prim ?annots ~args:[arg] `list

let rec michelson_type_eq m1 m2 = match m1, m2 with
  | Mprim {prim=p1; args = args1; _}, Mprim {prim=p2; args = args2; _} ->
    if p1 <> p2 then false
    else if List.length args1 <> List.length args2 then false
    else List.for_all (fun x -> x) @@ List.map2 michelson_type_eq args1 args2
  | _ -> false

let string_of_asset_type = function
  | ATXTZ -> "XTZ"
  | ATFT _ -> "FT"
  | ATNFT _ -> "NFT"
  | ATMT _ -> "MT"

let asset_class_mich = function
  | ATXTZ -> prim `Left ~args:[prim `Unit]
  | ATFT {token_id=None; _} -> prim `Right ~args:[prim `Left ~args:[ prim `Unit ]]
  | ATFT _ -> prim `Right ~args:[prim `Right ~args:[ prim `Left ~args:[ Mint Z.zero ] ]]
  | ATNFT _ | ATMT _ ->
    prim `Right ~args:[prim `Right ~args:[ prim `Left ~args:[ Mint Z.one ] ]]

let asset_class_type =
  (prim `or_ ~args:[prim `unit; prim `or_ ~args:[prim `unit; prim `or_ ~args:[
       prim `nat; prim `or_ ~args:[prim `unit; prim `bytes ]]]])

let asset_data = function
  | ATXTZ -> Ok (Tzfunc.Raw.mk "\000")
  | ATFT {token_id=None; contract} -> Tzfunc.Forge.pack (prim `address) (Mstring contract)
  | ATFT {token_id=Some asset_token_id; contract=asset_contract}
  | ATNFT { asset_contract; asset_token_id }
  | ATMT { asset_contract; asset_token_id } ->
    Tzfunc.Forge.pack (prim `pair ~args:[ prim `address; prim `nat ])
      (prim `Pair ~args:[ Mstring asset_contract; Mint asset_token_id ])

let asset_type_mich a =
  let$ data = asset_data a in
  Result.ok @@ prim `Pair ~args:[
    asset_class_mich a;
    Mbytes (Tzfunc.Crypto.hex_of_raw data)
  ]

let asset_mich a =
  let$ asset_type = asset_type_mich a.asset_type in
  Ok (prim `Pair ~args:[
      asset_type;
      Mint a.asset_value
    ])

let asset_type_type = prim `pair ~args:[ asset_class_type; prim `bytes]
let asset_type = prim `pair ~args:[asset_type_type; prim `nat]

let option_mich f = function
  | None -> prim `None
  | Some x -> prim `Some ~args:[ f x ]

let keccak (s : Tzfunc.Raw.t) =
  Tzfunc.Raw.mk @@ Digestif.KECCAK_256.(to_raw_string @@ digest_string (s :> string))

let hash_key maker_edpk make_asset_type take_asset_type salt =
  let maker = Tzfunc.Forge.pack (prim `option ~args:[prim `key])
      (option_mich (fun s -> Mstring s) maker_edpk) in
  let$ make_asset_type_mich = asset_type_mich make_asset_type in
  let$ make_asset_type =
    Tzfunc.Forge.pack asset_type_type make_asset_type_mich in
  let$ take_asset_type_mich = asset_type_mich take_asset_type in
  let$ take_asset_type =
    Tzfunc.Forge.pack asset_type_type take_asset_type_mich in
  let salt = Tzfunc.Forge.pack (prim `nat) @@ Mint salt in
  let$ b = Tzfunc.Binary.Writer.concat [
      maker;
      Ok (keccak make_asset_type);
      Ok (keccak take_asset_type);
      salt
    ] in
  Result.ok @@ Tzfunc.Crypto.hex_of_raw @@ keccak b

let part_type = prim `pair ~args:[ prim `address; prim `nat ]
let order_data_type =
  prim `pair ~args:[prim `list ~args:[ part_type ]; prim `list ~args:[ part_type ]]

let order_type =
  prim `pair ~args:[
    prim `option ~args:[ prim `key ];
    prim `pair ~args:[
      asset_type;
      prim `pair ~args:[
        prim `option ~args:[ prim `key ];
        prim `pair ~args:[
          asset_type;
          prim `pair ~args:[
            prim `nat;
            prim `pair ~args:[
              prim `option ~args:[ prim `timestamp ];
              prim `pair ~args:[
                prim `option ~args:[ prim `timestamp ];
                prim `pair ~args:[
                  prim `bytes;
                  prim `bytes
                ]
              ]
            ]
          ]
        ]
      ]
    ]
  ]

let flat_order_type
    ~maker ~make ~taker ~take ~salt
    ~start_date ~end_date ~data_type ~payouts ~origin_fees =
  let open Tzfunc.Forge in
  let maker = option_mich (fun s -> Mstring s) (Some maker) in
  let$ make = asset_mich make in
  let taker = option_mich (fun s -> Mstring s) taker in
  let$ take = asset_mich take in
  let sdate = option_mich (fun c -> Mstring (Proto.A.cal_to_str c)) start_date in
  let edate = option_mich (fun c -> Mstring (Proto.A.cal_to_str c)) end_date in
  let$ data_type = pack (prim `string) (Mstring data_type) in
  let$ data = pack order_data_type
      (prim `Pair ~args:[
          Mseq (List.map (fun p -> prim `Pair ~args:[
              Mstring p.part_account;
              Mint (Z.of_int32 p.part_value) ]) payouts);
          Mseq (List.map (fun p -> prim `Pair ~args:[
              Mstring p.part_account;
              Mint (Z.of_int32 p.part_value) ]) origin_fees);
        ]) in
  Ok
    (prim `Pair ~args:[
        maker;
        make;
        taker;
        take;
        Mint salt;
        sdate;
        edate;
        Mbytes (Tzfunc.Crypto.hex_of_raw @@ keccak data_type);
        Mbytes (Tzfunc.Crypto.hex_of_raw data);
      ])

let flat_order order =
  let maker = order.order_elt.order_elt_maker_edpk in
  let make = order.order_elt.order_elt_make in
  let taker = order.order_elt.order_elt_taker_edpk in
  let take = order.order_elt.order_elt_take in
  let salt = order.order_elt.order_elt_salt in
  let start_date = order.order_elt.order_elt_start in
  let end_date = order.order_elt.order_elt_end in
  flat_order_type
    ~maker ~make ~taker ~take ~salt ~start_date ~end_date
    ~data_type:"V1"
    ~payouts:order.order_data.order_rarible_v2_data_v1_payouts
    ~origin_fees:order.order_data.order_rarible_v2_data_v1_origin_fees

let mich_order_form
    ~maker ~make ~taker ~take ~salt ~start_date ~end_date ~data_type ~payouts ~origin_fees =
  let open Tzfunc.Forge in
  let$ data_type = pack (prim `string) (Mstring data_type) in
  let$ data = pack order_data_type
      (prim `Pair ~args:[
          Mseq (List.map (fun p -> prim `Pair ~args:[
              Mstring p.part_account;
              Mint (Z.of_int32 p.part_value) ]) payouts);
          Mseq (List.map (fun p -> prim `Pair ~args:[
              Mstring p.part_account;
              Mint (Z.of_int32 p.part_value) ]) origin_fees);
        ]) in
  let$ asset_make = asset_mich make in
  let$ asset_take = asset_mich take in
  Ok (prim `Pair ~args:[
      option_mich (fun s -> Mstring s) (Some maker);
      prim `Pair ~args:[
        asset_make;
        prim `Pair ~args:[
          option_mich (fun s -> Mstring s) taker;
          prim `Pair ~args:[
            asset_take;
            prim `Pair ~args:[
              Mint salt;
              prim `Pair ~args:[
                option_mich (fun c -> Mstring (Proto.A.cal_to_str c)) start_date;
                prim `Pair ~args:[
                  option_mich (fun c -> Mstring (Proto.A.cal_to_str c)) end_date;
                  prim `Pair ~args:[
                    Mbytes (Tzfunc.Crypto.hex_of_raw @@ keccak data_type);
                    Mbytes (Tzfunc.Crypto.hex_of_raw data);
                  ]
                ]
              ]
            ]
          ]
        ]
      ]
    ])

let hash_order_form maker make taker take salt start_date end_date data_type payouts origin_fees =
  let open Tzfunc.Forge in
  let$ x =
    mich_order_form
      ~maker ~make ~taker ~take ~salt ~start_date ~end_date ~data_type ~payouts ~origin_fees in
  let$ res = pack order_type x in
  Ok res

(* // who fills asset collection `fill` ?
 * function hashKeyOrder(iorder : order) : bytes {
 *   return keccak(concat([
 *     pack(iorder.maker);
 *     keccak(pack(iorder.makeAsset.assetType));
 *     keccak(pack(iorder.takeAsset.assetType));
 *     pack(iorder.salt)]))
 * } *)

let calculate_remaining make_value take_value fill cancelled =
  if cancelled then Z.zero, Z.zero
  else
    let take = Z.sub take_value fill in
    let make = Z.(div (mul take make_value) take_value) in
    make, take

let calculate_fee data protocol_commission =
  List.fold_left (fun acc p -> Z.(add acc (of_int32 p.part_value)))
    protocol_commission
    data.order_rarible_v2_data_v1_origin_fees

let calculate_rounded_make_balance make_value take_value make_balance =
  let max_take = Z.(div (mul make_balance take_value) make_value) in
  Z.(div (mul make_value max_take) take_value)

let calculate_make_stock
    make_value take_value fill data make_balance protocol_commission fee_side cancelled =
  let factor = Z.of_int 10000 in
  let make, _take = calculate_remaining make_value take_value fill cancelled in
  let fee = match fee_side with
    | None | Some FeeSideTake -> Z.zero
    | Some FeeSideMake -> calculate_fee data protocol_commission in
  let make_balance = Z.(div (mul make_balance factor) (add fee factor)) in
  let rounded_make_balance = calculate_rounded_make_balance make_value take_value make_balance in
  min make rounded_make_balance

let get_fee_side make_asset take_asset =
  match make_asset.asset_type, take_asset.asset_type with
  | ATXTZ, _ -> Some FeeSideMake
  | _, ATXTZ -> Some FeeSideTake
  (* | ATERC20 _, _ -> Some FeeSideMake
   * | _, ATERC20 _ -> Some FeeSideTake
   * | ATERC1155 _, _ -> Some FeeSideMake
   * | _, ATERC1155 _ -> Some FeeSideTake *)
  | _, _ -> None

let order_elt_from_order_form_elt elt =
  let make_asset = elt.order_form_elt_make in
  let take_asset = elt.order_form_elt_take in
  (* TODO *)
  let$ hash =
    hash_key
      (Some elt.order_form_elt_maker_edpk)
      make_asset.asset_type
      take_asset.asset_type
      elt.order_form_elt_salt in
  let now = CalendarLib.Calendar.now () in
  Ok {
    order_elt_maker = elt.order_form_elt_maker ;
    order_elt_maker_edpk = elt.order_form_elt_maker_edpk ;
    order_elt_taker = elt.order_form_elt_taker;
    order_elt_taker_edpk = elt.order_form_elt_taker_edpk;
    order_elt_make = make_asset;
    order_elt_take = take_asset;
    order_elt_fill = Z.zero;
    order_elt_start = elt.order_form_elt_start;
    order_elt_end = elt.order_form_elt_end;
    order_elt_make_stock = Z.zero;
    order_elt_cancelled = false;
    order_elt_salt = elt.order_form_elt_salt;
    order_elt_signature = elt.order_form_elt_signature;
    order_elt_created_at = now;
    order_elt_last_update_at = now;
    order_elt_hash = (hash :> string);
    order_elt_make_balance = None;
    order_elt_price_history = [];
    order_elt_status = OACTIVE ;
  }

let order_from_order_form form =
  let$ order_elt = order_elt_from_order_form_elt form.order_form_elt in
  Ok { order_elt; order_data = form.order_form_data; order_type = () }

let order_form_elt_from_order_elt order_elt = {
  order_form_elt_maker = order_elt.order_elt_maker ;
  order_form_elt_maker_edpk = order_elt.order_elt_maker_edpk ;
  order_form_elt_taker = order_elt.order_elt_taker ;
  order_form_elt_taker_edpk = order_elt.order_elt_taker_edpk ;
  order_form_elt_make = order_elt.order_elt_make ;
  order_form_elt_take = order_elt.order_elt_take ;
  order_form_elt_salt = order_elt.order_elt_salt ;
  order_form_elt_start = order_elt.order_elt_start ;
  order_form_elt_end = order_elt.order_elt_end ;
  order_form_elt_signature = order_elt.order_elt_signature ;
}

let order_form_from_order order = {
  order_form_elt =  order_form_elt_from_order_elt order.order_elt ;
  order_form_data = order.order_data; order_form_type = ()
}

let string_opt_of_float_opt = function
  | None -> None
  | Some f -> Some (string_of_float f)

let string_of_float_opt = function
  | None -> "0"
  | Some f -> string_of_float f

let float_opt_of_string_opt = function
  | None -> None
  | Some f -> Some (float_of_string f)

let order_side_opt_of_string_opt = function
  | None -> None
  | Some "LEFT" -> Some OSLEFT
  | Some "RIGHT" -> Some OSRIGHT
  | _ -> assert false

let string_opt_of_order_side_opt = function
  | None -> None
  | Some OSLEFT -> Some "LEFT"
  | Some OSRIGHT -> Some "RIGHT"

let int64_opt_of_timestamp_opt = function
  | None -> None
  | Some t -> Some (Int64.of_float @@ CalendarLib.Calendar.to_unixfloat t)

let timestamp_opt_of_int64_opt = function
  | None -> None
  | Some f -> Some (CalendarLib.Calendar.from_unixfloat @@ Int64.to_float f)

let string_opt_of_int64_opt = function
  | None -> None
  | Some i -> Some (Int64.to_string i)

let int64_opt_of_string_opt = function
  | None -> None
  | Some i -> Some (Int64.of_string i)


let filter_all_type_to_pgarray = List.map (fun t ->
    Option.some @@
    String.lowercase_ascii @@
    EzEncoding.construct nft_activity_filter_all_type_enc t)

let filter_all_type_to_string l =
  String.concat ";" @@
  List.map (fun t ->
      String.lowercase_ascii @@
      EzEncoding.construct nft_activity_filter_all_type_enc t) l

let filter_order_all_type_to_string l =
  String.concat ";" @@
  List.map (fun t -> match t with
      | OALLCANCEL_LIST -> "cancel_l"
      | OALLCANCEL_BID ->  "cancel_b"
      | _ ->
        String.lowercase_ascii @@
        EzEncoding.construct order_activity_filter_all_type_enc t) l

let filter_user_type_to_pgarray = List.map (fun t ->
    Option.some @@
    String.lowercase_ascii @@
    EzEncoding.construct nft_activity_filter_user_type_enc t)

let filter_user_type_to_string l =
  String.concat ";" @@
  List.map (fun t ->
      String.lowercase_ascii @@
      EzEncoding.construct nft_activity_filter_user_type_enc t) l

let filter_order_user_type_to_string l =
  String.concat ";" @@
  List.map (fun t -> match t with
      | `CANCEL_LIST -> "cancel_l"
      | `CANCEL_BID ->  "cancel_b"
      | _ ->
        String.lowercase_ascii @@
        EzEncoding.construct order_activity_filter_user_type_enc t) l

let order_bid_status_to_string l =
  String.concat ";" @@
  List.map (fun t ->
      EzEncoding.construct order_bid_status_enc t) l

let order_status_to_string l =
  String.concat ";" @@
  List.map (fun t ->
      EzEncoding.construct order_status_enc t) l

let short ?(len=8) h =
  if String.length h > len then String.sub h 0 len else h

let to_parts l =
  List.map (fun (part_account, part_value) -> { part_account; part_value }) l

let mk_order_event order = {
  order_event_event_id = Hex.show @@ Hex.of_bigstring @@ Hacl.Rand.gen 128 ;
  order_event_order_id = order.order_elt.order_elt_hash ;
  order_event_order = order ;
  order_event_type = () ;
}

let mk_update_item_event item = {
  nft_item_event_event_id = Hex.show @@ Hex.of_bigstring @@ Hacl.Rand.gen 128 ;
  nft_item_event_item_id = item.nft_item_id ;
  nft_item_event_type = `UPDATE ;
  nft_item_event_item = item ;
}

let mk_delete_item_event item = {
  nft_item_event_event_id = Hex.show @@ Hex.of_bigstring @@ Hacl.Rand.gen 128 ;
  nft_item_event_item_id = item.nft_item_id ;
  nft_item_event_type = `DELETE ;
  nft_item_event_item = item ;
}

let mk_update_ownership_event os = {
  nft_ownership_event_event_id = Hex.show @@ Hex.of_bigstring @@ Hacl.Rand.gen 128 ;
  nft_ownership_event_ownership_id = os.nft_ownership_id ;
  nft_ownership_event_type = `UPDATE ;
  nft_ownership_event_ownership = os ;
}

let mk_delete_ownership_event os = {
  nft_ownership_event_event_id = Hex.show @@ Hex.of_bigstring @@ Hacl.Rand.gen 128 ;
  nft_ownership_event_ownership_id = os.nft_ownership_id ;
  nft_ownership_event_type = `DELETE ;
  nft_ownership_event_ownership = os ;
}

let mk_nft_collection_event collection = {
  nft_collection_event_event_id = Hex.show @@ Hex.of_bigstring @@ Hacl.Rand.gen 128 ;
  nft_collection_event_collection_id = collection.nft_collection_id ;
  nft_collection_event_collection = collection ;
  nft_collection_event_type = () ;
}


let pk_to_pkh_exn pk = match Tzfunc.Crypto.pk_to_pkh pk with
  | Error _ -> failwith ("cannot hash edpk " ^ pk)
  | Ok pkh -> pkh

let tzip21_attribute_to_rarible_attribute a =
  let v = match a.attribute_value with
    | `String s -> Some s
    | `Float f ->
      begin
        try Some (string_of_int @@ int_of_float f)
        with _ -> Some (string_of_float f)
      end
    | _ -> None in
  match v with
  | Some v ->
    Some {
      nft_item_attribute_key = a.attribute_name ;
      nft_item_attribute_value = v ;
      nft_item_attribute_type = a.attribute_type ;
      nft_item_attribute_format = None ;
    }
  | None -> None

let tzip21_attributes_to_rarible_attributes l =
  List.map tzip21_attribute_to_rarible_attribute l

let replace_token_id ~pattern token_id =
  let regexp = Str.regexp "{tokenId}" in
  Str.global_replace regexp token_id pattern

let is_animation_format mime_type =
  match String.split_on_char '/' mime_type with
  | "video" :: _ | "audio" :: _ | "model" :: _ -> true
  | _ -> false

let rarible_attributes_of_tzip21_attributes = function
  | None -> None
  | Some attr ->
    Option.some @@
    List.filter_map tzip21_attribute_to_rarible_attribute attr

let find_animation_asset m =
  begin
    match Filename.extension @@
      Option.value ~default:"" m.tzip21_tm_artifact_uri with
    | ".mp4" | ".mp3" -> m.tzip21_tm_artifact_uri
    | _ ->
      begin
        match
          Filename.extension @@
          Option.value ~default:"" m.tzip21_tm_display_uri with
        | ".mp4" | ".mp3" -> m.tzip21_tm_display_uri
        | _ ->
          begin
            match
              Filename.extension @@
              Option.value ~default:"" m.tzip21_tm_thumbnail_uri with
            | ".mp4" | ".mp3" -> m.tzip21_tm_thumbnail_uri
            | _ -> None
          end
      end
  end

let add_glb_extension uri =
  if String.contains uri '?' then Printf.sprintf "%s&extension=.glb" uri
  else Printf.sprintf "%s?extension=.glb" uri

let might_add_glb_extension uri formats =
  match List.find_opt (fun f -> f.format_uri = uri) formats with
  | None -> uri
  | Some f ->
    match f.format_mime_type with
    | None -> uri
    | Some mt ->
      if mt = "model/gltf-binary" || mt = "model/gltf+json" then
        add_glb_extension uri
      else uri

let rarible_meta_of_tzip21_meta meta =
  match meta with
  | None -> None
  | Some m ->
    let nft_item_meta_animation =
      match m.tzip21_tm_artifact_uri, m.tzip21_tm_formats with
      | None, _ -> None
      | Some _, None -> find_animation_asset m
      | Some uri, Some formats ->
        if List.exists (fun f -> match f.format_mime_type with
            | None -> false
            | Some mt -> f.format_uri = uri && is_animation_format mt)
            formats then Some (might_add_glb_extension uri formats)
        else find_animation_asset m in
    Some {
      nft_item_meta_name = Option.value ~default:"Unnamed item" m.tzip21_tm_name ;
      nft_item_meta_description = m.tzip21_tm_description ;
      nft_item_meta_attributes =
        rarible_attributes_of_tzip21_attributes m.tzip21_tm_attributes ;
      nft_item_meta_animation ;
      nft_item_meta_image =
        begin match m.tzip21_tm_artifact_uri with
          | Some _ as uri when uri <> nft_item_meta_animation -> uri
          | _ ->
            begin match m.tzip21_tm_display_uri with
              | Some _ as uri -> uri
              | None ->
                begin match m.tzip21_tm_thumbnail_uri with
                  | Some _ as uri -> uri
                  | None -> m.tzip21_tm_artifact_uri
                end
            end
        end ;
    }

let check_address a =
  match Tzfunc.Crypto.Pkh.b58dec a with
  | Ok _ -> true
  | Error _ ->
    try
      let _ = Tzfunc.Crypto.(Base58.decode ~prefix:Prefix.contract_public_key_hash a) in
      true
    with _ -> false

let tid ~contract ~token_id =
  Format.sprintf "%s:%s" contract (Z.to_string token_id)

let oid ~contract ~token_id ~owner =
  Format.sprintf "%s:%s" (tid ~contract ~token_id) owner

let nft_kind_to_string = function
  | `rarible -> "rarible"
  | `ubi -> "ubi"
  | `fa2 -> "fa2"

let nft_kind_of_string = function
  | "rarible" -> `rarible
  | "ubi" -> `ubi
  | "fa2" -> `fa2
  | s -> failwith ("unknown nft kind " ^ s)
