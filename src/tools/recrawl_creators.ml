open Hooks
open Crawlori
open Make(Pg)(struct type extra = Rtypes.config end)
open Proto
open Let
open Rtypes
open Db.Misc

module SSet = Set.Make(String)

let filename = ref None
let recrawl_start = ref None
let recrawl_end = ref None
let mode = ref "node"

let spec = [
  "--start", Arg.Int (fun i -> recrawl_start := Some (Int32.of_int i)), "Start level for recrawl";
  "--end", Arg.Int (fun i -> recrawl_end := Some (Int32.of_int i)), "Optional end level for recrawl";
  "--mode", Arg.Set_string mode, "Mode for recrawl: 'node' (default) or 'db'";
]

let update_creators ~contract ~token_id ~account =
  let token_id = Z.to_string token_id in
  let tid = contract ^ ":" ^ token_id  in
  let creators = [ Some (EzEncoding.construct part_enc {
      part_account=account; part_value = 10000l }) ] in
  use None @@ fun dbh ->
  let>? () = [%pgsql dbh "update token_info set creators = $creators where id = $tid"] in
  let>? () = [%pgsql dbh
      "insert into creators(id, contract, token_id, account, value, block, main) \
       values($tid, $contract, $token_id, $account, 10000, '', true) on conflict do nothing"] in
  Db.Produce.nft_item_event dbh contract (Z.of_string token_id) ()

let operation contracts _ (tokens, ext_diff) op =
  Format.printf "Block %s (%ld)\r@?" (Common.Utils.short op.bo_block) op.bo_level;
  match op.bo_meta with
  | None -> Lwt.return_error @@
    `generic ("no_metadata", Format.sprintf "no metadata found for operation %s" op.bo_hash)
  | Some meta ->
    let _, _, oindex2 = op.bo_indexes in
    let ext_diff = if oindex2 = 0l then meta.op_lazy_storage_diff else ext_diff in
    if meta.op_status = `applied then
      let contract = match op.bo_op.kind with
        | Transaction tr -> Some tr.destination
        | Origination _ -> Some (Tzfunc.Crypto.op_to_KT1 op.bo_hash)
        | _ -> None in
      match contract with
      | None -> Lwt.return_ok (tokens, ext_diff)
      | Some contract ->
        match Rtypes.SMap.find_opt contract contracts with
        | None -> Lwt.return_ok (tokens, ext_diff)
        | Some nft ->
          let balances = Common.Storage_diff.get_big_map_updates nft.nft_ledger
              (if oindex2 = 0l then meta.op_lazy_storage_diff
               else ext_diff @ meta.op_lazy_storage_diff) in
          let|>? tokens = fold_rp (fun tokens -> function
              | `nat token_id, Some (`address account)
              | `tuple [`nat token_id; `address account], Some _
              | `tuple [`address account; `nat token_id], Some _ ->
                begin match TIMap.find_opt (contract, token_id) tokens with
                  | None | Some true -> Lwt.return_ok tokens
                  | _ ->
                    Format.printf "Block %s (%ld)@." (Common.Utils.short op.bo_block) op.bo_level;
                    Format.printf "\027[0;35mUpdate creators %s %s %s\027[0m@."
                      contract (Z.to_string token_id) account;
                    let|>? () = update_creators ~contract ~token_id ~account in
                    TIMap.update (contract, token_id) (fun _ -> Some true) tokens
                end
              | _ -> Lwt.return_ok tokens
            ) tokens balances in
          tokens, ext_diff
    else Lwt.return_ok (tokens, ext_diff)

let add_indexes () =
  use None @@ fun dbh ->
  let>? () = [%pgsql dbh "create index token_balance_updates_contract_index on token_balance_updates(contract)"] in
  [%pgsql dbh "create index token_balance_updates_token_id_index on token_balance_updates(token_id)"]

let remove_indexes () =
  use None @@ fun dbh ->
  let>? () = [%pgsql dbh "drop index token_balance_updates_contract_index"] in
  [%pgsql dbh "drop index token_balance_updates_token_id_index"]

let first_token_balance_update ~token_id ~contract =
  use None @@ fun dbh ->
  let|>? l = [%pgsql dbh
      "select account from token_balance_updates \
       where token_id = ${Z.to_string token_id} and contract = $contract and account is not null \
       and balance > 0 order by level asc, index asc, balance asc limit 1"] in
  match l with
  | [ Some account ] -> Some account
  | _ -> None

let db_mode map =
  iter_rp (fun ((contract, token_id), _) ->
      let>? o = first_token_balance_update ~token_id ~contract in
      match o with
      | None -> Lwt.return_ok ()
      | Some account -> update_creators ~contract ~token_id ~account) @@
  Rtypes.TIMap.bindings map

let main () =
  Arg.parse spec (fun f -> filename := Some f) "recrawl_creators.exe [options] config.json";
  let>? tokens = Db.Utils.tokens_without_creators () in
  if !mode = "node" then
    let>? config = Lwt.return @@ Crawler_config.get !filename Rtypes.config_enc in
    let contracts_set = Rtypes.TIMap.fold (fun (c, _) _ acc -> SSet.add c acc) tokens SSet.empty in
    let contracts = SSet.elements contracts_set in
    let>? db_contracts = Db.Utils.get_contracts contracts in
    let contracts = Db.Config.db_contracts db_contracts in
    match !recrawl_start with
    | Some start ->
      let|>? _ = async_recrawl ~config ~start ?end_:!recrawl_end ~operation:(operation contracts) ((), (tokens, [])) in
      ()
    | _ ->
      Format.printf "Missing arguments: '--start' is required@.";
      Lwt.return_ok ()
  else if !mode = "db" then
    db_mode tokens
  else (
    Format.printf "Unhandled mode: %S@." !mode;
    Lwt.return_ok ())

let () =
  EzLwtSys.run @@ fun () ->
  Lwt.map (Result.iter_error Rp.print_error) (main ())
