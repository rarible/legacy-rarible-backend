open Let
open Common
open Proto

let node = ref "https://tz.functori.com"
let retrieve = ref false

let spec = [
  "--node", Arg.Set_string node,
  "Node to use to retrieve contract metadata from context";
  "--retrieve", Arg.Set retrieve,
  "Use the context to look for ipfs link";
]

let expr key =
  match Forge.(pack (prim `string) (Mstring key)) with
  | Error _ -> None
  | Ok b ->
    Some Tzfunc.Crypto.(Base58.encode ~prefix:Prefix.script_expr_hash @@ Blake2b_32.hash [ b ])

let retrieve_contract_metadata ~source ~metadata_id =
  match expr "" with
  | None -> Lwt.return None
  | Some hash ->
    let> r = Tzfunc.Node.(
        get_bigmap_value_raw ~base:(EzAPI.BASE source) metadata_id hash) in
    match r with
    | Error e ->
      Format.eprintf "Cannot retrieve metadata:\n%s@." (Tzfunc.Rp.string_of_error e);
      Lwt.return None
    | Ok None | Ok (Some (Bytes _)) | Ok (Some (Other _)) ->
      Format.eprintf "Wrong metadata format@.";
      Lwt.return None
    | Ok ((Some Micheline m)) ->
      match Typed_mich.parse_value Contract_spec.metadata_field.Rtypes.bmt_value m with
      | Ok (`bytes v) ->
        let s = (Tzfunc.Crypto.hex_to_raw v :> string) in
        if Parameters.decode s then Lwt.return @@ Some s
        else Lwt.return None
      | _ ->
        Format.eprintf "Wrong metadata type@.";
        Lwt.return None

let usage =
  "usage: " ^ Sys.argv.(0) ^ " [--force]"

let () =
  Arg.parse spec (fun _ -> ()) usage;
  EzCurl_common.set_timeout (Some 3);
  Lwt_main.run @@ Lwt.map (Result.iter_error Crp.print_error) @@
  let>? l = Db.Utils.contract_metadata ~retrieve:!retrieve () in
  iter_rp (fun r ->
      let>? metadata_uri =
        if not !retrieve then
          let l = EzEncoding.destruct Json_encoding.(assoc string) r#metadata in
          Lwt.return_ok @@ begin match List.assoc_opt "" l with
            | None -> None
            | Some uri -> Some uri
          end
        else
          match r#metadata_id with
          | None -> Lwt.return_ok None
          | Some id ->
            let metadata_id = Z.of_string id in
            let> m = retrieve_contract_metadata ~source:!node ~metadata_id:metadata_id in
            Lwt.return_ok m in
      Db.Utils.update_contract_metadata
        ~set_metadata:!retrieve ~contract:r#address ~block:r#block
        ~level:r#level ~tsp:r#tsp ~metadata:r#metadata ?metadata_uri:metadata_uri ()) l
