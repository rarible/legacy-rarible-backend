let cwd = Sys.getcwd ()
let exe = Sys.argv.(0)

let contract_name = "nft"
let storage_name = "nft_storage"
let test_name = "nft_test"
let contract_dir = "../_build/default/contracts/mligo/nft_single"

let ligo_file = ref None
let format = ref "text"
let output = ref (None : string option)
let client = ref (Option.value ~default:"tezos-client" (Sys.getenv_opt "TEZOS_CLIENT"))
let endpoint = ref None
let contract = ref contract_name
let source = ref (None : string option)
let burn_cap = ref 2.5
let mich = ref (None: string option)
let fee = ref (None: float option)
let amount = ref (None: int option)
let verbose = ref 0
let main = ref "main"
let storage = ref None
let dry_run = ref false
let metadata = ref ""
let admin = ref "Tezos.source"

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
  "--storage", Arg.String (fun s -> storage := Some s), "storage of contract (default: 'store')";
  "--mich", set_opt_string mich, "michelson contract path";
  "--client", Arg.Set_string client, "tezos client";
  "--endpoint", set_opt_string endpoint, "node endpoint";
  "--contract", Arg.Set_string contract,
  Format.sprintf "contract name in tezos client storage (default: %s)" !contract;
  "--source", set_opt_string source, "source for origination/calls";
  "--burn-cap", Arg.Set_float burn_cap,
  Format.sprintf "burn cap for the origination (default: %F)" !burn_cap;
  "--fee", set_opt_float fee, "optionally force fee";
  "--verbose", Arg.Set_int verbose, "verbosity";
  "--dev", Arg.Unit (fun () ->
      endpoint := Some "http://granada.tz.functori.com";
      verbose := 1
    ), "set dev settings";
  "--dry-run", Arg.Set dry_run, "dry run";
  "--metadata", Arg.Set_string metadata, "token metadata";
  "--admin", Arg.Set_string admin, "contract admin";
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

let hex s =
  let shift i =
    if i < 10 then Char.chr @@ i + 48
    else Char.chr @@ i + 87 in
  String.init (2 * String.length s) (fun i ->
      let pos = i / 2 in
      if i mod 2 = 0 then shift @@ Char.code (String.get s pos) / 16
      else shift @@ (Char.code (String.get s pos)) mod 16)

let compile_contract () =
  let file = make_file contract_name in
  Filename.quote_command "ligo" ?stdout:!output [
    "compile-contract"; "--michelson-format"; !format; file; !main ]

let storage_repr () =
  let info = Format.sprintf "Big_map.literal [%s]" @@ String.concat ";" @@
    List.filter_map (fun s ->
        match String.split_on_char '=' s with
        | [ k; v ] -> Some ("\"" ^ k ^ "\", 0x" ^ hex v)
        | _ -> None) @@ String.split_on_char ',' !metadata in
  Format.sprintf
    "{ admin = (%s : address); pending_admin = (None : address option); \
     paused = true; ledger = (Big_map.empty : ledger); \
     operators = (Big_map.empty : operators_storage); \
     operators_for_all = (Big_map.empty : operators_for_all_storage); \
     token_metadata = (Big_map.empty : token_metadata_storage); \
     next_token_id = 0n; metadata = (%s : (string, bytes) big_map); \
     royalties_contract = (\"KT1CB1PpofoYnkAKTBi82JagRdwaED6Uojon\" : address) }"
    !admin info

let compile_storage () =
  let st, file = match !storage with
    | None -> storage_repr (), make_file contract_name
    | Some s -> s, make_file storage_name in
  let source = match !source with
    | None -> missing [ "--source", !source ]; []
    | Some source -> [ "--source"; source ] in
  let cmd = Filename.quote_command "ligo" ([
      "compile-storage"; "--michelson-format"; !format] @ source @ [
        file; !main; st ]) in
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
    let dry_run = if !dry_run then [ "--dry-run" ] else [] in
    let storage = command_result @@ compile_storage () in
    let mich = match !mich with
      | Some mich -> mich
      | None -> command_result ~f:(String.concat "\n") @@ compile_contract () in
    let fee = match !fee with None -> [] | Some f -> [ "--fee"; Format.sprintf "%F" f ] in
    let log = if !verbose > 1 then ["-l"] else [] in
    let endpoint = match !endpoint with None -> [] | Some e -> [ "-E"; e ] in
    let s = Filename.quote_command !client ( endpoint @ [
        "originate"; "contract"; !contract; "transferring"; "0";
        "from"; source; "running"; mich; "--init"; storage; "--burn-cap";
        Format.sprintf "%F" !burn_cap] @ fee @ log @ dry_run) in
    if !verbose > 0 then Format.printf "Command:\n%s@." s;
    Some s
  | source ->
    missing ["--source", source ];
    None

let get_storage () =
  let dry_run = if !dry_run then [ "--dry-run" ] else [] in
  let endpoint = match !endpoint with None -> [] | Some e -> [ "-E"; e ] in
  let s =
    Filename.quote_command !client (endpoint @ [
        "get"; "contract"; "storage"; "for"; !contract ] @
        dry_run) in
  if !verbose > 0 then Format.printf "Command:\n%s@." s;
  s

let pack ~typ ~key =
  let endpoint = match !endpoint with None -> [] | Some e -> [ "-E"; e ] in
  let cmd = Filename.quote_command !client (endpoint @ [
      "hash"; "data"; Format.sprintf "%s" key;
      "of"; "type"; typ ]) in
  if !verbose > 0 then Format.printf "Command:\n%s@." cmd;
  let f = function
    | _ :: s :: _ ->
      let i = String.index s ':' in
      String.trim @@ String.sub s (i+1) (String.length s - i - 1)
    | _ -> failwith "wrong pack result" in
  command_result ~f cmd

