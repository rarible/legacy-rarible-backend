open Proto
open Rtypes

(*
(or
 (or
  (or
   (pair %balance_of (list %requests (pair (address %owner) (nat %token_id)))
         (contract (list (pair (pair (address %owner) (nat %token_id)) (nat %balance)))))
   (list %update_operators
         (or (pair (address %owner) (pair (address %operator) (nat %token_id)))
             (pair (address %owner) (pair (address %operator) (nat %token_id))))))
  (or
   (list %update_operators_for_all (or address address))
   (list %transfer (pair address (list (pair (address %to) (pair (nat %token_id) (nat %amount))))))))
 (or
  (or
   (pair %mint (nat %itokenid) (pair (address %iowner) (pair (nat %iamount) (list %royalties (pair (address %partAccount) (nat %partValue))))))
   (pair %burn (nat %itokenid) (pair (address %iowner) (nat %iamount))))
  (or
   (bytes %setMetadataUri)
   (pair %setTokenMetadata (nat %iTokenId) (map %iExtras string string)))))
*)

let rec flatten = function
  | Mprim { prim = `Pair; args; annots } ->
    let args = List.fold_left (fun acc x -> match flatten x with
        | Mprim { prim = `Pair; args; _ } -> acc @ args
        | _ -> acc @ [ x ]) [] args in
    let args = List.map flatten args in
    Mprim { prim = `Pair; args; annots }
  | Mprim {prim; args; annots} ->
    Mprim {prim; args = List.map flatten args; annots}
  | Mseq l -> Mseq (List.map flatten l)
  | m -> m

let parse_update_operators m =
  let rec aux acc = function
    | [] -> Ok acc
    | Mprim { prim = add; args = [
        Mprim { prim = `Pair; args = [
            Mstring op_owner;
            Mstring op_operator;
            Mint id;
          ]; _ }
      ]; _ } :: t ->
      begin match add with
        | `Left ->
          aux ({op_owner; op_operator; op_token_id = Z.to_int64 id; op_add=true} :: acc) t
        | `Right ->
          aux ({op_owner; op_operator; op_token_id = Z.to_int64 id; op_add=false} :: acc) t
        | _ -> Error `unexpected_michelson_value
      end
    | _ -> Error `unexpected_michelson_value in
  match m with
  | Mseq l -> begin match aux [] l with
      | Error e -> Error e
      | Ok l -> Ok (Operator_updates (List.rev l))
    end
  | _ -> Error `unexpected_michelson_value

let parse_update_operators_all m =
  let rec aux acc = function
    | [] -> Ok acc
    | Mprim { prim = `Left; args = [ Mstring operator ]; _} :: t ->
      aux ((operator, true) :: acc) t
    | Mprim { prim = `Right; args = [ Mstring operator ]; _} :: t ->
      aux ((operator, false) :: acc) t
    | _ -> Error `unexpected_michelson_value in
  match m with
  | Mseq l -> begin match aux [] l with
      | Error e -> Error e
      | Ok l -> Ok (Operator_updates_all (List.rev l))
    end
  | _ -> Error `unexpected_michelson_value

let parse_transfer m =
  let rec aux_to acc = function
    | [] -> Ok acc
    | Mprim { prim = `Pair; args = [
        Mstring tr_destination;
        Mint id;
        Mint amount;
      ]; _} :: t ->
      aux_to ({tr_destination; tr_token_id = Z.to_int64 id; tr_amount = Z.to_int64 amount} :: acc) t
    | _ -> Error `unexpected_michelson_value in
  let rec aux_from acc = function
    | [] -> Ok acc
    | Mprim { prim = `Pair; args = [
          Mstring tr_source;
          Mseq txs
        ]; _} :: t ->
      begin match aux_to [] txs with
        | Error e -> Error e
        | Ok txs -> aux_from ({ tr_source; tr_txs = List.rev txs } :: acc) t
      end
    | _ -> Error `unexpected_michelson_value in
  match m with
  | Mseq l -> begin match aux_from [] l with
      | Error e -> Error e
      | Ok l -> Ok (Transfers (List.rev l))
    end
  | _ -> Error `unexpected_michelson_value

let parse_mint = function
  | Mprim { prim = `Pair; args = [
      Mint id;
      Mstring tk_owner;
      Mint amount;
      Mseq royalties ]; _ } ->
    let mi_meta = [] in
    let mi_royalties = List.filter_map (function
        | Mprim { prim = `Elt; args = [ Mstring s; Mint i ]; _ } -> Some (s, Z.to_int64 i)
        | _ -> None) royalties in
    Ok (Mint_tokens {
        mi_op = { tk_op = { tk_token_id = Z.to_int64 id; tk_amount = Z.to_int64 amount };
                  tk_owner };
        mi_royalties; mi_meta })
  | _ -> Error `unexpected_michelson_value

let parse_burn = function
  | Mprim {prim = `Pair; args = [Mint id; Mstring tk_owner; Mint amount]; _ } ->
    Ok (Burn_tokens { tk_owner; tk_op = {
        tk_token_id = Z.to_int64 id; tk_amount = Z.to_int64 amount } })
  | _ -> Error `unexpected_michelson_value

let parse_metadata_uri = function
  | Mbytes h -> Ok (Metadata_uri (Hex.to_string h))
  | _ -> Error `unexpected_michelson_value

