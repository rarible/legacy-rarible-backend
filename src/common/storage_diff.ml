open Proto
open Rtypes

let big_map_allocs l =
  let f id key_type value_type =
    match Typed_mich.parse_type key_type, Typed_mich.parse_type value_type with
    | Error _, _ | _, Error _ -> id, None
    | Ok k, Ok v ->
      id, Some (Typed_mich.short_micheline_type k, Typed_mich.short_micheline_type v) in
  List.sort (fun (id1, _) (id2, _) -> compare id1 id2) @@
  List.filter_map (function
      | Big_map { id; diff = SDAlloc {key_type; value_type; _} } ->
        if id < Z.zero then None
        else Some (f id key_type value_type)
      | Big_map { id; diff = SDCopy {source; _} } ->
        List.find_map (function
            | Big_map { id = idc; diff = SDAlloc {key_type; value_type; _} } when source = Z.to_string idc ->
              Some (f id key_type value_type)
            | _ -> None) l
      | _ -> None) l

let get_big_map_id ~allocs bm_index k v =
  let rec aux i = function
    | [] -> None
    | _ :: t when i < bm_index -> aux (i+1) t
    | (id, t) :: _ ->
      match t with
      | Some (k2, v2) when k = k2 && v = v2 -> Some id
      | _ -> None in
  aux 0 allocs

let get_big_map_updates bm l =
  let f l =
    List.filter_map (fun {bm_key; bm_value; _} ->
        match Typed_mich.parse_value bm.bm_types.bmt_key bm_key with
        | Error _ -> None
        | Ok k ->
          match bm_value with
          | None -> Some (k, None)
          | Some value ->
            match Typed_mich.parse_value bm.bm_types.bmt_value value with
            | Error _ -> None
            | Ok v -> Some (k, Some v)) l in
  List.flatten @@
  List.filter_map (function
      | Big_map { id; diff = SDUpdate l }
      | Big_map { id; diff = SDAlloc {updates=l; _} } when id = bm.bm_id ->
        if id < Z.zero then None
        else Some (f l)
      | Big_map { id; diff = SDCopy {source; _} } when id = bm.bm_id ->
        List.find_map (function
            | Big_map { id = idc; diff = SDAlloc {updates=l; _} } when source = Z.to_string idc ->
              Some (f l)
            | _ -> None) l
      | _ -> None) l
