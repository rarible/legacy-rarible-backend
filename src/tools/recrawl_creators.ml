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

let spec = [
  "--start", Arg.Int (fun i -> recrawl_start := Some (Int32.of_int i)), "Start level for recrawl";
  "--end", Arg.Int (fun i -> recrawl_end := Some (Int32.of_int i)), "Optional end level for recrawl";
]

let update_creators ~contract ~id ~account =
  let id = Z.to_string id in
  let tid = contract ^ ":" ^ id  in
  let creators = [ Some (EzEncoding.construct part_enc {
      part_account=account; part_value = 10000l }) ] in
  use None @@ fun dbh ->
  let>? () = [%pgsql dbh "update token_info set creators = $creators where id = $tid"] in
  [%pgsql dbh
      "insert into creators(id, contract, token_id, account, value, block, main) \
       values($tid, $contract, $id, $account, 10000, '', true) on conflict do nothing"]

let operation contracts _ (tokens, ext_diff) op =
  Format.printf "Block %s (%ld)\r@?" (Common.Utils.short op.bo_block) op.bo_level;
  match op.bo_meta with
  | None -> Lwt.return_error @@
    `generic ("no_metadata", Format.sprintf "no metadata found for operation %s" op.bo_hash)
  | Some meta ->
    let ext_diff = if op.bo_index = 0l then meta.op_lazy_storage_diff else ext_diff in
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
              (if op.bo_index = 0l then meta.op_lazy_storage_diff
               else ext_diff @ meta.op_lazy_storage_diff) in
          let|>? tokens = fold_rp (fun tokens -> function
              | `nat id, Some (`address account)
              | `tuple [`nat id; `address account], Some _
              | `tuple [`address account; `nat id], Some _ ->
                begin match TIMap.find_opt (contract, id) tokens with
                  | None | Some true -> Lwt.return_ok tokens
                  | _ ->
                    Format.printf "Block %s (%ld)@." (Common.Utils.short op.bo_block) op.bo_level;
                    Format.printf "\027[0;35mUpdate creators %s %s %s\027[0m@."
                      contract (Z.to_string id) account;
                    let|>? () = update_creators ~contract ~id ~account in
                    TIMap.update (contract, id) (fun _ -> Some true) tokens
                end
              | _ -> Lwt.return_ok tokens
            ) tokens balances in
          tokens, ext_diff
    else Lwt.return_ok (tokens, ext_diff)

let main () =
  Arg.parse spec (fun f -> filename := Some f) "recrawl_creators.exe [options] config.json";
  let>? config = Lwt.return @@ Crawler_config.get !filename Rtypes.config_enc in
  let>? tokens = Db.Utils.tokens_without_creators () in
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

let () =
  EzLwtSys.run @@ fun () ->
  Lwt.map (Result.iter_error Rp.print_error) (main ())
