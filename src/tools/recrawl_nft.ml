open Hooks
open Crawlori
open Make(Pg)(struct type extra = Rtypes.config end)
open Proto
open Let
module SMap = Map.Make(String)

let filename = ref None
let contracts = ref []
let recrawl_start = ref None
let recrawl_end = ref None

let spec = [
  "--contracts", Arg.String (fun s -> contracts := String.split_on_char ',' s), "contracts to recrawl";
  "--start", Arg.Int (fun i -> recrawl_start := Some (Int32.of_int i)), "Start level for recrawl";
  "--end", Arg.Int (fun i -> recrawl_end := Some (Int32.of_int i)), "Optional end level for recrawl";
]

let operation config () op =
  Format.printf "Block %s (%ld)\r@?" (Common.Utils.short op.bo_block) op.bo_level;
  match op.bo_meta with
  | None -> Lwt.return_error @@
    `generic ("no_metadata", Format.sprintf "no metadata found for operation %s" op.bo_hash)
  | Some meta ->
    if meta.op_status = `applied then
      match op.bo_op.kind with
      | Transaction tr ->
        begin match tr.parameters, SMap.find_opt tr.destination config.Crawlori.Config.extra.Rtypes.contracts with
          | Some {entrypoint; value = Micheline m }, Some nft ->
            Db.Misc.use None @@ fun dbh ->
            Format.printf "Block %s (%ld)@." (Common.Utils.short op.bo_block) op.bo_level;
            Db.Crawl.insert_nft ~dbh ~config ~meta ~op ~contract:tr.destination ~forward:true ~entrypoint ~nft m
          | _ -> Lwt.return_ok ()
        end
      | Origination ori ->
        let contract = Tzfunc.Crypto.op_to_KT1 op.bo_hash in
        if List.mem contract !contracts then
          Db.Misc.use None @@ fun dbh ->
          Db.Crawl.insert_origination ~forward:true ~crawled:false config dbh op ori
        else Lwt.return_ok ()
      | _ -> Lwt.return_ok ()
    else Lwt.return_ok ()

let main () =
  Arg.parse spec (fun f -> filename := Some f) "recrawl_nft.exe [options] config.json";
  let>? config = Lwt.return @@ Crawler_config.get !filename Rtypes.config_enc in
  let>? db_contracts = Db.Utils.get_contracts !contracts in
  let nft_contracts = Db.Config.db_contracts db_contracts in
  config.Cconfig.extra.Rtypes.contracts <- nft_contracts;
  match !recrawl_start with
  | Some start ->
    let>? _ = async_recrawl ~config ~start ?end_:!recrawl_end ~operation ((), ()) in
    iter_rp (fun contract -> Db.Crawl.set_crawled_nft contract) !contracts
  | _ ->
    Format.printf "Missing arguments: '--start', '--contracts' are required@.";
    Lwt.return_ok ()

let () =
  EzLwtSys.run @@ fun () ->
  Lwt.map (function
      | Error e -> Rp.print_error e
      | Ok _ -> ()) (main ())
