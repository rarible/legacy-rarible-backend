let node = ref "node"
let script = ref "sdk/dist/main/script.js"

let deploy_collection ?endpoint ~source ~royalties_contract () =
  let endpoint = match endpoint with None -> [] | Some e -> ["--endpoint"; e] in
  let cmd = Filename.quote_command !node @@
    [ !script; "deploy_fa2"; "--owner"; fst source;
      "--royalties_contract"; royalties_contract; "--edsk"; snd source ] @
    endpoint in
  Script.command_result ~f:(fun l -> List.hd @@ List.rev l) cmd

let deploy_royalties ?endpoint source =
  let endpoint = match endpoint with None -> [] | Some e -> ["--endpoint"; e] in
  let cmd = Filename.quote_command !node @@
    [ !script; "deploy_royalties"; "--owner"; fst source;
      "--edsk"; snd source ] @
    endpoint in
  Script.command_result ~f:(fun l -> List.hd @@ List.rev l) cmd

let mint_tokens ?endpoint ~amount ~royalties ~source ~contract token_id =
  let royalties = Format.sprintf "{%s}" @@ String.concat "," @@
    List.map (fun (account, value) -> Format.sprintf "%S: %Ld" account value) royalties in
  let endpoint = match endpoint with None -> [] | Some e -> ["--endpoint"; e] in
  let cmd = Filename.quote_command !node @@
    [ !script; "mint"; "--contract"; contract; "--royalties"; royalties;
      "--amount"; amount; "--token_id"; token_id; "--edsk"; snd source ]
    @ endpoint in
  try
    let _ = Script.command_result cmd in
    Lwt.return_unit
  with _ -> Lwt.fail_with "mint failure"

let burn_tokens ?endpoint ~amount ~source ~contract token_id =
  let endpoint = match endpoint with None -> [] | Some e -> ["--endpoint"; e] in
  let cmd = Filename.quote_command !node @@
    [ !script; "burn"; "--contract"; contract;
      "--amount"; amount; "--token_id"; token_id; "--edsk"; snd source ]
    @ endpoint in
  try
    let _ = Script.command_result cmd in
    Lwt.return_unit
  with _ -> Lwt.fail_with "burn failure"

let transfer_tokens ?endpoint ~token_id ~amount ~source ~contract destination =
  let endpoint = match endpoint with None -> [] | Some e -> ["--endpoint"; e] in
  let cmd = Filename.quote_command !node @@
    [ !script; "transfer"; "--contract"; contract;
      "--amount"; amount; "--token_id"; token_id; "--edsk"; snd source; "--to"; destination ]
    @ endpoint in
  try
    let _ = Script.command_result cmd in
    Lwt.return_unit
  with _ -> Lwt.fail_with "transfer failure"

let set_token_metadata ?endpoint ~token_id ~source ~contract metadata =
  let endpoint = match endpoint with None -> [] | Some e -> ["--endpoint"; e] in
  let metadata = Format.sprintf "{%s}" @@ String.concat ", " @@ List.map (fun (k, v) ->
      Format.sprintf "%S: %S" k v) metadata in
  let cmd = Filename.quote_command !node @@
    [ !script; "set_token_metadata"; "--contract"; contract;
      "--token_id"; token_id; "--edsk"; source; "--metadata"; metadata ]
    @ endpoint in
  try
    let _ = Script.command_result cmd in
    Lwt.return_unit
  with _ -> Lwt.fail_with "set token metadata failure"

let set_metadata_uri ?endpoint ~source ~contract metadata_uri =
  let endpoint = match endpoint with None -> [] | Some e -> ["--endpoint"; e] in
  let cmd = Filename.quote_command !node @@
    [ !script; "set_metadata_uri"; "--contract"; contract;
      "--edsk"; source; "--metadata_uri"; metadata_uri ]
    @ endpoint in
  try
    let _ = Script.command_result cmd in
    Lwt.return_unit
  with _ -> Lwt.fail_with "set metadata uri failure"

let deploy_validator ?endpoint ~exchange ~royalties source =
  let endpoint = match endpoint with None -> [] | Some e -> ["--endpoint"; e] in
  let cmd = Filename.quote_command !node @@
    [ !script; "deploy_validator"; "--exchange"; exchange;
      "--edsk"; source; "--royalties_contract"; royalties ] @
    endpoint in
  Script.command_result ~f:(fun l -> List.hd @@ List.rev l) cmd

let deploy_exchange ?endpoint ~owner ~receiver ~fee source =
  let endpoint = match endpoint with None -> [] | Some e -> ["--endpoint"; e] in
  let cmd = Filename.quote_command !node @@
    [ !script; "deploy_exchange"; "--edsk"; source; "--owner"; owner;
      "--receiver"; receiver; "--fee"; Int64.to_string fee ] @
    endpoint in
  Script.command_result ~f:(fun l -> List.hd @@ List.rev l) cmd

let set_validator ?endpoint ~source ~contract validator =
  let endpoint = match endpoint with None -> [] | Some e -> ["--endpoint"; e] in
  let cmd = Filename.quote_command !node @@
    [ !script; "set_validator"; "--contract"; contract;
      "--edsk"; source; "--validator"; validator ]
    @ endpoint in
  try
    let _ = Script.command_result cmd in
    Lwt.return_unit
  with _ -> Lwt.fail_with "set validator failure"

let update_operators_for_all ?endpoint ~contract ~operator source =
  let endpoint = match endpoint with None -> [] | Some e -> ["--endpoint"; e] in
  let cmd = Filename.quote_command !node @@
    [ !script; "update_operators_for_all"; "--contract"; contract;
      "--edsk"; source; "--operator"; operator;  ]
    @ endpoint in
  try
    let _ = Script.command_result cmd in
    Lwt.return_unit
  with _ -> Lwt.fail_with "transfer failure"
