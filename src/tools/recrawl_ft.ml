open Hooks
open Crawlori
open Make(Pg)(struct type extra = Rtypes.config end)
open Proto
open Let
open Rtypes

let filename = ref None
let ft_contract = ref None
let ft_token_id = ref None
let recrawl_start = ref None
let recrawl_end = ref None
let fetch = ref false

let spec = [
  "--contract", Arg.String (fun s -> ft_contract := Some s), "FT contract to recrawl";
  "--token-id", Arg.Int (fun i -> ft_token_id := Some (Z.of_int i)), "token_id of contract to recrawl";
  "--fetch", Arg.Set fetch, "fetch contract information from context";
  "--start", Arg.Int (fun i -> recrawl_start := Some (Int32.of_int i)), "Start level for recrawl";
  "--end", Arg.Int (fun i -> recrawl_end := Some (Int32.of_int i)), "Optional end level for recrawl";
]

let handle_operation contract ft config () op =
  Format.printf "Block %s (%ld)\r@?" (Common.Utils.short op.bo_block) op.bo_level;
  match op.bo_meta with
  | None ->
    Lwt.return_error @@
    `generic ("no_metadata", Format.sprintf "no metadata found for operation %s" op.bo_hash)
  | Some meta ->
    if meta.op_status = `applied then
      match op.bo_op.kind with
      | Transaction tr ->
        if not (tr.destination = contract) then Lwt.return_ok ()
        else
          Db.Misc.use None (fun dbh ->
              Format.printf "Block %s (%ld)@." (Common.Utils.short op.bo_block) op.bo_level;
              Db.Crawl.insert_ft ~dbh ~config ~op ~contract ~forward:true {ft with Rtypes.ft_crawled=Some true})
      | _ -> Lwt.return_ok ()
    else Lwt.return_ok ()

let rec search ~name (t : Mtyped.ftype) (m : Mtyped.value) : (Mtyped.stype * Mtyped.value) option =
  let open Mtyped in
  if t.name = Some name then Some (Mtyped.short t, m)
  else match t.typ, m with
    | `option t, `some m
    | `or_ (t, _), `left m
    | `or_ (_, t), `right m -> search ~name t m
    | `tuple [], `tuple _ | `tuple _, `tuple [] -> None
    | `tuple (ht :: t), `tuple (hm :: m) ->
      begin match search ~name ht hm with
        | None -> search ~name {name=None;typ=`tuple t} (`tuple m)
        | Some m -> Some m
      end
    | _ -> None

let match_fields ~expected script =
  let open Common.Contract_spec in
  match script.storage, get_code_elt `storage script.code with
  | Bytes _, _ | Other _, _ | _, None ->
    Error (`generic ("contract_info_error", "unknown script format"))
  | Micheline storage_value, Some storage_type ->
    let$ storage_type = Mtyped.parse_type storage_type in
    let$ storage_value = Mtyped.(parse_value (short storage_type) storage_value) in
    Ok (List.map (fun name ->
        match search ~name storage_type storage_value with
        | Some (`big_map (bmt_key, bmt_value), `nat bm_id) ->
          Some {bm_id; bm_types = {bmt_key; bmt_value}}
        | _ -> None) expected)

let get_fa1_decimals metadata_id =
  let get s = Tzfunc.Node.(get_bigmap_value ~typ:(prim `string) metadata_id (Mstring s)) in
  let>? v = get "decimals" in
  match v with
  | Some (Micheline (Mbytes h)) when int_of_string_opt (Tzfunc.Crypto.hex_to_raw h :> string) <> None ->
    Lwt.return_ok (Int32.of_string (Tzfunc.Crypto.hex_to_raw h :> string))
  | _ ->
    let>? v = get "" in
    match v with
    | Some (Micheline (Mbytes h)) ->
      let uri = (Tzfunc.Crypto.hex_to_raw h :> string) in
      let|> r = Db.Metadata.get_json uri in
      begin match r with
        | Error _ -> Error (`generic ("contract_info_error", "cannot fetch uri " ^ uri))
        | Ok (meta, _) ->
          match meta.tzip21_tm_decimals with
          | None -> Error (`generic ("contract_info_error", "no decimals in " ^ uri))
          | Some d -> Ok (Int32.of_int d)
      end
    | _ -> Lwt.return_error (`generic ("contract_info_error", "cannot get decimals"))

let get_fa2_decimals metadata_id token_id =
  let>? v = Tzfunc.Node.(get_bigmap_value ~typ:(prim `nat) metadata_id (Mint token_id)) in
  match v with
  | Some (Micheline (Mprim {prim=`Pair; args=[_; Mseq l]; _})) ->
    begin match List.find_map (function
        | Mprim {prim = `Elt; args=[Mstring "decimals"; Mbytes h]; _} when int_of_string_opt (Tzfunc.Crypto.hex_to_raw h :> string) <> None ->
          Some (Int32.of_string (Tzfunc.Crypto.hex_to_raw h :> string))
        | _ -> None) l with
    | Some d -> Lwt.return_ok d
    | None ->
      match List.find_map (function
          | Mprim {prim = `Elt; args=[Mstring ""; Mbytes h]; _} ->
            Some (Tzfunc.Crypto.hex_to_raw h :> string)
          | _ -> None) l with
      | None -> Lwt.return_error (`generic ("contract_info_error", "cannot get decimals"))
      | Some uri ->
        let|> r = Db.Metadata.get_json uri in
        match r with
        | Error _ -> Error (`generic ("contract_info_error", "cannot fetch uri " ^ uri))
        | Ok (meta, _) ->
          match meta.tzip21_tm_decimals with
          | None -> Error (`generic ("contract_info_error", "no decimals in " ^ uri))
          | Some d -> Ok (Int32.of_int d)
    end
  | _ -> Lwt.return_error (`generic ("contract_info_error", "cannot get decimals"))

