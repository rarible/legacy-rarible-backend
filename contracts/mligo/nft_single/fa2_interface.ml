open Mligo

type transfer_destination = {
  to_ : address;
  token_id : nat;
  amount : nat;
} [@@comb] [@@param Transfer]

type transfer = {
  from_ : address;
  txs : transfer_destination list;
} [@@comb] [@@param Transfer]

type balance_of_request = {
  owner : address;
  token_id : nat;
} [@@comb]

type balance_of_response = {
  request : balance_of_request;
  balance : nat;
} [@@comb]

type balance_of_param = {
  requests : balance_of_request list;
  callback : (balance_of_response list) contract;
} [@@comb]

type operator_param = {
  owner : address;
  operator : address;
  token_id: nat;
} [@@comb] [@@param Update_operators]

type operator_update =
  | Add_operator of operator_param
  | Remove_operator of operator_param

type token_metadata = {
  token_id : nat;
  token_info : (string, bytes) map;
} [@@comb] [@@param Store]

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
  | Update_operators of operator_update list
  | Managed of bool
[@@entry Fa2]

type nft_entry_points =
  | Fa2 of fa2_entry_points
  | Token_metadata of token_metadata_param
[@@entry Assets]

type token_def = {
  from_ : nat;
  to_ : nat;
} [@@comb] [@@param Store]

type nft_meta = (token_def, token_metadata) big_map [@@param Store]

type ledger = (nat, address) big_map [@@param Store]

type operator_storage = ((address * (address * nat)), unit) big_map [@@param Store]
type managed_storage = (address, unit) big_map [@@param Store]

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
} [@@store]
