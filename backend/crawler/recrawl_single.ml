open Hooks
open Crawlori
open Make(Pg)(struct type extra = Rtypes.config end)
open Proto
open Let

let filename = ref None
let ft_contract = ref None
let recrawl_start = ref None
let recrawl_end = ref None

let spec = [
  "--contract", Arg.String (fun s -> ft_contract := Some s), "FT contract to recrawl";
  "--start", Arg.Int (fun i -> recrawl_start := Some (Int32.of_int i)), "Start level for recrawl";
  "--end", Arg.Int (fun i -> recrawl_end := Some (Int32.of_int i)), "Optional end level for recrawl";
]

let handle_operation contract ft config () op =
  Format.printf "Block %s (%ld)\r@?" (Common.Utils.short op.bo_block) op.bo_level;
  match op.bo_meta with
  | None -> Lwt.return_ok ()
  | Some meta ->
    if meta.op_status = `applied then
      match op.bo_op.kind with
      | Transaction tr ->
        if not (tr.destination = contract) then Lwt.return_ok ()
        else
          Db.use None (fun dbh ->
              Format.printf "Block %s (%ld)@." (Common.Utils.short op.bo_block) op.bo_level;
              Db.insert_ft ~dbh ~config ~op ~contract {ft with Rtypes.ft_crawled=true})
      | _ -> Lwt.return_ok ()
    else Lwt.return_ok ()

let handle_block _config () bl =
  Db.use None (fun dbh -> Db.set_main_recrawl ~dbh bl.hash)

let main () =
  Arg.parse spec (fun f -> filename := Some f) "recrawl_async.exe [options] config.json";
  let>? config = Lwt.return @@ Crawler_config.get !filename Rtypes.config_enc in
  match !ft_contract, !recrawl_start with
  | Some ft_contract, Some start ->
    let>? ft = Db.get_ft_contract ft_contract in
    begin match ft with
      | None ->
        Format.printf "Contract not in DB@.";
        Lwt.return_ok ()
      | Some ft ->

        let>? _ = async_recrawl ~config ~start ?end_:!recrawl_end
            ~operation:(handle_operation ft_contract ft)
            ~block:handle_block
            ((), ()) in
        Db.set_crawled ft_contract
    end
  | _ ->
      Format.printf "Missing arguments: '--contract', '--kind', '--id', '--start' are required@.";
      Lwt.return_ok ()

let () =
  EzLwtSys.run @@ fun () ->
  Lwt.map (function
      | Error e -> Rp.print_error e
      | Ok _ -> ()) (main ())
