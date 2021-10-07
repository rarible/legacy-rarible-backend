open Proto
open Rtypes

let (let$) = Result.bind

let rec flatten = function
  | Mprim { prim = `Pair; args; annots } ->
    let args = List.fold_left (fun acc x -> match flatten x with
        | Mprim { prim = `Pair; args; _ } -> acc @ args
        | _ -> acc @ [ x ]) [] args in
    let args = List.map flatten args in
    Mprim { prim = `Pair; args; annots }
  | Mprim { prim = `pair; args; annots } ->
    let args = List.fold_left (fun acc x -> match flatten x with
        | Mprim { prim = `pair; args; _ } -> acc @ args
        | _ -> acc @ [ x ]) [] args in
    let args = List.map flatten args in
    Mprim { prim = `pair; args; annots }
  | Mprim {prim; args; annots} ->
    Mprim {prim; args = List.map flatten args; annots}
  | Mseq l -> Mseq (List.map flatten l)
  | m -> m

let rec list_entrypoints acc = function
  | Mprim { prim = `or_; args = l ; _ } ->
    let arg1 = List.nth l 0 in
    let arg2 = List.nth l 1 in
    begin match list_entrypoints acc arg1 with
      | Error e -> Error e
      | Ok acc -> list_entrypoints acc arg2
    end
  | Mprim { annots = [ s ]; _ } as m when String.get s 0 = '%' ->
    Ok (m :: acc)
  | _ ->
    Error `unexpected_michelson_value

let entrypoints m = match flatten m with
  | Mseq l ->
    begin match
        List.find_map
          (function
            | Mprim { prim = `parameter; args = [ arg ]; _} -> Some arg
            | _ -> None) l with
    | Some arg ->
      list_entrypoints [] arg
    | None -> Error `unexpected_michelson_value
    end
  | _ -> Error `unexpected_michelson_value

let rec michelson_type_eq m1 m2 = match m1, m2 with
  | Mprim {prim=p1; args = args1; _}, Mprim {prim=p2; args = args2; _} ->
    if p1 <> p2 then false
    else if List.length args1 <> List.length args2 then false
    else List.for_all (fun x -> x) @@ List.map2 michelson_type_eq args1 args2
  | _ -> false

let match_entrypoints l = function
  | None | Some (Other _) | Some (Bytes _) -> false
  | Some (Micheline code) ->
    match entrypoints code with
    | Error _ -> false
    | Ok entrypoints ->
      let rec aux = function
        | [] -> true
        | m1 :: q -> match List.find_opt (fun m2 -> michelson_type_eq m1 m2) entrypoints with
          | None -> false
          | Some _ -> aux q in
      aux l

let prim ?(args=[]) ?(annots=[]) prim = Mprim {prim; args; annots}
let pair ?annots args = prim ?annots ~args `pair
let list ?annots arg = prim ?annots ~args:[arg] `list

let fa2_entrypoints = [
  pair ~annots:["%balance_of"] [
    list (pair [ prim `address; prim `nat ]);
    prim `contract ~args:[ list @@ pair [ prim `address; prim `nat;  prim `nat ] ]
  ];

  list ~annots:["%update_operators"] @@
  prim `or_ ~args:[
    pair [ prim `address; prim `address; prim `nat ];
    pair [ prim `address; prim `address; prim `nat ]
  ];

  list ~annots:["%transfer"] @@
  pair [ prim `address; list @@ pair [ prim `address; prim `nat; prim `nat ] ];
]

let fa2_ext_entrypoints = [
  list ~annots:["%update_operators_for_all"] @@
  prim `or_ ~args:[ prim `address; prim `address ];

  pair ~annots:["%mint"] [
    prim `nat; prim `address; prim `nat; list @@ pair [ prim `address; prim `nat ]
  ];

  pair ~annots:["%burn"] [ prim `nat; prim `address; prim `nat ];

  pair ~annots:["%setMetadataToken"] [
    prim `nat;
    prim `map ~args:[ prim `string; prim `string ] ]
]

let storage_fields = function
  | None | Some (Other _) | Some (Bytes _) -> Error `not_michelson
  | Some (Micheline m) -> match flatten m with
    | Mseq l ->
      begin match
          List.find_map
            (function
              | Mprim { prim = `storage; args = [ arg ]; _} -> Some arg
              | _ -> None) l with
      | Some arg ->
        begin match arg with
          | Mprim { prim = `pair; args ; _ } ->
            Result.ok @@
            snd @@ List.fold_left (fun (i, acc) m ->
                match m with
                | Mprim { annots = [ name ]; _ } -> i+1, ((name, i) :: acc)
                | _ -> i, acc) (0, []) args
          | _ -> Error `unexpected_michelson_value
        end
      | None -> Error `unexpected_michelson_value
      end
    | _ -> Error `unexpected_michelson_value

let match_fields l script =
  match storage_fields script.code with
  | Error e -> Error e
  | Ok fields ->
    match script.storage with
    | Bytes _ | Other _ -> Error `not_michelson
    | Micheline m -> match flatten m with
      | Mprim { prim = `Pair; args; _ } ->
        Ok (List.map (fun n ->
            match List.assoc_opt ("%" ^ n) fields with
            | None -> None
            | Some i -> List.nth_opt args i) l)
      | _ -> Error `unexpected_michelson_value

let string_of_asset_type = function
  | ATXTZ -> "XTZ"
  | ATFA_1_2 _ -> "FA_1_2"
  | ATFA_2 _ -> "FA_2"
  | ATETH -> "ETH"
  | ATERC721 _ -> "ERC721"

(* fun AssetType.hash(type: AssetType): Word = keccak256(Tuples.assetTypeHashType().encode(Tuple3.apply(
 *     TYPE_HASH.bytes(),
 *     type.type.bytes(),
 *     keccak256(type.data).bytes()
 * ))) *)

(* fun hashKey(maker: Address, makeAssetType: AssetType, takeAssetType: AssetType, salt: BigInteger): Word =
 *     keccak256(
 *         Tuples.orderKeyHashType().encode(
 *             Tuple4(
 *                 maker,
 *                 AssetType.hash(makeAssetType).bytes(),
 *                 AssetType.hash(takeAssetType).bytes(),
 *                 salt
 *             )
 *         )
 *     ) *)

let asset_class_mich = function
  | ATXTZ -> prim `Left ~args:[prim `Unit]
  | ATFA_1_2 _ -> prim `Right ~args:[prim `Left ~args:[ prim `Unit ]]
  | ATFA_2 _ -> prim `Right ~args:[prim `Right ~args:[ prim `Left ~args:[ prim `Unit ] ]]
  | ATETH -> assert false
  | ATERC721 _ -> assert false

let asset_class_type =
  (prim `or_ ~args:[prim `unit; prim `or_ ~args:[prim `unit; prim `or_ ~args:[
       prim `unit; prim `or_ ~args:[prim `unit; prim `bytes ]]]])

let asset_data = function
  | ATXTZ -> Ok "\000"
  | ATFA_1_2 a -> Tzfunc.Forge.pack (prim `address) (Mstring a)
  | ATFA_2 { asset_fa2_contract; asset_fa2_token_id } ->
    Tzfunc.Forge.pack (prim `pair ~args:[ prim `address; prim `nat ])
      (prim `Pair ~args:[ Mstring asset_fa2_contract; Mint (Z.of_string asset_fa2_token_id) ])
  | ATETH -> assert false
  | ATERC721 _ -> assert false


let asset_type_mich a =
  let$ data = asset_data a in
  Result.ok @@ prim `Pair ~args:[
    asset_class_mich a;
    Mbytes (Hex.of_string data)
  ]

let asset_mich a =
  let$ asset_type = asset_type_mich a.asset_type in
  Ok (prim `Pair ~args:[
      asset_type;
      Mint (Z.of_string a.asset_value)
    ])

let asset_type_type = prim `pair ~args:[ asset_class_type; prim `bytes]
let asset_type = prim `pair ~args:[asset_type_type; prim `nat]

let option_mich f = function
  | None -> prim `None
  | Some x -> prim `Some ~args:[ f x ]

let keccak s =
  Digestif.KECCAK_256.(to_raw_string @@ digest_string s)

let hash_key maker make_asset_type take_asset_type salt =
  let$ maker = Tzfunc.Forge.pack (prim `option ~args:[prim `key])
      (option_mich (fun s -> Mstring s) maker) in
  let$ make_asset_type_mich = asset_type_mich make_asset_type in
  let$ make_asset_type =
    Tzfunc.Forge.pack asset_type_type make_asset_type_mich in
  let$ take_asset_type_mich = asset_type_mich take_asset_type in
  let$ take_asset_type =
    Tzfunc.Forge.pack asset_type_type take_asset_type_mich in
  let$ salt = Tzfunc.Forge.pack (prim `nat) @@ Mint (Z.of_string salt) in
  Result.ok @@ Hex.show @@ Hex.of_string @@ keccak @@ String.concat "" [
    maker;
    keccak make_asset_type;
    keccak take_asset_type;
    salt
  ]

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

let mich_order_form
    ~maker ~make ~taker ~take ~salt ~start_date ~end_date ~data_type ~payouts ~origin_fees =
  let open Tzfunc.Forge in
  let$ data_type = pack (prim `string) (Mstring data_type) in
  let$ data = pack order_data_type
      (prim `Pair ~args:[
          Mseq (List.map (fun p -> prim `Pair ~args:[
              Mstring p.part_account;
              Mint (Z.of_int p.part_value) ]) payouts);
          Mseq (List.map (fun p -> prim `Pair ~args:[
              Mstring p.part_account;
              Mint (Z.of_int p.part_value) ]) origin_fees);
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
              Mint (Z.of_string salt);
              prim `Pair ~args:[
                option_mich (fun c -> Mstring (Proto.A.cal_to_str c)) start_date;
                prim `Pair ~args:[
                  option_mich (fun c -> Mstring (Proto.A.cal_to_str c)) end_date;
                  prim `Pair ~args:[
                    Mbytes (Hex.of_string @@ keccak data_type);
                    Mbytes (Hex.of_string data);
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
  if cancelled then 0L, 0L
  else
    let take = Int64.sub take_value fill in
    let make = Int64.(div (mul take make_value) take_value) in
    make, take

let calculate_fee data protocol_commission = match data with
  | RaribleV2Order { order_rarible_v2_data_v1_origin_fees ; _ } ->
    List.fold_left (fun acc p -> Int64.(add acc (of_int p.part_value)))
      protocol_commission
      order_rarible_v2_data_v1_origin_fees
  | _ -> assert false

let calculate_rounded_make_balance make_value take_value make_balance =
  let max_take = Int64.(div (mul make_balance take_value) make_value) in
  Int64.(div (mul make_value max_take) take_value)

let calculate_make_stock
    make_value take_value fill data make_balance protocol_commission fee_side cancelled =
  let make, _take = calculate_remaining make_value take_value fill cancelled in
  let fee = match fee_side with
    | None | Some FeeSideTake -> 0L
    | Some FeeSideMake -> calculate_fee data protocol_commission in
  let make_balance = Int64.(div (mul make_balance 10000L) (add fee 10000L)) in
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
      (Some elt.order_form_elt_maker)
      make_asset.asset_type
      take_asset.asset_type
      elt.order_form_elt_salt in
  let now = CalendarLib.Calendar.now () in
  Ok {
    order_elt_maker = elt.order_form_elt_maker ;
    order_elt_taker = elt.order_form_elt_taker;
    order_elt_make = make_asset;
    order_elt_take = take_asset;
    order_elt_fill = "0";
    order_elt_start = elt.order_form_elt_start;
    order_elt_end = elt.order_form_elt_end;
    order_elt_make_stock = "0";
    order_elt_cancelled = false;
    order_elt_salt = elt.order_form_elt_salt;
    order_elt_signature = elt.order_form_elt_signature;
    order_elt_created_at = now;
    order_elt_last_update_at = now;
    order_elt_pending = Some [];
    order_elt_hash = hash;
    order_elt_make_balance = None;
    order_elt_make_price_usd = "0";
    order_elt_take_price_usd = "0";
    order_elt_price_history = [];
  }

let order_from_order_form form =
  let$ order_elt = order_elt_from_order_form_elt form.order_form_elt in
  Ok { order_elt; order_data = form.order_form_data }

let order_form_elt_from_order_elt order_elt = {
  order_form_elt_maker = order_elt.order_elt_maker ;
  order_form_elt_taker = order_elt.order_elt_taker ;
  order_form_elt_make = order_elt.order_elt_make ;
  order_form_elt_take = order_elt.order_elt_take ;
  order_form_elt_salt = order_elt.order_elt_salt ;
  order_form_elt_start = order_elt.order_elt_start ;
  order_form_elt_end = order_elt.order_elt_end ;
  order_form_elt_signature = order_elt.order_elt_signature ;
}

let order_form_from_order order = {
  order_form_elt =  order_form_elt_from_order_elt order.order_elt ;
  order_form_data = order.order_data
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
  List.map (fun t ->
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
  List.map (fun t ->
      String.lowercase_ascii @@
      EzEncoding.construct order_activity_filter_user_type_enc t) l

let order_bid_status_to_string l =
  String.concat ";" @@
  List.map (fun t ->
      EzEncoding.construct order_bid_status_enc t) l

let sign ~edsk ~bytes =
  let open Tzfunc.Crypto in
  let sk = Hacl.Sign.unsafe_sk_of_bytes (Bigstring.of_string @@ Base58.decode Prefix.ed25519_seed edsk) in
  let msg = Bigstring.of_string @@ Crypto.Blake2b_32.hash [bytes] in
  let signature = Bigstring.create 64 in
  Hacl.Sign.sign ~sk ~msg ~signature;
  Base58.encode Prefix.ed25519_signature @@ Bigstring.to_string @@ signature

let check ~edpk ~signature ~bytes =
  let open Tzfunc.Crypto in
  let pk = Hacl.Sign.unsafe_pk_of_bytes (Bigstring.of_string @@ Base58.decode Prefix.ed25519_public_key edpk) in
  let msg = Bigstring.of_string @@ Crypto.Blake2b_32.hash [bytes] in
  let signature = Bigstring.of_string @@ Base58.decode Prefix.ed25519_signature signature in
  Hacl.Sign.verify ~pk ~msg ~signature

let short ?(len=8) h =
  if String.length h > len then String.sub h 0 len else h
