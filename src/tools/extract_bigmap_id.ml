open Tzfunc
open Common
open Proto
open Let

type bm_kind = [ `token | `contract | `royalties ]

let node = ref "https://tz.functori.com"
let contracts = ref None
let kind = ref `token

let kind_of_string = function
  | "token" -> `token
  | "contract" -> `contract
  | "royalties" -> `royalties
  | _ -> failwith "unknown kind"

let get contract =
  let> account = Node.get_account_info ~base:(EzAPI.BASE !node) contract in
  match account with
  | Error e ->
    Format.printf "%s@." (Rp.string_of_error e);
    Format.printf "contract %s not found@." contract;
    Lwt.return_ok None
  | Ok account ->
    match account.ac_script with
    | None ->
      Format.printf "%s is not a contract@." contract;
      Lwt.return_ok None
    | Some script ->
      match Contract_spec.get_storage_fields script,
            Contract_spec.get_code_elt `storage script.code with
      | Error _, _ | _, None ->
        Format.printf "wrong storage kind for %s@." contract;
        Lwt.return_ok None
      | Ok fields, Some storage_type ->
        let>? storage_type = Lwt.return @@ Mtyped.parse_type storage_type in
        let|>? storage_value = Lwt.return @@ Mtyped.(parse_value (short storage_type) script.storage) in
        let name = match !kind with
          | `token -> "token_metadata"
          | `contract -> "metadata"
          | `royalties -> "royalties" in
        match List.assoc_opt name fields with
        | None -> None
        | Some _ ->
          Mtyped.search_value ~name storage_type storage_value

let spec = [
  "--contracts", Arg.String (fun s ->
      contracts := Some (String.split_on_char ',' s)),
  "Contracts to retrieve metadata id (separated by ',')";
  "--node", Arg.Set_string node, "Node address";
  "--kind", Arg.String (fun s -> kind := kind_of_string s),
  "Kind of metadata ID to get ('token', 'contract', 'royalties')"
]

let () =
  Arg.parse spec (fun _ -> ()) "extract_bigmap_id";
  Lwt_main.run @@
  Lwt.map (function
      | Error _ -> Format.printf "Error@."
      | Ok _ -> ()) @@
  let>? contracts = match !contracts with
    | None -> Db.Utils.get_unknown_bm_id ~kind:!kind ()
    | Some contracts -> Lwt.return_ok contracts in
  iter_rp (fun contract ->
      Format.printf "contract %s@." contract;
      let> o = get contract in
      match o with
      | Ok (Some (`nat id)) -> Db.Utils.set_bm_id ~contract ~kind:!kind id
      | _ ->
        Format.printf "No value@.";
        Lwt.return_ok ()) contracts
