let node = ref "node"
let script = ref "sdk/dist/main/script.js"

let deploy_collection ?endpoint ~source ~royalties_contract () =
  let endpoint = match endpoint with None -> [] | Some e -> ["--endpoint"; e] in
  let cmd = Filename.quote_command !node @@
    [ !script; "deploy_fa2"; "--owner"; fst source;
      "--royalties_contract"; royalties_contract; "--edsk"; snd source ] @
    endpoint in
  let r = Script.command_result ~f:(fun l -> List.hd @@ List.rev l) cmd in
  let kt1 = Tzfunc.Crypto.op_to_KT1 r in
  kt1, kt1, source, royalties_contract

let deploy_royalties ?endpoint source =
  let endpoint = match endpoint with None -> [] | Some e -> ["--endpoint"; e] in
  let cmd = Filename.quote_command !node @@
    [ !script; "deploy_royalties"; "--owner"; fst source;
      "--edsk"; snd source ] @
    endpoint in
  let r = Script.command_result ~f:(fun l -> List.hd @@ List.rev l) cmd in
  let kt1 = Tzfunc.Crypto.op_to_KT1 r in
  kt1, kt1

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
    Lwt.return_ok ()
  with _ -> Lwt.fail_with "mint failure"

let burn_tokens ?endpoint ~amount ~source ~contract token_id =
  let endpoint = match endpoint with None -> [] | Some e -> ["--endpoint"; e] in
  let cmd = Filename.quote_command !node @@
    [ !script; "burn"; "--contract"; contract;
      "--amount"; amount; "--token_id"; token_id; "--edsk"; snd source ]
    @ endpoint in
  try
    let _ = Script.command_result cmd in
    Lwt.return_ok ()
  with _ -> Lwt.fail_with "burn failure"

let transfer_tokens ?endpoint ~token_id ~amount ~source ~contract destination =
  let endpoint = match endpoint with None -> [] | Some e -> ["--endpoint"; e] in
  let cmd = Filename.quote_command !node @@
    [ !script; "transfer"; "--contract"; contract;
      "--amount"; amount; "--token_id"; token_id; "--edsk"; snd source; "--to"; destination ]
    @ endpoint in
  try
    let _ = Script.command_result cmd in
    Lwt.return_ok ()
  with _ -> Lwt.fail_with "transfer failure"

let set_token_metadata ?endpoint ~token_id ~source ~contract metadata =
  let endpoint = match endpoint with None -> [] | Some e -> ["--endpoint"; e] in
  let metadata = Format.sprintf "{%s}" @@ String.concat ", " @@ List.map (fun (k, v) ->
      Format.sprintf "%S: %S" k v) metadata in
  let cmd = Filename.quote_command !node @@
    [ !script; "set_token_metadata"; "--contract"; contract;
      "--token_id"; token_id; "--edsk"; snd source; "--metadata"; metadata ]
    @ endpoint in
  try
    let _ = Script.command_result cmd in
    Lwt.return_ok ()
  with _ -> Lwt.fail_with "set token metadata failure"

let set_metadata_uri ?endpoint ~token_id ~source ~contract metadata_uri =
  let endpoint = match endpoint with None -> [] | Some e -> ["--endpoint"; e] in
  let cmd = Filename.quote_command !node @@
    [ !script; "set_metadata_uri"; "--contract"; contract;
      "--token_id"; token_id; "--edsk"; snd source; "--metadata_uri"; metadata_uri ]
    @ endpoint in
  try
    let _ = Script.command_result cmd in
    Lwt.return_ok ()
  with _ -> Lwt.fail_with "set metadata uri failure"
