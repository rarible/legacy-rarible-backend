let cwd = Sys.getcwd ()
let exe = Sys.argv.(0)

let contract_name = "fa2_nft_asset"
let storage_name = "fa2_nft_storage"
let test_name = "fa2_nft_test"
let contract_dir = "_build/default/src/contract"

let ligo_file = ref None
let format = ref "text"
let output = ref (None : string option)
let client = ref "tezos-client"
let endpoint = ref "http://tz.functori.com"
let contract = ref contract_name
let source = ref (None : string option)
let burn_cap = ref 1.2
let mich = ref (None: string option)
let fee = ref (None: float option)
let amount = ref (None: int option)
let verbose = ref 0
let main = ref "nft_asset_main"
let storage = ref "store"

let make_file s = match !ligo_file with
  | None ->
    Filename.(
      concat
        (dirname @@ concat cwd exe)
        (concat contract_dir (s ^ ".mligo")))
  | Some f -> f

let set_opt_string r = Arg.String (fun s -> r := Some s)
let set_opt_float r = Arg.Float (fun f -> r := Some f)
let set_opt_int r = Arg.Int (fun i -> r := Some i)

let arg_parse ~spec ~usage f =
  Arg.parse spec f usage

let spec = [
  "--file", set_opt_string ligo_file, Format.sprintf "ligo contract/storage path";
  "--format", Arg.Set_string format,
  "output format for ligo compilation (default: text)";
  "--output", set_opt_string output, "output file for compiled contract";
  "--main", Arg.Set_string main, "main entrypoint of contract (default: 'nft_asset_main')";
  "--storage", Arg.Set_string storage, "storage of contract (default: 'store')";
  "--mich", set_opt_string mich, "michelson contract path";
  "--client", Arg.Set_string client, "tezos client";
  "--endpoint", Arg.Set_string endpoint,
  Format.sprintf "node endpoint (default: %s)" !endpoint;
  "--contract", Arg.Set_string contract,
  Format.sprintf "contract name in tezos client storage (default: %s)" !contract;
  "--source", set_opt_string source, "source for origination/calls";
  "--burn-cap", Arg.Set_float burn_cap,
  Format.sprintf "burn cap for the origination (default: %F)" !burn_cap;
  "--fee", set_opt_float fee, "optionally force fee";
  "--verbose", Arg.Set_int verbose, "verbosity";
  "--dev", Arg.Unit (fun () ->
      endpoint := "http://granada.tz.functori.com";
      verbose := 1
    ), "set dev settings";
]

let missing l =
  List.iter (fun (name, opt) ->
      match opt with
      | None ->
        let _, _, descr = List.find (fun (n, _, _) -> n = name) spec in
        Format.eprintf "Missing argument: %s %s@." name descr
      | _ -> ()) l

let command_result ?(f=(fun l -> String.concat " " @@ List.map String.trim l)) cmd =
  if !verbose > 0 then Format.printf "Command:\n%s@." cmd;
  let ic = Unix.open_process_in cmd in
  let rec aux acc =
    try aux ((input_line ic) :: acc)
    with End_of_file -> List.rev acc in
  let s = f (aux []) in
  close_in ic;
  if s = "" then failwith "Empty result"
  else s

let compile_contract () =
  let file = make_file contract_name in
  Filename.quote_command "ligo" ?stdout:!output [
    "compile-contract"; "--michelson-format"; !format; file; !main ]

let compile_storage () =
  let file = make_file storage_name in
  let source = match !source with
    | None -> missing [ "--source", !source ]; []
    | Some source -> [ "--source"; source ] in
  let cmd = Filename.quote_command "ligo" ([
      "compile-storage"; "--michelson-format"; !format] @ source @ [
        file; !main; !storage ]) in
  cmd

let compile_parameter s =
  let file = make_file contract_name in
  let cmd = Filename.quote_command "ligo" [
      "compile-parameter"; "--michelson-format"; !format; file; !main; s ] in
  cmd

let ligo_test () =
  let file = make_file test_name in
  let cmd = Filename.quote_command "ligo" [
      "test"; file ] in
  cmd

let deploy () = match !source with
  | Some source ->
    let storage = command_result @@ compile_storage () in
    let mich = match !mich with
      | Some mich -> mich
      | None ->
        let s = command_result ~f:(String.concat "\n") @@ compile_contract () in
        let file = make_file contract_name in
        let name = Filename.(remove_extension @@ basename file) ^ ".mich" in
        let oc = open_out name in
        output_string oc s;
        close_out oc;
        name in
    let fee = match !fee with None -> [] | Some f -> [ "--fee"; Format.sprintf "%F" f ] in
    let log = if !verbose > 1 then ["-l"] else [] in
    let s = Filename.quote_command !client ([
        "-E"; !endpoint; "originate"; "contract"; !contract; "transferring"; "0";
        "from"; source; "running"; mich; "--init"; storage; "--burn-cap";
        Format.sprintf "%F" !burn_cap] @ fee @ log) in
    if !verbose > 0 then Format.printf "Command:\n%s@." s;
    Some s
  | source ->
    missing ["--source", source ];
    None

