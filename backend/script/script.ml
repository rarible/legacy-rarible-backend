let cwd = Sys.getcwd ()
let exe = Sys.argv.(0)

let file = ref None
let format = ref "text"
let output = ref (None : string option)
let client = ref (Option.value ~default:"tezos-client" (Sys.getenv_opt "TEZOS_CLIENT"))
let endpoint = ref None
let contract = ref None
let source = ref (None : string option)
let burn_cap = ref 3.2
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

let storage_public_nft ?(expiry=31536000000L) admin =
  Format.sprintf {|{ %S; {}; {}; {}; {}; {}; {}; {}; %Ld; False; {Elt "" 0x} }|} admin expiry

let storage_private_nft ?(expiry=31536000000L) admin =
  Format.sprintf {|{ %S; {}; {}; {}; {}; {}; {}; {}; {}; %Ld; False; {Elt "" 0x} }|} admin expiry

let storage_public_multi ?(expiry=31536000000L) admin =
  Format.sprintf {|{ %S; {}; {}; {}; {}; {}; {}; {}; %Ld; False; {Elt "" 0x} }|} admin expiry

let storage_private_multi ?(expiry=31536000000L) admin =
  Format.sprintf {|{ %S; {}; {}; {}; {}; {}; {}; {}; {}; %Ld; False; {Elt "" 0x} }|} admin expiry

let storage_ubi admin =
  Format.sprintf "Pair %S (Some %S) None False {} {} {} {} {}" admin admin

let storage_royalties ~admin =
  Format.sprintf "{ %S; None; {}; {} }" admin

let storage_exchange ~admin ~receiver ~fee =
  Format.sprintf {|{ %S; %S; %s; None; {}; None; {Elt "" 0x}}|}
    admin receiver (Z.to_string fee)

let storage_validator ~admin ~exchange ~royalties ~fill =
  Format.sprintf {|{ %S; %S; %S; %S; {}; {}; {Elt "" 0x}}|}
    admin exchange royalties fill

let storage_fill ?validator admin =
  let validator = match validator with None -> "None" | Some v -> Format.sprintf "Some %S" v in
  Format.sprintf {|{ %S; %s; {}}|} admin validator

let storage_matcher = "Unit"

let compile_contract filename =
  Filename.quote_command "completium-cli" [ "generate"; "michelson"; filename ]

let deploy_aux
    ?(dry_run=false) ?(burn_cap= !burn_cap) ?fee ?(verbose=0) ?endpoint
    ?(force=false) ~filename storage source contract =
    let dry_run = if dry_run then [ "--dry-run" ] else [] in
    let mich = match Filename.extension filename with
      | ".tz" -> filename
      | ".arl" -> command_result ~f:(String.concat "\n") @@ compile_contract filename
      | _ -> failwith (Format.sprintf "extension of %S not handled" filename) in
    let fee = match fee with None -> [] | Some f -> [ "--fee"; Format.sprintf "%F" f ] in
    let log = if verbose > 1 then ["-l"] else [] in
    let endpoint = match endpoint with None -> [] | Some e -> [ "-E"; e ] in
    let force = if force then [ "--force" ] else [] in
    let s = Filename.quote_command !client ( endpoint @ [
        "-w"; "none" ; "originate"; "contract"; contract; "transferring"; "0";
        "from"; source; "running"; mich; "--init"; storage; "--burn-cap";
        Format.sprintf "%F" burn_cap ; ] @ fee @ log @ dry_run @ force) in
    if verbose > 0 then Format.printf "Command:\n%s@." s;
    s

let deploy ~filename storage = match !source, !contract with
  | Some source, Some contract ->
    Some
      (deploy_aux
         ~dry_run:!dry_run ~burn_cap:!burn_cap
         ?fee:!fee ~verbose:!verbose ?endpoint:!endpoint
         ~filename storage source contract)
  | source, contract ->
    missing ["--source", source; "--contract", contract ];
    None

let import_key ?(verbose=0) alias sk =
  let sk = Printf.sprintf "unencrypted:%s" sk in
  let s =
    Filename.quote_command !client  (["import"; "secret"; "key"; alias; sk]) in
  if verbose > 0 then Format.printf "Command:\n%s@." s;
  s

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

