open Let
open Crawlori
open Make(Pg)(struct type extra = Rtypes.config end)

let kafka_config_file = ref ""
let filename = ref None



let args = [
  ("--kafka-config", Arg.Set_string kafka_config_file, "set kafka configuration")
]

let usage = "usage: " ^ Sys.argv.(0) ^ " conf.json [--kafka-config string]"

let () =
  EzLwtSys.run @@ fun () ->
  Arg.parse args (fun f -> filename := Some f) usage;
  Lwt.map (function
      | Error e ->
        Format.eprintf "%s@." (Rp.string_of_error e);
        exit 1
      | Ok () -> ()) @@
  let>? () = Db.Rarible_kafka.may_set_kafka_config !kafka_config_file in
  EzPGUpdater.main Cconfig.database ~upgrades:Updates.upgrades;
  let>? config = Lwt.return @@ Crawler_config.get !filename Rtypes.config_enc in
  Hooks.set_operation Db.insert_operation;
  Hooks.set_block Db.insert_block;
  Hooks.set_main Db.set_main;
  Hooks.set_forward_end (fun _config _level -> Db.update_supply ());
  let>? config = Crawler_config.fill_config config in
  Format.printf "Config used:\n%s@." @@
  EzEncoding.construct ~compact:false (Config.enc Rtypes.config_enc) config;
  let>? () = init config in
  loop config
