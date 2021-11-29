#if !FA1
#define FA1

type transfer = [@layout:comb] {
  from: address ;
  to: address ;
  value: nat }

type approve = [@layout:comb] {
  spender: address ;
  value: nat }

type account = [@layout:comb] {
  balance: nat ;
  allowances: (address, nat) map }

type allowance = [@layout:comb] {
  owner: address ;
  spender: address }

type storage = [@layout:comb] {
  supply: nat ;
  ledger: (address, account) big_map ;
  token_metadata: (nat, (nat * (string, bytes) map) ) big_map
}

type params = [@layout:comb]
  | Transfer of transfer
  | Approve of approve

[@inline]
let get_account (s : storage) (addr : address) : account =
  match Big_map.find_opt addr s.ledger with
  | None -> { balance = 0n; allowances = (Map.empty : (address, nat) map) }
  | Some acc -> acc

[@inline]
let get_allowance (owner : account) (spender : address) : nat =
  match Map.find_opt spender owner.allowances with | None -> 0n | Some n -> n

let transfer ((t, s) : (transfer * storage)) : operation list * storage =
  let ac = get_account s t.from in
  match is_nat (ac.balance - t.value) with
  | None -> (failwith "NotEnoughBalance" : operation list * storage)
  | Some ac_balance ->
    let ac =
      if t.from <> Tezos.sender
      then
        let allowance = get_allowance ac Tezos.sender in
        match is_nat (allowance - t.value) with
        | None -> (failwith "NotEnoughAllowance" : account)
        | Some d ->
          let ac_allowances = Map.update Tezos.sender (Some d) ac.allowances in
          { balance = ac_balance ; allowances = ac_allowances  }
      else { ac with balance = ac_balance } in
    let s = { s with ledger = (Big_map.update t.from (Some ac) s.ledger) } in
    let dest = get_account s t.to in
    let dest = { dest with balance = (dest.balance + t.value) } in
    ([] : operation list), { s with ledger = (Big_map.update t.to (Some dest) s.ledger) }

let approve ((a, s) : (approve * storage)) : operation list * storage =
  let ac = get_account s Tezos.sender in
  let allowance = get_allowance ac a.spender in
  let () =
    if (allowance > 0n) && (a.value > 0n) then failwith "UnsafeAllowanceChange" in
  let ac =
    { ac with allowances = (Map.update a.spender (Some a.value) ac.allowances) } in
  ([] : operation list), { s with ledger = (Big_map.update Tezos.sender (Some ac) s.ledger) }

[@view]
let getBalance ((addr, s) : (address * storage)) : nat =
  let owner = get_account s addr in owner.balance

[@view]
let getAllowance ((a, s) : (allowance * storage)) : nat =
  let owner = get_account s a.owner in get_allowance owner a.spender

[@view]
let getTotalSupply (((), s) : (unit * storage)) : nat =
  s.supply

let main ((action, s) : (params * storage)) : (operation list * storage) =
  match action with
  | Transfer t -> transfer (t, s)
  | Approve a -> approve (a, s)

#endif
