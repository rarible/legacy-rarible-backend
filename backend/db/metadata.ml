open Let
open Rtypes
open Common
open Misc

let to_4_decimals r =
  if r.royalties_decimals <> 4 then
    List.map (fun p ->
        let db =
          Common.Utils.decimal_balance
            ~decimals:(Int32.of_int r.royalties_decimals)
            (Z.of_int32 p.part_value) in
        let ab = Common.Utils.absolute_balance ~decimals:4l db in
        { p with part_value = Z.to_int32 ab })
      r.royalties_shares
  else r.royalties_shares

let parse meta =
  try
    let tzip21_meta = EzEncoding.destruct tzip21_token_metadata_enc meta in
    tzip21_meta.tzip21_tm_name,
    Option.bind tzip21_meta.tzip21_tm_creators
      (fun c -> Some (EzEncoding.construct ext_creators_enc c)),
    tzip21_meta.tzip21_tm_description,
    Option.bind tzip21_meta.tzip21_tm_attributes
      (fun a -> Some (EzEncoding.construct tzip21_attributes_enc a)),
    tzip21_meta.tzip21_tm_display_uri
  with _ ->
    None, None, None, None, None

let get_or_timeout ?(timeout=30.) ?msg url =
  let timeout = Lwt_unix.sleep timeout >>= fun () -> Lwt.return_error (-1, Some "timeout") in
  Lwt.pick [ timeout ; EzReq_lwt.get ?msg url ]

let parse_uri s =
  let proto = try String.sub s 0 6 with _ -> "" in
  if proto = "https:" || proto = "http:/" then Some s
  else if proto = "ipfs:/" then Some s
  else None

let get_json ?(source="https://rarible.mypinata.cloud/") ?(quiet=false) ?timeout meta =
  if not quiet then Format.eprintf "get_metadata_json %s@." meta ;
  let msg = if not quiet then Some "get_metadata_json" else None in
  (* 3 ways to recovers metadata :directly json, ipfs link and http(s) link *)
  try
    Lwt.return_ok (meta, EzEncoding.destruct tzip21_token_metadata_enc meta, None)
  with _ ->
    begin
      let proto = try String.sub meta 0 6 with _ -> "" in
      if proto = "https:" || proto = "http:/" then
        let|>? json = get_or_timeout ?timeout (EzAPI.URL meta) in
        json, meta
      else if proto = "ipfs:/" then
        let url = try String.sub meta 7 ((String.length meta) - 7) with _ -> "" in
        let fs, url = try
            let may_fs = String.sub url 0 5 in
            if may_fs = "ipfs/" then
              "ipfs/", String.sub url 5 ((String.length meta) - 5)
            else if may_fs = "ipns/" then
              "ipns/", String.sub url 5 ((String.length meta) - 5)
            else "ipfs/", url
          with _ -> "", url in
        let uri = Printf.sprintf "%s%s%s" source fs url in
        let|>? json = get_or_timeout ?timeout ?msg (EzAPI.URL uri) in
        json, uri
      else Lwt.return_error (0, Some (Printf.sprintf "unknow scheme %S" proto))
    end >>= function
    | Ok (json, uri) ->
      begin try
          let metadata = EzEncoding.destruct tzip21_token_metadata_enc json in
          Lwt.return_ok (json, metadata, Some uri)
        with exn ->
          Format.eprintf "%s@." @@ Printexc.to_string exn ;
          Lwt.return_error (-1, None)
      end
    | Error (c, str) -> Lwt.return_error (c, str)

let get_contract_metadata ?(source="https://rarible.mypinata.cloud/") ?(quiet=false) ?timeout raw =
  if not quiet then Format.eprintf "get_contract_json %s@." raw ;
  let msg = if not quiet then Some "get_contract_json" else None in
  (* 3 ways to recovers metadata :directly json, ipfs link and http(s) link *)
  try
    Lwt.return_ok (EzEncoding.destruct tzip16_metadata_enc raw)
  with _ ->
    begin
      let proto = try String.sub raw 0 6 with _ -> "" in
      if proto = "https:" || proto = "http:/" then
        let|>? json = get_or_timeout ?timeout (EzAPI.URL raw) in
        json
      else if proto = "ipfs:/" then
        let url = try String.sub raw 7 ((String.length raw) - 7) with _ -> "" in
        let fs, url = try
            let may_fs = String.sub url 0 5 in
            if may_fs = "ipfs/" then
              "ipfs/", String.sub url 5 ((String.length raw) - 5)
            else if may_fs = "ipns/" then
              "ipns/", String.sub url 5 ((String.length raw) - 5)
            else "ipfs/", url
          with _ -> "", url in
        let uri = Printf.sprintf "%s%s%s" source fs url in
        let|>? json = get_or_timeout ?timeout ?msg (EzAPI.URL uri) in
        json
      else Lwt.return_error (0, Some (Printf.sprintf "unknow scheme %S" proto))
    end >>= function
    | Ok json ->
      begin try
          let metadata = EzEncoding.destruct tzip16_metadata_enc json in
          Lwt.return_ok metadata
        with exn ->
          Format.eprintf "%s@." @@ Printexc.to_string exn ;
          Lwt.return_error (-1, None)
      end
    | Error (c, str) -> Lwt.return_error (c, str)

