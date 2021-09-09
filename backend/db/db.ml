open Let
open Tzfunc.Proto
open Rtypes
open Hooks

module PGOCaml = Pg.PGOCaml

let () = Pg.PG.Pool.init ~database:Cconfig.database ()

let use dbh f = match dbh with
  | None -> Pg.PG.Pool.use f
  | Some dbh -> f dbh

let get_contracts ?dbh () =
  use dbh @@ fun dbh ->
  [%pgsql dbh "select address from contracts where main"]

let insert_fake ?dbh address =
  use dbh @@ fun dbh ->
  [%pgsql dbh
      "insert into contracts(kind, address, block, level, last, main) \
       values('', $address, '', 0, now(), true) \
       on conflict do nothing"]

let get_balance ?dbh ~contract ~owner token_id =
  use dbh @@ fun dbh ->
  let|>? l =
    [%pgsql dbh
        "select amount from tokens where contract = $contract and \
         owner = $owner and token_id = $token_id"] in
  match l with
  | [ amount ] -> Some amount
  | _ -> None

let one ?(err="expected unique roaw not found") l = match l with
  | [ x ] -> Lwt.return_ok x
  | _ -> Lwt.return_error (`hook_error err)

let set_account dbh addr ~block ~tsp ~level =
  [%pgsql dbh
      "insert into accounts(address, block, level, last) \
       values($addr, $block, $level, $tsp) on conflict do nothing"]

let transaction_id op =
  match op.bo_numbers, op.bo_nonce with
  | Some n, _ -> Lwt.return_ok ("counter_" ^ Z.to_string n.counter)
  | _, Some nonce -> Lwt.return_ok ("nonce_" ^ Int32.to_string nonce)
  | _ -> Lwt.return_error (`hook_error "no counter or nonce in transaction")

let set_mint dbh op kt1 m =
  let meta = EzEncoding.construct token_metadata_enc m.mi_meta in
  let token_id = m.mi_op.tk_op.tk_token_id in
  let owner = m.mi_op.tk_owner in
  let>? () = [%pgsql dbh
      "insert into tokens(contract, token_id, block, level, last, owner, amount, \
       metadata, transaction, supply) \
       values($kt1, $token_id, ${op.bo_block}, ${op.bo_level}, ${op.bo_tsp}, \
       $owner, 0, $meta, ${op.bo_hash}, 0) on conflict do nothing"] in
  let>? () = set_account dbh owner ~block:op.bo_block ~level:op.bo_level ~tsp:op.bo_tsp in
  let mint = EzEncoding.construct token_op_owner_enc m.mi_op in
  let>? id = transaction_id op in
[%pgsql dbh
      "insert into contract_updates(transaction, id, block, level, tsp, \
       contract, mint) \
       values(${op.bo_hash}, $id, ${op.bo_block}, ${op.bo_level}, \
       ${op.bo_tsp}, $kt1, $mint) \
       on conflict do nothing"]

let set_burn dbh op tr m =
  let burn = EzEncoding.construct token_op_owner_enc m in
  let>? id = transaction_id op in
  [%pgsql dbh
      "insert into contract_updates(transaction, id, block, level, tsp, \
       contract, burn) \
       values(${op.bo_hash}, $id, ${op.bo_block}, ${op.bo_level}, \
       ${op.bo_tsp}, ${tr.destination}, $burn) \
       on conflict do nothing"]

let set_transfer dbh op tr lt =
  let>? id = transaction_id op in
  let kt1 = tr.destination in
  let|>? () = iter_rp (fun {tr_source; tr_txs} ->
      let|>? () = iter_rp (fun {tr_destination; tr_token_id; tr_amount} ->
          let>? () = [%pgsql dbh
              "insert into tokens(contract, token_id, block, level, last, owner, amount, \
               metadata, transaction, supply) \
               values($kt1, $tr_token_id, ${op.bo_block}, ${op.bo_level}, ${op.bo_tsp}, \
               $tr_destination, 0, '{}', ${op.bo_hash}, 0) on conflict do nothing"] in
          [%pgsql dbh
              "insert into token_updates(transaction, id, block, level, tsp, \
               source, destination, contract, token_id, amount) \
               values(${op.bo_hash}, $id, ${op.bo_block}, ${op.bo_level}, \
               ${op.bo_tsp}, $tr_source, $tr_destination, ${tr.destination}, \
               $tr_token_id, $tr_amount) \
               on conflict do nothing"]
        ) tr_txs in
      ()) lt in
  ()

