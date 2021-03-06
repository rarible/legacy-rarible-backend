open Let
open Common
open Proto

let config = ref None
let contract = ref None
let retrieve  = ref false
let node = ref "https://tz.functori.com"
let force = ref false
let royalties = ref false
let decimals = ref false
let fast = ref false
let fast_levels = ref 10
let kafka_config_file = ref ""

let spec = [
  "--retrieve-context", Arg.Set retrieve,
  "Retrieve unknown metadata from context";
  "--node", Arg.Set_string node,
  "Node to use to retrieve metadata from context";
  "--split-load", Arg.String (fun s -> config := Some s),
  "fetch missing metadata (this uses config to fetch from different sources)";
  "--contract", Arg.String (fun s -> contract := Some s),
  "Update metadata only for this contract";
  "--force", Arg.Set force,
  "Force reset of metadata";
  "--royalties", Arg.Set royalties,
  "Fetch metadata for missing royalties items";
  "--decimals", Arg.Set decimals,
  "Fetch metadata for items with 0 decimals royalties";
  "--fast", Arg.Set fast,
  "Only fetch latest missing metadata";
  "--fast-levels", Arg.Set_int fast_levels,
  "Set the number of metadata handled by fast argument";
  "--kafka-config", Arg.Set_string kafka_config_file, "set kafka configuration"
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
        get_bigmap_value_raw ~base:(EzAPI.BASE source) token_metadata_id hash) in
    match r with
    | Error e ->
      Format.eprintf "Cannot retrieve metadata:\n%s@." (Tzfunc.Rp.string_of_error e);
      Lwt.return None
    | Ok None ->
      Format.eprintf "Wrong token metadata format@.";
      Lwt.return None
    | Ok (Some m) ->
      match Mtyped.parse_value Contract_spec.token_metadata_field.Rtypes.bmt_value m with
      | Ok (`tuple [`nat _; `assoc l]) ->
        Lwt.return (Some (Parameters.parse_metadata l))
      | _ ->
        Format.eprintf "Wrong token metadata type@.";
        Lwt.return None

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
  Lwt_main.run @@ Lwt.map (Result.iter_error Crp.print_error) @@
  let>? () = Db.Rarible_kafka.may_set_kafka_config !kafka_config_file in
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
                 let token_metadata_id = Z.of_string id in
                 let> metadata =
                   retrieve_token_metadata
                     ~source ~token_metadata_id ~token_id:(Z.of_string r#token_id) in
                 match metadata with
                 | None -> Lwt.return_ok ()
                 | Some l ->
                   let metadata = EzEncoding.construct Json_encoding.(assoc any_ezjson_value) l in
                   Db.Utils.update_metadata ~contract:r#contract ~token_id:r#token_id ~block:r#block
                     ~level:r#level ~tsp:r#tsp ~metadata ~set_metadata:true ()) l)
      else
        config.daemon_ipfs_sources,
        Db.Utils.fetch_metadata_from_source
          ~verbose:0 ~timeout:(float_of_int config.daemon_timeout) in
    let>? l =
      match !force, !contract, !retrieve, !decimals with
      | true, Some contract, _, _ ->
        let levels = if !fast then Some !fast_levels else None in
        Db.Utils.contract_token_metadata ~royalties:!royalties ?levels contract
      | _, _, true, _ -> Db.Utils.empty_token_metadata ?contract:!contract ()
      | true, _, _, true -> Db.Utils.decimals_0_token_metadata ()
      | true, None, false, false ->
        if !royalties then Db.Utils.no_royalties_token_metadata ()
        else Lwt.return_ok []
      | _ ->
        let levels = if !fast then Some !fast_levels else None in
        Db.Utils.unknown_token_metadata ?contract:!contract ?levels () in
    split l sources f
  | None ->
    if !retrieve then
      let>? l = match !force, !contract with
        | true, Some contract -> Db.Utils.contract_token_metadata ~royalties:!royalties contract
        | _ -> Db.Utils.empty_token_metadata ?contract:!contract () in
      Format.printf "Retrieving %d token metadata from context@." (List.length l);
      iter_rp (fun r ->
          match r#token_metadata_id with
          | None -> Lwt.return_ok ()
          | Some id ->
            let token_metadata_id = Z.of_string id in
            let> metadata =
              retrieve_token_metadata
                ~source:!node ~token_metadata_id ~token_id:(Z.of_string r#token_id) in
            match metadata with
            | None -> Lwt.return_ok ()
            | Some l ->
              let metadata = EzEncoding.construct Json_encoding.(assoc any_ezjson_value) l in
              Db.Utils.update_metadata ~contract:r#contract ~token_id:r#token_id ~block:r#block
                ~level:r#level ~tsp:r#tsp ~metadata ~set_metadata:true ()) l
    else
      let>? l = match !force, !contract, !decimals with
        | true, Some contract, _ ->
          let levels = if !fast then Some !fast_levels else None in
          Db.Utils.contract_token_metadata ~royalties:!royalties ?levels contract
        | true, _, true -> Db.Utils.decimals_0_token_metadata ()
        | true, None, false ->
          if !royalties then Db.Utils.no_royalties_token_metadata ()
          else Lwt.return_ok []
        | _ ->
          let levels = if !fast then Some !fast_levels else None in
          Db.Utils.unknown_token_metadata ?contract:!contract ?levels () in
      Format.printf "Getting %d token metadata from given uri@." (List.length l);
      iter_rp (fun r ->
          Db.Utils.update_metadata ~contract:r#contract ~token_id:r#token_id ~block:r#block
            ~level:r#level ~tsp:r#tsp ~metadata:r#metadata ?metadata_uri:r#metadata_uri ()) l
