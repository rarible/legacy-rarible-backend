open Proto
open Rtypes
open Let

let unexpected_michelson = Error `unexpected_michelson_value

let get_name_annots = function
  | [ s ] when String.length s > 0 && String.get s 0 = '%' ->
    Some (String.sub s 1 (String.length s - 1))
  | _ -> None

let rec parse_type : (micheline -> (micheline_type, _) result) = function
  | Mseq _ | Mint _ | Mstring _ | Mbytes _ -> unexpected_michelson
  | Mprim { prim; args; annots } ->
    let name = get_name_annots annots in
    match prim, args with
    | `address, _ -> Ok { name; typ=`address }
    | `bool, _ -> Ok { name; typ=`bool }
    | `bytes, _ -> Ok { name; typ=`bytes }
    | `chain_id, _ -> Ok { name; typ=`chain_id }
    | `int, _ -> Ok { name; typ=`int }
    | `key, _ -> Ok { name; typ=`key }
    | `key_hash, _ -> Ok { name; typ=`key_hash }
    | `mutez, _ -> Ok { name; typ=`mutez }
    | `nat, _ -> Ok { name; typ=`nat }
    | `operation, _ -> Ok { name; typ=`operation }
    | `signature, _ -> Ok { name; typ=`signature }
    | `string, _ -> Ok { name; typ=`string }
    | `timestamp, _ -> Ok { name; typ=`timestamp }
    | `unit, _ -> Ok { name; typ=`unit }
    | `option, [ arg ] ->
      let$ t = parse_type arg in
      Ok { name; typ=`option t }
    | `contract, [ arg ] ->
      let$ t = parse_type arg in
      Ok { name; typ=`contract t }
    | `or_, [ l; r ] ->
      let$ l = parse_type l in
      let$ r = parse_type r in
      Ok { name; typ=`or_ (l, r) }
    | `list, [ arg ] | `set, [ arg ] ->
      let$ t = parse_type arg in
      Ok { name; typ=`seq t }
    | `lambda, [ arg; res ] ->
      let$ arg = parse_type arg in
      let$ res = parse_type res in
      Ok { name; typ=`lambda (arg, res) }
    | `map, [ k; v ] ->
      let$ k = parse_type k in
      let$ v = parse_type v in
      Ok { name; typ=`map (k, v) }
    | `big_map, [ k; v ] ->
      let$ k = parse_type k in
      let$ v = parse_type v in
      Ok { name; typ=`big_map (k, v) }
    | `pair, [ arg1; arg2 ] ->
      begin match parse_type arg1, parse_type arg2 with
        | Ok t1, Ok {typ=`tuple l; _} -> Ok { name; typ=`tuple (t1 :: l) }
        | Ok t1, Ok t2 -> Ok { name; typ=`tuple [t1; t2] }
        | _ -> unexpected_michelson
      end
    | `pair, (arg1 :: args) ->
      begin match parse_type arg1, parse_type (Mprim {prim=`pair; args; annots=[]}) with
        | Ok t1, Ok {typ=`tuple l; _} -> Ok { name; typ=`tuple (t1 :: l) }
        | Ok t1, Ok t2 -> Ok { name; typ=`tuple [t1; t2] }
        | _ -> unexpected_michelson
      end
    | _ -> unexpected_michelson

let parse_value t m : (micheline_value, _) result =
  let rec aux (t : micheline_type_short) (m : micheline) : (micheline_value, _) result = match t, m with
    | `seq t, Mseq l ->
      Result.map (fun l -> `seq l ) @@ Let.map_res (aux t) l
    | `map (k, v), Mseq l | `big_map (k, v), Mseq l ->
      Result.map (fun l -> `assoc l) @@
      Let.map_res (function
          | Mprim { prim = `Elt; args= [m1; m2]; _ } ->
            begin match aux k m1, aux v m2 with
              | Ok x1, Ok x2 -> Ok (x1, x2)
              | Error e, _ | _, Error e -> Error e
            end
          | m -> Error (`unexpected_michelson_type (k, m))) l
    | `string, Mstring s -> Ok (`string s)
    | `key, Mstring s -> Ok (`key s)
    | `key_hash, Mstring s -> Ok (`key_hash s)
    | `address, Mstring s ->
      Ok (`address s)
    | `signature, Mstring s -> Ok (`signature s)
    | `chain_id, Mstring s -> Ok (`chain_id s)
    | `timestamp, Mstring s -> Ok (`timestamp (Proto.A.cal_of_str s))
    | `nat, Mint i -> Ok (`nat i)
    | `int, Mint i -> Ok (`int i)
    | `mutez, Mint i -> Ok (`mutez i)
    | `timestamp, Mint i ->
      Ok (`timestamp (CalendarLib.Calendar.from_unixfloat (Z.to_float i)))
    | `bytes, Mbytes b -> Ok (`bytes b)
    | `key, Mbytes b ->
      Result.map (fun (s, _) -> `key s) @@
      Tzfunc.Binary.Reader.(pk {s=Tzfunc.Crypto.hex_to_raw b; offset=0})
    | `key_hash, Mbytes b ->
      Result.map (fun (s, _) -> `key_hash s) @@
      Tzfunc.Binary.Reader.(pkh {s=Tzfunc.Crypto.hex_to_raw b; offset=0})
    | `address, Mbytes b ->
      Result.map (fun (s, _) -> `address s) @@
      Tzfunc.Binary.Reader.(contract {s=Tzfunc.Crypto.hex_to_raw b; offset=0})
    | `signature, Mbytes b ->
      Result.map (fun (s, _) -> `signature s) @@
      Tzfunc.Binary.Reader.(signature {s=Tzfunc.Crypto.hex_to_raw b; offset=0})
    | `chain_id, Mbytes b ->
      Result.map (fun (s, _) -> `chain_id s) @@
      Tzfunc.Binary.Reader.(chain_id {s=Tzfunc.Crypto.hex_to_raw b; offset=0})
    | `option _, Mprim { prim=`None; args=[]; _} -> Ok `none
    | `unit, Mprim { prim=`Unit; args=[]; _} -> Ok `unit
    | `bool, Mprim { prim=`True; args=[]; _} -> Ok (`bool true)
    | `bool, Mprim { prim=`False; args=[]; _} -> Ok (`bool false)
    | `option t, Mprim { prim = `Some; args=[m]; _} ->
      Result.map (fun x -> `some x) @@ aux t m
    | `or_ (l, _), Mprim { prim = `Left; args=[m]; _} ->
      Result.map (fun x -> `left x) @@ aux l m
    | `or_ (_, r), Mprim { prim = `Right; args=[m]; _} ->
      Result.map (fun x -> `right x) @@ aux r m
    | `tuple [ t1; t2 ], Mseq [m1; m2]
    | `tuple [ t1; t2 ], Mprim {prim=`Pair; args=[m1; m2]; _} ->
      begin match aux t1 m1, aux t2 m2 with
        | Ok v1, Ok v2 -> Ok (`tuple [ v1; v2 ])
        | Error e, _ | _, Error e -> Error e
      end
    | `tuple (t1 :: t), Mprim {prim=`Pair; args=[m1; m2]; _} ->
      begin match aux t1 m1, aux (`tuple t) m2 with
        | Ok v1, Ok (`tuple v) -> Ok (`tuple (v1 :: v))
        | Error e, _ | _, Error e -> Error e
        | _ -> unexpected_michelson
      end
    | `tuple (t1 :: t), Mseq (m1 :: m)
    | `tuple (t1 :: t), Mprim {prim=`Pair; args=(m1 :: m); _} ->
      begin match aux t1 m1, aux (`tuple t) (Mseq m) with
        | Ok v1, Ok (`tuple v) -> Ok (`tuple (v1 :: v))
        | Error e, _ | _, Error e -> Error e
        | _ -> unexpected_michelson
      end
    | `operation, _ -> Ok `operation
    | `contract _, _ -> Ok `contract
    | `lambda _, _ -> Ok `lambda
    | t, m ->
      Error (`unexpected_michelson_type (t, m)) in
  aux t m

let rec search_value ~name (t : micheline_type) (m : micheline_value) : micheline_value option =
  if t.name = Some name then Some m
  else match t.typ, m with
    | `option t, `some m
    | `or_ (t, _), `left m
    | `or_ (_, t), `right m -> search_value ~name t m
    | `tuple [], `tuple _ | `tuple _, `tuple [] -> None
    | `tuple (ht :: t), `tuple (hm :: m) ->
      begin match search_value ~name ht hm with
        | None -> search_value ~name {name=None;typ=`tuple t} (`tuple m)
        | Some m -> Some m
      end
    | _ -> None

let rec short_micheline_type (t : micheline_type) : micheline_type_short = match t.typ with
  | `address -> `address
  | `big_map (k, v) -> `big_map (short_micheline_type k, short_micheline_type v)
  | `bool -> `bool
  | `bytes -> `bytes
  | `chain_id -> `chain_id
  | `contract t -> `contract (short_micheline_type t)
  | `int -> `int
  | `key -> `key
  | `key_hash -> `key_hash
  | `lambda (arg, res) -> `lambda (short_micheline_type arg, short_micheline_type res)
  | `mutez -> `mutez
  | `nat -> `nat
  | `operation -> `operation
  | `signature -> `signature
  |`string -> `string
  | `timestamp -> `timestamp
  | `unit -> `unit
  | `map (k, v) -> `map (short_micheline_type k, short_micheline_type v)
  | `option t -> `option (short_micheline_type t)
  | `or_ (l, r) -> `or_ (short_micheline_type l, short_micheline_type r)
  | `seq t -> `seq (short_micheline_type t)
  | `tuple l -> `tuple (List.map short_micheline_type l)

let rec named_micheline_type ?name (t : micheline_type_short) : micheline_type = match t with
  | `address -> {typ=`address; name}
  | `bool -> {typ=`bool; name}
  | `bytes -> {typ=`bytes; name}
  | `chain_id -> {typ=`chain_id; name}
  | `contract t -> {typ=`contract (named_micheline_type t); name}
  | `int -> {typ=`int; name}
  | `key -> {typ=`key; name}
  | `key_hash -> {typ=`key_hash; name}
  | `lambda (arg, res)-> {typ=`lambda (named_micheline_type arg, named_micheline_type res); name}
  | `mutez -> {typ=`mutez; name}
  | `nat -> {typ=`nat; name}
  | `operation -> {typ=`operation; name}
  | `signature -> {typ=`signature; name}
  | `string -> {typ=`string; name}
  | `timestamp -> {typ=`timestamp; name}
  | `unit -> {typ=`unit; name}
  | `map (k, v) -> {typ=`map (named_micheline_type k, named_micheline_type v); name}
  | `big_map (k, v) -> {typ=`big_map (named_micheline_type k, named_micheline_type v); name}
  | `option t -> {typ=`option (named_micheline_type t); name}
  | `or_ (l, r) -> {typ=`or_ (named_micheline_type l, named_micheline_type r); name}
  | `seq t -> {typ=`seq (named_micheline_type t); name}
  | `tuple l -> {typ=`tuple (List.map named_micheline_type l); name}

let asset_class_type : micheline_type_short =
  `or_ (`unit, `or_ (`unit, `or_ (`int, `or_ (`int, `bytes))))

let asset_type_type : micheline_type_short = `tuple [asset_class_type; `bytes]
let asset_type = `tuple [asset_type_type; `nat]

let order_type =
  `tuple [
    `option `key;
    asset_type;
    `option `key;
    asset_type;
    `nat;
    `option `timestamp;
    `option `timestamp;
    `bytes;
    `bytes;
  ]

let part_type = `tuple [`address; `nat]
let order_data_type = `tuple [`seq part_type; `seq part_type; `bool ]

let do_transfers_type =
  `tuple [
    asset_type_type;
    asset_type_type;
    order_data_type;
    order_data_type;
    `tuple [ `nat; `nat ];
    order_type;
    order_type;
    `nat;
    `seq (`tuple [`address; `nat])
  ]