let set_update dbh op tr lt =
  let>? id = transaction_id op in
  let kt1 = tr.destination in
  iter_rp (fun {op_owner; op_operator; op_token_id; op_add} ->
      let>? () = [%pgsql dbh
          "insert into token_updates(transaction, id, block, level, tsp, \
           source, operator, add, contract, token_id) \
           values(${op.bo_hash}, $id, ${op.bo_block}, ${op.bo_level}, \
           ${op.bo_tsp}, $op_owner, $op_operator, $op_add, \
           $kt1, $op_token_id) on conflict do nothing"] in
      set_account dbh op_operator ~block:op.bo_block ~level:op.bo_level ~tsp:op.bo_tsp) lt

let set_update_all dbh op tr lt =
  let>? id = transaction_id op in
  let kt1 = tr.destination in
  let source = op.bo_op.source in
  iter_rp (fun (operator, add) ->
      let>? () = [%pgsql dbh
          "insert into token_updates(transaction, id, block, level, tsp, \
           source, operator, add, contract) \
           values(${op.bo_hash}, $id, ${op.bo_block}, ${op.bo_level}, \
           ${op.bo_tsp}, $source, $operator, $add, $kt1) on conflict do nothing"] in
      set_account dbh operator ~block:op.bo_block ~level:op.bo_level ~tsp:op.bo_tsp) lt

let set_uri dbh op tr s =
  let>? id = transaction_id op in
  [%pgsql dbh
      "insert into contract_updates(transaction, id, block, level, tsp, \
       contract, uri) \
       values(${op.bo_hash}, $id, ${op.bo_block}, ${op.bo_level}, \
       ${op.bo_tsp}, ${tr.destination}, $s) \
       on conflict do nothing"]

let set_metadata dbh op tr (token_id, l) =
  let meta = EzEncoding.construct token_metadata_enc l in
  let>? id = transaction_id op in
  let source = op.bo_op.source in
  let kt1 = tr.destination in
  [%pgsql dbh
      "insert into token_updates(transaction, id, block, level, tsp, \
       source, token_id, contract, metadata) \
       values(${op.bo_hash}, $id, ${op.bo_block}, ${op.bo_level}, \
       ${op.bo_tsp}, $source, $token_id, $kt1, $meta) \
       on conflict do nothing"]

let set_transaction dbh op tr =
  match tr.parameters with
  | Some {entrypoint; value = Micheline m} ->
    begin match Utils.parse_nft entrypoint m with
      | Ok (Mint_tokens m) -> set_mint dbh op tr.destination m
      | Ok (Burn_tokens b) -> set_burn dbh op tr b
      | Ok (Transfers t) -> set_transfer dbh op tr t
      | Ok (Operator_updates t) -> set_update dbh op tr t
      | Ok (Operator_updates_all t) -> set_update_all dbh op tr t
      | Ok (Metadata_uri s) -> set_uri dbh op tr s
      | Ok (Token_metadata x) -> set_metadata dbh op tr x
      | Error _ -> Lwt.return_ok ()
    end
  | _ -> Lwt.return_ok ()

let filter_contracts _ori =
  (* todo: filter from storage *)
  None

let set_origination config dbh op ori =
  match filter_contracts ori with
  | None -> Lwt.return_ok ()
  | Some (kind, mints) ->
    let kt1 = Tzfunc.Crypto.op_to_KT1 op.bo_hash in
    let>? () = set_mint dbh op kt1 mints in
    let|>? () = [%pgsql dbh
        "insert into contracts(kind, address, block, level, last) \
         values($kind, $kt1, ${op.bo_block}, ${op.bo_level}, ${op.bo_tsp}) \
         on conflict do nothing"] in
    let open Crawlori.Config in
    match config.accounts with
    | None -> config.accounts <- Some (SSet.singleton kt1)
    | Some accs -> config.accounts <- Some (SSet.add kt1 accs)

