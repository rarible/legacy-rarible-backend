open Let
open Crawlori
open Make(Pg)

let fill_config config =
  let open Config in
  let>? accounts = Db.get_contracts () in
  match accounts, config.accounts with
  | [], None -> Lwt.return_ok ()
  | [], Some s -> iter_rp Db.insert_fake (SSet.elements s)
  | l, None -> config.accounts <- Some (SSet.of_list l); Lwt.return_ok ()
  | l, Some s ->
    let|>? () = iter_rp Db.insert_fake (SSet.elements s) in
    config.accounts <- Some (List.fold_left (fun acc a -> SSet.add a acc) s l)

let () =
  EzLwtSys.run @@ fun () ->
  Lwt.map (fun _ -> ()) @@
  let>? config = Unix_sys.get_config () in
  Hooks.set_operation Db.set_operation;
  Hooks.set_block Db.set_block;
  Hooks.set_main Db.set_main;
  let>? () = fill_config config in
  let>? () = init config in
  loop config