let insert_mint_metadata_creators dbh ?(forward=false) ~contract ~token_id ~block ~level ~tsp metadata =
  match metadata.tzip21_tm_creators with
  | Some (CParts l) ->
    iter_rp (fun p ->
        try
          ignore @@
          Tzfunc.Crypto.(Base58.decode ~prefix:Prefix.contract_public_key_hash p.part_account) ;
          [%pgsql dbh
              "insert into tzip21_creators(contract, token_id, block, level, \
               tsp, account, value, main) \
               values($contract, ${Z.to_string token_id}, $block, $level, $tsp, \
               ${p.part_account}, ${p.part_value}, $forward) \
               on conflict do nothing"]
        with _ -> Lwt.return_ok ())
      l
  | Some (CAssoc l) ->
    iter_rp (fun (part_account, part_value) ->
        try
          ignore @@
          Tzfunc.Crypto.(Base58.decode ~prefix:Prefix.contract_public_key_hash part_account) ;
          [%pgsql dbh
              "insert into tzip21_creators(contract, token_id, block, level, \
               tsp, account, value, main) \
               values($contract, ${Z.to_string token_id}, $block, $level, $tsp, $part_account, \
               $part_value, $forward) \
               on conflict do nothing"]
        with _ -> Lwt.return_ok ())
      l
  | Some (CTZIP12 l) ->
    let len = List.length l in
    if len > 0 then
      let value = Int32.of_int (10000 / len) in
      iter_rp (fun part_account ->
          try
            ignore @@
            Tzfunc.Crypto.(Base58.decode ~prefix:Prefix.contract_public_key_hash part_account) ;
            [%pgsql dbh
                "insert into tzip21_creators(contract, token_id, block, level, \
                 tsp, account, value, main) \
                 values($contract, ${Z.to_string token_id}, $block, $level, $tsp, \
                 $part_account, $value, $forward) \
                 on conflict do nothing"]
          with _ -> Lwt.return_ok ())
        l
    else Lwt.return_ok ()
  | Some (CNull l) ->
    let l = List.filter_map (fun x -> x) l in
    let len = List.length l in
    if len > 0 then
      let value = Int32.of_int (10000 / len) in
      iter_rp (fun part_account ->
          try
            ignore @@
            Tzfunc.Crypto.(Base58.decode ~prefix:Prefix.contract_public_key_hash part_account) ;
            [%pgsql dbh
                "insert into tzip21_creators(contract, token_id, block, level, \
                 tsp, account, value, main) \
                 values($contract, ${Z.to_string token_id}, $block, $level, $tsp, \
                 $part_account, $value, $forward) \
                 on conflict do nothing"]
          with _ -> Lwt.return_ok ())
        l
    else Lwt.return_ok ()
  | None -> Lwt.return_ok ()

let insert_mint_metadata_formats dbh ?(forward=false) ~contract ~token_id ~block ~level ~tsp metadata =
  match metadata.tzip21_tm_formats with
  | Some formats ->
  iter_rp (fun f ->
      let size = Option.bind f.format_file_size (fun i -> Some (Int32.of_int i))  in
      let dim_value, dim_unit =
        match f.format_dimensions with
        | None -> None, None
        | Some d -> Some d.format_dim_value, Some d.format_dim_unit in
      let dr_value, dr_unit =
        match f.format_data_rate with
        | None -> None, None
        | Some d -> Some d.format_dim_value, Some d.format_dim_unit in
      [%pgsql dbh
          "insert into tzip21_formats(contract, token_id, block, level, \
           tsp, uri, hash, mime_type, file_size, file_name, duration, \
           dimensions_value, dimensions_unit, data_rate_value, data_rate_unit, main) \
           values($contract, ${Z.to_string token_id}, $block, $level, $tsp, ${f.format_uri}, \
           $?{f.format_hash}, $?{f.format_mime_type}, $?size, \
           $?{f.format_file_name}, $?{f.format_duration}, $?dim_value, \
           $?dim_unit, $?dr_value, $?dr_unit, $forward) \
           on conflict (uri, contract, token_id) do update set \
           uri = ${f.format_uri}, hash = $?{f.format_hash}, \
           mime_type = $?{f.format_mime_type}, file_size = $?size, \
           file_name = $?{f.format_file_name}, \
           duration = $?{f.format_duration}, \
           dimensions_value = $?dim_value, \
           dimensions_unit = $?dim_unit, \
           data_rate_value = $?dr_value, \
           data_rate_unit = $?dr_unit, \
           main = $forward \
           where tzip21_formats.contract = $contract and \
           tzip21_formats.token_id = ${Z.to_string token_id} and \
           tzip21_formats.uri = ${f.format_uri}"])
    formats
  | None -> Lwt.return_ok ()

