open Mligo

type simple_admin =
  | Set_admin of address
  | Confirm_admin
  | Pause of bool
[@@entry Admin]

type simple_admin_storage = {
  admin : address;
  pending_admin : address option;
  paused : bool;
}

let set_admin (new_admin, s : address * simple_admin_storage) : simple_admin_storage =
  { s with pending_admin = Some new_admin }

let confirm_new_admin (s : simple_admin_storage) : simple_admin_storage =
  match s.pending_admin with
  | None -> (failwith "NO_PENDING_ADMIN" : simple_admin_storage)
  | Some pending ->
    if Tezos.sender = pending then
      { s with pending_admin = (None : address option); admin = Tezos.sender }
    else (failwith "NOT_A_PENDING_ADMIN" : simple_admin_storage)


let pause (paused, s: bool * simple_admin_storage) : simple_admin_storage =
  { s with paused = paused }

let fail_if_not_admin (a : simple_admin_storage) : unit =
  if Tezos.sender <> a.admin then failwith "NOT_AN_ADMIN" else ()

let fail_if_paused (a : simple_admin_storage) : unit =
  if a.paused then failwith "PAUSED" else ()

let simple_admin (param, s : simple_admin * simple_admin_storage)
  : (operation list) * simple_admin_storage =
  let ops : operation list = [] in
  let s = match param with
    | Set_admin new_admin ->
      let () = fail_if_not_admin s in
      set_admin (new_admin, s)
    | Confirm_admin ->
      confirm_new_admin s
    | Pause paused ->
      let () = fail_if_not_admin s in
      pause (paused, s) in
  (ops, s)
