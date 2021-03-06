open Let
open Crawlori
open Make(Pg)(struct type extra = Rtypes.config end)
open Rtypes
open Config

let get file extra_enc =
  match file with
  | None ->
    Error `no_config
  | Some f ->
    try Ok (EzEncoding.destruct (Config.enc extra_enc) f)
    with _ ->
      try
        let ic = open_in f in
        let s = really_input_string ic (in_channel_length ic) in
        let config = EzEncoding.destruct (Config.enc extra_enc) s in
        Ok config
      with exn ->
        Error (`cannot_parse_config exn)

let dummy_extra = {
  exchange = ""; royalties = ""; transfer_manager = "";
  contracts = SMap.empty; ft_contracts = SMap.empty; hen_info = None;
  tezos_domains = None; versum_info = None; fxhash_info = None;
  ipfs_source = None; ipfs_timeout = None;
}

let rarible_contracts ?(db=dummy_extra) config =
  let extra = config.extra in
  if extra.exchange = "" && db.exchange = "" ||
       extra.royalties = "" && db.royalties = "" then
    Lwt.return_error (`hook_error ("missing_rarible_contracts"))
  else
    let extra = if extra.exchange = "" then { extra with exchange = db.exchange } else extra in
    let extra = if extra.royalties = "" then { extra with royalties = db.royalties } else extra in
    let extra = if extra.transfer_manager = "" then { extra with transfer_manager = db.transfer_manager } else extra in
    let extra = { extra with ft_contracts = SMap.union (fun _ v_config v_db ->
        let ft_crawled = match v_config.ft_crawled, v_db.ft_crawled with
          | None, c | c, None -> c
          | Some c_c, _ -> Some c_c in
        Some {v_config with ft_crawled}) extra.ft_contracts db.ft_contracts } in
    let extra = { extra with contracts = SMap.union (fun _ v _ -> Some v) extra.contracts db.contracts } in
    let s = match config.accounts with
      | None -> SSet.empty
      | Some s -> s in
    let s = SSet.add extra.exchange s in
    let s = SSet.add extra.royalties s in
    let s = SSet.add extra.transfer_manager s in
    let s = match extra.hen_info with None -> s | Some info -> SSet.add info.hen_minter s in
    let s = match extra.tezos_domains with None -> s | Some (c, _) -> SSet.add c s in
    let s = SMap.fold (fun a _ acc -> SSet.add a acc) extra.ft_contracts s in
    let s = SMap.fold (fun a _ acc -> SSet.add a acc) extra.contracts s in
    Lwt.return_ok { config with accounts = Some s; extra }

let fill_config config =
  let>? db_extra = Db.Config.get_extra_config () in
  let>? config = rarible_contracts ?db:db_extra config in
  let>? () = Db.Config.update_extra_config config.extra in
  Lwt.return_ok config
