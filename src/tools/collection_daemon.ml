open Let

let node = ref "https://tz.functori.com"
let retrieve = ref false
let name = ref false
let kafka_config_file = ref ""
let contract = ref ""

let spec = [
  "--node", Arg.Set_string node,
  "Node to use to retrieve contract metadata from context";
  "--retrieve", Arg.Set retrieve,
  "Use the context to look for ipfs link";
  "--name-symbol", Arg.Set name,
  "Retrieve name and symbol fields from metadata bigmap";
  "--contract", Arg.Set_string contract, "Retrieve metadata for a contract";
  "--kafka-config", Arg.Set_string kafka_config_file, "set kafka configuration"
]

let usage =
  "usage: " ^ Sys.argv.(0) ^ " [options]"

let () =
  Arg.parse spec (fun _ -> ()) usage;
  EzCurl_common.set_timeout (Some 3);
  Lwt_main.run @@ Lwt.map (Result.iter_error Crp.print_error) @@
  let>? () = Db.Rarible_kafka.may_set_kafka_config !kafka_config_file in
  if !name then
    let>? l = Db.Utils.contract_metadata_no_name () in
    iter_rp (fun r ->
        let>? name, symbol =
          match r#metadata_id with
          | None -> Lwt.return_ok (None, None)
          | Some id ->
            let metadata_id = Z.of_string id in
            let> n =
              Db.Utils.retrieve_contract_metadata ~source:!node ~metadata_id:metadata_id "name" in
            let> s =
              Db.Utils.retrieve_contract_metadata ~source:!node ~metadata_id:metadata_id "symbol" in
            Lwt.return_ok (n, s) in
        let>? () = match name with
          | None -> Lwt.return_ok ()
          | Some n ->
            Db.Utils.update_contract_metadata_name
              ~contract:r#address ~block:r#block
              ~level:r#level ~tsp:r#tsp ~metadata:r#metadata n in
        match symbol with
        | None -> Lwt.return_ok ()
        | Some s ->
          Db.Utils.update_contract_metadata_symbol
            ~contract:r#address ~metadata:r#metadata s) l
  else
    let>? l =
      if !contract <> "" then Db.Utils.metadata !contract
      else Db.Utils.contract_metadata ~retrieve:!retrieve () in
    iter_rp (fun r ->
        let>? metadata_uri =
          if not !retrieve then
            let l = EzEncoding.destruct Json_encoding.(assoc any_ezjson_value) r#metadata in
            match List.assoc_opt "" l with
            | Some (`String uri) -> Lwt.return_ok @@ Some uri
            | _ -> Lwt.return_ok None
          else
            match r#metadata_id with
            | None -> Lwt.return_ok None
            | Some id ->
              let metadata_id = Z.of_string id in
              let> m =
                Db.Utils.retrieve_contract_metadata ~source:!node ~metadata_id:metadata_id "" in
              Lwt.return_ok m in
        Db.Utils.update_contract_metadata
          ~source:!node ?metadata_id:r#metadata_id
          ~set_metadata:!retrieve ~contract:r#address ~block:r#block
          ~level:r#level ~tsp:r#tsp ~metadata:r#metadata ?metadata_uri:metadata_uri ()) l
