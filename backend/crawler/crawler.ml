open Let
open Crawlori
open Make(Pg)

let fill_config config =
  let open Config in
  let|>? accounts = Db.get_contracts () in
  match accounts, config.accounts with
  | [], _ -> ()
  | l, None -> config.accounts <- Some (SSet.of_list l)
  | l, Some s ->
    config.accounts <- Some (List.fold_left (fun acc a -> SSet.add a acc) s l)

let () =
  EzLwtSys.run @@ fun () ->
  Lwt.map (fun _ -> ()) @@
  let>? config = Unix_sys.get_config () in
  Hooks.set_operation Db.set_operation;
  Hooks.set_main Db.set_main;
  let>? () = fill_config config in
  let>? () = init config in
  loop config
