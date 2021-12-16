open Tzfunc
open Common
open Proto
open Let

let node = ref "https://hangzhou.tz.functori.com"
let contracts = ref None
let kind = ref "token"

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
      match script.storage, Contract_spec.get_storage_fields script,
            Contract_spec.get_code_elt `storage script.code with
      | Bytes _, _, _ | Other _, _, _ | _, Error _, _ | _, _, None ->
        Format.printf "wrong storage kind for %s@." contract;
        Lwt.return_ok None
      | Micheline storage_value, Ok fields, Some storage_type ->
        let>? storage_type = Lwt.return @@ Typed_mich.parse_type storage_type in
        let|>? storage_value = Lwt.return @@ Typed_mich.(parse_value (short_micheline_type storage_type) storage_value) in
        let name = if !kind = "token" then "token_metadata" else "metadata" in
        match List.assoc_opt name fields with
        | None -> None
        | Some _ ->
          Typed_mich.search_value ~name storage_type storage_value

let spec = [
  "--contracts", Arg.String (fun s ->
      contracts := Some (String.split_on_char ',' s)),
  "Contracts to retrieve metadata id (separated by ',')";
  "--node", Arg.Set_string node, "Node address";
  "--kind", Arg.Set_string kind, "Kind of metadata ID to get ('token' or 'contract')"
]

let () =
  Arg.parse spec (fun _ -> ()) "extract_metadata_id";
  Lwt_main.run @@
  Lwt.map (function
      | Error _ -> Format.printf "Error@."
      | Ok _ -> ()) @@
  let>? contracts = match !contracts with
    | None ->
      if !kind = "token" then Db.get_unknown_token_metadata_id ()
      else if !kind = "contract" then Db.get_unknown_metadata_id ()
      else Lwt.return_ok []
    | Some contracts -> Lwt.return_ok contracts in
  iter_rp (fun contract ->
      Format.printf "contract %s@." contract;
      let> o = get contract in
      match o with
      | Ok (Some (`nat id)) ->
        if !kind = "token" then Db.set_token_metadata_id ~contract id
        else if !kind = "contract" then Db.set_metadata_id ~contract id
        else Lwt.return_ok ()
      | _ ->
        Format.printf "No value@.";
        Lwt.return_ok ()) contracts
