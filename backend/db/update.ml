let () =
  EzPGUpdater.main Cconfig.database ~upgrades:Updates.upgrades
