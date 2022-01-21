open Let
open Tzfunc
open Proto
open Rtypes
open Db.Misc

let collection = ref ""
let issuer = ref ""
let node = ref "https://tz.functori.com"
let bigmap = ref Z.zero
let issuer_bigmap = ref Z.zero
let kind = ref ""
let step = ref 10000L

let spec = [
  "--issuer", Arg.Set_string issuer, "set fxhash issuer";
  "--issuer-bigmap", Arg.String (fun s -> issuer_bigmap := Z.of_string s), "set fxhash issuer bigmap";
  "--collection", Arg.Set_string collection, "set collection";
  "--collection-bigmap", Arg.String (fun s -> bigmap := Z.of_string s), "set bigmap";
  "--kind", Arg.Set_string kind, "kind of royalties (versum, fxhash)";
  "--node", Arg.Set_string node, "tezos node to use";
  "--step", Arg.Int (fun i -> step := Int64.of_int i), "steps";
]

let update_royalties id royalties =
  use None @@ fun dbh ->
  [%pgsql dbh
      "update token_info set royalties = $royalties where \
       contract = ${!collection} and token_id = $id"]

let print_result r =
  begin match r with
    | Error e -> Rp.print_error e
    | Ok _ -> ()
  end;
  None

let iter_ids f =
  let>? n = Db.Utils.collection_items_count !collection in
  let m = Int64.div n !step in
  iter_rp (fun i ->
      let offset = Int64.mul !step i in
      let>? ids = Db.Utils.collection_items ~offset ~limit:!step !collection in
      iter_rp (fun id ->
          Format.printf "%s %s@." !collection id;
          let> o = f id in
          match o with
          | None -> Lwt.return_ok ()
          | Some royalties -> update_royalties id royalties) ids) @@
  List.init Int64.(to_int @@ succ m) Int64.of_int

let get_hen id =
  let|> r = Node.(get_bigmap_value ~typ:(prim `nat) !bigmap (Mint (Z.of_string id))) in
  match r with
  | Ok (Some (Micheline (Mprim {prim = `Pair; args = [Mstring part_account; Mint v]; _}))) ->
    Some (
      EzEncoding.construct parts_enc [ {
          part_account; part_value = Z.(to_int32 @@ v * ~$10) } ])
  | r -> print_result r

let get_rarible id =
  let|> r = Node.(get_bigmap_value ~typ:(prim `nat) !bigmap (Mint (Z.of_string id))) in
  match r with
  | Ok (Some (Micheline (Mseq l))) ->
    let l = List.filter_map (function
        | Mprim {prim = `Pair; args = [Mstring part_account; Mint v]; _} ->
          Some { part_account; part_value = Z.to_int32 v }
        | _ -> None) l in
    Some (EzEncoding.construct parts_enc l)
  | r -> print_result r

let get_versum id =
  let typ = Common.Contract_spec.versum_royalties_field.bmt_value in
  let|> r = Node.(get_bigmap_value ~typ:(prim `nat) !bigmap (Proto.Mint (Z.of_string id))) in
  match r with
  | Ok (Some (Micheline m)) ->
    begin match Mtyped.parse_value typ m with
      | Ok (`tuple [ _; _; _; `nat royalty; `seq l ]) ->
        let l = List.filter_map (function
            | `tuple [ `address part_account; `nat pct ] ->
              Some {
                part_account;
                part_value = Z.(to_int32 @@ royalty * pct / ~$100) }
            | _ -> None) l in
        Some (EzEncoding.construct parts_enc l)
      | r -> print_result r
    end
  | r -> print_result r

let get_fxhash id =
  if (!issuer="" || !issuer_bigmap = Z.zero) then (
    Format.printf "Missing issuer or issuer-bigmap or kind argument@.";
    exit 1)
  else
    let data_typ = Common.Contract_spec.fxhash_data_field.bmt_value in
    let issuer_typ = Common.Contract_spec.fxhash_issuer_field.bmt_value in
    let> r = Node.(get_bigmap_value ~typ:(prim `nat) !bigmap (Proto.Mint (Z.of_string id))) in
    match r with
    | Ok (Some (Micheline m)) ->
      begin match Mtyped.parse_value data_typ m with
        | Ok (`tuple [ `tuple [_; `nat issuer_id ]; _; _ ]) ->
          let|> r = Node.(get_bigmap_value ~typ:(prim `nat) !issuer_bigmap (Proto.Mint issuer_id)) in
          begin match r with
            | Ok (Some (Micheline m)) ->
              begin match Mtyped.parse_value issuer_typ m with
                | Ok (`tuple [`tuple [ `tuple [ `address part_account; _ ]; _; _; _ ]; _; `nat pct; _; _ ]) ->
                  Some (EzEncoding.construct parts_enc [ {
                      part_account; part_value = Z.(to_int32 @@ pct * ~$10) } ])
                | r -> print_result r
              end
            | r -> print_result r
          end
        | r -> Lwt.return @@ print_result r
      end
    | r -> Lwt.return @@ print_result r

let () =
  Arg.parse spec (fun _ -> ()) "fetch_off_royalties.exe [OPTIONS]";
  Node.set_node !node;
  if !collection = "" || !bigmap = Z.zero || !kind = "" then (
    Format.printf "Missing collection or collection-bigmap or kind argument@.";
    exit 1);
  let main () =
    if !kind = "versum" then iter_ids get_versum
    else if !kind = "fxhash" then iter_ids get_fxhash
    else if !kind = "hen" then iter_ids get_hen
    else if !kind = "rarible" then iter_ids get_rarible
    else (
      Format.printf "Unknown kind %S@." !kind;
      exit 1) in
  Lwt_main.run (Lwt.map (Result.iter_error Crawlori.Rp.print_error) @@ main ())
