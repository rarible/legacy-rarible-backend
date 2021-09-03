open Mligo

type operator_transfer_policy =
  | No_transfer
  | Owner_transfer
  | Owner_or_operator_transfer
[@@comb]

type owner_hook_policy =
  | Owner_no_hook
  | Optional_owner_hook
  | Required_owner_hook
[@@comb]

type custom_permission_policy = {
  tag : string;
  config_api: address option;
} [@@comb]

type permissions_descriptor = {
  operator : operator_transfer_policy;
  receiver : owner_hook_policy;
  sender : owner_hook_policy;
  custom : custom_permission_policy option;
} [@@comb]
