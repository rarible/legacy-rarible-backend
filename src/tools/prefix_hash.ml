open Let

let hashes = ref []
let collection = ref true
let spec = [
  "--owner", Arg.Clear collection, "search an owner";
  "--collection", Arg.Set collection, "search a collection"
]
let () =
  Arg.parse spec (fun s -> hashes := !hashes @ [ s ]) "prefix_hash";
  Lwt_main.run @@ Lwt.map (fun _ -> ()) @@
  iter_rp (fun h ->
      let> r = Db.Utils.find_hash ~collection:!collection h in
      Format.printf "%s -> @?" h;
      let () = match r with
        | Error _ | Ok [] -> Format.printf "not found@."
        | Ok [ h ] -> Format.printf "%s@." h
        | Ok l -> Format.printf "\n\t%s@." @@ String.concat "\n\t" l in
      Lwt.return_ok ()
    ) !hashes
