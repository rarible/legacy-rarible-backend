open Let

let hashes = ref []

let () =
  Arg.parse [] (fun s -> hashes := !hashes @ [ s ]) "prefix_hash";
  Lwt_main.run @@ Lwt.map (fun _ -> ()) @@
  iter_rp (fun h ->
      let> r = Db.find_hash h in
      Format.printf "%s -> @?" h;
      let () = match r with
        | Error _ | Ok [] -> Format.printf "not found@."
        | Ok [ h ] -> Format.printf "%s@." h
        | Ok l -> Format.printf "\n\t%s@." @@ String.concat "\n\t" l in
      Lwt.return_ok ()
    ) !hashes
