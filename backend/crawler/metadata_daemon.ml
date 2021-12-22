open Let
open Common
open Proto

let contract = ref None
let retrieve  = ref false
let node = ref "https://tz.functori.com"

let spec = [
  "--contract", Arg.String (fun s -> contract := Some s),
  "Only try to reset metadata for this contract";
  "--retrieve-context", Arg.Set retrieve,
  "Retrieve unknown metadata from context";
  "--node", Arg.Set_string node,
  "Node to use to retrieve metadata from context";
]

let expr token_id =
  match Forge.(pack (prim `nat) (Mint token_id)) with
  | Error _ -> None
  | Ok b ->
    Some Tzfunc.Crypto.(Base58.encode ~prefix:Prefix.script_expr_hash @@ Blake2b_32.hash [ b ])

let retrieve_token_metadata ~token_metadata_id ~token_id =
  match expr token_id with
  | None -> Lwt.return None
  | Some hash ->
    let> r = Tzfunc.Node.(
        get_big_map_value_raw ~base:(EzAPI.BASE !node) token_metadata_id hash) in
    match r with
    | Error e ->
      Format.eprintf "Cannot retrieve metadata:\n%s@." (Tzfunc.Rp.string_of_error e);
      Lwt.return None
    | Ok (Bytes _) | Ok (Other _) ->
      Format.eprintf "Wrong token metadata format@.";
      Lwt.return None
    | Ok (Micheline m) ->
      begin match Typed_mich.parse_value Contract_spec.token_metadata_field.Rtypes.bmt_value m with
        | Ok (`tuple [`nat _; `assoc l]) ->
          Lwt.return (Some (Parameters.parse_metadata l))
        | _ ->
          Format.eprintf "Wrong token metadata type@.";
          Lwt.return None
      end

let () =
  Arg.parse spec (fun _ -> ()) "metadata_daemon";
  EzCurl_common.set_timeout (Some 3);
  Lwt_main.run @@ Lwt.map (fun _ -> ()) @@
  let>? () =
    if !retrieve then
      let>? l = Db.empty_token_metadata ?contract:!contract () in
      iter_rp (fun r ->
          match r#token_metadata_id with
          | None -> Lwt.return_ok ()
          | Some id ->
            let token_metadata_id = int_of_string id in
          let> metadata = retrieve_token_metadata ~token_metadata_id
              ~token_id:(Z.of_string r#token_id) in
          match metadata with
          | None -> Lwt.return_ok ()
          | Some l ->
            let metadata = EzEncoding.construct Json_encoding.(assoc string) l in
            Db.update_metadata ~contract:r#contract ~token_id:r#token_id ~block:r#block
              ~level:r#level ~tsp:r#tsp ~metadata ~set_metadata:true ()) l
    else Lwt.return_ok () in
  let>? l = Db.unknown_token_metadata ?contract:!contract () in
  iter_rp (fun r ->
      Db.update_metadata ~contract:r#contract ~token_id:r#token_id ~block:r#block
        ~level:r#level ~tsp:r#tsp ~metadata:r#metadata ?metadata_uri:r#metadata_uri ()) l