let get_storage () =
  let s =
    Filename.quote_command !client [
      "-E"; !endpoint; "get"; "contract"; "storage"; "for"; !contract ] in
  if !verbose > 0 then Format.printf "Command:\n%s@." s;
  s

let pack ~typ ~key =
  let cmd = Filename.quote_command !client [
      "-E"; !endpoint; "hash"; "data"; Format.sprintf "%s" key;
      "of"; "type"; typ ] in
  if !verbose > 0 then Format.printf "Command:\n%s@." cmd;
  let f = function
    | _ :: s :: _ ->
      let i = String.index s ':' in
      String.trim @@ String.sub s (i+1) (String.length s - i - 1)
    | _ -> failwith "wrong pack result" in
  command_result ~f cmd

let get_bigmap_value bm_id key typ =
  let expr = pack ~typ ~key in
  let s = Filename.quote_command !client [
      "-E"; !endpoint; "get"; "element"; expr; "of"; "big"; "map"; bm_id ] in
  if !verbose > 0 then Format.printf "Command:\n%s@." s;
  s

let call param = match !source with
  | Some source ->
    let fee = match !fee with None -> [] | Some f -> [ "--fee"; Format.sprintf "%F" f ] in
    let log = if !verbose > 1 then ["-l"] else [] in
    let param = command_result @@ compile_parameter param in
    let s = Filename.quote_command !client ([
        "-E"; !endpoint; "call"; !contract; "from"; source;
        "--arg"; Format.sprintf "%s" param; "--burn-cap";
        Format.sprintf "%F" !burn_cap ] @ fee @ log) in
    if !verbose > 0 then Format.printf "Command:\n%s@." s;
    Some s
  | src -> missing [ "--source", src ]; None

let owner bm_id token_id =
  command_result @@ get_bigmap_value bm_id token_id "nat"

let owners bm_id l =
  List.iter (fun id ->
      let owner = owner bm_id id in
      Format.printf "%s: %s@." id owner) l;
  None

(** printers *)

let assets s = Format.sprintf "Assets (%s)" s
let admin s = Format.sprintf "Admin (%s)" s
let tokens s = Format.sprintf "Tokens (%s)" s

let set_admin s = admin @@ Format.sprintf "Set_admin %S" s
let confirm_admin () = admin @@ "Confirm_admin"
let set_company_wallet s = admin @@ Format.sprintf "Set_company_wallet %S" s
let confirm_company_wallet () = admin @@ "Confirm_company_wallet"
let pause b = admin @@ Format.sprintf "Pause %B" b

let address s = Format.sprintf "(%S : address)" s
let nat i = Format.sprintf "%dn" i

let mint_params ~start l =
  Format.sprintf
    "{ token_def = { from_ = %s; to_ = %s }; \
     metadata = { token_id = %s; token_info = (Map.empty : (string, bytes) map) }; \
     owners = [ %s ] }"
    (nat start) (nat @@ start + List.length l) (nat start)
    (String.concat "; " @@ List.map address l)

let mint_tokens ~start l =
  tokens @@ Format.sprintf "Mint_tokens %s" (mint_params ~start l)

let burn_tokens ~start ~end_ =
  tokens @@ Format.sprintf "Burn_tokens {from_ = %s; to_ = %s}" (nat start) (nat end_)

let fa2 s = assets @@ Format.sprintf "Fa2 (%s)" s

let transfer l =
  fa2 @@ Format.sprintf "Transfer [%s]" @@ String.concat "; " @@
  List.map (fun (src, l) ->
      Format.sprintf "{from_=%s; txs = [%s]}" (address src) @@
      String.concat "; " @@ List.map (fun (id, to_) ->
          Format.sprintf "{to_=%s; token_id = %s; amount = 1n}" (address to_) (nat id)) l)
    l

let update_operators l =
  fa2 @@ Format.sprintf "Update_operators [%s]" @@ String.concat "; " @@
  List.map (fun (id, owner, operator, add) ->
      Format.sprintf "{owner = %s; operator = %s; token_id = %s; add = %B}"
        (address owner) (address operator) (nat id) add) l

let managed add =
  fa2 @@ Format.sprintf "Managed %s" add

(** entrypoints *)

let set_admin s = call @@ set_admin s
let confirm_admin () = call @@ confirm_admin ()
let set_company_wallet s = call @@ set_company_wallet s
let confirm_company_wallet () = call @@ confirm_company_wallet ()
let pause b = call @@ pause b

