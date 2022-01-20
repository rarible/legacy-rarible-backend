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

let spec = [
  "--issuer", Arg.Set_string issuer, "set fxhash issuer";
  "--issuer-bigmap", Arg.String (fun s -> issuer_bigmap := Z.of_string s), "set fxhash issuer bigmap";
  "--collection", Arg.Set_string collection, "set collection";
  "--collection-bigmap", Arg.String (fun s -> bigmap := Z.of_string s), "set bigmap";
  "--kind", Arg.Set_string kind, "kind of royalties (versum, fxhash)";
  "--node", Arg.Set_string node, "tezos node to use";
]

let versum () =
  let typ = Common.Contract_spec.versum_royalties_field.bmt_value in
  let>? ids = Db.Utils.collection_items !collection in
  iter_rp (fun id ->
      Format.printf "%s %s@." !issuer id;
      let> r = Node.(get_bigmap_value ~typ:(prim `nat) !bigmap (Proto.Mint (Z.of_string id))) in
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
            let royalties = EzEncoding.construct parts_enc l in
            use None @@ fun dbh ->
            [%pgsql dbh
                "update token_info set royalties = $royalties where \
                 contract = ${!collection} and token_id = $id"]
          | _ ->
            Lwt.return_ok ()
        end
      | Error e ->
        Rp.print_error e;
        Lwt.return_ok ()
      | Ok _ -> Lwt.return_ok ()) ids

let fxhash () =
  if !issuer = "" || !issuer_bigmap = Z.zero then (
    Format.printf "Missing issuer or issuer-bigmap argument@.";
    exit 1)
  else
    let data_typ = Common.Contract_spec.fxhash_data_field.bmt_value in
    let issuer_typ = Common.Contract_spec.fxhash_issuer_field.bmt_value in
    let>? ids = Db.Utils.collection_items !collection in
    iter_rp (fun id ->
        Format.printf "%s %s@." !issuer id;
        let> r = Node.(get_bigmap_value ~typ:(prim `nat) !bigmap (Proto.Mint (Z.of_string id))) in
        match r with
        | Ok (Some (Micheline m)) ->
          begin match Mtyped.parse_value data_typ m with
            | Ok (`tuple [ `tuple [_; `nat issuer_id ]; _; _ ]) ->
              let> r = Node.(get_bigmap_value ~typ:(prim `nat) !issuer_bigmap (Proto.Mint issuer_id)) in
              begin match r with
                | Ok (Some (Micheline m)) ->
                  begin match Mtyped.parse_value issuer_typ m with
                    | Ok (`tuple [`tuple [ `tuple [ `address part_account; _ ]; _; _; _ ]; _; `nat pct; _; _ ]) ->
                      let royalties = EzEncoding.construct parts_enc [ {
                          part_account; part_value = Z.(to_int32 @@ pct * ~$10) } ] in
                      use None @@ fun dbh ->
                      [%pgsql dbh
                          "update token_info set royalties = $royalties where \
                           contract = ${!collection} and token_id = $id"]
                    | _ -> Lwt.return_ok ()
                  end
                | _ -> Lwt.return_ok ()
              end
            | _ -> Lwt.return_ok ()
          end
        | Error e ->
          Rp.print_error e;
          Lwt.return_ok ()
        | Ok _ -> Lwt.return_ok ()) ids

let () =
  Arg.parse spec (fun _ -> ()) "fetch_off_royalties.exe [OPTIONS]";
  Node.set_node !node;
  if !collection = "" || !issuer = "" || !bigmap = Z.zero || !kind = "" then (
    Format.printf "Missing collection or collection-bigmap argument@.";
    exit 1);
  let main () =
    if !kind = "versum" then versum ()
    else if !kind = "fxhash" then fxhash ()
    else (
      Format.printf "Unknown kind@.";
      exit 1) in
  Lwt_main.run (Lwt.map (Result.iter_error Crawlori.Rp.print_error) @@ main ())
