open Proto
open Rtypes

let (let$) = Result.bind

let prim ?(args=[]) ?(annots=[]) prim = Mprim {prim; args; annots}
let pair ?annots args = prim ?annots ~args `pair
let list ?annots arg = prim ?annots ~args:[arg] `list

let rec flatten = function
  | Mprim { prim = `Pair; args; annots } ->
    let args = List.fold_left (fun acc x -> match flatten x with
        | Mprim { prim = `Pair; args; _ } -> acc @ args
        | _ -> acc @ [ x ]) [] args in
    let args = List.map flatten args in
    prim `Pair ~args ~annots
  | Mprim { prim = `pair; args; annots } ->
    let args = List.fold_left (fun acc x -> match flatten x with
        | Mprim { prim = `pair; args; _ } -> acc @ args
        | _ -> acc @ [ x ]) [] args in
    let args = List.map flatten args in
    prim `pair ~args ~annots
  | Mprim {prim=p; args; annots} ->
    prim p ~args:(List.map flatten args) ~annots
  | Mseq l -> Mseq (List.map flatten l)
  | m -> m

let res_map f l =
  let rec aux acc = function
    | [] -> Ok (List.rev acc)
    | t :: q -> match f t with
      | Ok x -> aux (x :: acc) q
      | Error e -> Error e in
  aux [] l

let parse_typed t m : (typed_micheline list, [> `unexpected_michelson_type of micheline * micheline]) result =
  let rec aux acc t m = match t, m with
    | Mprim { prim=`list; args=[t]; _ }, Mseq l
    | Mprim { prim=`set; args=[t]; _ }, Mseq l ->
      Result.map (fun l -> acc @ [ `seq l ]) @@
      res_map (fun x -> aux [] t x) l
    | Mprim { prim=`map; args=[k; v]; _ }, Mseq l
    | Mprim { prim=`big_map; args=[k; v]; _ }, Mseq l ->
      Result.map (fun l -> acc @ [ `assoc l ]) @@
      res_map (function
          | Mprim { prim = `Elt; args= [m1; m2]; _ } ->
            begin match aux [] k m1, aux [] v m2 with
              | Ok x1, Ok x2 -> Ok (x1, x2)
              | Error e, _ | _, Error e -> Error e
            end
          | m -> Error (`unexpected_michelson_type (k, m))) l
    | Mprim { prim = `string; _ }, Mstring s -> Ok (acc @ [ `string s ])
    | Mprim { prim = `key; _ }, Mstring s -> Ok (acc @ [ `key s ])
    | Mprim { prim = `key_hash; _ }, Mstring s -> Ok (acc @ [ `key_hash s ])
    | Mprim { prim = `address; _ }, Mstring s -> Ok (acc @ [ `address s ])
    | Mprim { prim = `signature; _ }, Mstring s -> Ok (acc @ [ `signature s ])
    | Mprim { prim = `timestamp; _}, Mstring s -> Ok (acc @ [ `timestamp (Proto.A.cal_of_str s) ])
    | Mprim { prim = `nat; _ }, Mint i -> Ok (acc @ [ `nat i ])
    | Mprim { prim = `int; _ }, Mint i -> Ok (acc @ [ `int i ])
    | Mprim { prim = `mutez; _ }, Mint i -> Ok (acc @ [ `mutez i ])
    | Mprim { prim = `timestamp; _ }, Mint i ->
      Ok (acc @ [ `timestamp (CalendarLib.Calendar.from_unixfloat (Z.to_float i)) ])
    | Mprim { prim = `bytes; _ }, Mbytes b -> Ok (acc @ [ `bytes b ])
    | Mprim { prim = `key; _ }, Mbytes b ->
      Result.map (fun (s, _) -> acc @ [ `key s ]) @@
      Tzfunc.Binary.Reader.(pk {s=Tzfunc.Crypto.hex_to_raw b; offset=0})
    | Mprim { prim = `key_hash; _ }, Mbytes b ->
      Result.map (fun (s, _) -> acc @ [ `key s ]) @@
      Tzfunc.Binary.Reader.(pkh {s=Tzfunc.Crypto.hex_to_raw b; offset=0})
    | Mprim { prim = `address; _ }, Mbytes b ->
      Result.map (fun (s, _) -> acc @ [ `address s ]) @@
      Tzfunc.Binary.Reader.(contract {s=Tzfunc.Crypto.hex_to_raw b; offset=0})
    | Mprim { prim = `signature; _ }, Mbytes b ->
      Result.map (fun (s, _) -> acc @ [ `signature s ]) @@
      Tzfunc.Binary.Reader.(signature {s=Tzfunc.Crypto.hex_to_raw b; offset=0})
    | Mprim { prim=`option; _ }, Mprim { prim=`None; args=[]; _} -> Ok ( acc @ [ `none ] )
    | Mprim { prim=`unit; _ }, Mprim { prim=`Unit; args=[]; _} -> Ok ( acc @ [ `unit ] )
    | Mprim { prim=`bool; _}, Mprim { prim=`True; args=[]; _} -> Ok ( acc @ [ `true_ ] )
    | Mprim { prim=`bool; _}, Mprim { prim=`False; args=[]; _} -> Ok ( acc @ [ `false_ ] )
    | Mprim { prim=`option; args=[t]; _ }, Mprim { prim = `Some; args=[m]; _} ->
      Result.map (fun x -> acc @ [ `some x ]) @@ aux [] t m
    | Mprim { prim=`or_; args=[l; _r]; _ }, Mprim { prim = `Left; args=[m]; _} ->
      Result.map (fun x -> acc @ [ `left x ]) @@ aux [] l m
    | Mprim { prim=`or_; args=[_l; r]; _ }, Mprim { prim = `Right; args=[m]; _} ->
      Result.map (fun x -> acc @ [ `right x ]) @@ aux [] r m
    | Mprim { prim = `pair; args=[]; _ }, Mseq [] -> Ok acc
    | Mprim { prim = `pair; args=t1 :: t; _ }, Mprim { prim=`Pair; args=m1 :: m; _ }
    | Mprim { prim = `pair; args=t1 :: t; _ }, Mseq (m1 :: m) ->
      begin match aux acc t1 m1 with
        | Error e -> Error e
        | Ok acc -> aux acc (Mprim { prim = `pair; args=t; annots=[] }) (Mseq m)
      end
    | Mprim { prim = `operation; _ }, _ -> Ok (acc @ [ `operation ])
    | Mprim { prim = `contract; _ }, _ -> Ok (acc @ [ `contract ])
    | Mprim { prim = `lambda; _ }, _ -> Ok (acc @ [ `lambda ])
    | t, m ->
      Error (`unexpected_michelson_type (t, m)) in
  aux [] t m

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

let asset_class_mich = function
  | ATXTZ -> prim `Left ~args:[prim `Unit]
  | ATFA_1_2 _ -> prim `Right ~args:[prim `Left ~args:[ prim `Unit ]]
  | ATFA_2 _ -> prim `Right ~args:[prim `Right ~args:[ prim `Left ~args:[ prim `Unit ] ]]

let asset_class_type =
  (prim `or_ ~args:[prim `unit; prim `or_ ~args:[prim `unit; prim `or_ ~args:[
       prim `unit; prim `or_ ~args:[prim `unit; prim `bytes ]]]])

let asset_data = function
  | ATXTZ -> Ok (Tzfunc.Raw.mk "\000")
  | ATFA_1_2 a -> Tzfunc.Forge.pack (prim `address) (Mstring a)
  | ATFA_2 { asset_fa2_contract; asset_fa2_token_id } ->
    Tzfunc.Forge.pack (prim `pair ~args:[ prim `address; prim `nat ])
      (prim `Pair ~args:[ Mstring asset_fa2_contract; Mint (Z.of_string asset_fa2_token_id) ])

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
      Mint (Z.of_string a.asset_value)
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
  let salt = Tzfunc.Forge.pack (prim `nat) @@ Mint (Z.of_string salt) in
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
        Mint (Z.of_string salt);
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
              Mint (Z.of_string salt);
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
  if cancelled then 0L, 0L
  else
    let take = Int64.sub take_value fill in
    let make = Int64.(div (mul take make_value) take_value) in
    make, take

let calculate_fee data protocol_commission =
  List.fold_left (fun acc p -> Int64.(add acc (of_int32 p.part_value)))
    protocol_commission
    data.order_rarible_v2_data_v1_origin_fees

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
    order_elt_hash = (hash :> string);
    order_elt_make_balance = None;
    order_elt_price_history = [];
    order_elt_status = None
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

let flat_order_type =
  pair [
    prim `option ~args:[prim `key];
    asset_type;
    prim `option ~args:[prim `key];
    asset_type;
    prim `nat;
    prim `option ~args:[ prim `timestamp ];
    prim `option ~args:[ prim `timestamp ];
    prim `bytes;
    prim `bytes;
  ]

let do_transfers_type =
  pair [
    asset_type_type;
    asset_type_type;
    pair [ prim `nat; prim `nat ];
    flat_order_type;
    flat_order_type;
    prim `nat;
    prim `list ~args:[ pair [prim `address; prim `nat] ]
  ]

let pk_to_pkh_exn pk = match Tzfunc.Crypto.pk_to_pkh pk with
  | Error _ -> failwith ("cannot hash edpk " ^ pk)
  | Ok pkh -> pkh

let tzip21_attribute_to_rarible_attribute a = {
  nft_item_attribute_key = a.attribute_name ;
  nft_item_attribute_value = Some (a.attribute_value) ;
  nft_item_attribute_type = a.attribute_type ;
  nft_item_attribute_format = None ;
}

let tzip21_attributes_to_rarible_attributes l =
  List.map tzip21_attribute_to_rarible_attribute l
