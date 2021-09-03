open Mligo
include Fa2_errors
include Fa2_permissions_descriptor
include Fa2_interface

(**
  Updates operator storage using an `update_operator` command.
  Helper function to implement `Update_operators` FA2 entrypoint
*)
let update_operators (storage : operator_storage) (update : operator_param)
    : operator_storage =
  if update.op_add then
    Big_map.update (update.op_owner, (update.op_operator, update.op_token_id)) (Some ()) storage
  else
    Big_map.remove (update.op_owner, (update.op_operator, update.op_token_id)) storage

(**
Validate if operator update is performed by the token owner.
@param updater an address that initiated the operation; usually `Tezos.sender`.
*)
let validate_update_operators_by_owner (op : operator_param) (updater : address)
  : unit =
  if op.op_owner = updater then () else failwith fa2_not_owner

(**
  Generic implementation of the FA2 `%update_operators` entrypoint.
  Assumes that only the token owner can change its operators.
 *)
let fa2_update_operators (storage : operator_storage) (ops : operator_param list)
  : operator_storage =
  let process_update (storage, update : operator_storage * operator_param) : operator_storage =
    let () = validate_update_operators_by_owner update Tezos.sender in
    update_operators storage update in
  List.fold process_update ops storage

(**
  owner * operator * token_id * ops_storage -> unit
*)
type operator_validator = address -> address -> nat -> storage -> unit

(**
Default implementation of the operator validation function.
The default implicit `operator_transfer_policy` value is `Owner_or_operator_transfer`
 *)
let default_operator_validator (owner : address) (operator : address)
    (token_id : nat) (s : storage) : unit =
  if owner = operator then () (* transfer by the owner *)
  else if operator = s.company_wallet && Big_map.mem owner s.managed then () (* the company wallet is permitted *)
  else if Big_map.mem (owner, (operator, token_id)) s.operators then () (* the operator is permitted for the token_id *)
  else (failwith fa2_not_operator : unit) (* the operator is not permitted for the token_id *)
