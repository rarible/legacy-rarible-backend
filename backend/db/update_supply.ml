let () =
  Lwt_main.run @@ Lwt.map (fun _ -> ()) @@
  Db.update_supply ()