let get_bigmap_value bm_id key typ =
  let endpoint = match !endpoint with None -> [] | Some e -> [ "-E"; e ] in
  let expr = pack ~typ ~key in
  let s = Filename.quote_command !client (endpoint @ [
      "get"; "element"; expr; "of"; "big"; "map"; bm_id ]) in
  if !verbose > 0 then Format.printf "Command:\n%s@." s;
  s

let call param = match !source with
  | Some source ->
    let fee = match !fee with None -> [] | Some f -> [ "--fee"; Format.sprintf "%F" f ] in
    let log = if !verbose > 1 then ["-l"] else [] in
    let dry_run = if !dry_run then [ "--dry-run" ] else [] in
    let endpoint = match !endpoint with None -> [] | Some e -> [ "-E"; e ] in
    let param = command_result @@ compile_parameter param in
    let s = Filename.quote_command !client (endpoint @ [
        "call"; !contract; "from"; source;
        "--arg"; param; "--burn-cap";
        Format.sprintf "%F" !burn_cap ] @ fee @ log @ dry_run) in
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

let address s = Format.sprintf "(%S : address)" s
let nat i = Format.sprintf "%dn" i

let assets s = Format.sprintf "Assets (%s)" s
let admin s = Format.sprintf "Admin (%s)" s
let manager s = Format.sprintf "Manager (%s)" s

let set_admin s = admin @@ Format.sprintf "Set_admin %s" (address s)
let confirm_admin () = admin @@ "Confirm_admin"
let pause b = admin @@ Format.sprintf "Pause %B" b

let mint_tokens ~id ~owner ~amount l =
  manager @@ Format.sprintf "Mint { token_id = %s; owner = %s; amount = %s; royalties = ([ %s ] : part list) }"
    (nat id) (address owner) (nat amount)
    (String.concat "; " @@ List.map (fun (ad, am) -> Format.sprintf "(%s, %s)" (address ad) (nat am)) l)

let burn_tokens ~id ~owner ~amount =
  manager @@ Format.sprintf "Burn { token_id = %s; owner = %s; amount = %s }"
    (nat id) (address owner) (nat amount)

let transfer l =
  assets @@ Format.sprintf "Transfer [%s]" @@ String.concat "; " @@
  List.map (fun (src, l) ->
      Format.sprintf "{from_=%s; txs = [%s]}" (address src) @@
      String.concat "; " @@ List.map (fun (id, amount, to_) ->
          Format.sprintf "{to_=%s; token_id = %s; amount = %s}" (address to_) (nat id) (nat amount)) l)
    l

let update_operators l =
  assets @@ Format.sprintf "Update_operators [%s]" @@ String.concat "; " @@
  List.map (fun (id, owner, operator, add) ->
      Format.sprintf "%s {owner = %s; operator = %s; token_id = %s}"
        (if add then "Add_operator" else "Remove_operator") (address owner) (address operator) (nat id)) l

let update_operators_for_all l =
  assets @@ Format.sprintf "Update_operators_for_all [%s]" @@ String.concat "; " @@
  List.map (fun (operator, add) ->
      Format.sprintf "%s %s"
        (if add then "Add_operator_for_all" else "Remove_operator_for_all")
        (address operator)) l

(** entrypoints *)

let set_admin s = call @@ set_admin s
let confirm_admin () = call @@  confirm_admin ()
let pause b = call @@ pause b

let mint_tokens id owner amount l =
  let l = List.fold_left (fun acc s ->
      match String.split_on_char '=' s with
      | [ ad; v ] -> acc @ [ ad, int_of_string v ]
      | _ -> acc) [] l in
  call @@ mint_tokens ~id:(int_of_string id) ~owner ~amount:(int_of_string amount) l

let burn_tokens id owner amount =
  call @@ burn_tokens ~id:(int_of_string id) ~owner ~amount:(int_of_string amount)

let transfer l =
  let l = List.fold_left (fun acc s ->
      match acc, String.split_on_char '=' s with
      | (src, l) :: t, [ id; dst ] ->
        begin match String.split_on_char '*' id with
          | [ id; amount ] ->
            (src, l @ [ int_of_string id, int_of_string amount, dst ]) :: t
          | _ ->
            (src, l @ [ int_of_string id, 1, dst ]) :: t
        end
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

let update_operators_for_all l =
  let l = List.map (fun s ->
      let add = String.get s 0 = '+' in
      String.sub s 1 (String.length s - 1), add) l in
  call @@ update_operators_for_all l

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
  ["pause"], "pause the contract";
  ["unpause"], "unpause the contract";
  ["mint <token_id> <owner> <amount> (<address_royalties>=<amount_royalties>)*"], "mint tokens";
  ["burn <token_id> <owner> <amount>"], "burn tokens";
  ["transfer (<source> (<token_id>\\*<amount>?=<destination>)*)*"], "transfer tokens";
  ["update_operators (<token_id>=<owner>< + | - ><operator>)*"], "update operators";
  ["update_operators_for_all (< + | - ><operator>)*"], "update operators for all token_ids";
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
    | [ "pause" ] -> pause true
    | [ "unpause" ] -> pause false
    | "mint" :: id :: owner :: amount :: l -> mint_tokens id owner amount l
    | "burn" :: id :: owner :: amount :: [] -> burn_tokens id owner amount
    | "transfer" :: l -> transfer l
    | "update_operators" :: l -> update_operators l
    | "update_operators_for_all" :: l -> update_operators_for_all l
    | "owners" :: bm_id :: l -> owners bm_id l
    | [ "test" ] -> Some (ligo_test ())
    | _ -> Arg.usage spec usage; None in
  match cmd with
  | Some s -> exit @@ Sys.command s
  | None -> ()
