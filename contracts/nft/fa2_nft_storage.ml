open Mligo
include Fa2_nft_asset

let store : storage = {
  admin = (Tezos.source : address);
  company_wallet = (Tezos.source : address);
  pending_admin = (None : address option);
  pending_company_wallet = (None : address option);
  paused = true;
  ledger = (Big_map.empty : (nat, address) big_map);
  operators = (Big_map.empty : operator_storage);
  managed = (Big_map.empty : managed_storage);
  token_metas = (Big_map.empty : (token_def, token_metadata) big_map);
  token_defs = (Set.empty : token_def set);
  next_token_id = 0n;
  metadata = (Big_map.empty : (string, bytes) big_map)
}
