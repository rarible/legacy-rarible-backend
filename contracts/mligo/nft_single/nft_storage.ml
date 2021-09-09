open Mligo
include Nft

let store : storage = {
  admin = (Tezos.source : address);
  pending_admin = (None : address option);
  paused = true;
  ledger = (Big_map.empty : (nat * address, nat) big_map);
  operators = (Big_map.empty : operator_storage);
  approved = (Big_map.empty : approved_storage);
  token_metadata = (Big_map.empty : (nat, nat * (string, bytes) map) big_map);
  next_token_id = 0n;
  metadata = (Big_map.literal [
      "", 0x74657a6f732d73746f726174653a6a736f6eh
    ]: (string, bytes) big_map)
}
