open Hooks
open Crawlori
open Make(Pg)(struct type extra = Rtypes.config end)
open Proto
open Let
module SSet = Set.Make(String)

let filename = ref None
let objkt_contract = ref "KT1Aq4wWmVanpQhq4TTfjZXB5AjFpx15iQMM"
let recrawl_start = ref None
let recrawl_end = ref None

let spec = [
  "--contract", Arg.String (fun s -> objkt_contract := s), "OBJKT contract";
  "--start", Arg.Int (fun i -> recrawl_start := Some (Int32.of_int i)), "Start level for recrawl";
  "--end", Arg.Int (fun i -> recrawl_end := Some (Int32.of_int i)), "Optional end level for recrawl";
]

let handle_result config = function
  | Error e ->
    Format.printf "OBJKT originated contracts:\n%s@." @@
    EzEncoding.construct (Config.enc Rtypes.config_enc) config;
    Lwt.return_error e
  | Ok _ -> Lwt.return_ok ()

let ext ~config bop =
  match bop.bo_meta with
  | None -> Lwt.return_ok ()
  | Some meta ->
    if meta.op_status = `applied then
      match bop.bo_op.kind with
      | Transaction tr ->
        let> r = Db.Misc.use None (fun dbh ->
            Db.Crawl.insert_transaction ~forward:true ~config ~dbh ~op:bop tr) in
        handle_result config r
      | _ -> Lwt.return_ok ()
    else Lwt.return_ok ()

let config_r = ref None

let int ~config bop =
  match bop.bo_meta with
  | None -> Lwt.return_ok ()
  | Some meta ->
    if meta.op_status = `applied then
      match bop.bo_op.kind with
      | Transaction tr ->
        let> r = Db.Misc.use None (fun dbh ->
            Db.Crawl.insert_transaction ~forward:true ~config ~dbh ~op:bop tr) in
        handle_result config r
      | Origination ori ->
        if bop.bo_op.source = !objkt_contract then
          let> r = Db.Misc.use None (fun dbh ->
              let>? () = Db.Crawl.insert_origination ~forward:true ~crawled:false config dbh bop ori in
              config_r := Some config;
              Lwt.return_ok ()
            ) in
          handle_result config r
        else Lwt.return_ok ()
      | _ -> Lwt.return_ok ()
    else Lwt.return_ok ()

let operation ~config (index, ()) b o =
  fold_rp (fun (index, ()) m ->
      let bo_meta = Option.bind m.man_metadata (fun x -> Some x.man_operation_result) in
      let bop = {
        bo_block = b.hash; bo_level = b.header.shell.level;
        bo_tsp = b.header.shell.timestamp; bo_hash = o.op_hash;
        bo_op = m.man_info; bo_meta; bo_numbers = None;
        bo_nonce = None; bo_counter = m.man_numbers.counter;
        bo_index = index } in
      let>? () = ext ~config bop in
      let internals = match m.man_metadata with
        | None -> []
        | Some meta -> meta.man_internal_operation_results in
      let|>? (next_index, ()) = fold_rp (fun (index, ()) iop ->
          let bo_meta = Some {
              iop.in_result with
              op_lazy_storage_diff =
                iop.in_result.op_lazy_storage_diff @
                (Option.fold ~none:[] ~some:(fun m -> m.man_operation_result.op_lazy_storage_diff)
                   m.man_metadata) } in
          let bop = {
              bo_block = b.hash; bo_level = b.header.shell.level;
              bo_tsp = b.header.shell.timestamp; bo_hash = o.op_hash;
              bo_op = iop.in_content; bo_meta; bo_numbers = None;
              bo_nonce = Some iop.in_nonce; bo_counter = m.man_numbers.counter;
              bo_index = index } in
          let|>? acc = int ~config bop in
          (Int32.succ index, acc)) (index, ()) internals in
      (next_index, ())) (index, ()) o.op_contents

let block config () b =
  Format.printf "Block %s (%ld)@." (Common.Utils.short b.hash) b.header.shell.level;
  let|>? _, acc =
    fold_rp (fun (index, ()) o -> operation ~config (index, ()) b o)
      (0l, ()) b.operations in
  acc

let print_config_r () =
  match !config_r with
  | None -> ()
  | Some c ->
    Format.printf "OBJKT originated contracts:\n%s@." @@
    EzEncoding.construct (Config.enc Rtypes.config_enc) c

let main () =
  Arg.parse spec (fun f -> filename := Some f) "recrawl_objkt.exe [options] config.json";
  let>? config = Lwt.return @@ Crawler_config.get !filename Rtypes.config_enc in
  let config = { config with Config.extra = {
      Rtypes.exchange = ""; royalties = ""; transfer_manager = ""; hen_info = None;
      ft_contracts = Rtypes.SMap.empty; contracts = config.Config.extra.Rtypes.contracts;
      tezos_domains = None; versum_info = None; fxhash_info = None } } in
  let s = match config.Config.accounts with
    | None -> SSet.empty
    | Some s -> s in
  let s = Rtypes.SMap.fold (fun a _ acc -> SSet.add a acc) config.Config.extra.Rtypes.contracts s in
  let config = { config with Config.accounts = Some s } in
  match !recrawl_start with
  | Some start ->
    let> r = async_recrawl ~config ~start ?end_:!recrawl_end ~block ((), ()) in
    print_config_r ();
    Lwt.return r
  | _ ->
    Format.printf "Missing arguments: '--start' is required@.";
    Lwt.return_ok ((), ())

let () =
  Sys.(set_signal sigint (Signal_handle (fun _ -> print_config_r (); exit 1)));
  EzLwtSys.run @@ fun () ->
  Lwt.map (function
      | Error e -> Rp.print_error e
      | Ok _ -> ()) (main ())
