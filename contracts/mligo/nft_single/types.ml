open Mligo
include Errors

(* Fa2 *)

type transfer_destination = {
  tr_dst : address; [@key "to_"]
  tr_token_id : nat;
  tr_amount : nat;
} [@@comb] [@@param Transfer]

type transfer = {
  tr_src : address; [@key "from_"]
  tr_txs : transfer_destination list;
} [@@comb] [@@param Transfer]

type balance_of_request = {
  ba_owner : address;
  ba_token_id : nat;
} [@@comb]

type balance_of_response = {
  ba_request : balance_of_request;
  ba_balance : nat;
} [@@comb]

type balance_of_param = {
  ba_requests : balance_of_request list;
  ba_callback : (balance_of_response list) contract;
} [@@comb]

type operator_param = {
  op_owner : address;
  op_operator : address;
  op_token_id: nat;
} [@@comb] [@@param Update_operators]

type operator_update =
  | Add_operator of operator_param
  | Remove_operator of operator_param
[@@param Update_operators]

type operator_update_for_all =
  | Add_operator_for_all of address
  | Remove_operator_for_all of address
[@@param Update_operators_all]

type fa2 =
  | Transfer of transfer list
  | Balance_of of balance_of_param
  | Update_operators of operator_update list
  | Update_operators_for_all of operator_update_for_all list
[@@entry Assets]

(* Manager *)

type part = {
  pa_account : address;
  pa_value: nat;
} [@@param Mint]

type mint_param = {
  mi_token_id : nat;
  mi_owner : address;
  mi_amount : nat;
  mi_royalties : part list;
} [@@comb] [@@param Mint]

type burn_param = {
  bu_token_id : nat;
  bu_owner : address;
  bu_amount : nat;
} [@@comb] [@@param Burn]

type manager =
  | Mint of mint_param
  | Burn of burn_param
  | SetTokenMetadata of (nat * (string, string) map)
[@@entry Manager]

(* Admin *)

type admin =
  | SetMetadataUri of bytes
[@@entry Admin]

(* Main *)

type param =
  | Assets of fa2
  | Admin of admin
  | Manager of manager
[@@entry Main]

(* Storage *)

type ledger = (nat * address, nat) big_map [@@param Store]
type operators_storage = ((address * (address * nat)), unit) big_map [@@param Store]
type operators_for_all_storage = ((address * address), unit) big_map [@@param Store]
type token_metadata_storage = (nat, (string, string) map) big_map [@@param Store]

type storage = {
  admin : address;
  pending_admin : address option;
  paused : bool;
  ledger : ledger;
  operators : operators_storage;
  operators_for_all : operators_for_all_storage;
  token_metadata : token_metadata_storage;
  next_token_id : nat;
  metadata : (string, bytes) big_map;
  royalties_contract : address;
} [@@store]
