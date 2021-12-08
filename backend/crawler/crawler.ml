open Let
open Crawlori
open Make(Pg)(struct type extra = Rtypes.config end)
open Rtypes
open Config

let kafka_config_file = ref ""
let filename = ref None

let dummy_extra = {
  admin_wallet = ""; exchange = ""; royalties = "";
  contracts = SMap.empty; ft_contracts = SMap.empty
}

let rarible_contracts ?(db=dummy_extra) config =
  let extra = config.extra in
  if extra.exchange = "" && db.exchange = "" ||
       extra.royalties = "" && db.royalties = "" then
    Lwt.return_error (`hook_error ("missing_rarible_contracts"))
  else
    let extra = if extra.exchange = "" then { extra with exchange = db.exchange } else extra in
    let extra = if extra.royalties = "" then { extra with royalties = db.royalties } else extra in
    let extra = { extra with ft_contracts = SMap.union (fun _ _ v -> Some v) extra.ft_contracts db.ft_contracts } in
    let extra = { extra with contracts = SMap.union (fun _ v _ -> Some v) extra.contracts db.contracts } in
    let s = match config.accounts with
      | None -> SSet.empty
      | Some s -> s in
    let s = SSet.add extra.exchange s in
    let s = SMap.fold (fun a _ acc -> SSet.add a acc) extra.ft_contracts s in
    let s = SMap.fold (fun a _ acc -> SSet.add a acc) extra.contracts s in
    Lwt.return_ok { config with accounts = Some s; extra }

let fill_config config =
  let>? db_extra = Db.get_extra_config () in
  let>? config = rarible_contracts ?db:db_extra config in
  let>? () = Db.update_extra_config config.extra in
  Lwt.return_ok config


let args = [
  ("--kafka-config", Arg.Set_string kafka_config_file, "set kafka configuration")
]

let usage = "usage: " ^ Sys.argv.(0) ^ " conf.json [--kafka-config string]"

let () =
  EzLwtSys.run @@ fun () ->
  Arg.parse args (fun f -> filename := Some f) usage;
  Lwt.map (fun _ -> ()) @@
  let>? () = Db.Rarible_kafka.may_set_kafka_config !kafka_config_file in
  let>? config = Lwt.return @@ Crawler_config.get !filename Rtypes.config_enc in
  Hooks.set_operation Db.insert_operation;
  Hooks.set_block Db.insert_block;
  Hooks.set_main Db.set_main;
  let>? config = fill_config config in
  Format.printf "Config used:\n%s@." @@
  EzEncoding.construct ~compact:false (Config.enc Rtypes.config_enc) config;
  let>? () = init config in
  loop config
