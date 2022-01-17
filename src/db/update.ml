let () =
  let database = match Sys.getenv_opt "PGDATABASE" with
    | None -> Cconfig.database
    | Some db -> db in
  EzPGUpdater.main database ~upgrades:Updates.upgrades
