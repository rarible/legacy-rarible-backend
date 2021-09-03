open Mligo
include Token_manager
include Fa2_nft_token

type nft_asset_param =
  | Assets of nft_entry_points
  | Admin of admin
  | Tokens of token_manager
[@@entry Main]

let nft_asset_main (param, s : nft_asset_param * storage) : (operation list) * storage =
  match param with
  | Admin p -> admin (p, s)
  | Tokens p -> token_manager (p, s)
  | Assets p ->
    let () = fail_if_paused s in
    nft_token_main (p, s)