let set_operation config dbh op =
  let open Hooks in
  match op.bo_op.kind with
  | Transaction tr -> set_transaction dbh op tr
  | Origination ori -> set_origination config dbh op ori
  | _ -> Lwt.return_ok ()

let set_block config dbh b =
  iter_rp (fun op ->
      iter_rp (fun c -> match c.man_info.kind with
          | Origination ori ->
            let op = {
              Hooks.bo_block = b.hash; bo_level = b.header.shell.level;
              bo_tsp = b.header.shell.timestamp; bo_hash = op.op_hash;
              bo_op = c.man_info;
              bo_meta = Option.map (fun m -> m.man_operation_result) c.man_metadata;
              bo_numbers = Some c.man_numbers; bo_nonce = None } in
            set_origination config dbh op ori
          | _ -> Lwt.return_ok ()
        ) op.op_contents
    ) b.operations

let contract_updates_base dbh ~main ~contract ~block ~level ~tsp ~burn
    {tk_owner; tk_op = {tk_token_id; tk_amount} } =
  let main_s = if main then 1L else -1L in
  let factor = if burn then Int64.neg main_s else main_s in
  let>? l_amount = [%pgsql dbh
      "update tokens set supply = supply + $factor * $tk_amount::bigint, \
       amount = amount + $factor * $tk_amount::bigint
           where token_id = $tk_token_id and contract = $contract and owner = $tk_owner \
       returning amount"] in
  let>? () = [%pgsql dbh
      "update tokens set supply = supply + $factor * $tk_amount::bigint \
       where token_id = $tk_token_id and contract = $contract and owner <> $tk_owner"] in
  (* update account *)
  let>? new_amount = one ~err:"no amount for burn update" l_amount in
  let new_token = EzEncoding.construct account_token_enc {
      at_token_id = tk_token_id;
      at_contract = contract;
      at_amount = new_amount } in
  let old_token = EzEncoding.construct account_token_enc {
      at_token_id = tk_token_id;
      at_contract = contract;
      at_amount = Int64.(sub new_amount (mul main_s tk_amount))  } in
  [%pgsql dbh
      "update accounts set tokens = array_append(array_remove(tokens, $old_token), $new_token), \
       block = case when $main then $block else block end, \
       level = case when $main then $level else level end, \
       last = case when $main then $tsp else last end where address = $tk_owner"]

let contract_updates dbh main l =
  iter_rp (fun r ->
      let contract, block, level, tsp = r#contract, r#block, r#level, r#tsp in
      let>? n = match r#mint, r#burn, r#uri with
        | Some json, _, _ ->
          let tk = EzEncoding.destruct token_op_owner_enc json in
          let|>? () = contract_updates_base dbh ~main ~contract ~block ~level ~tsp ~burn:false tk in
          if main then 1L else -1L
        | _, Some json, _ ->
          let tk = EzEncoding.destruct token_op_owner_enc json in
          let|>? () = contract_updates_base dbh ~main ~contract ~block ~level ~tsp ~burn:true tk in
          if main then -1L else 1L
        | _, _, Some uri ->
          let|>? () =
            if main then
              [%pgsql dbh
                  "update contracts set metadata = jsonb_set(metadata, '{ \"\" }', $uri, true), \
                   block = $block, last = $tsp, level = $level where address = $contract"]
            else Lwt.return_ok () in
          0L
        | _ -> Lwt.return_ok 0L in
      (* update contracts *)
      [%pgsql dbh
          "update contracts set \
           tokens_number = tokens_number + $n, \
           block = case when $main then $block else block end, \
           last = case when $main then $tsp else last end, \
           level = case when $main then $level else level end \
           where address = ${r#contract}"]) l

let operator_updates dbh ?token_id ~operator ~add ~contract ~block ~level ~tsp ~source main =
  let no_token_id = Option.is_none token_id in
  [%pgsql dbh
      "update tokens set \
       operators = case when ($main and $add) or (not $main and not $add) then \
       array_append(operators, $operator) else array_remove(operators, $operator) end, \
       block = case when $main then $block else block end, \
       level = case when $main then $level else level end, \
       last = case when $main then $tsp else last end \
       where ($no_token_id or token_id = $?token_id) and owner = $source and contract = $contract"]

let transfer_updates dbh main ~contract ~block ~level ~tsp ~token_id ~source amount destination =
  let amount = if main then amount else Int64.neg amount in
  let>? info = [%pgsql dbh
      "update tokens set amount = amount - $amount, \
       block = case when $main then $block else block end, \
       level = case when $main then $level else level end, \
       last = case when $main then $tsp else last end where token_id = $token_id and \
       owner = $source and contract = $contract returning amount, metadata, supply, transaction"] in
  let>? new_src_amount, meta, supply, transaction = one ~err:"source token not found for transfer update" info in
  let>? l_new_dst_amount =
    [%pgsql dbh
        "update tokens set amount = amount + $amount, \
         metadata = case when amount = 0 then $meta else metadata end, \
         supply = case when amount = 0 then $supply else supply end, \
         transaction = case when amount = 0 then $transaction else transaction end, \
         block = case when $main then $block else block end, \
         level = case when $main then $level else level end, \
         last = case when $main then $tsp else last end where token_id = $token_id and \
         owner = $destination and contract = $contract returning amount"] in
  let>? new_dst_amount = one ~err:"destination token not found for transfer update" l_new_dst_amount in
  let at = { at_token_id = token_id; at_contract = contract; at_amount = new_src_amount } in
  let new_token_src = EzEncoding.construct account_token_enc at in
  let old_token_src = EzEncoding.construct account_token_enc {at with at_amount = Int64.add new_src_amount amount} in
  let new_token_dst = EzEncoding.construct account_token_enc {at with at_amount = new_dst_amount} in
  let old_token_dst = EzEncoding.construct account_token_enc {at with at_amount = Int64.sub new_dst_amount amount} in
  let>? () =
    [%pgsql dbh
        "update accounts set \
         block = case when $main then $block else block end, \
         level = case when $main then $level else level end, \
         last = case when $main then $tsp else last end, \
         tokens = array_append(array_remove(tokens, $old_token_src), $new_token_src) \
         where address = $source"] in
  [%pgsql dbh
      "update accounts set \
       block = case when $main then $block else block end, \
       level = case when $main then $level else level end, \
       last = case when $main then $tsp else last end, \
       tokens = array_append(array_remove(tokens, $old_token_dst), $new_token_dst) \
       where address = $destination"]

let token_updates dbh main l =
  iter_rp (fun r ->
      let contract, block, level, tsp, source =
        r#contract, r#block, r#level, r#tsp, r#source in
      match r#destination, r#token_id, r#amount, r#operator, r#add, r#metadata  with
      | Some destination, Some token_id, Some amount, _, _, _ ->
        transfer_updates dbh main ~contract ~block ~level ~tsp ~token_id ~source amount destination
      | _, token_id, _, Some operator, Some add, _ ->
        operator_updates dbh main ~operator ~add ~contract ~block ~level ~tsp ?token_id ~source
      | _, Some token_id, _, _, _, Some meta ->
        if main then
          [%pgsql dbh
            "update tokens set metadata = $meta where contract = $contract and \
             token_id = $token_id"]
        else Lwt.return_ok ()
      | _ -> Lwt.return_error (`hook_error "invalid token_update")) l


let set_main _config dbh {Hooks.m_main; m_hash} =
  use (Some dbh) @@ fun dbh ->
  let>? () = [%pgsql dbh "update contracts set main = $m_main where block = $m_hash"] in
  let>? () = [%pgsql dbh "update tokens set main = $m_main where block = $m_hash"] in
  let>? () = [%pgsql dbh "update accounts set main = $m_main where block = $m_hash"] in
  let>? t_updates = [%pgsql.object dbh "update token_updates set main = $m_main where block = $m_hash returning *"] in
  let>? c_updates = [%pgsql.object dbh "update contract_updates set main = $m_main where block = $m_hash returning *"] in
  let>? () = contract_updates dbh m_main c_updates in
  token_updates dbh m_main t_updates
