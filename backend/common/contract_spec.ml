open Proto
open Rtypes
open Utils
open Let

let get_code_elt p = function
  | Some (Micheline (Mseq l)) ->
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
      begin match Typed_mich.get_name_annots annots with
        | None -> Ok acc
        | Some name -> match Typed_mich.parse_type m with
          | Error e -> Error e
          | Ok t -> Ok ((name, Typed_mich.short_micheline_type t) :: acc)
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

let fa2_entrypoints : (string * micheline_type_short) list = [
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
let mint_ubi_entry = `tuple [ `address; `nat; `option `bytes ]
let mint_ubi2_entry = `tuple [ `tuple [ `address; `nat ]; `map (`string, `bytes); `nat ]
let burn_nft_entry = `nat
let burn_mt_entry = `tuple [ `nat; `nat ]
let set_token_metadata_entry = `tuple [ `nat; `map (`string, `bytes) ]

let fa2_ext_entrypoints : (string * micheline_type_short) list = [
  "update_operators_for_all", update_operators_all_entry;
  "mint", mint_mt_entry;
  "mint", mint_nft_entry;
  "burn", burn_mt_entry;
  "burn", burn_nft_entry;
  "setTokenMetadata", set_token_metadata_entry;
]

let get_storage_fields script =
  let rec aux bm_index acc = function
    | {name=None; typ=`tuple []} -> bm_index, acc
    | {name=None; typ=`tuple (h :: t)} ->
      let bm_index, acc = aux bm_index acc h in
      aux bm_index acc {name=None; typ=`tuple t}
    | {name=Some n; typ = `big_map (k, v)} ->
      bm_index + 1, (n, Some (
          bm_index, Typed_mich.short_micheline_type k, Typed_mich.short_micheline_type v)) :: acc
    | {name=Some n; _} ->
      bm_index, (n, None) :: acc
    | _ -> bm_index, acc in
  match get_code_elt `storage script.code with
  | None -> unexpected_michelson
  | Some m -> match Typed_mich.parse_type m with
    | Error e -> Error e
    | Ok t -> Ok (List.rev @@ snd @@ aux 0 [] t)

let match_fields ~expected ~allocs script =
  match script.storage, get_storage_fields script, get_code_elt `storage script.code with
  | Bytes _, _, _ | Other _, _, _ | _, Error _, _ | _, _, None ->
    unexpected_michelson
  | Micheline storage_value, Ok fields, Some storage_type ->
    let$ storage_type = Typed_mich.parse_type storage_type in
    let$ storage_value = Typed_mich.(parse_value (short_micheline_type storage_type) storage_value) in
    Ok (List.map (fun name ->
        match List.assoc_opt name fields with
        | None -> None, None
        | Some None ->
          Typed_mich.search_value ~name storage_type storage_value, None
        | Some (Some (bm_index, k, v)) ->
          Typed_mich.search_value ~name storage_type storage_value,
          (match Storage_diff.get_big_map_id ~allocs bm_index k v with
           | None -> None
           | Some id -> Some (id, k, v))
      ) expected)

let ledger_fa2_multiple_field = `tuple [ `address; `nat ], `nat
let ledger_nft_field = `nat, `address
let ledger_fa2_multiple_inversed_field = `tuple [ `nat; `address ], `nat
let ledger_fa2_single_field = `address, `nat
let ledger_fa1_field = `address, `tuple [`nat; `map (`address, `nat) ]
let ledger_lugh_field = `tuple [ `address; `nat ], `tuple [`nat; `nat; `bool ]

let set_royalties_entry = `tuple [`address; `nat; `map (`address, `nat)]
