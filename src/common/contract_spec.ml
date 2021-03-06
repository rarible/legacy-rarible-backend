open Proto
open Rtypes
open Utils
open Let

let get_code_elt p = function
  | Mseq l ->
    List.find_map
      (function
        | Mprim { prim; args = [ arg ]; _} when prim = p -> Some arg
        | _ -> None) l
  | _ -> None

let get_entrypoints script =
  let rec aux acc = function
    | Mprim { prim = `or_; args = l ; _ } ->
      let arg1 = List.nth l 0 in
      let arg2 = List.nth l 1 in
      begin match aux acc arg1 with
        | Error e -> Error e
        | Ok acc -> aux acc arg2
      end
    | Mprim { annots; _ } as m ->
      begin match Mtyped.get_name_annots annots with
        | None -> Ok acc
        | Some name -> match Mtyped.parse_type m with
          | Error e -> Error e
          | Ok t -> Ok ((name, Mtyped.short t) :: acc)
      end
    | _ -> unexpected_michelson in
  match get_code_elt `parameter script.code with
  | Some m -> aux [] m
  | None -> unexpected_michelson

let match_entrypoints ~expected ~entrypoints =
  List.map (fun m1 -> List.exists (fun m2 -> m1 = m2) entrypoints) expected

let transfer_entry = `seq ( `tuple [`address; `seq ( `tuple [ `address; `nat; `nat ] ) ])
let update_operators_entry = `seq (
    `or_ (`tuple [ `address; `address; `nat ], `tuple [ `address; `address; `nat ]))

let fa2_entrypoints : (string * Mtyped.stype) list = [
  "balance_of", `tuple [
    `seq (`tuple [`address; `nat]);
    `contract (`seq (`tuple [ `tuple [ `address; `nat ]; `nat ]))
  ];
  "update_operators", update_operators_entry;
  "transfer", transfer_entry
]

let update_operators_all_entry = `seq (`or_ (`address, `address))
let mint_mt_entry = `tuple [ `nat; `address; `nat; `map (`string, `bytes); `seq (`tuple [`address; `nat]) ]
let mint_nft_entry = `tuple [ `nat; `address; `map (`string, `bytes); `seq (`tuple [`address; `nat]) ]
let mint_ubi_entry = `tuple [ `address; `nat ]
let mint_ubi2_entry = `tuple [ `tuple [ `address; `nat ]; `map (`string, `bytes); `nat ]
let mint_hen_entry = `tuple [ `tuple [ `address; `nat ] ; `tuple [ `nat ; `map (`string, `bytes) ] ]
let burn_nft_entry = `nat
let burn_mt_entry = `tuple [ `nat; `nat ]
let set_token_metadata_entry = `tuple [ `nat; `map (`string, `bytes) ]

let fa2_ext_entrypoints : (string * Mtyped.stype) list = [
  "update_operators_for_all", update_operators_all_entry;
  "mint", mint_mt_entry;
  "mint", mint_nft_entry;
  "burn", burn_mt_entry;
  "burn", burn_nft_entry;
]

let get_storage_fields script =
  let rec aux bm_index acc = function
    | {Mtyped.typ=`tuple []; name = None} -> bm_index, acc
    | {Mtyped.typ=`tuple (h :: t); _} ->
      let bm_index, acc = aux bm_index acc h in
      aux bm_index acc {Mtyped.name=None; typ=`tuple t}
    | {Mtyped.name=Some n; typ = `big_map (k, v)} ->
      bm_index + 1, (n, Some (
          bm_index, Mtyped.short k, Mtyped.short v)) :: acc
    | {Mtyped.name=Some n; _} ->
      bm_index, (n, None) :: acc
    | _ -> bm_index, acc in
  match get_code_elt `storage script.code with
  | None -> unexpected_michelson
  | Some m -> match Mtyped.parse_type m with
    | Error e -> Error e
    | Ok t -> Ok (List.rev @@ snd @@ aux 0 [] t)

let match_fields ~expected ~allocs script =
  match get_storage_fields script, get_code_elt `storage script.code with
  | Error _, _ | _, None ->
    unexpected_michelson
  | Ok fields, Some storage_type ->
    let$ storage_type = try Mtyped.parse_type storage_type with _ -> unexpected_michelson in
    let$ storage_value = try Mtyped.(parse_value (short storage_type) script.storage) with _ -> unexpected_michelson in
    Ok (List.map (fun name ->
        match List.assoc_opt name fields with
        | None -> None, None
        | Some None ->
          Mtyped.search_value ~name storage_type storage_value, None
        | Some (Some (bm_index, k, v)) ->
          Mtyped.search_value ~name storage_type storage_value,
          (match Storage_diff.get_big_map_id ~allocs bm_index k v with
           | None -> None
           | Some bm_id -> Some {bm_id; bm_types = {bmt_key=k; bmt_value=v}})
      ) expected)

let ledger_fa2_multiple_field = { bmt_key = `tuple [ `address; `nat ]; bmt_value = `nat }
let ledger_nft_field = { bmt_key = `nat; bmt_value = `address }
let ledger_fa2_multiple_inversed_field = { bmt_key = `tuple [ `nat; `address ]; bmt_value = `nat }
let ledger_fa2_single_field = { bmt_key = `address; bmt_value = `nat }
let ledger_fa1_field = { bmt_key = `address; bmt_value = `tuple [`nat; `map (`address, `nat) ] }
let ledger_lugh_field = { bmt_key = `tuple [ `address; `nat ]; bmt_value = `tuple [`nat; `bool ] }

let token_metadata_field = { bmt_key = `nat; bmt_value = `tuple [ `nat; `map (`string, `bytes) ] }
let metadata_field = { bmt_key = `string; bmt_value = `bytes }
let royalties_field = { bmt_key = `nat; bmt_value = `seq (`tuple [ `address; `nat ]) }
let hen_royalties_field = { bmt_key = `nat; bmt_value = `tuple [ `address; `nat ] }
let versum_royalties_field = {
  bmt_key = `nat;
  bmt_value =
    `tuple [
      `tuple [
        `tuple [ `bool; `map (`string, `bytes) ];
        `seq (`tuple [`address; `seq (`tuple [`nat; `nat])]);
        `nat ];
      `tuple [ `address (* minter *); `option `timestamp];
      `bool;
      `nat; (* royalty *)
      `seq (`tuple [ `address; `nat]); (* splits *)
    ]}
let fxhash_issuer_field = {
  bmt_key = `nat;
  bmt_value =
    `tuple [
      `tuple [
        `tuple [ `address (* author *); `nat ];
        `bool; `nat; `bytes ];
      `tuple [ `nat; `mutez ];
      `nat (* royalties *); `nat; `timestamp
    ]
}
let fxhash_data_field = {
  bmt_key = `nat;
  bmt_value = `tuple [ `tuple [ `bool; `nat (* issuer_id *) ]; `nat; `nat ];
}

let set_royalties_entry = `tuple [`address; `nat; `map (`address, `nat)]

let checked_field ~expected = function
  | (_, Some {bm_id; bm_types}) when bm_types = expected -> Some bm_id
  | _ -> None

let tezos_domains_field = {
  bmt_key = `bytes;
  bmt_value =
    `tuple [
      `tuple [ `tuple [ `option `address; `map (`string, `bytes) ];
               `tuple [ `option `bytes; `map (`string, `bytes) ] ];
      `tuple [ `tuple [ `nat; `address ]; `option `nat ] ]
}
