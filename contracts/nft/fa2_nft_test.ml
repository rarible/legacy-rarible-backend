open Mligo
open List
include Fa2_nft_asset

let src = Test.nth_bootstrap_account 0
let other = Test.nth_bootstrap_account 1

let initial_storage : storage = {
  admin = src;
  company_wallet = src;
  pending_admin = (None : address option);
  pending_company_wallet = (None : address option);
  paused = true;
  ledger = (Big_map.empty : (nat, address) big_map);
  operators = (Big_map.empty : operator_storage);
  managed = (Big_map.empty : managed_storage);
  token_defs = (Set.empty : token_def set);
  next_token_id = 0n;
  token_metas = (Big_map.empty : (token_def, token_metadata) big_map);
  metadata = (Big_map.empty : (string, bytes) big_map)
}

let next_token_id (storage : storage) =
  storage.next_token_id

let test_mint =
  let () = Test.set_source src in
  let (taddr, _, _) = Test.originate nft_asset_main initial_storage 0t in
  let contr = Test.to_contract taddr in
  let storage = Test.get_storage taddr in
  let owners = [ src; other ] in
  let from_ = next_token_id storage in
  let token_def = { from_ = from_ ; to_ = from_ + List.length owners } in
  let metadata = { meta_token_id = from_; meta_token_info = (Map.empty : (string, bytes) map) } in
  let mint_param = {token_def = token_def; token_metadata = metadata; owners = owners } in
  let () = Test.transfer_to_contract_exn contr (Tokens (Mint_tokens mint_param) ) 0t in
  let storage = Test.get_storage taddr in
  let () = assert (next_token_id storage = from_ + List.length owners) in
  ()