let call_aux
    ?(dry_run=false) ?(burn_cap=2.5) ?fee ?(verbose=0) ?endpoint
    ~entrypoint ~param source contract =
  let fee = match fee with None -> [] | Some f -> [ "--fee"; Format.sprintf "%F" f ] in
  let log = if verbose > 1 then ["-l"] else [] in
  let dry_run = if dry_run then [ "--dry-run" ] else [] in
  let endpoint = match endpoint with None -> [] | Some e -> [ "-E"; e ] in
  let s = Filename.quote_command !client (endpoint @ [
      "-w" ; "none"; "call"; contract; "from"; source;
      "--entrypoint"; entrypoint;
      "--arg"; param; "--burn-cap";
      Format.sprintf "%F" burn_cap ] @ fee @ log @ dry_run) in
  if verbose > 0 then Format.printf "Command:\n%s@." s;
  s

let owner bm_id token_id =
  command_result @@ get_bigmap_value bm_id token_id "nat"

let owners bm_id l =
  List.iter (fun id ->
      let owner = owner bm_id id in
      Format.printf "%s: %s@." id owner) l;
  None

(** printers *)

let hex s =
  let shift i =
    if i < 10 then Char.chr @@ i + 48
    else Char.chr @@ i + 87 in
  String.init (2 * String.length s) (fun i ->
      let pos = i / 2 in
      if i mod 2 = 0 then shift @@ Char.code (String.get s pos) / 16
      else shift @@ (Char.code (String.get s pos)) mod 16)

