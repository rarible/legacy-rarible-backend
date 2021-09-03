open Mligo

type transfer_destination = {
  tr_dst : address;
  tr_token_id : nat;
  tr_amount : nat;
} [@@comb]

type transfer = {
  tr_from : address;
  tr_txs : transfer_destination list;
} [@@comb]

type balance_of_request = {
  bal_owner : address;
  bal_token_id : nat;
} [@@comb]

type balance_of_response = {
  bal_request : balance_of_request;
  bal_balance : nat;
} [@@comb]

type balance_of_param = {
  bal_requests : balance_of_request list;
  bal_callback : (balance_of_response list) contract;
} [@@comb]

type operator_param = {
  op_owner : address;
  op_operator : address;
  op_token_id: nat;
  op_add : bool;
} [@@comb]

type token_metadata = {
  meta_token_id : nat;
  meta_token_info : (string, bytes) map;
} [@@comb]

(*
One of the options to make token metadata discoverable is to declare
`token_metadata : token_metadata_storage` field inside the FA2 contract storage
*)
type token_metadata_storage = (nat, token_metadata) big_map

(**
Optional type to define view entry point to expose token_metadata on chain or
as an external view
 *)
type token_metadata_param = {
  token_ids : nat list;
  handler : (token_metadata list) -> unit;
} [@@comb]

type fa2_entry_points =
  | Transfer of transfer list
  | Balance_of of balance_of_param
  | Update_operators of operator_param list
  | Managed of bool

type token_def = {
  from_ : nat;
  to_ : nat;
} [@@comb] [@@param]

type nft_meta = (token_def, token_metadata) big_map

type ledger = (nat, address) big_map

type operator_storage = ((address * (address * nat)), unit) big_map
type managed_storage = (address, unit) big_map

type storage = {
  admin : address;
  company_wallet: address;
  pending_admin : address option;
  pending_company_wallet : address option;
  paused : bool;
  ledger : ledger;
  operators : operator_storage;
  managed : managed_storage;
  token_defs : token_def set;
  next_token_id : nat;
  token_metas : nft_meta;
  metadata : (string, bytes) big_map;
}