let insert_mint_metadata_attributes dbh ?(forward=false) ~contract ~token_id ~block ~level ~tsp metadata =
  match metadata.tzip21_tm_attributes with
  | Some attributes ->
    iter_rp (fun a ->
        let value = Ezjsonm.value_to_string a.attribute_value in
        [%pgsql dbh
            "insert into tzip21_attributes(contract, token_id, block, level, \
             tsp, name, value, type, main) \
             values($contract, ${Z.to_string token_id}, $block, $level, $tsp, \
             ${a.attribute_name}, $value, $?{a.attribute_type}, $forward) \
             on conflict (name, contract, token_id) do update set \
             value = $value, \
             type = $?{a.attribute_type}, \
             main = $forward \
             where tzip21_attributes.contract = $contract and \
             tzip21_attributes.token_id = ${Z.to_string token_id} and \
             tzip21_attributes.name = ${a.attribute_name}"])
      attributes
  | None -> Lwt.return_ok ()

let insert_mint_metadata dbh ?(forward=false) ~contract ~token_id ~block ~level ~tsp metadata =
  let>? () =
    insert_mint_metadata_creators dbh ~forward ~contract ~token_id ~block ~level ~tsp metadata in
  let>? () =
    insert_mint_metadata_formats dbh ~forward ~contract ~token_id ~block ~level ~tsp metadata in
  let>? () =
    insert_mint_metadata_attributes dbh ~forward ~contract ~token_id ~block ~level ~tsp metadata in
  let id = Printf.sprintf "%s:%s" contract (Z.to_string token_id) in
  let name = match metadata.tzip21_tm_name with
    | None -> None
    | Some n -> if Parameters.decode n then Some n else None in
  let symbol = match metadata.tzip21_tm_symbol with
    | None -> None
    | Some n -> if Parameters.decode n then Some n else None in
  let decimals = Option.bind metadata.tzip21_tm_decimals (fun i -> Some (Int32.of_int i))  in
  let artifact_uri = metadata.tzip21_tm_artifact_uri in
  let display_uri = metadata.tzip21_tm_display_uri in
  let thumbnail_uri = metadata.tzip21_tm_thumbnail_uri in
  let description = match metadata.tzip21_tm_description with
    | None -> None
    | Some n -> if Parameters.decode n then Some n else None in
  let minter = metadata.tzip21_tm_minter in
  let is_boolean_amount = metadata.tzip21_tm_is_boolean_amount in
   let tags = match metadata.tzip21_tm_tags with
     | None -> None
     | Some t -> Some (List.map (fun tag ->
         if Parameters.decode tag then
           Option.some tag
         else None) t) in
  let contributors = match metadata.tzip21_tm_contributors with
    | None -> None
    | Some c -> Some (List.map Option.some c) in
  let publishers = match metadata.tzip21_tm_publishers with
    | None -> None
    | Some p -> Some (List.map Option.some p) in
  let date = metadata.tzip21_tm_date in
  let block_level = match metadata.tzip21_tm_block_level with
    | None -> None
    | Some i -> Some (Int32.of_int i) in
  let genres = match metadata.tzip21_tm_genres with
    | None -> None
    | Some g -> Some (List.map Option.some g) in
  let language = metadata.tzip21_tm_language in
  let rights = metadata.tzip21_tm_rights in
  let right_uri = metadata.tzip21_tm_right_uri in
  let is_transferable = metadata.tzip21_tm_is_transferable in
  let should_prefer_symbol = metadata.tzip21_tm_should_prefer_symbol in
  let royalties = match metadata.tzip21_tm_royalties with
    | None -> None
    | Some r -> Some (EzEncoding.construct parts_enc @@ to_4_decimals r) in
  [%pgsql dbh
      "insert into tzip21_metadata(id, contract, token_id, block, level, tsp, \
       name, symbol, decimals, artifact_uri, display_uri, thumbnail_uri, \
       description, minter, is_boolean_amount, tags, contributors, \
       publishers, date, block_level, genres, language, rights, right_uri, \
       is_transferable, should_prefer_symbol, royalties, main) \
       values ($id, $contract, ${Z.to_string token_id}, $block, $level, $tsp, $?name, $?symbol, \
       $?decimals, $?artifact_uri, $?display_uri, $?thumbnail_uri, \
       $?description, $?minter, $?is_boolean_amount, $?tags, $?contributors, \
       $?publishers, $?date, $?block_level, $?genres, $?language, $?rights, \
       $?right_uri, $?is_transferable, $?should_prefer_symbol, $?royalties, $forward) \
       on conflict (id) do update set \
       name = $?name, symbol = $?symbol, decimals = $?decimals, \
       artifact_uri = $?artifact_uri, display_uri = $?display_uri, \
       thumbnail_uri = $?thumbnail_uri, description = $?description, \
       minter = $?minter, is_boolean_amount = $?is_boolean_amount, \
       tags = $?tags, contributors = $?contributors, publishers = $?publishers, \
       date = $?date, block_level = $?block_level, genres = $?genres, \
       language = $?language, rights = $?rights, right_uri = $?right_uri, \
       is_transferable = $?is_transferable, \
       should_prefer_symbol = $?should_prefer_symbol, \
       royalties = $?royalties, \
       main = $forward \
       where tzip21_metadata.id = $id"]

