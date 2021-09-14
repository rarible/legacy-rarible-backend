open Mligo
include Types

let mint_tokens (s : storage) (p: mint_param) : storage * operation list =
  if s.next_token_id <> p.mi_token_id then
    (failwith "NOT_PERMITTED_ID" : storage * operation list)
  else
    let ledger = Big_map.add (p.mi_token_id, p.mi_owner) p.mi_amount s.ledger in
    let ops = match
        (Tezos.get_entrypoint_opt "%setRoyalties" s.royalties_contract
         : (address * nat * part list) contract option) with
    | None -> (failwith "NoRoyaltiesContract" : operation list)
    | Some c -> [ Tezos.transaction (p.mi_owner, p.mi_token_id, p.mi_royalties) 0t c ] in
    { s with ledger }, ops


let burn_tokens (s : storage) (p : burn_param)  : storage =
  match Big_map.find_opt (p.bu_token_id, p.bu_owner) s.ledger with
  | None -> (failwith "INVALID_PARAM" : storage)
  | Some am ->
    let ledger = match is_nat (am - p.bu_amount) with
      | None -> (failwith fa2_insufficient_balance : ledger)
      | Some am ->
        if am = 0n then Big_map.remove (p.bu_token_id, p.bu_owner) s.ledger
        else Big_map.update (p.bu_token_id, p.bu_owner) (Some am) s.ledger in
    { s with ledger }

let set_token_metadata (s : storage) (token_id : nat) (metadata: (string, string) map) : storage =
  {s with token_metadata = Big_map.update token_id (Some metadata) s.token_metadata }

let manager (param, s : manager * storage) : (operation list) * storage =
  let s, ops = match param with
    | Mint p -> mint_tokens s p
    | Burn p -> burn_tokens s p, ([] : operation list)
    | SetTokenMetadata (token_id, meta) ->
      set_token_metadata s token_id meta, ([] : operation list)
  in
  ops, s
