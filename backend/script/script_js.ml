open Script_types

let node = ref "node"
let script = ref "sdk/dist/main/script.js"

let deploy_collection ?endpoint c =
  let endpoint = match endpoint with None -> [] | Some e -> ["--endpoint"; e] in
  let cmd = Filename.quote_command !node @@
    [ !script; "deploy_nft"; "--owner"; c.col_admin.tz1; "--edsk"; c.col_admin.edsk ] @
    endpoint in
  Script.command_result ~f:(fun l -> List.hd @@ List.rev l) cmd

let deploy_royalties ?endpoint source =
  let endpoint = match endpoint with None -> [] | Some e -> ["--endpoint"; e] in
  let cmd = Filename.quote_command !node @@
    [ !script; "deploy_royalties"; "--owner"; source.tz1;
      "--edsk"; source.edsk ] @
    endpoint in
  Script.command_result ~f:(fun l -> List.hd @@ List.rev l) cmd

let mint_tokens ?endpoint c it =
  let supply = match it.it_kind with `nft -> [] | `mt a -> [ "--amount"; Int64.to_string a ] in
  let royalties = Format.sprintf "{%s}" @@ String.concat "," @@
    List.map (fun (account, value) -> Format.sprintf "%S: %Ld" account value) it.it_royalties in
  let endpoint = match endpoint with None -> [] | Some e -> ["--endpoint"; e] in
  let cmd = Filename.quote_command !node @@
    [ !script; "mint"; "--contract"; it.it_collection; "--royalties"; royalties;
      "--token_id"; Int64.to_string it.it_token_id; "--edsk"; c.col_admin.edsk;
      "--owner"; it.it_owner.tz1;
      "--metadata" ; EzEncoding.construct Json_encoding.(assoc string) it.it_metadata ]
    @ supply @ endpoint in
  try
    let _ = Script.command_result cmd in
    Lwt.return_unit
  with _ -> Lwt.fail_with "mint failure"

let burn_tokens ?endpoint it kind =
  let endpoint = match endpoint with None -> [] | Some e -> ["--endpoint"; e] in
  let amount = match kind with `nft -> [] | `mt a -> [ "--amount"; Int64.to_string a ] in
  let cmd = Filename.quote_command !node @@
    [ !script; "burn"; "--contract"; it.it_collection;
      "--token_id"; Int64.to_string it.it_token_id; "--edsk"; it.it_owner.edsk ]
    @ amount @ endpoint in
  try
    let _ = Script.command_result cmd in
    Lwt.return_unit
  with _ -> Lwt.fail_with "burn failure"

let transfer_tokens ?endpoint it ~amount destination =
  let endpoint = match endpoint with None -> [] | Some e -> ["--endpoint"; e] in
  let cmd = Filename.quote_command !node @@
    [ !script; "transfer"; "--contract"; it.it_collection;
      "--amount"; Int64.to_string amount; "--token_id";
      Int64.to_string it.it_token_id; "--edsk"; it.it_owner.edsk; "--to"; destination.tz1 ]
    @ endpoint in
  try
    let _ = Script.command_result cmd in
    Lwt.return_unit
  with _ -> Lwt.fail_with "transfer failure"

let set_token_metadata ?endpoint it =
  let endpoint = match endpoint with None -> [] | Some e -> ["--endpoint"; e] in
  let metadata = Format.sprintf "{%s}" @@ String.concat ", " @@ List.map (fun (k, v) ->
      Format.sprintf "%S: %S" k v) it.it_metadata in
  let cmd = Filename.quote_command !node @@
    [ !script; "set_token_metadata"; "--contract"; it.it_collection;
      "--token_id"; Int64.to_string it.it_token_id; "--edsk"; it.it_owner.edsk; "--metadata"; metadata ]
    @ endpoint in
  try
    let _ = Script.command_result cmd in
    Lwt.return_unit
  with _ -> Lwt.fail_with "set token metadata failure"

let set_metadata ?endpoint c =
  let endpoint = match endpoint with None -> [] | Some e -> ["--endpoint"; e] in
  let cmd = Filename.quote_command !node @@
    [ !script; "set_metadata"; "--contract"; c.col_kt1;
      "--edsk"; c.col_admin.edsk; "--metadata_key"; ""; "--metadata_value"; c.col_metadata ]
    @ endpoint in
  try
    let _ = Script.command_result cmd in
    Lwt.return_unit
  with _ -> Lwt.fail_with "set metadata uri failure"

let deploy_validator ?endpoint ~exchange ~royalties source =
  let endpoint = match endpoint with None -> [] | Some e -> ["--endpoint"; e] in
  let cmd = Filename.quote_command !node @@
    [ !script; "deploy_validator"; "--exchange"; exchange;
      "--edsk"; source.edsk; "--royalties_contract"; royalties ] @
    endpoint in
  Script.command_result ~f:(fun l -> List.hd @@ List.rev l) cmd

let deploy_exchange ?endpoint ~admin ~receiver ~fee source =
  let endpoint = match endpoint with None -> [] | Some e -> ["--endpoint"; e] in
  let cmd = Filename.quote_command !node @@
    [ !script; "deploy_exchange"; "--edsk"; source.edsk; "--owner"; admin.tz1;
      "--receiver"; receiver.tz1; "--fee"; Int64.to_string fee ] @
    endpoint in
  Script.command_result ~f:(fun l -> List.hd @@ List.rev l) cmd

let set_validator ?endpoint ~source ~contract validator =
  let endpoint = match endpoint with None -> [] | Some e -> ["--endpoint"; e] in
  let cmd = Filename.quote_command !node @@
    [ !script; "set_validator"; "--contract"; contract;
      "--edsk"; source.edsk; "--validator"; validator ]
    @ endpoint in
  try
    let _ = Script.command_result cmd in
    Lwt.return_unit
  with _ -> Lwt.fail_with "set validator failure"

let update_operators_for_all ?endpoint ~contract ~operator source =
  let endpoint = match endpoint with None -> [] | Some e -> ["--endpoint"; e] in
  let cmd = Filename.quote_command !node @@
    [ !script; "update_operators_for_all"; "--contract"; contract;
      "--edsk"; source.edsk; "--operator"; operator;  ]
    @ endpoint in
  try
    let _ = Script.command_result cmd in
    Lwt.return_unit
  with _ -> Lwt.fail_with "transfer failure"
