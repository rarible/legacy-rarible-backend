open EzAPIServer
open Rtypes

let erc20_balance ((_, contract), owner) () =
  return_ok { contract; owner; balance = Z.zero; decimal_balance = Z.zero }
[@@get {path="/balances/{contract : string}/{owner : string}"; output=erc20_balance_enc}]

[@@@server 8080]
