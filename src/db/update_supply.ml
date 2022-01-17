let () =
  Lwt_main.run @@ Lwt.map (fun _ -> ()) @@
  Db.Utils.update_supply ()
