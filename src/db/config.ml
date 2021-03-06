open Let
open Rtypes
open Misc

let db_contracts =
  List.fold_left (fun acc r ->
      match r#ledger_key, r#ledger_value with
      | Some k, Some v ->
        let bmt_key = EzEncoding.destruct Mtyped.stype_enc.Proto.json k in
        let bmt_value = EzEncoding.destruct Mtyped.stype_enc.Proto.json v in
        let v = {
          nft_ledger = {bm_types = {bmt_key; bmt_value}; bm_id = Z.of_string r#ledger_id};
          nft_meta_id=Option.map Z.of_string r#metadata_id;
          nft_token_meta_id=Option.map Z.of_string r#token_metadata_id;
          nft_royalties_id=Option.map Z.of_string r#royalties_id;
          nft_crawled=Some r#crawled; nft_kind = Common.Utils.nft_kind_of_string r#kind
        } in
        SMap.add r#address v acc
      | _ -> acc) SMap.empty

let db_ft_contract r =
  let v = match r#kind, r#ledger_key, r#ledger_value with
    | "fa2_single", _, _ -> Some Fa2_single
    | "fa1", _, _ -> Some Fa1
    | "fa2_multiple", _, _ -> Some Fa2_multiple
    | "lugh", _, _ -> Some Lugh
    | "fa2_multiple_inversed", _, _ -> Some Fa2_multiple_inversed
    | "custom", Some k, Some v ->
      let bmt_key = EzEncoding.destruct Mtyped.stype_enc.Proto.json k in
      let bmt_value = EzEncoding.destruct Mtyped.stype_enc.Proto.json v in
      Some (Custom {bmt_key; bmt_value})
    | _ -> None in
  match v with
  | None -> None
  | Some ft_kind -> Some {
      ft_kind; ft_ledger_id = Z.of_string r#ledger_id; ft_decimals = r#decimals;
      ft_crawled=Some r#crawled; ft_token_id = Option.map Z.of_string r#token_id}

let db_ft_contracts =
  List.fold_left (fun acc r ->
      match db_ft_contract r with
      | None -> acc
      | Some ft -> SMap.add r#address ft acc) SMap.empty

let get_extra_config ?dbh () =
  use dbh @@ fun dbh ->
  let>? contracts =
    [%pgsql.object dbh
        "select kind, address, ledger_id, ledger_key, ledger_value, metadata_id, \
         token_metadata_id, royalties_id, crawled \
         from contracts where main"] in
  let>? ft_contracts =
    [%pgsql.object dbh
        "select address, kind, ledger_id, ledger_key, ledger_value, crawled, \
         token_id, decimals from ft_contracts"] in
  let>? r = [%pgsql.object dbh
      "select exchange, royalties, transfer_manager from state"] in
  match r with
  | [ r ] ->
    let contracts = db_contracts contracts in
    let ft_contracts = db_ft_contracts ft_contracts in
    Lwt.return_ok (Some {
      exchange = r#exchange;
      royalties = r#royalties;
      transfer_manager = r#transfer_manager;
      ft_contracts; contracts;
      hen_info = None; tezos_domains = None; versum_info = None; fxhash_info = None;
      ipfs_source = None; ipfs_timeout = None;
    })
  | [] -> Lwt.return_ok None
  | _ -> Lwt.return_error (`hook_error "wrong_state")

let update_ft_contract ?dbh contract lk =
  let id = Z.to_string lk.ft_ledger_id in
  let token_id = Option.map Z.to_string lk.ft_token_id in
  let no_crawled, crawled = match lk.ft_crawled with
    | None -> true, false
    | Some b -> false, b in
  let kind, k, v = match lk.ft_kind with
    | Fa2_single -> "fa2_single", None, None
    | Fa2_multiple -> "fa2_multiple", None, None
    | Fa2_multiple_inversed -> "fa2_multiple_inversed", None, None
    | Fa1 -> "fa1", None, None
    | Lugh -> "lugh", None, None
    | Custom {bmt_key; bmt_value} ->
      "custom",
      Some (EzEncoding.construct Mtyped.stype_enc.Proto.json bmt_key),
      Some (EzEncoding.construct Mtyped.stype_enc.Proto.json bmt_value) in
  use dbh @@ fun dbh ->
  [%pgsql dbh
      "insert into ft_contracts(address, kind, ledger_id, ledger_key, \
       ledger_value, crawled, token_id, decimals) \
       values($contract, $kind, $id, $?k, $?v, $crawled, $?token_id, \
       ${lk.ft_decimals}) on conflict (address) \
       do update set kind = $kind, ledger_id = $id, ledger_key = $?k, \
       ledger_value = $?v, \
       crawled = case when $no_crawled then ft_contracts.crawled else $crawled end, \
       token_id = $?token_id, decimals = ${lk.ft_decimals}"]

let update_extra_config ?dbh e =
  use dbh @@ fun dbh ->
  let>? r = [%pgsql.object dbh "select * from state"] in
  let>? () = match r with
    | [] ->
      [%pgsql dbh
          "insert into state(exchange, royalties, transfer_manager) \
           values (${e.exchange}, ${e.royalties}, ${e.transfer_manager})"]
    | _ ->
      [%pgsql dbh
          "update state set exchange = ${e.exchange}, \
           royalties = ${e.royalties}, transfer_manager = ${e.transfer_manager}"] in
  iter_rp (fun (address, lk) -> update_ft_contract ~dbh address lk)
    (SMap.bindings e.ft_contracts)