let mint_tokens id l =
  let l = List.fold_left (fun acc s ->
      match String.split_on_char '*' s with
      | [ times; o ] -> acc @ List.init (int_of_string times) (fun _ -> o)
      | _ -> acc @ [ s ]) [] l in
  call @@ mint_tokens ~start:(int_of_string id) l

let burn_tokens start end_ =
  call @@ burn_tokens ~start:(int_of_string start) ~end_:(int_of_string end_)

let transfer l =
  let l = List.fold_left (fun acc s ->
      match acc, String.split_on_char '=' s with
      | (src, l) :: t, [ id; dst ] -> (src, l @ [ int_of_string id, dst ]) :: t
      | _ -> (s, []) :: acc) [] l in
  call @@ transfer (List.rev l)

let update_operators l =
  let l = List.map (fun s ->
      let i = String.index s '=' in
      let id = int_of_string (String.sub s 0 i) in
      let s = String.sub s (i+1) (String.length s - i - 1) in
      let add, i = match String.index_opt s '+' with
        | Some i -> true, i
        | None -> false, String.index s '-' in
      id, String.sub s 0 i, String.sub s (i+1) (String.length s - i - 1), add) l in
  call @@ update_operators l

let managed s = call @@ managed s

(** main *)

let actions = [
  ["compile"; "compile contract"], "compile the contract";
  ["compile storage"], "compile the storage";
  ["compile param <param>"; "compile parameter <param>"], "compile the following parameter";
  ["deploy"], "deploy the contract";
  ["storage"], "get the storage of the contract";
  ["value <big_map_id> <big_map_key>"], "get the big map value";
  ["call <param>"], "call the contract with the following param";
  ["set_admin <tz1...>"], "set the admin of the contract";
  ["confirm_admin"], "confirm the admin of the contract";
  ["set_company_wallet <tz1...>"], "set the wallet to manage others NFTs";
  ["confirm_company_wallet"], "confirm the wallet to manage other NFTs";
  ["pause"], "pause the contract";
  ["unpause"], "unpause the contract";
  ["mint <from_id> (<i_1>*)?<owner_1> .. (<i_n>*)?<owner_n>"], "mint tokens";
  ["burn <from_id> <to_id>"], "burn tokens";
  ["transfer <src_1> <id_1_1=dst_1_1> .. <id_1_n=dst_1_n> <src_2> .. <src_m> .. <id_m_n=dst_m_n>"], "transfer tokens";
  ["update <id_1>=<owner_i>< + | - ><op_1> .. <id_n>=<owner_n>< + | - ><op_n>"], "update operators";
  ["managed <true | false>"], "set managed";
  ["test"], "launch ligo tests";
]

let usage =
  "usage: rarible.mlt <options> <actions>\nactions:\n  " ^
  (String.concat "\n  " @@ List.map (fun (cmds, descr) ->
       Format.sprintf "- %s -> %s" (String.concat " | " cmds) descr) actions) ^ "\noptions:"

let main () =
  let action = ref [] in
  Unix.putenv "TEZOS_CLIENT_UNSAFE_DISABLE_DISCLAIMER" "y";
  Arg.parse spec (fun s -> action := s :: !action) usage;
  let cmd = match List.rev !action with
    | [ "compile" ] | [ "compile"; "contract" ] -> Some (compile_contract ())
    | [ "compile"; "storage" ] ->
      Some (compile_storage ())
    | [ "compile"; "param"; s ] | [ "compile"; "parameter"; s ] ->
      Some (compile_parameter s)
    | [ "deploy" ] -> deploy ()
    | [ "storage" ] -> Some (get_storage ())
    | [ "value"; bm_id; key; typ ] -> Some (get_bigmap_value bm_id key typ)
    | [ "call"; s ] -> call s
    | [ "set_admin"; s ] -> set_admin s
    | [ "confirm_admin" ] -> confirm_admin ()
    | [ "set_company_wallet"; s ] -> set_company_wallet s
    | [ "confirm_company_wallet" ] -> confirm_company_wallet ()
    | [ "pause" ] -> pause true
    | [ "unpause" ] -> pause false
    | "mint" :: id :: l -> mint_tokens id l
    | [ "burn"; from; to_ ] -> burn_tokens from to_
    | "transfer" :: l -> transfer l
    | "update" :: l -> update_operators l
    | ["managed"; b ]  -> managed b
    | "owners" :: bm_id :: l -> owners bm_id l
    | [ "test" ] -> Some (ligo_test ())
    | _ -> Arg.usage spec usage; None in
  match cmd with
  | Some s -> exit @@ Sys.command s
  | None -> ()