let mint_tokens_repr ?(kind=`nft) ?(metadata=[]) ?(royalties=[]) ~owner id =
  Format.sprintf "{ %s; %S; %s{%s}; {%s} }" (Z.to_string id) owner
    (match kind with `nft -> "" | `mt supply -> Format.sprintf "%s; " (Z.to_string supply))
    (String.concat "; " @@ List.map (fun (k, v) -> Format.sprintf "Elt %S 0x%s" k (hex v)) metadata)
    (String.concat "; " @@ List.map (fun (ad, am) -> Format.sprintf "Pair %S %Ld" ad  am) royalties)

let mint_ubi_tokens_repr ~id ~owner =
  Format.sprintf "{%S; %s; None}" owner (Z.to_string id)

let burn_tokens_repr ~id ~kind =
  match kind with
    | `nft -> Z.to_string id
    | _ ->
      Format.sprintf "{%s%s}" (Z.to_string id)
        (match kind with `nft -> "" | `mt amount -> Format.sprintf "; %s" (Z.to_string amount))

let set_royalties_repr ~contract ~id ~royalties =
  Format.sprintf "{%S; Some %s; {%s}}" contract (Z.to_string id)
    (String.concat "; " @@ List.map (fun (ad, am) -> Format.sprintf "{%S; %Ld}" ad  am) royalties)

let ubi_set_royalties_repr ~id ~royalties =
  Format.sprintf "{%s; {%s}}" (Z.to_string id)
    (String.concat "; " @@ List.map (fun (ad, am) -> Format.sprintf "{%S; %Ld}" ad  am) royalties)

type transfer_dest = {
  trd_id: Z.t;
  trd_amount: Z.t;
  trd_dst: string
}

type transfer = {
  tr_src: string;
  tr_txs: transfer_dest list
}

let transfer_repr l =
  Format.sprintf "{%s}" @@ String.concat "; " @@
  List.map (fun {tr_src; tr_txs} ->
      Format.sprintf "{%S; {%s}}" tr_src @@
      String.concat "; " @@ List.map (fun {trd_id; trd_amount; trd_dst} ->
          Format.sprintf "{%S; %s; %s}" trd_dst (Z.to_string trd_id) (Z.to_string trd_amount)) tr_txs)
    l

type update_operator = {
  uo_id: Z.t;
  uo_owner: string;
  uo_operator: string;
  uo_add: bool
}

let update_operators_repr l =
  Format.sprintf "{%s}" @@ String.concat "; " @@
  List.map (fun {uo_id; uo_owner; uo_operator; uo_add} ->
      Format.sprintf "%s {%S; %S; %s}"
        (if uo_add then "Left" else "Right") uo_owner uo_operator (Z.to_string uo_id)) l

let update_operators_for_all_repr l =
  Format.sprintf "{%s}" @@ String.concat "; " @@
  List.map (fun (operator, add) ->
      Format.sprintf "%s %S"
        (if add then "Left" else "Right") operator) l

let set_token_metadata_repr ~id ~metadata =
  Format.sprintf "{%Ld; {%s}}" id @@ String.concat "; " @@
  List.map (fun (k, v) -> Format.sprintf "Elt %S 0x%s" k (hex v)) metadata

let set_metadata_repr ~key ~value =
  Format.sprintf "{%S; 0x%s}" key (hex value)

(** entrypoints *)

let match_orders_aux ?endpoint source contract param =
  call_aux ?endpoint ~entrypoint:"matchOrders" ~param source contract

let mint_tokens_aux ?endpoint ?kind ?royalties ?metadata ~id ~owner source contract =
  let param = mint_tokens_repr ~owner ?kind ?metadata ?royalties id in
  call_aux ?endpoint ~entrypoint:"mint" ~param source contract

let mint_ubi_tokens_aux ?endpoint id owner source contract =
  let param = mint_ubi_tokens_repr ~id ~owner in
  call_aux ?endpoint ~entrypoint:"mint" ~param source contract

let mint_tokens ~id ~owner ~kind royalties =
  let kind = match String.split_on_char '=' kind with
    | [ "mt"; supply ] -> `mt (Z.of_string supply)
    | [ "nft" ] -> `nft
    | _ -> failwith "kind of token not understood" in
  let royalties = List.fold_left (fun acc s ->
      match String.split_on_char '=' s with
      | [ ad; v ] -> acc @ [ ad, Int64.of_string v ]
      | _ -> acc) [] royalties in
  call ~entrypoint:"mint" @@
  mint_tokens_repr ~owner ~kind ~royalties (Z.of_string id)

let set_royalties_aux ?endpoint ~contract ~id ~royalties source contract_royalties =
  let param = set_royalties_repr ~id ~contract ~royalties in
  call_aux ?endpoint ~entrypoint:"setRoyalties" ~param source contract_royalties

let ubi_set_royalties_aux ?endpoint ~id ~royalties source contract =
  let param = ubi_set_royalties_repr ~id ~royalties in
  call_aux ?endpoint ~entrypoint:"setRoyalties" ~param source contract

let burn_tokens_aux ?endpoint ~id ~kind source contract =
  let param = burn_tokens_repr ~id ~kind in
  call_aux ?endpoint ~entrypoint:"burn" ~param source contract

let burn_tokens ~id ~kind =
  let kind = match String.split_on_char '=' kind with
    | [ "mt"; amount ] -> `mt (Z.of_string amount)
    | [ "nft" ] -> `nft
    | _ -> failwith "kind of token not understood" in
  call ~entrypoint:"burn" @@
  burn_tokens_repr ~id:(Z.of_string id) ~kind

let transfer_aux ?endpoint l source contract =
  let param = transfer_repr l in
  call_aux ?endpoint ~entrypoint:"transfer" ~param source contract

let transfer l =
  let l = List.fold_left (fun acc s ->
      match acc, String.split_on_char '=' s with
      | {tr_src; tr_txs} :: t, [ id; trd_dst ] ->
        begin match String.split_on_char '*' id with
          | [ id; amount ] ->
            {tr_src; tr_txs = tr_txs @ [
                 {trd_id = Z.of_string id;
                  trd_amount = Z.of_string amount; trd_dst } ]} :: t
          | _ ->
            {tr_src; tr_txs = tr_txs @ [
                 { trd_id = Z.of_string id; trd_amount = Z.one; trd_dst }]} :: t
        end
      | _ -> {tr_src=s; tr_txs = []} :: acc) [] l in
  call ~entrypoint:"transfer" @@ transfer_repr (List.rev l)

let update_operators_aux ?endpoint l source contract =
  let param = update_operators_repr l in
  call_aux ?endpoint ~entrypoint:"update_operators" ~param source contract

let update_operators l =
  let l = List.map (fun s ->
      let i = String.index s '=' in
      let uo_id = Z.of_string (String.sub s 0 i) in
      let s = String.sub s (i+1) (String.length s - i - 1) in
      let uo_add, i = match String.index_opt s '+' with
        | Some i -> true, i
        | None -> false, String.index s '-' in
      {uo_id; uo_owner=String.sub s 0 i; uo_operator=String.sub s (i+1) (String.length s - i - 1); uo_add}) l in
  call ~entrypoint:"update_operators" @@ update_operators_repr l

let update_operators_for_all_aux ?endpoint l source contract =
  let param = update_operators_for_all_repr l in
  call_aux ?endpoint ~entrypoint:"update_operators_for_all" ~param source contract

let update_operators_for_all l =
  let l = List.map (fun s ->
      let add = String.get s 0 = '+' in
      String.sub s 1 (String.length s - 1), add) l in
  call ~entrypoint:"update_operators_for_all" @@ update_operators_for_all_repr l

let set_token_metadata_aux ?endpoint ~id ~metadata source contract =
  let param = set_token_metadata_repr ~id ~metadata in
  call_aux ?endpoint ~entrypoint:"setTokenMetadata" ~param source contract

let set_token_metadata ~id ~metadata =
  let metadata = List.filter_map (fun s ->
      match String.index_opt s '=' with
      | None -> None
      | Some i -> Some (String.sub s 0 i, String.sub s (i+1) (String.length s - i - 1))) metadata in
  call ~entrypoint:"setTokenMetadata" @@ set_token_metadata_repr ~id:(Int64.of_string id) ~metadata

let set_metadata_aux ?endpoint ~key ~value source contract =
  let param = set_metadata_repr ~key ~value in
  call_aux ?endpoint ~entrypoint:"setMetadata" ~param source contract

let set_metadata ~key ~value =
  call ~entrypoint:"setMetadataUri" @@ set_metadata_repr ~key ~value

let set_validator_aux ?endpoint kt1 source contract =
  let param = Printf.sprintf "%S" kt1  in
  call_aux ?endpoint  ~entrypoint:"setValidator" ~param source contract

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
    | [ "deploy_nft"; admin ] ->
      deploy ~filename:"contracts/arl/fa2.arl" (storage_public_nft admin)
    | [ "deploy_royalties"; admin ] ->
      deploy ~filename:"contracts/arl/royalties.arl" (storage_royalties ~admin)
    | [ "deploy_exchange"; admin; receiver; fee ] ->
      deploy ~filename:"contracts/arl/exchangeV2.arl"
        (storage_exchange ~admin ~receiver ~fee:(Z.of_string fee))
    | [ "deploy_validator"; admin; exchange; royalties; fill ] ->
      deploy ~filename:"contracts/arl/validator.arl"
        (storage_validator ~admin ~exchange ~royalties ~fill)
    | "deploy_fill" :: admin :: l ->
      let validator = match l with [ v ] -> Some v | _ -> None in
      deploy ~filename:"contracts/arl/fill.arl"
        (storage_fill ?validator admin)
    | [ "deploy_matcher" ] ->
      deploy ~filename:"contracts/arl/matcher.arl" storage_matcher
    | [ "storage" ] -> get_storage ()
    | [ "value"; bm_id; key; typ ] -> Some (get_bigmap_value bm_id key typ)
    | [ "call"; entrypoint; s ] -> call ~entrypoint s
    | "mint" :: id :: owner :: kind :: royalties -> mint_tokens ~id ~owner ~kind royalties
    | "burn" :: [ id; kind ] -> burn_tokens ~id ~kind
    | "transfer" :: l -> transfer l
    | "update_operators" :: l -> update_operators l
    | "update_operators_for_all" :: l -> update_operators_for_all l
    | "set_token_metadata" :: id :: metadata -> set_token_metadata ~id ~metadata
    | "set_metadata" :: [ key; value ] -> set_metadata ~key ~value
    | "owners" :: bm_id :: l -> owners bm_id l
    | _ -> Arg.usage spec usage; None in
  match cmd with
  | Some s -> exit @@ Sys.command s
  | None -> ()