let get_info contract =
  let>? a = Tzfunc.Node.get_account_info contract in
  let>? fields = match a.ac_script with
    | None -> Lwt.return_error (`generic ("contract_info_error", Format.sprintf "contract %s without_script" contract))
    | Some script ->
      Lwt.return @@ match_fields ~expected:["token_metadata"; "ledger"; "balances"] script in
  match fields with
  | [ Some metadata; Some ledger; _ ] | [ Some metadata; _; Some ledger ] ->
    let ft_ledger_id = ledger.bm_id in
    let metadata_id = metadata.bm_id in
    let>? ft_decimals, ft_kind = match !ft_token_id, ledger.bm_types with
      | None, t when t = Common.Contract_spec.ledger_fa1_field ->
        let>? decimals = get_fa1_decimals metadata_id in
        Lwt.return_ok (decimals, Fa1)
      | Some token_id, _ ->
        let>? decimals = get_fa2_decimals metadata_id token_id in
        let kind =
          if ledger.bm_types = Common.Contract_spec.ledger_fa2_multiple_field then Fa2_multiple
          else if ledger.bm_types = Common.Contract_spec.ledger_fa2_multiple_inversed_field then Fa2_multiple_inversed
          else if ledger.bm_types = Common.Contract_spec.ledger_fa2_single_field then Fa2_single
          else if ledger.bm_types = Common.Contract_spec.ledger_lugh_field then Lugh
          else Custom ledger.bm_types in
        Lwt.return_ok (decimals, kind)
      | _ -> Lwt.return_error (`generic ("contract_info_error", "incompatible token_id and ledger types")) in
    Lwt.return_ok {ft_kind; ft_decimals; ft_ledger_id; ft_crawled = None; ft_token_id = !ft_token_id}
  | _ ->
    Lwt.return_error (`generic ("contract_info_error", "missing bigmap token_metadata or ledger"))

let main () =
  Arg.parse spec (fun f -> filename := Some f) "recrawl_ft.exe [options] config.json";
  let>? config = Lwt.return @@ Crawler_config.get !filename Rtypes.config_enc in
  Tzfunc.Node.set_node (List.hd config.Crawlori.Config.nodes);
  match !ft_contract, !recrawl_start with
  | Some ft_contract, Some start ->
    let>? ft =
      if not !fetch then
        let>? ft = (Db.Utils.get_ft_contract ft_contract :> (ft_ledger option, Crawlori.Rp.error) result Lwt.t) in
        match ft with
        | None -> Lwt.return_error (`generic ("contract_info_error", "contract not in DB"))
        | Some ft -> Lwt.return_ok ft
      else
        let>? ft = (get_info ft_contract :> (ft_ledger, Crawlori.Rp.error) result Lwt.t) in
        let|>? () = Db.Config.update_ft_contract ft_contract ft in
        ft in
    let>? _ = async_recrawl ~config ~start ?end_:!recrawl_end
        ~operation:(handle_operation ft_contract ft)
        ((), ()) in
    Db.Crawl.set_crawled_ft ft_contract
  | _ ->
    Format.printf "Missing arguments: '--contract', '--start' are required@.";
    Lwt.return_ok ()

let () =
  EzLwtSys.run @@ fun () ->
  Lwt.map (function
      | Error e -> Rp.print_error e
      | Ok _ -> ()) (main ())
