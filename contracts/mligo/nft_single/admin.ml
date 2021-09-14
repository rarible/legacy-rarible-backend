open Mligo
include Types

let fail_if_not_admin (a : storage) : unit =
  if Tezos.sender <> a.admin then failwith "NOT_AN_ADMIN" else ()

let set_metadata_uri (s : storage) (uri : bytes) : storage =
  { s with metadata = Big_map.update "" (Some uri) s.metadata }

let admin (param, s : admin * storage) : (operation list) * storage =
  let ops : operation list = [] in
  let s = match param with
    | SetMetadataUri b -> set_metadata_uri s b in
  (ops, s)
