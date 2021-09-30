open Let
open Crawlori
open Make(Pg)(struct type extra = Rtypes.config end)
open Rtypes
open Config

let dummy_extra = { admin_wallet = ""; exchange_v2 = ""; royalties = ""; validator = "" }

let rarible_contracts ?(db=dummy_extra) config =
  let>? () =
    if config.extra.exchange_v2 = "" && db.exchange_v2 = "" ||
       config.extra.royalties = "" && db.royalties = "" ||
       config.extra.validator = "" && db.validator = "" then
      Lwt.return_error @@ `hook_error ("missing_rarible_contracts")
    else Lwt.return_ok () in
  if config.extra.exchange_v2 = "" then config.extra.exchange_v2 <- db.exchange_v2;
  if config.extra.royalties = "" then config.extra.royalties <- db.royalties;
  if config.extra.validator = "" then config.extra.validator <- db.validator;
  let s = match config.accounts with
    | None -> SSet.empty
    | Some s -> s in
  let s = SSet.add config.extra.exchange_v2 s in
  let s = SSet.add config.extra.validator s in
  config.accounts <- Some s;
  Lwt.return_ok ()

let fill_config config =
  let>? accounts = Db.get_contracts () in
  let>? () = match accounts, config.accounts with
    | [], None -> Lwt.return_ok ()
    | [], Some s -> iter_rp Db.insert_fake (SSet.elements s)
    | l, None -> config.accounts <- Some (SSet.of_list l); Lwt.return_ok ()
    | l, Some s ->
      let|>? () = iter_rp Db.insert_fake (SSet.elements s) in
      config.accounts <- Some (List.fold_left (fun acc a -> SSet.add a acc) s l) in
  let>? db_extra = Db.get_extra_config () in
  let>? () = rarible_contracts ?db:db_extra config in
  Db.update_extra_config config.extra

let () =
  EzLwtSys.run @@ fun () ->
  Lwt.map (fun _ -> ()) @@
  let>? config = Unix_sys.get_config Rtypes.config_enc in
  Hooks.set_operation Db.insert_operation;
  Hooks.set_block Db.insert_block;
  Hooks.set_main Db.set_main;

  let>? () = fill_config config in
  let>? () = init config in
  loop config
