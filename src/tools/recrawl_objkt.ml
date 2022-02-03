open Hooks
open Crawlori
open Make(Pg)(struct type extra = Rtypes.config end)
open Proto
open Let
open Rtypes
module SSet = Set.Make(String)

let filename = ref None
let objkt_contract = ref "KT1Aq4wWmVanpQhq4TTfjZXB5AjFpx15iQMM"
let recrawl_start = ref None
let recrawl_end = ref None
let reset = ref false

let spec = [
  "--contract", Arg.String (fun s -> objkt_contract := s), "OBJKT contract";
  "--start", Arg.Int (fun i -> recrawl_start := Some (Int32.of_int i)), "Start level for recrawl";
  "--end", Arg.Int (fun i -> recrawl_end := Some (Int32.of_int i)), "Optional end level for recrawl";
  "--reset", Arg.Set reset, "clear all objkt contracts";
]

let operation config ext_diff op =
  match op.bo_meta with
  | None ->
    Lwt.return_error @@
    `generic ("no_metadata", Format.sprintf "no metadata found for operation %s" op.bo_hash)
  | Some meta ->
    let _, _, oindex2 = op.bo_indexes in
    if meta.op_status = `applied then
      let ext_diff = if oindex2 = 0l then meta.op_lazy_storage_diff else ext_diff in
      let op_lazy_storage_diff =
        if oindex2 = 0l then meta.op_lazy_storage_diff
        else ext_diff @ meta.op_lazy_storage_diff in
      let meta = {meta with op_lazy_storage_diff} in
      let op = { op with bo_meta = Some meta } in
      Db.Misc.use None @@ fun dbh ->
      let>? () = match op.bo_op.kind with
        | Transaction tr ->
          Db.Crawl.insert_transaction ~forward:true ~config ~dbh ~op tr
        | Origination ori ->
          if op.bo_op.source = !objkt_contract then
            Db.Crawl.insert_origination ~forward:true ~crawled:false config dbh op ori
          else Lwt.return_ok ()
        | _ -> Lwt.return_ok () in
      Lwt.return_ok ext_diff
    else Lwt.return_ok ext_diff

let block _config () b =
  Format.printf "Block %s (%ld)@." (Common.Utils.short b.hash) b.header.shell.level;
  Lwt.return_ok ()

let objkt_contracts_list () =
  Format.printf "Fetching objkt contracts@.";
  let enc = Json_encoding.(list @@ EzEncoding.ignore_enc @@ obj1 (req "address" string)) in
  let> r1 = EzReq_lwt.get (EzAPI.URL (Format.sprintf "https://staging.api.tzkt.io/v1/accounts/%s/contracts?offset=0&limit=10000" !objkt_contract)) in
  let|> r2 = EzReq_lwt.get (EzAPI.URL (Format.sprintf "https://staging.api.tzkt.io/v1/accounts/%s/contracts?offset=10000&limit=10000" !objkt_contract)) in
  match r1, r2 with
  | Error _, _ | _, Error _ -> Error (`generic ("tzkt_api_error", ""))
  | Ok s1, Ok s2 ->
    Ok (EzEncoding.destruct enc s1 @ EzEncoding.destruct enc s2)

let objkt_contracts () =
  let>? contracts = objkt_contracts_list () in
  Format.printf "Searching for objkt contracts in DB@.";
  let|>? contracts = Db.Utils.get_contracts contracts in
  Format.printf "Loading %d objkt contracts@." @@ List.length contracts;
  let map = Db.Config.db_contracts contracts in
  SMap.fold (fun c v acc ->
      SMap.update c (fun _ ->
          match v.nft_crawled with
          | Some true -> None
          | _ -> Some {v with nft_crawled = Some true}) acc) map map

let reset_contracts contracts =
  Format.printf "Resetting %d@." @@ List.length contracts;
  Db.Utils.clear_contracts contracts

let main () =
  Arg.parse spec (fun f -> filename := Some f) "recrawl_objkt.exe [options] config.json";
  if !reset then
    let>? contracts = objkt_contracts_list () in
    reset_contracts contracts
  else
    let>? contracts = objkt_contracts () in
    let>? config = Lwt.return @@ Crawler_config.get !filename Rtypes.config_enc in
    let config = { config with Config.extra = {
        Rtypes.exchange = ""; royalties = ""; transfer_manager = ""; hen_info = None;
        ft_contracts = Rtypes.SMap.empty; contracts;
        tezos_domains = None; versum_info = None; fxhash_info = None } } in
    let s = match config.Config.accounts with
      | None -> SSet.empty
      | Some s -> s in
    let s = Rtypes.SMap.fold (fun a _ acc -> SSet.add a acc) config.Config.extra.Rtypes.contracts s in
    let config = { config with Config.accounts = Some s } in
    match !recrawl_start with
    | Some start ->
      Format.printf "Recrawling@.";
      let>? _ = async_recrawl ~config ~start ?end_:!recrawl_end ~block ~operation ((), []) in
      let contracts = List.map fst @@ SMap.bindings contracts in
      let>? () = iter_rp (fun c -> Db.Crawl.set_crawled_nft c) contracts in
      Db.Utils.refresh_objkt_royalties contracts
    | _ ->
      Format.printf "Missing arguments: '--start' is required@.";
      exit 1

let () =
  EzLwtSys.run @@ fun () ->
  Lwt.map (Result.iter_error Rp.print_error) (main ())
