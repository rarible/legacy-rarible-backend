open Let

let node = ref "https://tz.functori.com"
let retrieve = ref false

let spec = [
  "--node", Arg.Set_string node,
  "Node to use to retrieve contract metadata from context";
  "--retrieve", Arg.Set retrieve,
  "Use the context to look for ipfs link";
]

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
          Lwt.return_ok @@ List.assoc_opt "" l
        else
          match r#metadata_id with
          | None -> Lwt.return_ok None
          | Some id ->
            let metadata_id = Z.of_string id in
            let> m = Db.Utils.retrieve_contract_metadata ~source:!node ~metadata_id:metadata_id "" in
            Lwt.return_ok m in
      Db.Utils.update_contract_metadata
        ~source:!node ?metadata_id:r#metadata_id
        ~set_metadata:!retrieve ~contract:r#address ~block:r#block
        ~level:r#level ~tsp:r#tsp ~metadata:r#metadata ?metadata_uri:metadata_uri ()) l
