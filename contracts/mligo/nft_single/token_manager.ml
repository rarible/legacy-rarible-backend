open Mligo
include Admin

type mint_param = {
  token_def : token_def;
  metadata : token_metadata;
  owners : address list;
} [@@comb] [@@param]

type token_manager =
  | Mint_tokens of mint_param
  | Burn_tokens of token_def
[@@entry Tokens]

let validate_mint_param (p : mint_param) : unit =
  let td = p.token_def in
  match is_nat (td.to_ - td.from_) with
  | None -> failwith "EMPTY_TOKEN_DEF_RANGE"
  | Some n -> if n <> List.size p.owners then failwith "INVALID_OWNERS_LENGTH"

type zip_acc = {
  zip : (address * nat ) list;
  next_token : nat;
}

let zip_owners_with_token_ids (owners : address list) (from_token_id : nat) :
  (address * nat ) list =
  let res = List.fold
      ( fun (acc, owner : zip_acc * address) ->
          {
            zip = (owner, acc.next_token) :: acc.zip;
            next_token = acc.next_token + 1n;
          }
      )
      owners
      {
        zip = ([] : (address * nat) list);
        next_token = from_token_id;
      }

  in
  res.zip

let mint_tokens (s : storage) (p : mint_param)  : storage =
  let () = validate_mint_param p in
  let td = p.token_def in
  if s.next_token_id > td.from_ then (failwith "USED_TOKEN_IDS" : storage)
  else
    let token_defs = Set.add td s.token_defs in
    let token_metas = Big_map.add td p.metadata s.token_metas in
    let tid_owners = zip_owners_with_token_ids p.owners td.from_ in
    let ledger = List.fold (fun (l, owner_id : ledger * (address * nat)) ->
        let owner, tid = owner_id in
        Big_map.add tid owner l
      ) tid_owners s.ledger in
    { s with token_defs; token_metas; next_token_id = td.to_; ledger }

let rec remove_tokens (from_, to_, ledger : nat * nat * ledger) : ledger =
  if from_ = to_ then ledger
  else
    let ledger = Big_map.remove from_ ledger in
    remove_tokens (from_ + 1n, to_, ledger)

let remove_token_aux (s : storage) (p : token_def) : storage =
  let token_defs = Set.remove p s.token_defs in
  let token_metas = Big_map.remove p s.token_metas in
  let ledger = remove_tokens (p.from_, p.to_, s.ledger) in
  { s with ledger; token_defs; token_metas }

let burn_tokens (s : storage) (p : token_def)  : storage =
  match Big_map.find_opt p s.token_metas with
  | None -> (failwith "INVALID_PARAM" : storage)
  | Some m ->
    if Tezos.sender = s.admin then remove_token_aux s p
    else if not (Map.mem "burnable" m.token_info) then (failwith "NOT_BURNABLE" : storage)
    else if p.from_ <> p.to_ + 1n then (failwith "NOT_AN_ADMIN" : storage)
    else match Big_map.find_opt p.from_ s.ledger with
      | None -> (failwith "INVALID_PARAM" : storage)
      | Some owner ->
        if Tezos.sender <> owner then (failwith "NOT_AN_ADMIN_OR_OWNER" : storage)
        else remove_token_aux s p

let token_manager (param, s : token_manager * storage) : (operation list) * storage =
  let s = match param with
    | Mint_tokens p ->
      let () = fail_if_not_admin s in
      mint_tokens s p
    | Burn_tokens p -> burn_tokens s p in
  ([] : operation list), s