let get_uri_pattern ~dbh contract =
  let>? l =
    [%pgsql dbh
        "select uri_pattern from contracts \
         where main and address = $contract order by level desc"] in
  match l with
  | [] -> Lwt.return_ok None
  | p :: _ -> Lwt.return_ok p

let insert_token_metadata ?forward ~dbh ~block ~level ~tsp ~contract (token_id, l) =
  let>? json, tzip21_meta, uri =
    match List.assoc_opt "" l with
    | Some meta ->
      begin
        get_json meta >>= function
        | Ok (_json, metadata, uri) ->
          Lwt.return_ok (EzEncoding.construct Rtypes.token_metadata_enc l, Some metadata, uri)
        | Error (code, str) ->
          Printf.eprintf "Cannot get metadata from url: %d %s\n%!"
            code (match str with None -> "None" | Some s -> s);
          Lwt.return_ok (EzEncoding.construct Rtypes.token_metadata_enc l, None, None)
      end
    | None ->
      Lwt.return_ok (EzEncoding.construct Rtypes.token_metadata_enc l, None, None) in
  let>? royalties = match tzip21_meta with
    | None -> Lwt.return_ok None
    | Some metadata ->
      let>? () = insert_mint_metadata dbh ?forward ~contract ~token_id ~block ~level ~tsp metadata in
      Lwt.return_ok metadata.tzip21_tm_royalties in
  Lwt.return_ok (json, uri, royalties)

let insert_tzip16_metadata ?(forward=false) ~dbh ~block ~level ~tsp ~contract metadata =
  let name = match metadata.tzip16_name with
    | None -> None
    | Some n -> if Parameters.decode n then Some n else None in
  let description = match metadata.tzip16_description with
    | None -> None
    | Some n -> if Parameters.decode n then Some n else None in
  let version = match metadata.tzip16_version with
    | None -> None
    | Some n -> if Parameters.decode n then Some n else None in
  let license = Ezjsonm.value_to_string metadata.tzip16_license in
  let authors = match metadata.tzip16_authors with
    | None -> None
    | Some l ->
      Some (List.map (fun a -> if Parameters.decode a then Some a else None) l) in
  let homepage = match metadata.tzip16_homepage with
    | None -> None
    | Some n -> if Parameters.decode n then Some n else None in
  let source = Ezjsonm.value_to_string metadata.tzip16_license in
  let interfaces = match metadata.tzip16_interfaces with
    | None -> None
    | Some l ->
      Some (List.map (fun a -> if Parameters.decode a then Some a else None) l) in
  let errors = Ezjsonm.value_to_string metadata.tzip16_license in
  let views = Ezjsonm.value_to_string metadata.tzip16_license in
  [%pgsql dbh
      "insert into tzip16_metadata(contract,block,level,tsp,main,name,\
       description,version,license,authors,homepage,source,interfaces,\
       errors,views) \
       values ($contract,$block,$level,$tsp,$forward,$?name,$?description, \
       $?version, $license,$?authors,$?homepage,$source,$?interfaces,\
       $errors,$views) \
       on conflict (contract) do update set \
       block=$block,level=$level,tsp=$tsp,main=$forward,name=$?name,\
       description=$?description,version=$?version,\
       license=$license,authors=$?authors,\
       homepage=$?homepage,source=$source,\
       interfaces=$?interfaces,errors=$errors,views=$views \
       where tzip16_metadata.contract = $contract"]

let insert_tzip16_metadata ?forward ~dbh ~block ~level ~tsp ~contract value =
  get_contract_metadata value >>= function
  | Ok metadata ->
    insert_tzip16_metadata ~dbh ?forward ~contract ~block ~level ~tsp metadata
  | Error (code, str) ->
    Printf.eprintf "Cannot get metadata from url: %d %s\n%!"
      code (match str with None -> "None" | Some s -> s);
    Lwt.return_ok ()
