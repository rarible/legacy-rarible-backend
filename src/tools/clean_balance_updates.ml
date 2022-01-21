let level = ref None

let spec = [
  "--level", Arg.Int (fun i -> level := Some (Int32.of_int i)),
  "Max level to remove token balance updates"
]

let () =
  Arg.parse spec (fun _ -> ()) "clean_balance_update.exe [OPTIONS]";
  Lwt_main.run @@ Lwt.map (fun _ -> ()) @@
  Db.Utils.clean_balance_updates ?level:!level ()
