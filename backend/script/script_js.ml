let node = ref "node"
let script = ref "sdk/dist/script.js"

let rec sys_command ?(verbose=0) ?(retry=0) c =
  if verbose > 0 then Printf.eprintf "cmd: %s\n%!" c ;
  let oldstdout = Unix.dup Unix.stdout in
  let oldstderr = Unix.dup Unix.stderr in
  let out_temp_fn = Filename.temp_file "sys_command" "stdout_redirect" in
  let err_temp_fn = Filename.temp_file "sys_command" "stderr_redirect" in
  let newstdout = open_out out_temp_fn in
  let newstderr = open_out err_temp_fn in
  Unix.dup2 (Unix.descr_of_out_channel newstdout) Unix.stdout;
  Unix.dup2 (Unix.descr_of_out_channel newstderr) Unix.stderr;
  let code = Sys.command c in
  flush newstdout ;
  flush newstderr ;
  Unix.dup2 oldstdout Unix.stdout ;
  Unix.dup2 oldstderr Unix.stderr ;
  close_out newstdout ;
  close_out newstderr ;
  if code <> 0 && retry > 0 then
    begin
    Printf.eprintf "Failure on Sys.command (%s)... retrying in 2sec\n%!" err_temp_fn ;
    Unix.sleep 2 ;
    sys_command ~verbose ~retry:(retry-1) c
  end
  else
    code, out_temp_fn, err_temp_fn

let deploy_collection ?endpoint ~source ~royalties_contract () =
  let endpoint = match endpoint with None -> [] | Some e -> ["--endpoint"; e] in
  let cmd = Filename.quote_command !node @@
    [ !node; !script; "deploy"; "--owner"; fst source;
      "--royalties_contract"; royalties_contract; "--edsk"; snd source ] @
    endpoint in
  let code, out, err = sys_command cmd in
  if code <> 0 then
    failwith (Printf.sprintf "deploy failure : out %S err %S" out err)
  else
    let kt1 = Tzfunc.Crypto.op_to_KT1 (String.trim out) in
    kt1, kt1, source, royalties_contract

let mint_tokens ?endpoint ~amount ~royalties ~source ~contract token_id =
  let royalties = Format.sprintf "{%s}" @@ String.concat "," @@
    List.map (fun (account, value) -> Format.sprintf "%S: %Ld" account value) royalties in
  let endpoint = match endpoint with None -> [] | Some e -> ["--endpoint"; e] in
  let cmd = Filename.quote_command !node @@
    [ !node; !script; "mint"; "--contract"; contract; "--royalties"; royalties;
      "--amount"; amount; "--token_id"; token_id; "--edsk"; snd source ]
    @ endpoint in
  let code, out, err = sys_command cmd in
  if code <> 0 then
    Lwt.fail_with ("mint failure : log " ^ out ^ " & " ^ err)
  else Lwt.return_ok ()

let burn_tokens ?endpoint ~amount ~source ~contract token_id =
  let endpoint = match endpoint with None -> [] | Some e -> ["--endpoint"; e] in
  let cmd = Filename.quote_command !node @@
    [ !node; !script; "burn"; "--contract"; contract;
      "--amount"; amount; "--token_id"; token_id; "--edsk"; snd source ]
    @ endpoint in
  let code, out, err = sys_command cmd in
  if code <> 0 then
    Lwt.fail_with ("burn failure : log " ^ out ^ " & " ^ err)
  else Lwt.return_ok ()

let transfer_tokens ?endpoint ~token_id ~amount ~source ~contract destination =
  let endpoint = match endpoint with None -> [] | Some e -> ["--endpoint"; e] in
  let cmd = Filename.quote_command !node @@
    [ !node; !script; "transfer"; "--contract"; contract;
      "--amount"; amount; "--token_id"; token_id; "--edsk"; snd source; "--to"; destination ]
    @ endpoint in
  let code, out, err = sys_command cmd in
  if code <> 0 then
    Lwt.fail_with ("transfer failure : log " ^ out ^ " & " ^ err)
  else Lwt.return_ok ()

let set_token_metadata ?endpoint ~token_id ~source ~contract metadata =
  let endpoint = match endpoint with None -> [] | Some e -> ["--endpoint"; e] in
  let metadata = Format.sprintf "{%s}" @@ String.concat ", " @@ List.map (fun (k, v) ->
      Format.sprintf "%S: %S" k v) metadata in
  let cmd = Filename.quote_command !node @@
    [ !node; !script; "set_token_metadata"; "--contract"; contract;
      "--token_id"; token_id; "--edsk"; snd source; "--metadata"; metadata ]
    @ endpoint in
  let code, out, err = sys_command cmd in
  if code <> 0 then
    Lwt.fail_with ("set token metadata failure : log " ^ out ^ " & " ^ err)
  else Lwt.return_ok ()

let set_metadata_uri ?endpoint ~token_id ~source ~contract metadata_uri =
  let endpoint = match endpoint with None -> [] | Some e -> ["--endpoint"; e] in
  let cmd = Filename.quote_command !node @@
    [ !node; !script; "set_metadata_uri"; "--contract"; contract;
      "--token_id"; token_id; "--edsk"; snd source; "--metadata_uri"; metadata_uri ]
    @ endpoint in
  let code, out, err = sys_command cmd in
  if code <> 0 then
    Lwt.fail_with ("set token metadata failure : log " ^ out ^ " & " ^ err)
  else Lwt.return_ok ()
