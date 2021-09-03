open Mligo
include Fa2_interface

type admin =
  | Set_admin of address
  | Confirm_admin
  | Pause of bool
  | Set_company_wallet of address
  | Confirm_company_wallet
[@@entry Admin]

let set_admin (s : storage) (a : address) : storage =
  { s with pending_admin = Some a }

let set_company_wallet (s : storage) (a : address) : storage =
  { s with pending_company_wallet = Some a  }

let confirm_admin (s : storage) : storage =
  match s.pending_admin with
  | None -> (failwith "NO_PENDING_ADMIN" : storage)
  | Some pending ->
    if Tezos.sender = pending then
      { s with pending_admin = (None : address option); admin = Tezos.sender }
    else (failwith "NOT_A_PENDING_ADMIN" : storage)

let confirm_company_wallet (s : storage) : storage =
  match s.pending_company_wallet with
  | None -> (failwith "NO_PENDING_COMPANY_WALLET" : storage)
  | Some pending ->
    if Tezos.sender = pending then
      { s with pending_company_wallet = (None : address option); company_wallet = Tezos.sender }
    else (failwith "NOT_A_PENDING_COMPANY_WALLET" : storage)

let pause (s : storage) (paused : bool) : storage =
  { s with paused }

let fail_if_not_admin (a : storage) : unit =
  if Tezos.sender <> a.admin then failwith "NOT_AN_ADMIN" else ()

let fail_if_paused (a : storage) : unit =
  if a.paused then failwith "PAUSED" else ()

let admin (param, s : admin * storage) : (operation list) * storage =
  let ops : operation list = [] in
  let s = match param with
    | Set_admin new_admin ->
      let () = fail_if_not_admin s in
      set_admin s new_admin
    | Set_company_wallet wallet ->
      let () = fail_if_not_admin s in
      set_company_wallet s wallet
    | Confirm_admin -> confirm_admin s
    | Confirm_company_wallet -> confirm_company_wallet s
    | Pause paused ->
      let () = fail_if_not_admin s in
      pause s paused in
  (ops, s)
