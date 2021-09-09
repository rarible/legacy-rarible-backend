open Mligo
open List
include Nft

let src = Test.nth_bootstrap_account 0
let other = Test.nth_bootstrap_account 1

let initial_storage : storage = {
  admin = src;
  pending_admin = (None : address option);
  paused = true;
  ledger = (Big_map.empty : ((nat * address), nat) big_map);
  operators = (Big_map.empty : operators_storage);
  operators_for_all = (Big_map.empty : operators_for_all_storage);
  next_token_id = 0n;
  token_metadata = (Big_map.empty : token_metadata_storage);
  metadata = (Big_map.empty : (string, bytes) big_map);
  royalties_contract = other;
}

let next_token_id (storage : storage) =
  storage.next_token_id

let test_mint =
  let () = Test.set_source src in
  let (taddr, _, _) = Test.originate main initial_storage 0t in
  let contr = Test.to_contract taddr in
  let storage = Test.get_storage taddr in
  let mi_owners = [ src, 10n; other, 10n ] in
  let mi_token_id = next_token_id storage in
  let quantity = List.fold (fun ((acc, (_, am)) : nat * (address * nat)) -> acc + am) mi_owners 0n in
  let mint_param = {
    mi_token_id;
    mi_owner = src;
    mi_amount = 10n;
    mi_royalties = [ {pa_account=src; pa_value=10n} ];
    mi_info = (Map.empty : (string, bytes) map);
  } in
  let () = Test.transfer_to_contract_exn contr (Manager (Mint mint_param) ) 0t in
  let storage = Test.get_storage taddr in
  let () = assert (next_token_id storage = mi_token_id + quantity) in
  let () = assert (Big_map.find_opt (3n, src) storage.ledger = Some 1n) in
  let () = assert (Big_map.find_opt (10n, src) storage.ledger = (None : nat option)) in
  storage
