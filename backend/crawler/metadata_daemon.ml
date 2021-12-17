let contract = ref None

let spec = [
  "--contract", Arg.String (fun s -> contract := Some s),
  "Only try to reset metadata for this contract";
]

let () =
  Lwt_main.run @@ Lwt.map (fun _ -> ()) @@
  Db.update_unknown_metadata ?contract:!contract ()
