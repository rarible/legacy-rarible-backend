open Let
open Common
open Proto

let config = ref None
let contract = ref None
let retrieve  = ref false
let node = ref "https://tz.functori.com"

let spec = [
  "--retrieve-context", Arg.Set retrieve,
  "Retrieve unknown metadata from context";
  "--node", Arg.Set_string node,
  "Node to use to retrieve metadata from context";
  "--split-load", Arg.String (fun s -> config := Some s),
  "fetch missing metadata (this uses config to fetch from different sources)";
]

let expr token_id =
  match Forge.(pack (prim `nat) (Mint token_id)) with
  | Error _ -> None
  | Ok b ->
    Some Tzfunc.Crypto.(Base58.encode ~prefix:Prefix.script_expr_hash @@ Blake2b_32.hash [ b ])

let retrieve_token_metadata ~source ~token_metadata_id ~token_id =
  match expr token_id with
  | None -> Lwt.return None
  | Some hash ->
    let> r = Tzfunc.Node.(
        get_big_map_value_raw ~base:(EzAPI.BASE source) token_metadata_id hash) in
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

let split l sources f =
  Format.eprintf "split %d item(s) from %d source(s) @."
    (List.length l) (List.length sources) ;
  let> agg = match sources with
    | [] -> Format.eprintf "empty sources@." ; Lwt.return []
    | [ source ] -> Lwt.return [ source, l ]
    | sources ->
      let init = List.map (fun s -> s, []) sources in
      let len = List.length sources in
      Lwt.return @@
      snd @@
      List.fold_left (fun (cpt, acc) r ->
          let i = cpt mod len in
          let s, old = List.nth acc i in
          (cpt + 1), (s, (r :: old)) :: (List.remove_assoc s acc))
        (0, init) l in
  let ps = List.map (fun (source, l) ->
      f ~source l >>= function
      | Ok _ -> Lwt.return_unit
      | Error err ->
        Format.eprintf "%s@." @@ Crp.string_of_error err ;
        Lwt.return_unit) agg in
  Lwt.join ps >>= fun () ->
  Lwt.return_ok ()

let usage =
  "usage: " ^ Sys.argv.(0) ^ " [--retrieve-context] [--split-load conf.json]"

let () =
  Arg.parse spec (fun _ -> ()) usage;
  EzCurl_common.set_timeout (Some 3);
  Lwt_main.run @@ Lwt.map (fun _ -> ()) @@
  let>? () =
    match !config with
    | Some c ->
      let open Rtypes in
      let ic = open_in c in
      let s = really_input_string ic (in_channel_length ic) in
      close_in ic ;
      let config = EzEncoding.destruct Rtypes.daemon_config_enc s in
      let sources, f =
        if !retrieve then
          config.daemon_nodes,
          (fun ~source l ->
             iter_rp (fun r ->
                 match r#token_metadata_id with
                 | None -> Lwt.return_ok ()
                 | Some id ->
                   let token_metadata_id = int_of_string id in
                   let> metadata =
                     retrieve_token_metadata
                       ~source ~token_metadata_id ~token_id:(Z.of_string r#token_id) in
                   match metadata with
                   | None -> Lwt.return_ok ()
                   | Some l ->
                     let metadata = EzEncoding.construct Json_encoding.(assoc string) l in
                     Db.update_metadata ~contract:r#contract ~token_id:r#token_id ~block:r#block
                       ~level:r#level ~tsp:r#tsp ~metadata ~set_metadata:true ()) l)
        else
          config.daemon_ipfs_sources,
          Db.fetch_metadata_from_source ~verbose:0 ~timeout:(float_of_int config.daemon_timeout) in
      let>? l =
        if !retrieve then
          Db.empty_token_metadata ?contract:!contract ()
        else
          Db.unknown_token_metadata ?contract:!contract () in
      split l sources f
    | None ->
      if !retrieve then
        let>? l = Db.empty_token_metadata ?contract:!contract () in
        iter_rp (fun r ->
            match r#token_metadata_id with
            | None -> Lwt.return_ok ()
            | Some id ->
              let token_metadata_id = int_of_string id in
              let> metadata =
                retrieve_token_metadata
                  ~source:!node ~token_metadata_id ~token_id:(Z.of_string r#token_id) in
              match metadata with
              | None -> Lwt.return_ok ()
              | Some l ->
                let metadata = EzEncoding.construct Json_encoding.(assoc string) l in
                Db.update_metadata ~contract:r#contract ~token_id:r#token_id ~block:r#block
                  ~level:r#level ~tsp:r#tsp ~metadata ~set_metadata:true ()) l
      else
        let>? l = Db.unknown_token_metadata ?contract:!contract () in
        iter_rp (fun r ->
            Db.update_metadata ~contract:r#contract ~token_id:r#token_id ~block:r#block
              ~level:r#level ~tsp:r#tsp ~metadata:r#metadata ?metadata_uri:r#metadata_uri ()) l in
  Lwt.return_ok ()
