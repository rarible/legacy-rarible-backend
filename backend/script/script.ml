let cwd = Sys.getcwd ()
let exe = Sys.argv.(0)

let file = ref None
let format = ref "text"
let output = ref (None : string option)
let client = ref (Option.value ~default:"tezos-client" (Sys.getenv_opt "TEZOS_CLIENT"))
let endpoint = ref None
let contract = ref None
let source = ref (None : string option)
let burn_cap = ref 2.5
let mich = ref (None: string option)
let fee = ref (None: float option)
let verbose = ref 0
let dry_run = ref false

let set_opt_string r = Arg.String (fun s -> r := Some s)
let set_opt_float r = Arg.Float (fun f -> r := Some f)
let set_opt_int r = Arg.Int (fun i -> r := Some i)

let arg_parse ~spec ~usage f =
  Arg.parse spec f usage

let spec = [
  "--file", set_opt_string file, Format.sprintf "optional file input";
  "--client", Arg.Set_string client, "tezos client";
  "--endpoint", set_opt_string endpoint, "node endpoint";
  "--contract", set_opt_string contract,
  Format.sprintf "contract name in tezos client storage";
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
  match s, Unix.close_process_in ic with
  | "", _ -> failwith "Empty result"
  | _, Unix.WEXITED 0 -> s
  | _ -> failwith (Format.sprintf "Error processing %S" cmd)

let storage_fa2 ~admin ~royalties =
  Format.sprintf {|(Pair %S (Pair %S (Pair {} (Pair {} (Pair {} (Pair {} {Elt "" 0x}))))))|}
    admin royalties

let storage_royalties ~admin =
  Format.sprintf "(Pair %S (Pair None (Pair {} {})))" admin

let storage_exchange ~admin ~receiver ~fee =
  Format.sprintf {|(Pair %S (Pair %S (Pair %Ld (Pair None (Pair {} (Pair None {Elt "" 0x}))))))|}
    admin receiver fee

let storage_validator ~exchange ~royalties =
  Format.sprintf {|(Pair %S (Pair %S (Pair {} (Pair {} (Pair {} {Elt "" 0x})))))|}
    exchange royalties

let compile_contract filename =
  Filename.quote_command "completium-cli" [ "generate"; "michelson"; filename ]

let deploy ~filename storage = match !source, !contract with
  | Some source, Some contract ->
    let dry_run = if !dry_run then [ "--dry-run" ] else [] in
    let mich = match Filename.extension filename with
      | ".tz" -> filename
      | ".arl" -> command_result ~f:(String.concat "\n") @@ compile_contract filename
      | _ -> failwith (Format.sprintf "extension of %S not handled" filename) in
    let fee = match !fee with None -> [] | Some f -> [ "--fee"; Format.sprintf "%F" f ] in
    let log = if !verbose > 1 then ["-l"] else [] in
    let endpoint = match !endpoint with None -> [] | Some e -> [ "-E"; e ] in
    let s = Filename.quote_command !client ( endpoint @ [
        "originate"; "contract"; contract; "transferring"; "0";
        "from"; source; "running"; mich; "--init"; storage; "--burn-cap";
        Format.sprintf "%F" !burn_cap] @ fee @ log @ dry_run) in
    if !verbose > 0 then Format.printf "Command:\n%s@." s;
    Some s
  | source, contract ->
    missing ["--source", source; "--contract", contract ];
    None

let get_storage () = match !contract with
  | Some contract ->
    let dry_run = if !dry_run then [ "--dry-run" ] else [] in
    let endpoint = match !endpoint with None -> [] | Some e -> [ "-E"; e ] in
    let s =
      Filename.quote_command !client (endpoint @ [
          "get"; "contract"; "storage"; "for"; contract ] @
                                      dry_run) in
    if !verbose > 0 then Format.printf "Command:\n%s@." s;
    Some s
  | contract ->
    missing ["--contract", contract ];
    None

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

let call ~entrypoint param = match !source, !contract with
  | Some source, Some contract ->
    let fee = match !fee with None -> [] | Some f -> [ "--fee"; Format.sprintf "%F" f ] in
    let log = if !verbose > 1 then ["-l"] else [] in
    let dry_run = if !dry_run then [ "--dry-run" ] else [] in
    let endpoint = match !endpoint with None -> [] | Some e -> [ "-E"; e ] in
    let s = Filename.quote_command !client (endpoint @ [
        "call"; contract; "from"; source;
        "--entrypoint"; entrypoint;
        "--arg"; param; "--burn-cap";
        Format.sprintf "%F" !burn_cap ] @ fee @ log @ dry_run) in
    if !verbose > 0 then Format.printf "Command:\n%s@." s;
    Some s
  | src, contract -> missing [ "--source", src; "--contract", contract ]; None

let owner bm_id token_id =
  command_result @@ get_bigmap_value bm_id token_id "nat"

let owners bm_id l =
  List.iter (fun id ->
      let owner = owner bm_id id in
      Format.printf "%s: %s@." id owner) l;
  None

(** printers *)

let mint_tokens ~id ~owner ~amount l =
  Format.sprintf "Pair %Ld %S %Ld {%s}" id owner amount
    (String.concat "; " @@ List.map (fun (ad, am) -> Format.sprintf "Pair %S %Ld)" ad  am) l)

let burn_tokens ~id ~owner ~amount =
  Format.sprintf "Pair %Ld %S %Ld" id owner amount

let transfer l =
  Format.sprintf "{%s}" @@ String.concat "; " @@
  List.map (fun (src, l) ->
      Format.sprintf "Pair %S {%s}" src @@
      String.concat "; " @@ List.map (fun (id, amount, to_) ->
          Format.sprintf "Pair %S %Ld %Ld" to_ id amount) l)
    l

let update_operators l =
  Format.sprintf "{%s}" @@ String.concat "; " @@
  List.map (fun (id, owner, operator, add) ->
      Format.sprintf "%s (Pair %S %S %Ld)"
        (if add then "Left" else "Right") owner operator id) l

let update_operators_for_all l =
  Format.sprintf "{%s}" @@ String.concat "; " @@
  List.map (fun (operator, add) ->
      Format.sprintf "%s %S"
        (if add then "Left" else "Right") operator) l

let set_token_metadata id l =
  Format.sprintf "Pair %Ld %s" id @@ String.concat "; " @@
  List.map (fun (k, v) -> Format.sprintf "Elt %S %S" k v) l

let hex s =
  let shift i =
    if i < 10 then Char.chr @@ i + 48
    else Char.chr @@ i + 87 in
  String.init (2 * String.length s) (fun i ->
      let pos = i / 2 in
      if i mod 2 = 0 then shift @@ Char.code (String.get s pos) / 16
      else shift @@ (Char.code (String.get s pos)) mod 16)

let set_metadata_uri s =
  Format.sprintf "0x%s" (hex s)

(** entrypoints *)

let mint_tokens id owner amount l =
  let l = List.fold_left (fun acc s ->
      match String.split_on_char '=' s with
      | [ ad; v ] -> acc @ [ ad, Int64.of_string v ]
      | _ -> acc) [] l in
  call ~entrypoint:"mint" @@
  mint_tokens ~id:(Int64.of_string id) ~owner ~amount:(Int64.of_string amount) l

let burn_tokens id owner amount =
  call ~entrypoint:"burn" @@
  burn_tokens ~id:(Int64.of_string id) ~owner ~amount:(Int64.of_string amount)

let transfer l =
  let l = List.fold_left (fun acc s ->
      match acc, String.split_on_char '=' s with
      | (src, l) :: t, [ id; dst ] ->
        begin match String.split_on_char '*' id with
          | [ id; amount ] ->
            (src, l @ [ Int64.of_string id, Int64.of_string amount, dst ]) :: t
          | _ ->
            (src, l @ [ Int64.of_string id, 1L, dst ]) :: t
        end
      | _ -> (s, []) :: acc) [] l in
  call ~entrypoint:"transfer" @@ transfer (List.rev l)

let update_operators l =
  let l = List.map (fun s ->
      let i = String.index s '=' in
      let id = Int64.of_string (String.sub s 0 i) in
      let s = String.sub s (i+1) (String.length s - i - 1) in
      let add, i = match String.index_opt s '+' with
        | Some i -> true, i
        | None -> false, String.index s '-' in
      id, String.sub s 0 i, String.sub s (i+1) (String.length s - i - 1), add) l in
  call ~entrypoint:"update_operators" @@ update_operators l

let update_operators_for_all l =
  let l = List.map (fun s ->
      let add = String.get s 0 = '+' in
      String.sub s 1 (String.length s - 1), add) l in
  call ~entrypoint:"update_operators_for_all" @@ update_operators_for_all l

let set_token_metadata id l =
  let l = List.filter_map (fun s ->
      match String.index_opt s '=' with
      | None -> None
      | Some i -> Some (String.sub s 0 i, String.sub s (i+1) (String.length s - i - 1))) l in
  call ~entrypoint:"setTokenMetadata" @@ set_token_metadata (Int64.of_string id) l

let set_metadata_uri s =
  call ~entrypoint:"setMetadataUri" @@ set_metadata_uri s

(** main *)

let actions = [
  ["compile contract"], "compile the contract";
  ["deploy <contract file> <storage>"], "deploy the contract";
  ["deploy_fa2 <admin> <royalties_cotnract>"], "deploy fa2 contract";
  ["deploy_royalties <admin>"], "deploy royalties contract";
  ["deploy_exchange <admin> <default_receiver> <protocol_fee>"], "deploy exchangeV2 contract";
  ["deploy_validator <exchangeV2_contract> <royalties_contract>"], "deploy validator contract";
  ["storage"], "get the storage of the contract";
  ["value <big_map_id> <big_map_key>"], "get the big map value";
  ["call <entrypoint> <param>"], "call the contract with the following param";
  ["mint <token_id> <owner> <amount> (<address_royalties>=<amount_royalties>)*"], "mint tokens";
  ["burn <token_id> <owner> <amount>"], "burn tokens";
  ["transfer (<source> (<token_id>\\*<amount>?=<destination>)*)*"], "transfer tokens";
  ["update_operators (<token_id>=<owner>< + | - ><operator>)*"], "update operators";
  ["update_operators_for_all (< + | - ><operator>)*"], "update operators for all token_ids";
  ["set_token_metadata <token_id> (<key>=<value>)*"], "set token metadata";
  ["set_metadata_uri <string>"], "set metadata uri";
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
    | [ "compile"; "contract"; filename ] -> Some (compile_contract filename)
    | [ "deploy"; filename; storage ] -> deploy ~filename storage
    | [ "deploy_fa2"; admin; royalties ] ->
      deploy ~filename:"contracts/arl/fa2.arl" (storage_fa2 ~admin ~royalties)
    | [ "deploy_royalties"; admin ] ->
      deploy ~filename:"contracts/arl/royalties.arl" (storage_royalties ~admin)
    | [ "deploy_exchange"; admin; receiver; fee ] ->
      deploy ~filename:"contracts/arl/exchangeV2.arl"
        (storage_exchange ~admin ~receiver ~fee:(Int64.of_string fee))
    | [ "deploy_validator"; exchange; royalties ] ->
      deploy ~filename:"contracts/arl/validator.arl"
        (storage_validator ~exchange ~royalties)
    | [ "storage" ] -> get_storage ()
    | [ "value"; bm_id; key; typ ] -> Some (get_bigmap_value bm_id key typ)
    | [ "call"; entrypoint; s ] -> call ~entrypoint s
    | "mint" :: id :: owner :: amount :: l -> mint_tokens id owner amount l
    | "burn" :: id :: owner :: amount :: [] -> burn_tokens id owner amount
    | "transfer" :: l -> transfer l
    | "update_operators" :: l -> update_operators l
    | "update_operators_for_all" :: l -> update_operators_for_all l
    | "set_token_metadata" :: id :: l -> set_token_metadata id l
    | "set_metadata_uri" :: [ s ] -> set_metadata_uri s
    | "owners" :: bm_id :: l -> owners bm_id l
    | _ -> Arg.usage spec usage; None in
  match cmd with
  | Some s -> exit @@ Sys.command s
  | None -> ()
