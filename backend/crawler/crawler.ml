open Let
open Crawlori
open Make(Pg)(struct type extra = Rtypes.config end)
open Rtypes
open Config

let kafka_config_file = ref ""
let filename = ref None

let dummy_extra = {
  admin_wallet = ""; exchange_v2 = ""; royalties = ""; validator = "";
  ft_fa2 = []; ft_fa1 = []; ft_lugh = [];
}

let rarible_contracts ?(db=dummy_extra) config =
  let extra = config.extra in
  if extra.exchange_v2 = "" && db.exchange_v2 = "" ||
       extra.royalties = "" && db.royalties = "" ||
       extra.validator = "" && db.validator = "" then
    Lwt.return_error (`hook_error ("missing_rarible_contracts"))
  else
    let extra = if extra.exchange_v2 = "" then { extra with exchange_v2 = db.exchange_v2 } else extra in
    let extra = if extra.royalties = "" then { extra with royalties = db.royalties } else extra in
    let extra = if extra.validator = "" then { extra with validator = db.validator } else extra in
    let extra = if extra.ft_fa2 = [] then { extra with ft_fa2 = db.ft_fa2 } else extra in
    let extra = if extra.ft_fa1 = [] then { extra with ft_fa1 = db.ft_fa1 } else extra in
    let extra = if extra.ft_lugh = [] then { extra with ft_lugh = db.ft_lugh } else extra in
    let s = match config.accounts with
      | None -> SSet.empty
      | Some s -> s in
    let s = SSet.add extra.exchange_v2 s in
    let s = SSet.add extra.validator s in
    let s = List.fold_left (fun acc a -> SSet.add a acc) s (extra.ft_fa2 @ extra.ft_fa1 @ extra.ft_lugh) in
    Lwt.return_ok { config with accounts = Some s; extra }

let fill_config config =
  let>? accounts = Db.get_contracts () in
  let>? () = match accounts, config.accounts with
    | [], None -> Lwt.return_ok ()
    | [], Some s -> iter_rp Db.insert_fake (SSet.elements s)
    | l, None -> config.accounts <- Some (SSet.of_list l); Lwt.return_ok ()
    | l, Some s ->
      let|>? () = iter_rp Db.insert_fake (SSet.elements s) in
      config.accounts <- Some (List.fold_left (fun acc a -> SSet.add a acc) s l) in
  let>? db_extra = Db.get_extra_config () in
  let>? config = rarible_contracts ?db:db_extra config in
  let>? () = Db.update_extra_config config.extra in
  Lwt.return_ok config


let args = [
  ("--kafka-config", Arg.Set_string kafka_config_file, "set kafka configuration")
]

let usage = "usage: " ^ Sys.argv.(0) ^ " conf.json [--kafka-config string]"

let get_config extra =
  Crp.print_rp @@
  match !filename with
  | None -> Crp.rerr `no_config
  | Some f ->
    try
      let ic = open_in f in
      let json = Ezjsonm.from_channel ic in
      close_in ic;
      let config = Json_encoding.(destruct (Cconfig.enc extra) json) in
      Crp.rok config
    with exn -> Crp.rerr (`cannot_parse_config exn)

let () =
  EzLwtSys.run @@ fun () ->
  Arg.parse args (fun f -> filename := Some f) usage;
  Lwt.map (fun _ -> ()) @@
  let>? () = Db.Rarible_kafka.may_set_kafka_config !kafka_config_file in
  let>? config = get_config Rtypes.config_enc in
  Hooks.set_operation Db.insert_operation;
  Hooks.set_block Db.insert_block;
  Hooks.set_main Db.set_main;
  let>? config = fill_config config in
  let>? () = init config in
  loop config