let parse_token_metadata = function
  | Mprim {prim = `Pair; args = [Mint id; Mseq l]; _ } ->
    let l = List.filter_map (function
        | Mprim { prim = `Elt; args = [ Mstring k; Mstring v ]; _ } ->
          Some (k, v)
        | _ -> None) l in
    Ok (Token_metadata (Z.to_int64 id, l))
  | _ -> Error `unexpected_michelson_value

let rec parse_nft e p =
  let p = flatten p in
  match e, p with
  (* main *)
  | EPdefault, Mprim { prim = `Left; args = [ m ]; _ } ->
    parse_nft (EPnamed "left") m
  | EPdefault, Mprim { prim = `Right; args = [ m ]; _ } ->
    parse_nft (EPnamed "right") m
  | EPnamed "left", Mprim { prim = `Left; args = [ m ]; _ } ->
    parse_nft (EPnamed "left_left") m
  | EPnamed "left", Mprim { prim = `Right; args = [ m ]; _ } ->
    parse_nft (EPnamed "left_right") m
  | EPnamed "right", Mprim { prim = `Left; args = [ m ]; _ } ->
    parse_nft (EPnamed "right_left") m
  | EPnamed "right", Mprim { prim = `Right; args = [ m ]; _ } ->
    parse_nft (EPnamed "right_right") m
  | EPnamed "left_left", Mprim { prim = `Left; args = [ m ]; _ } ->
    parse_nft (EPnamed "balance_of") m
  | EPnamed "left_left", Mprim { prim = `Right; args = [ m ]; _ } ->
    parse_nft (EPnamed "update_operators") m
  | EPnamed "left_right", Mprim { prim = `Left; args = [ m ]; _ } ->
    parse_nft (EPnamed "update_operators_for_all") m
  | EPnamed "left_right", Mprim { prim = `Right; args = [ m ]; _ } ->
    parse_nft (EPnamed "transfer") m
  | EPnamed "right_left", Mprim { prim = `Left; args = [ m ]; _ } ->
    parse_nft (EPnamed "mint") m
  | EPnamed "right_left", Mprim { prim = `Right; args = [ m ]; _ } ->
    parse_nft (EPnamed "burn") m
  | EPnamed "right_right", Mprim { prim = `Left; args = [ m ]; _ } ->
    parse_nft (EPnamed "setMetadaraUri") m
  | EPnamed "right_right", Mprim { prim = `Right; args = [ m ]; _ } ->
    parse_nft (EPnamed "setTokenMetadata") m

  | EPnamed "update_operators", m -> parse_update_operators m
  | EPnamed "update_operators_for_all", m -> parse_update_operators_all m
  | EPnamed "transfer", m -> parse_transfer m
  | EPnamed "mint", m -> parse_mint m
  | EPnamed "burn", m -> parse_burn m
  | EPnamed "setMetadataUri", m -> parse_metadata_uri m
  | EPnamed "setTokenMetadata", m -> parse_token_metadata m

  | _ -> Error `unexpected_michelson_value

let rec list_entrypoints acc = function
  | Mprim { prim = `or_; args = [ arg1; arg2 ] ; _ } ->
    begin match list_entrypoints acc arg1 with
      | Error e -> Error e
      | Ok acc -> list_entrypoints acc arg2
    end
  | Mprim { annots = [ s ]; _ } as m when String.get s 0 = '%' ->
    Ok (m :: acc)
  | _ -> Error `unexpected_michelson_value

let entrypoints m = match flatten m with
  | Mseq [ Mprim { prim = `parameter; args = [ arg ]; _} ; _; _] ->
    list_entrypoints [] arg
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
    | Mseq [ _; Mprim { prim = `storage; args = [ arg ]; _} ; _] ->
      begin match arg with
        | Mprim { prim = `pair; args ; _ } ->
          Result.ok @@
          snd @@ List.fold_left (fun (i, acc) m ->
              match m with
              | Mprim { annots = [ name ]; _ } -> i+1, ((name, i) :: acc)
              | _ -> i, acc) (0, []) args
        | _ -> Error `unexpected_michelson_value
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

let (let$) = Result.bind

let pack m =
  let$ b = Forge.forge_micheline m in
  let h = Hex.of_string b in
  Forge.forge_micheline @@ Mbytes h

let asset_type_mich = function
  | ATXTZ -> prim `Left ~args:[prim `Unit]
  | ATFA_1_2 _ -> prim `Right ~args:[prim `Left ~args:[ prim `Unit ]]
  | ATFA_2 _ -> prim `Right ~args:[prim `Right ~args:[ prim `Left ~args:[ prim `Unit ] ]]
  | ATETH -> Mint Z.zero
  | ATERC721 _ -> Mint Z.one

let asset_mich a =
  prim `Pair ~args:[
    prim `Pair ~args:[ asset_type_mich a.asset_type; Mbytes (`Hex "00") ];
    Mint (Z.of_string a.asset_value)
  ]

let option_mich f = function
  | None -> prim `None
  | Some x -> prim `Some ~args:[ f x ]

let keccak s =
  Digestif.KECCAK_256.(to_raw_string @@ digest_string s)

let hash_key maker make_asset_type take_asset_type salt =
  let$ maker = pack @@ Mstring maker in
  let$ make_asset_type = pack @@ asset_type_mich make_asset_type in
  let$ take_asset_type = pack @@ asset_type_mich take_asset_type in
  let$ salt = pack @@ Mint (Z.of_string salt) in
  Result.ok @@ Hex.show @@ Hex.of_string @@ keccak @@ String.concat "" [
    maker;
    keccak make_asset_type;
    keccak take_asset_type;
    salt
  ]

let hash_order_form maker make taker take salt start_date end_date data_type payouts origin_fees =
  let$ data_type = pack (Mstring data_type) in
  let$ data = pack (prim `Pair ~args:[
      Mseq (List.map (fun p -> prim `Pair ~args:[
          Mstring p.part_account;
          Mint (Z.of_int p.part_value) ]) payouts);
      Mseq (List.map (fun p -> prim `Pair ~args:[
          Mstring p.part_account;
          Mint (Z.of_int p.part_value) ]) origin_fees);
    ]) in
  pack @@
  prim `Pair ~args:[
    option_mich (fun s -> Mstring s) (Some maker);
    prim `Pair ~args:[
      asset_mich make;
      prim `Pair ~args:[
        option_mich (fun s -> Mstring s) taker;
        prim `Pair ~args:[
          asset_mich take;
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
  ]

let hash_order order =
  Format.eprintf "hash_order\n%!";
  let elt = order.order_elt in
  (* todo : correct data_type *)
  match order.order_data with
  | RaribleV2Order o ->
    let$ data_type = pack (Mstring o.order_rarible_v2_data_v1_data_type) in
    let$ data = pack (prim `Pair ~args:[
        Mseq (List.map (fun p -> prim `Pair ~args:[
            Mstring p.part_account;
            Mint (Z.of_int p.part_value) ]) o.order_rarible_v2_data_v1_payouts);
        Mseq (List.map (fun p -> prim `Pair ~args:[
            Mstring p.part_account;
            Mint (Z.of_int p.part_value) ]) o.order_rarible_v2_data_v1_origin_fees);
      ]) in
    pack @@
    prim `Pair ~args:[
      option_mich (fun s -> Mstring s) (Some elt.order_elt_maker);
      prim `Pair ~args:[
        asset_mich elt.order_elt_make;
        prim `Pair ~args:[
          option_mich (fun s -> Mstring s) elt.order_elt_taker;
          prim `Pair ~args:[
            asset_mich elt.order_elt_take;
            prim `Pair ~args:[
              Mint (Z.of_string elt.order_elt_salt);
              prim `Pair ~args:[
                option_mich (fun c -> Mstring (Proto.A.cal_to_str c)) elt.order_elt_start;
                prim `Pair ~args:[
                  option_mich (fun c -> Mstring (Proto.A.cal_to_str c)) elt.order_elt_end;
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
    ]
  | _ -> Error `wrong_order

(* // who fills asset collection `fill` ?
 * function hashKeyOrder(iorder : order) : bytes {
 *   return keccak(concat([
 *     pack(iorder.maker);
 *     keccak(pack(iorder.makeAsset.assetType));
 *     keccak(pack(iorder.takeAsset.assetType));
 *     pack(iorder.salt)]))
 * } *)

let order_elt_from_order_form_elt elt =
  let make_asset = elt.order_form_elt_make in
  let take_asset = elt.order_form_elt_take in
  (* TODO *)
  let$ hash =
    hash_key
      elt.order_form_elt_maker
      make_asset.asset_type
      take_asset.asset_type
      elt.order_form_elt_salt in
  let make_balance = None in
  let make_stock = "0" in
  let now = CalendarLib.Calendar.now () in
  Ok {
    order_elt_maker = elt.order_form_elt_maker ;
    order_elt_taker = elt.order_form_elt_taker;
    order_elt_make = make_asset;
    order_elt_take = take_asset;
    order_elt_fill = "0";
    order_elt_start = elt.order_form_elt_start;
    order_elt_end = elt.order_form_elt_end;
    order_elt_make_stock = make_stock;
    order_elt_cancelled = false;
    order_elt_salt = elt.order_form_elt_salt;
    order_elt_signature = elt.order_form_elt_signature;
    order_elt_created_at = now;
    order_elt_last_update_at = now;
    order_elt_pending = Some [];
    order_elt_hash = hash;
    order_elt_make_balance = make_balance;
    order_elt_make_price_usd = None;
    order_elt_take_price_usd = None;
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
