open Mligo
include Fa2_operator_lib

(* range of nft tokens *)

(**
Retrieve the balances for the specified tokens and owners
@return callback operation
*)
let get_balance (p : balance_of_param) (ledger : ledger) : operation =
  let to_balance (r : balance_of_request) =
    match Big_map.find_opt r.bal_token_id ledger with
    | None -> (failwith fa2_token_undefined : balance_of_response)
    | Some o ->
      let bal = if o = r.bal_owner then 1n else 0n in
      { bal_request = r; bal_balance = bal } in
  let responses = List.map to_balance p.bal_requests in
  Tezos.transaction responses 0u p.bal_callback

(**
Update ledger balances according to the specified transfers. Fails if any of the
permissions or constraints are violated.
@param txs transfers to be applied to the ledger
@param validate_op function that validates if the tokens from the particular owner can be transferred.
 *)
let transfer (txs : transfer list) (validate_op : operator_validator)
    (s : storage) : ledger =
  (* process individual transfer *)
  let make_transfer (l, tx : ledger * transfer) =
    List.fold (fun (ll, dst : ledger * transfer_destination) ->
        if dst.tr_amount = 0n then ll
        else if dst.tr_amount <> 1n then (failwith fa2_insufficient_balance : ledger)
        else match Big_map.find_opt dst.tr_token_id ll with
          | None -> (failwith fa2_token_undefined : ledger)
          | Some o ->
            if o <> tx.tr_from then (failwith fa2_insufficient_balance : ledger)
            else
              let () = validate_op o Tezos.sender dst.tr_token_id s in
              Big_map.update dst.tr_token_id (Some dst.tr_dst) ll)
      tx.tr_txs l in
  List.fold make_transfer txs s.ledger

(** Finds a definition of the token type (token_id range) associated with the provided token id *)
let find_token_def (tid : nat) (token_defs : token_def set) : token_def =
  match Set.fold (fun (res, d : token_def option * token_def) ->
      match res with
      | Some _ -> res
      | None ->
        if tid >= d.from_ && tid < d.to_
        then  Some d
        else (None : token_def option)
    ) token_defs (None : token_def option) with
  | None -> (failwith fa2_token_undefined : token_def)
  | Some d -> d

let get_metadata (tokens : nat list) (storage : storage) : token_metadata list =
  List.map (fun (tid: nat) ->
    let tdef = find_token_def tid storage.token_defs in
    match Big_map.find_opt tdef storage.token_metas with
    | Some m -> { m with meta_token_id = tid }
    | None -> (failwith "NO_DATA" : token_metadata)) tokens


let update_managed (m : managed_storage) (add : bool) : managed_storage =
  if add then Big_map.update Tezos.sender (Some ()) m
  else Big_map.remove Tezos.sender m

let fa2_main (param, storage : fa2_entry_points * storage) : (operation  list) * storage =
  match param with
  | Transfer txs ->
    let ledger =
      transfer txs default_operator_validator storage in
    ([] : operation list), { storage with ledger }
  | Balance_of p ->
    let op = get_balance p storage.ledger in
    [ op ], storage
  | Update_operators ops ->
    let operators = fa2_update_operators storage.operators ops in
    let storage = { storage with operators } in
    ([] : operation list), storage
  | Managed add ->
    let managed = update_managed storage.managed add in
    let storage = { storage with managed } in
    ([] : operation list), storage



type nft_entry_points =
  | Fa2 of fa2_entry_points
  | Token_metadata of token_metadata_param

let nft_token_main (param, storage : nft_entry_points * storage)
  : (operation  list) * storage =
  match param with
  | Fa2 fa2 -> fa2_main (fa2, storage)
  | Token_metadata p ->
    let metas = get_metadata p.token_ids storage in
    let () = p.handler metas in
    ([] : operation list), storage
