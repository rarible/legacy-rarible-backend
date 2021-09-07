type z = Z.t [@encoding Json_encoding.(conv Z.to_string Z.of_string string)] [@@deriving encoding]

(** Api *)

type erc20_balance = {
  contract: string;
  owner: string;
  balance: z;
  decimal_balance: z; [@camel]
} [@@deriving encoding]


(** Interaction with Tezos contract *)

type transfer_destination = {
  tr_destination: string;
  tr_token_id: int64;
  tr_amount: int64;
} [@@deriving encoding]

type transfer = {
  tr_source: string;
  tr_txs: transfer_destination list;
} [@@deriving encoding]

type operator_update = {
  op_owner: string;
  op_operator: string;
  op_token_id: int64;
  op_add: bool;
} [@@deriving encoding]

type token_meta = (string * string) list [@assoc]
[@@deriving encoding]

type token_op = {
  tk_token_id: int64;
  tk_amount: int64;
} [@@deriving encoding]

type token_op_owner = {
  tk_op: token_op; [@merge]
  tk_owner: string;
} [@@deriving encoding {remove_prefix=3}]

type mint = {
  tk_own: token_op_owner; [@merge]
  tk_meta: token_meta;
} [@@deriving encoding]

type account_token = {
  at_token_id : int64;
  at_contract : string;
  at_amount : int64;
} [@@deriving encoding]

type param =
  | Transfers of transfer list
  | Operator_updates of operator_update list
  | Mint_tokens of mint list
  | Burn_tokens of token_op list
[@@deriving encoding]
