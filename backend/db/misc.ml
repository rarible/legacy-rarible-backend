module PGOCaml = Pg.PGOCaml

let () = Pg.PG.Pool.init ()

let use dbh f = match dbh with
  | None -> Pg.PG.Pool.use f
  | Some dbh -> f dbh

let one ?(err="expected unique row not found") l = match l with
  | [ x ] -> Lwt.return_ok x
  | _ -> Lwt.return_error (`hook_error err)
