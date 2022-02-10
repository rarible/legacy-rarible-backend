open Hooks
open Crawlori
open Make(Pg)(struct type extra = Rtypes.config end)
open Proto
open Let
open Rtypes
open Common
open Utils

let filename = ref None
let recrawl_start = ref None
let recrawl_end = ref None

let spec = [
  "--start", Arg.Int (fun i -> recrawl_start := Some (Int32.of_int i)), "Start level for recrawl";
  "--end", Arg.Int (fun i -> recrawl_end := Some (Int32.of_int i)), "Optional end level for recrawl";
]

let insert_op ~config ~contract ~entrypoint ~op m =
  Db.Misc.use None @@ fun dbh ->
  if contract = config.Crawlori.Config.extra.royalties then (* royalties *)
    match Parameters.parse_royalties entrypoint m with
    | Ok roy ->
      Format.printf "Block %s (%ld)@." (Common.Utils.short op.bo_block) op.bo_level;
      Format.printf "\027[0;35mset royalties %s %ld\027[0m@." (short op.bo_hash) op.bo_index;
      let|>? _ = Db.Crawl.insert_royalties ~dbh ~op ~forward:true roy in
      ()
    | _ -> Lwt.return_ok ()
  else if contract = config.Crawlori.Config.extra.exchange then (* exchange *)
    begin match Parameters.parse_cancel entrypoint m with
      | Ok { cc_hash; cc_maker_edpk; cc_maker; cc_make ; cc_take; cc_salt } ->
        Format.printf "Block %s (%ld)@." (Common.Utils.short op.bo_block) op.bo_level;
        Format.printf "\027[0;35mcancel order %s %ld %s\027[0m@."
          (short op.bo_hash) op.bo_index (short (cc_hash :> string));
        Db.Crawl.insert_cancel ~dbh ~op ~maker_edpk:cc_maker_edpk ~maker:cc_maker
          ~make:cc_make ~take:cc_take ~salt:cc_salt ~forward:true cc_hash
      | _ -> Lwt.return_ok ()
    end
  else if contract = config.Crawlori.Config.extra.transfer_manager then (* transfer_manager *)
    begin match Parameters.parse_do_transfers entrypoint m with
      | Ok {dt_left; dt_left_maker_edpk; dt_left_maker; dt_left_make_asset;
            dt_left_take_asset; dt_left_salt;
            dt_right; dt_right_maker_edpk; dt_right_maker; dt_right_make_asset;
            dt_right_take_asset; dt_right_salt;
            dt_fill_make_value; dt_fill_take_value} ->
        Format.printf "Block %s (%ld)@." (Common.Utils.short op.bo_block) op.bo_level;
        Format.printf "\027[0;35mdo transfers %s %ld %s %s\027[0m@."
          (short op.bo_hash) op.bo_index (short (dt_left :> string)) (short (dt_right :> string));
        Db.Crawl.insert_do_transfers
          ~dbh ~op ~forward:true
          ~left:dt_left ~left_maker_edpk:dt_left_maker_edpk
          ~left_maker:dt_left_maker ~left_make_asset:dt_left_make_asset
          ~left_take_asset:dt_left_take_asset ~left_salt:dt_left_salt
          ~right:dt_right ~right_maker_edpk:dt_right_maker_edpk
          ~right_maker:dt_right_maker ~right_make_asset:dt_right_make_asset
          ~right_take_asset:dt_right_take_asset ~right_salt:dt_right_salt
          ~fill_make_value:dt_fill_make_value ~fill_take_value:dt_fill_take_value ()
      | _ -> Lwt.return_ok ()
    end
  else Lwt.return_ok ()

let operation config () op =
  match op.bo_meta with
  | None -> Lwt.return_error @@
    `generic ("no_metadata", Format.sprintf "no metadata found for operation %s" op.bo_hash)
  | Some meta ->
    if meta.op_status = `applied then
      match op.bo_op.kind with
      | Transaction tr ->
        begin match tr.parameters with
          | Some {entrypoint; value = Micheline m } ->
            insert_op ~config ~contract:tr.destination ~entrypoint ~op m
          | _ -> Lwt.return_ok ()
        end
      | _ -> Lwt.return_ok ()
    else Lwt.return_ok ()

let block _config () b =
  Format.printf "Block %s (%ld)\r@?" (short b.hash) b.header.shell.level;
  Lwt.return_ok ()

let main () =
  Arg.parse spec (fun f -> filename := Some f) "recrawl_exchange.exe [options] config.json";
  let>? config = Lwt.return @@ Crawler_config.get !filename Rtypes.config_enc in
  match !recrawl_start with
  | Some start ->
    let|>? _ = async_recrawl ~config ~start ?end_:!recrawl_end ~operation ~block ((), ()) in
    ()
  | _ ->
    Format.printf "Missing arguments: '--start' is required@.";
    Lwt.return_ok ()

let () =
  EzLwtSys.run @@ fun () ->
  Lwt.map (function
      | Error e -> Rp.print_error e
      | Ok _ -> ()) (main ())
