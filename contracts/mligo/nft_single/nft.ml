open Mligo
include Manager
include Admin
include Assets

let main (param, s : param * storage) : (operation list) * storage =
  match param with
  | Admin p -> admin (p, s)
  | Manager p ->
    let () = fail_if_not_admin s in
    manager (p, s)
  | Assets p ->
    let () = fail_if_paused s in
    fa2 (p, s)
