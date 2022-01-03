open Hooks
open Crawlori
open Make(Pg)(struct type extra = Rtypes.config end)
open Proto
open Let
open Rtypes

let filename = ref None
let recrawl_start = ref None
let recrawl_end = ref None

let spec = [
  "--start", Arg.Int (fun i -> recrawl_start := Some (Int32.of_int i)), "Start level for recrawl";
  "--end", Arg.Int (fun i -> recrawl_end := Some (Int32.of_int i)), "Optional end level for recrawl";
]

let operation config () op =
  Format.printf "Block %s (%ld)\r@?" (Common.Utils.short op.bo_block) op.bo_level;
  match config.Config.extra.hen_info, op.bo_meta with
  | None, _ | _, None -> Lwt.return_ok ()
  | Some hen_info, Some meta ->
    if meta.op_status = `applied then
      match op.bo_op.kind with
      | Transaction tr ->
        if not (tr.destination = hen_info.hen_minter) then Lwt.return_ok ()
        else
          let bm = { bm_id = hen_info.hen_minter_id; bm_types = Common.Contract_spec.hen_royalties_field } in
          let royalties = Common.Storage_diff.get_big_map_updates bm meta.op_lazy_storage_diff in
          Db.Misc.use None (fun dbh ->
              Format.printf "Block %s (%ld)@." (Common.Utils.short op.bo_block) op.bo_level;
              iter_rp (function
                  | `nat token_id, Some (`tuple [ `address part_account; `nat v ]) ->
                    Db.Crawl.insert_royalties ~dbh ~op ~forward:true {
                      roy_contract = hen_info.hen_contract; roy_token_id = Some token_id;
                      roy_royalties = [ { part_account; part_value = Z.to_int32 v } ]}
                  | _ -> Lwt.return_ok ()) royalties)
      | _ -> Lwt.return_ok ()
    else Lwt.return_ok ()

let main () =
  Arg.parse spec (fun f -> filename := Some f) "recrawl_hen_royalties.exe [options] config.json";
  let>? config = Lwt.return @@ Crawler_config.get !filename Rtypes.config_enc in
  match config.Config.extra.hen_info, !recrawl_start with
  | Some _hen_info, Some start ->
    let>? _ = async_recrawl ~config ~start ?end_:!recrawl_end ~operation ((), ()) in
    Lwt.return_ok ()
  | _ ->
    Format.printf "Missing arguments: '--start' or 'hen_info' in config file@.";
    Lwt.return_ok ()

let () =
  EzLwtSys.run @@ fun () ->
  Lwt.map (function
      | Error e -> Rp.print_error e
      | Ok _ -> ()) (main ())
