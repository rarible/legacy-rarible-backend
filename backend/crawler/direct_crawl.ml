open Let
open Crawlori
open Proto

module PGOCaml = Pg.PGOCaml

let register_predecessor ?dbh b =
  Db.use dbh @@ fun dbh ->
  [%pgsql dbh
      "insert into predecessors(hash, predecessor, level, main) \
       values(${b.hash}, ${b.header.shell.predecessor}, ${b.header.shell.level}, true) \
       on conflict do nothing"]

let head ?dbh () =
  Db.use dbh @@ fun dbh ->
  let|>? l = [%pgsql dbh "select level from predecessors where main order by level desc limit 1"] in
  match l with
  | [ level ] -> Some level
  | _ -> None

let transaction f =
  Db.use None @@ fun dbh ->
  let>? () = PGOCaml.begin_work dbh in
  let> r = f dbh in match r with
  | Ok r ->
    let|>? () = PGOCaml.commit dbh in
    r
  | Error e ->
    let>? () = PGOCaml.rollback dbh in
    Lwt.return_error e

let handle_block ~config b =
  ignore config;
  transaction @@ fun dbh ->
  Format.printf "Block %s (%ld)@." (Common.Utils.short b.hash) b.header.shell.level;
  let>? _ = fold_rp (fun id op ->
      fold_rp (fun id c ->
          match c.man_metadata with
          | None -> Lwt.return_ok id
          | Some meta ->
            let bop = {
              Hooks.bo_block = b.hash; bo_level = b.header.shell.level;
              bo_tsp = b.header.shell.timestamp; bo_hash = op.op_hash;
              bo_op = c.man_info; bo_index = id;
              bo_meta = Option.map (fun m -> m.man_operation_result) c.man_metadata;
              bo_numbers = Some c.man_numbers; bo_nonce = None;
              bo_counter = c.man_numbers.counter } in
            let>? () =
              if meta.man_operation_result.op_status = `applied then
                match c.man_info.kind with
                | Origination ori ->
                  Db.insert_origination ~forward:true config dbh bop ori
                | Transaction tr ->
                  Db.insert_transaction ~forward:true ~config ~dbh ~op:bop tr
                | _ -> Lwt.return_ok ()
              else Lwt.return_ok () in
            let id = Int32.succ id in
            fold_rp (fun id iop ->
                let bop = {
                  Hooks.bo_block = b.hash; bo_level = b.header.shell.level;
                  bo_tsp = b.header.shell.timestamp; bo_hash = op.op_hash;
                  bo_op = c.man_info; bo_index = id; bo_meta = Some iop.in_result;
                  bo_numbers = None; bo_nonce = Some iop.in_nonce;
                  bo_counter = c.man_numbers.counter } in
                let>? () =
                  if meta.man_operation_result.op_status = `applied then
                    match iop.in_content.kind with
                    | Origination ori ->
                      Db.insert_origination ~forward:true config dbh bop ori
                    | Transaction tr ->
                      Db.insert_transaction ~forward:true ~config ~dbh ~op:bop tr
                    | _ -> Lwt.return_ok ()
                  else Lwt.return_ok () in
                Lwt.return_ok (Int32.succ id)
              ) id meta.man_internal_operation_results
        ) id op.op_contents
    ) 0l b.operations in
  register_predecessor ~dbh b

let register_level config level =
  let>? block = Request.block config (Int32.to_string level) in
  handle_block ~config block

let update_finally () =
  Db.update_supply ()

let register_direct config ~start ~end_ =
  let rec aux level =
    if level < end_ then
      let>? () = register_level config level in
      aux (Int32.succ level)
    else update_finally () in
  aux start

let end_ = ref None

let get_limits config =
  let>? meta = Request.head_metadata config in
  let blockchain_level = meta.Proto.meta_level.nl_level in
  let>? db_level = head () in
  let end_ = match !end_ with
    | None -> Int32.sub blockchain_level 50l
    | Some e -> min (Int32.sub blockchain_level 50l) e in
  let>? start = match db_level, config.Config.start with
    | None, None -> Lwt.return_error (`hook_error "No start given")
    | Some db, Some st -> Lwt.return_ok (min (max db st) end_)
    | Some s, _ | _, Some s -> Lwt.return_ok (min s end_) in
  Lwt.return_ok (start, end_)

let filename = ref None
let spec = [
  "--end", Arg.Int (fun i -> end_ := Some (Int32.of_int i)), "end of direct crawl"
]

let main () =
  Arg.parse spec (fun f -> filename := Some f) "direct_crawl config.json";
  let>? config = Lwt.return @@ Crawler_config.get !filename Rtypes.config_enc in
  let>? config = Crawler_config.fill_config config in
  Format.printf "Config used:\n%s@." @@
  EzEncoding.construct ~compact:false (Config.enc Rtypes.config_enc) config;
  let>? start, end_ = get_limits config in
  register_direct config ~start ~end_

let () =
  Lwt_main.run @@
  Lwt.map (function
      | Error e -> Format.eprintf "%s" @@ Rp.string_of_error e
      | Ok () -> ()) @@
  main ()
