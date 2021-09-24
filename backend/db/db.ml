open Let
open Tzfunc.Proto
open Rtypes
open Hooks
open Utils

module PGOCaml = Pg.PGOCaml

let () = Pg.PG.Pool.init ~database:Cconfig.database ()

let use dbh f = match dbh with
  | None -> Pg.PG.Pool.use f
  | Some dbh -> f dbh

let one ?(err="expected unique roaw not found") l = match l with
  | [ x ] -> Lwt.return_ok x
  | _ -> Lwt.return_error (`hook_error err)

let get_contracts ?dbh () =
  use dbh @@ fun dbh ->
  [%pgsql dbh "select address from contracts where main"]

let get_extra_config ?dbh () =
  use dbh @@ fun dbh ->
  let>? r = [%pgsql.object dbh
      "select admin_wallet, exchange_v2_contract, royalties_contract, \
       validator_contract from state"] in
  match r with
  | [ r ] ->  Lwt.return_ok (Some {
      admin_wallet = r#admin_wallet;
      exchange_v2 = r#exchange_v2_contract;
      royalties = r#royalties_contract;
      validator = r#validator_contract})
  | [] -> Lwt.return_ok None
  | _ -> Lwt.return_error (`hook_error "wrong_state")

let update_extra_config ?dbh e =
  use dbh @@ fun dbh ->
  let>? r = [%pgsql.object dbh "select * from state"] in
  match r with
  | [] ->
    [%pgsql dbh
        "insert into state(exchange_v2_contract, royalties_contract, validator_contract) \
         values (${e.exchange_v2}, ${e.royalties}, ${e.validator})"]
  | _ ->
    [%pgsql dbh
        "update state set exchange_v2_contract = ${e.exchange_v2}, \
         royalties_contract = ${e.royalties}, validator_contract = ${e.validator}"]

let insert_fake ?dbh address =
  use dbh @@ fun dbh ->
  [%pgsql dbh
      "insert into contracts(kind, address, owner, block, level, tsp, last, main) \
       values('', $address, '', '', 0, now(), now(), true) \
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

let set_account dbh addr ~block ~tsp ~level =
  [%pgsql dbh
      "insert into accounts(address, block, level, last) \
       values($addr, $block, $level, $tsp) on conflict do nothing"]

let transaction_id op =
  match op.bo_nonce with
  | None -> Z.to_string op.bo_counter
  | Some nonce -> Z.to_string op.bo_counter ^ "_" ^ Int32.to_string nonce

let insert_nft_activity dbh timestamp nft_activity =
  let act_type, act_from =
    match nft_activity.nft_activity_type with
    | NftActivityMint -> "mint", None
    | NftActivityBurn -> "burn", None
    | NftActivityTransfer fr -> "transfer", Some fr in
  let token_id =
    Int64.of_string nft_activity.nft_activity_elt.nft_activity_token_id in
  let value =
    Int64.of_string nft_activity.nft_activity_elt.nft_activity_value in
  let level =
    Int64.to_int32 nft_activity.nft_activity_elt.nft_activity_block_number in
  [%pgsql dbh
      "insert into nft_activities(\
       activity_type, transaction, block, level, date, contract, token_id, \
       owner, amount, tr_from) values ($act_type, \
       ${nft_activity.nft_activity_elt.nft_activity_transaction_hash}, \
       ${nft_activity.nft_activity_elt.nft_activity_block_hash}, \
       $level, $timestamp, \
       ${nft_activity.nft_activity_elt.nft_activity_contract}, \
       $token_id, \
       ${nft_activity.nft_activity_elt.nft_activity_owner}, $value, $?act_from) \
       on conflict do nothing"]

let create_nft_activity_elt op contract mi_op = {
  nft_activity_owner = mi_op.tk_owner ;
  nft_activity_contract = contract ;
  nft_activity_token_id = Int64.to_string mi_op.tk_op.tk_token_id ;
  nft_activity_value = Int64.to_string mi_op.tk_op.tk_amount ;
  nft_activity_transaction_hash = op.bo_hash ;
  nft_activity_block_hash = op.bo_block ;
  nft_activity_block_number = Int64.of_int32 op.bo_level ;
}

let insert_nft_activity_mint dbh op kt1 mi_op =
  let nft_activity_elt = create_nft_activity_elt op kt1 mi_op in
  let nft_activity = {
    nft_activity_type = NftActivityMint ;
    nft_activity_elt ;
  } in
  insert_nft_activity dbh op.bo_tsp nft_activity
  (* TODO : KAFKA *)

let insert_nft_activity_burn dbh op kt1 mi_op =
  let nft_activity_elt = create_nft_activity_elt op kt1 mi_op in
  let nft_activity = {
    nft_activity_type = NftActivityBurn ;
    nft_activity_elt ;
  } in
  insert_nft_activity dbh op.bo_tsp nft_activity
  (* TODO : KAFKA *)

let insert_nft_activity_transfer dbh op kt1 source owner token_id amount =
  let nft_activity_elt = {
    nft_activity_owner = owner ;
    nft_activity_contract = kt1;
    nft_activity_token_id = Int64.to_string token_id ;
    nft_activity_value = Int64.to_string amount ;
    nft_activity_transaction_hash = op.bo_hash ;
    nft_activity_block_hash = op.bo_block ;
    nft_activity_block_number = Int64.of_int32 op.bo_level ;
  } in
  let nft_activity = {
    nft_activity_type = NftActivityTransfer source ;
    nft_activity_elt ;
  } in
  insert_nft_activity dbh op.bo_tsp nft_activity
(* TODO : KAFKA *)

let set_mint dbh ~id op kt1 m =
  let meta = EzEncoding.construct token_metadata_enc m.mi_meta in
  let token_id = m.mi_op.tk_op.tk_token_id in
  let owner = m.mi_op.tk_owner in
  let>? () = [%pgsql dbh
      "insert into tokens(contract, token_id, block, level, tsp, last, owner, \
       amount, metadata, transaction, supply) \
       values($kt1, $token_id, ${op.bo_block}, ${op.bo_level}, ${op.bo_tsp}, \
       ${op.bo_tsp}, $owner, 0, $meta, ${op.bo_hash}, 0) on conflict do nothing"] in
  let>? () = set_account dbh owner ~block:op.bo_block ~level:op.bo_level ~tsp:op.bo_tsp in
  let mint = EzEncoding.construct token_op_owner_enc m.mi_op in
  let>? () = [%pgsql dbh
      "insert into contract_updates(transaction, id, block, level, tsp, \
       contract, mint) \
       values(${op.bo_hash}, $id, ${op.bo_block}, ${op.bo_level}, \
       ${op.bo_tsp}, $kt1, $mint) \
       on conflict do nothing"] in
  insert_nft_activity_mint dbh op kt1 m.mi_op

let set_burn dbh ~id op tr m =
  let burn = EzEncoding.construct token_op_owner_enc m in
  let>? () = [%pgsql dbh
      "insert into contract_updates(transaction, id, block, level, tsp, \
       contract, burn) \
       values(${op.bo_hash}, $id, ${op.bo_block}, ${op.bo_level}, \
       ${op.bo_tsp}, ${tr.destination}, $burn) \
       on conflict do nothing"] in
  insert_nft_activity_burn dbh op tr.destination m

let set_transfer dbh ~id op tr lt =
  let kt1 = tr.destination in
  let|>? () = iter_rp (fun {tr_source; tr_txs} ->
      let|>? () = iter_rp (fun {tr_destination; tr_token_id; tr_amount} ->
          let>? () = [%pgsql dbh
              "insert into tokens(contract, token_id, block, level, tsp, last, owner, amount, \
               metadata, transaction, supply) \
               values($kt1, $tr_token_id, ${op.bo_block}, ${op.bo_level}, ${op.bo_tsp}, ${op.bo_tsp}, \
               $tr_destination, 0, '{}', ${op.bo_hash}, 0) on conflict do nothing"] in
          let>? () = [%pgsql dbh
              "insert into token_updates(transaction, id, block, level, tsp, \
               source, destination, contract, token_id, amount) \
               values(${op.bo_hash}, $id, ${op.bo_block}, ${op.bo_level}, \
               ${op.bo_tsp}, $tr_source, $tr_destination, ${tr.destination}, \
               $tr_token_id, $tr_amount) \
               on conflict do nothing"] in
          insert_nft_activity_transfer
            dbh op kt1 tr_source tr_destination tr_token_id tr_amount
        ) tr_txs in
      ()) lt in
  ()

let set_update dbh ~id op tr lt =
  let kt1 = tr.destination in
  iter_rp (fun {op_owner; op_operator; op_token_id; op_add} ->
      let>? () = [%pgsql dbh
          "insert into token_updates(transaction, id, block, level, tsp, \
           source, operator, add, contract, token_id) \
           values(${op.bo_hash}, $id, ${op.bo_block}, ${op.bo_level}, \
           ${op.bo_tsp}, $op_owner, $op_operator, $op_add, \
           $kt1, $op_token_id) on conflict do nothing"] in
      set_account dbh op_operator ~block:op.bo_block ~level:op.bo_level ~tsp:op.bo_tsp) lt

let set_update_all dbh ~id op tr lt =
  let kt1 = tr.destination in
  let source = op.bo_op.source in
  iter_rp (fun (operator, add) ->
      let>? () = [%pgsql dbh
          "insert into token_updates(transaction, id, block, level, tsp, \
           source, operator, add, contract) \
           values(${op.bo_hash}, $id, ${op.bo_block}, ${op.bo_level}, \
           ${op.bo_tsp}, $source, $operator, $add, $kt1) on conflict do nothing"] in
      set_account dbh operator ~block:op.bo_block ~level:op.bo_level ~tsp:op.bo_tsp) lt

let set_uri dbh ~id op tr s =
  [%pgsql dbh
      "insert into contract_updates(transaction, id, block, level, tsp, \
       contract, uri) \
       values(${op.bo_hash}, $id, ${op.bo_block}, ${op.bo_level}, \
       ${op.bo_tsp}, ${tr.destination}, $s) \
       on conflict do nothing"]

let set_metadata dbh ~id op tr (token_id, l) =
  let meta = EzEncoding.construct token_metadata_enc l in
  let source = op.bo_op.source in
  let kt1 = tr.destination in
  [%pgsql dbh
      "insert into token_updates(transaction, id, block, level, tsp, \
       source, token_id, contract, metadata) \
       values(${op.bo_hash}, $id, ${op.bo_block}, ${op.bo_level}, \
       ${op.bo_tsp}, $source, $token_id, $kt1, $meta) \
       on conflict do nothing"]

let set_royalties dbh ~id op roy =
  let royalties = EzEncoding.(construct token_royalties_enc roy.roy_royalties) in
  let source = op.bo_op.source in
  [%pgsql dbh
      "insert into token_updates(transaction, id, block, level, tsp, \
       source, token_id, contract, royalties) \
       values(${op.bo_hash}, $id, ${op.bo_block}, ${op.bo_level}, \
       ${op.bo_tsp}, $source, ${roy.roy_token_id}, ${roy.roy_contract}, $royalties) \
       on conflict do nothing"]

let set_cancel dbh ~id op hash =
  let source = op.bo_op.source in
  [%pgsql dbh
      "insert into order_updates(transaction, id, block, level, tsp, source, cancel) \
       values(${op.bo_hash}, $id, ${op.bo_block}, ${op.bo_level}, \
       ${op.bo_tsp}, $source, $hash) \
       on conflict do nothing"]

let set_do_transfers dbh ~id op ~left ~right =
  let source = op.bo_op.source in
  [%pgsql dbh
      "insert into order_updates(transaction, id, block, level, tsp, source, \
       hash_left, hash_right) \
       values(${op.bo_hash}, $id, ${op.bo_block}, ${op.bo_level}, \
       ${op.bo_tsp}, $source, $left, $right) \
       on conflict do nothing"]

let set_transaction config dbh ~id op tr =
  match tr.parameters with
  | None | Some { value = Other _; _ } | Some { value = Bytes _; _ } -> Lwt.return_ok ()
  | Some {entrypoint; value = Micheline m} ->
    if tr.destination = config.Crawlori.Config.extra.royalties then (* royalties *)
      match Parameters.parse_royalties entrypoint m with
      | Ok roy ->
        Format.printf "\027[0;35mset royalties %s %s\027[0m@." (short op.bo_hash) id;
        set_royalties dbh ~id op roy
      | _ -> Lwt.return_ok ()
    else if tr.destination = config.Crawlori.Config.extra.exchange_v2 then (* exchange_v2 *)
      begin match Parameters.parse_exchange entrypoint m with
        | Ok (Cancel hash) ->
          Format.printf "\027[0;35mcancel order %s %s %s\027[0m@." (short op.bo_hash) id hash;
          set_cancel dbh ~id op hash
        | Ok (DoTransfers {left; right}) ->
          Format.printf "\027[0;35mapply orders %s %s %s %s\027[0m@." (short op.bo_hash) id left right;
          set_do_transfers dbh ~id op ~left ~right
        | _ ->
          (* todo : match order *)
          Lwt.return_ok ()
      end
    else (* nft *)
      begin match Parameters.parse_nft entrypoint m with
        | Ok (Mint_tokens m) ->
          Format.printf "\027[0;35mmint %s %s %s\027[0m@." (short op.bo_hash) id (short tr.destination);
          set_mint dbh ~id op tr.destination m
        | Ok (Burn_tokens b) ->
          Format.printf "\027[0;35mburn %s %s %s\027[0m@." (short op.bo_hash) id (short tr.destination);
          set_burn dbh ~id op tr b
        | Ok (Transfers t) ->
          Format.printf "\027[0;35mtransfer %s %s %s\027[0m@." (short op.bo_hash) id (short tr.destination);
          set_transfer dbh ~id op tr t
        | Ok (Operator_updates t) ->
          Format.printf "\027[0;35mupdate operator %s %s %s\027[0m@." (short op.bo_hash) id (short tr.destination);
          set_update dbh ~id op tr t
        | Ok (Operator_updates_all t) ->
          Format.printf "\027[0;35mupdate operator all %s %s %s\027[0m@." (short op.bo_hash) id (short tr.destination);
          set_update_all dbh ~id op tr t
        | Ok (Metadata_uri s) ->
          Format.printf "\027[0;35mset uri %s %s %s\027[0m@." (short op.bo_hash) id (short tr.destination);
          set_uri dbh ~id op tr s
        | Ok (Token_metadata x) ->
          Format.printf "\027[0;35mset metadata %s %s %s\027[0m@." (short op.bo_hash) id (short tr.destination);
          set_metadata dbh ~id op tr x
        | Error _ -> Lwt.return_ok ()
      end

let filter_contracts dbh ori =
  let|>? r = [%pgsql.object dbh "select admin_wallet, royalties_contract from state"] in
  match r with
  | [ r ] ->
    let open Utils in
    if match_entrypoints (fa2_entrypoints @ fa2_ext_entrypoints) ori.script.code then
      match match_fields [ "ledger"; "owner"; "royaltiesContract" ] ori.script with
      | Ok [ Some _; Some (Mstring owner); Some (Mstring royalties_contract) ] ->
        if r#royalties_contract = royalties_contract then
          Some (`nft (owner, (Z.to_int64 Z.zero)))
        else None
      | _ -> None
    else None
  | _ -> None

let set_origination config dbh op ori =
  let>? r = filter_contracts dbh ori in
  match r with
  | None -> Lwt.return_ok ()
  | Some (`nft (owner, ledger_id)) ->
    let kt1 = Tzfunc.Crypto.op_to_KT1 op.bo_hash in
    let|>? () = [%pgsql dbh
        "insert into contracts(kind, address, owner, block, level, tsp, last, ledger_id) \
         values('nft', $kt1, $owner, ${op.bo_block}, ${op.bo_level}, \
         ${op.bo_tsp}, ${op.bo_tsp}, $ledger_id) on conflict do nothing"] in
    let open Crawlori.Config in
    match config.accounts with
    | None -> config.accounts <- Some (SSet.singleton kt1)
    | Some accs -> config.accounts <- Some (SSet.add kt1 accs)

let set_operation config dbh op =
  let open Hooks in
  let id = transaction_id op in
  match op.bo_op.kind with
  | Transaction tr -> set_transaction config dbh ~id op tr
  (* | Origination ori -> set_origination config dbh op ori *)
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
              bo_numbers = Some c.man_numbers; bo_nonce = None;
              bo_counter = c.man_numbers.counter } in
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
       owner = $source and contract = $contract returning amount, metadata, supply, transaction, tsp"] in
  let>? new_src_amount, meta, supply, transaction, tsp = one ~err:"source token not found for transfer update" info in
  let>? l_new_dst_amount =
    [%pgsql dbh
        "update tokens set amount = amount + $amount, \
         metadata = case when amount = 0 then $meta else metadata end, \
         supply = case when amount = 0 then $supply else supply end, \
         transaction = case when amount = 0 then $transaction else transaction end, \
         tsp = case when amount = 0 then $tsp else tsp end, \
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
      match r#destination, r#token_id, r#amount, r#operator, r#add, r#metadata, r#royalties  with
      | Some destination, Some token_id, Some amount, _, _, _, _ ->
        transfer_updates dbh main ~contract ~block ~level ~tsp ~token_id ~source amount destination
      | _, token_id, _, Some operator, Some add, _, _ ->
        operator_updates dbh main ~operator ~add ~contract ~block ~level ~tsp ?token_id ~source
      | _, Some token_id, _, _, _, Some meta, _ ->
        if main then
          [%pgsql dbh
            "update tokens set metadata = $meta where contract = $contract and \
             token_id = $token_id"]
        else Lwt.return_ok ()
      | _, Some token_id, _, _, _, _, Some royalties ->
        if main then
          [%pgsql dbh
              "update tokens set royalties = $royalties where contract = $contract and \
               token_id = $token_id"]
        else Lwt.return_ok ()
      | _ -> Lwt.return_error (`hook_error "invalid token_update")) l

let order_updates dbh main l =
  iter_rp (fun r -> match r#cancel, r#hash_left, r#hash_right with
      | Some hash, _, _ ->
        [%pgsql dbh "update orders set cancelled = $main where hash = $hash"]
      | _, Some left, Some right ->
        let>? () = [%pgsql dbh "update orders set applied = $main where hash = $left"] in
        [%pgsql dbh "update orders set applied = $main where hash = $right"]
      | _ ->
        Lwt.return_error (`hook_error "invalid token_update")) l


let set_main _config dbh {Hooks.m_main; m_hash} =
  use (Some dbh) @@ fun dbh ->
  let>? () = [%pgsql dbh "update contracts set main = $m_main where block = $m_hash"] in
  let>? () = [%pgsql dbh "update tokens set main = $m_main where block = $m_hash"] in
  let>? () = [%pgsql dbh "update accounts set main = $m_main where block = $m_hash"] in
  let>? () = [%pgsql dbh "update nft_activities set main = $m_main where block = $m_hash"] in
  let>? t_updates = [%pgsql.object dbh "update token_updates set main = $m_main where block = $m_hash returning *"] in
  let>? c_updates = [%pgsql.object dbh "update contract_updates set main = $m_main where block = $m_hash returning *"] in
  let>? o_updates = [%pgsql.object dbh "update order_updates set main = $m_main where block = $m_hash returning *"] in
  let>? () = contract_updates dbh m_main c_updates in
  let>? () = token_updates dbh m_main t_updates in
  let>? () = order_updates dbh m_main o_updates in
  Lwt.return_ok ()

let to_parts l =
  List.map (fun (part_account, v) -> {
        part_account ;
        part_value = Int32.to_int v
      }) l

let get_nft_item_creators_from_metadata metadata =
  try
    let l = EzEncoding.destruct token_metadata_enc metadata in
    let creators = List.assoc "creators" l in
    EzEncoding.destruct (Json_encoding.list part_enc) creators
  with _ -> []

let get_nft_item_owners ?dbh contract token_id =
  use dbh @@ fun dbh ->
  [%pgsql dbh
      "select owner FROM tokens where contract = $contract and token_id = $token_id"]

(* let get_nft_item_royalties ?dbh id =
 *   use dbh @@ fun dbh ->
 *   let|>? l =
 *     [%pgsql dbh
 *         "select account, value FROM royalties where id = $id"] in
 *   to_parts l *)

(* let mk_item_transfer it_obj =
 *   Lwt.return_ok {
 *     item_transfer_type_ = "TRANSFER";
 *     item_transfer_owner = it_obj#owner ;
 *     item_transfer_value = Int64.to_string it_obj#value;
 *     item_transfer_from = it_obj#transfer_from;
 *   } *)

(* let get_nft_item_pending ?dbh id =
 *   use dbh @@ fun dbh ->
 *   let>? l =
 *     [%pgsql.object dbh
 *         "select owner, value, transfer_from from item_transfers where id = $id "] in
 *   map_rp (fun r -> mk_item_transfer r) l *)

(* let mk_media_meta obj =
 *   Lwt.return_ok
 *     (MediaSizeOriginal {
 *         meta_type = obj#media_type ;
 *         meta_width = Option.map Int32.to_int obj#width ;
 *         meta_height = Option.map Int32.to_int obj#height ;
 *       })
 *
 * let mk_nft_media obj =
 *   let|>? nft_media_meta = mk_media_meta obj in
 *   {
 *     nft_media_url = MediaSizeOriginal obj#url ;
 *     nft_media_meta ;
 *   } *)

(* let mk_item_attribute obj =
 *   Lwt.return_ok {
 *     nft_item_attribute_key = obj#key ;
 *     nft_item_attribute_value = obj#value ;
 *   } *)

(* let get_nft_item_meta ?dbh id =
 *   use dbh @@ fun dbh ->
 *   let>? meta = [%pgsql.object dbh
 *       "select name, description from nft_item_meta where id = $id "] in
 *   let>? meta = one meta in
 *   let>? medias = [%pgsql.object dbh
 *       "select url, media_type, width, height from nft_media where id = $id "] in
 *   let>? media = one medias in
 *   let>? attributes = [%pgsql.object dbh
 *       "select key, value from nft_item_attributes where id = $id "] in
 *   let>? image =
 *     if media#media_type = "image/png" then
 *       let|>? m = mk_nft_media media in
 *       Some m
 *     else Lwt.return_ok None in
 *   let>? animation =
 *     if media#media_type = "image/gif" then
 *       let|>? m = mk_nft_media media in
 *       Some m
 *     else Lwt.return_ok None in
 *   map_rp (fun r -> mk_item_attribute r) attributes >>=? fun attributes ->
 *   let attrs = match attributes with [] -> None | _ -> Some attributes in
 *   Lwt.return_ok {
 *     nft_item_meta_name = meta#name ;
 *     nft_item_meta_description = meta#description ;
 *     nft_item_meta_attributes = attrs ;
 *     nft_item_meta_image = image ;
 *     nft_item_meta_animation = animation ;
 *   } *)

let mk_nft_media json =
  try
    Some (EzEncoding.destruct nft_media_enc json)
  with _ -> None

let mk_nft_attributes json =
  try
    Some (EzEncoding.destruct (Json_encoding.list nft_item_attribute_enc) json)
  with _ -> None

let mk_nft_item_meta metadata =
  try
    let l = EzEncoding.destruct token_metadata_enc metadata in
    let name = List.assoc "name" l in
    let description = try Some (List.assoc "description" l) with Not_found -> None in
    let attributes = try mk_nft_attributes @@ List.assoc "attributes" l with Not_found -> None in
    let image = try mk_nft_media @@ List.assoc "image" l with Not_found -> None in
    let animation = try mk_nft_media @@ List.assoc "animation" l with Not_found -> None in
    Lwt.return_ok {
      nft_item_meta_name = name ;
      nft_item_meta_description = description ;
      nft_item_meta_attributes = attributes ;
      nft_item_meta_image = image ;
      nft_item_meta_animation = animation ;
    }
  with Not_found -> Lwt.return_error (`hook_error "no name in token metadata")
     | EzEncoding.DestructError ->
       Lwt.return_error (`hook_error ("metadata destruct error"))

let mk_nft_item ?include_meta obj =
  let creators = get_nft_item_creators_from_metadata obj#metadata in
  get_nft_item_owners obj#contract obj#token_id >>=? fun owners ->
  (* get_nft_item_royalties  >>=? fun royalties -> *)
  (* get_nft_item_pending nft_obj#id >>=? fun pending -> *)
  begin match include_meta with
    | Some true -> let|>? meta = mk_nft_item_meta obj#metadata in Some meta
    | _ -> Lwt.return_ok None
  end
  >>=? fun meta ->
  (* let pending = match pending with [] -> None | _ -> Some [] in *)
  Lwt.return_ok {
    nft_item_id = Option.get obj#id ;
    nft_item_contract = obj#contract ;
    nft_item_token_id = Int64.to_string obj#token_id ;
    nft_item_creators = creators ;
    nft_item_supply = Int64.to_string obj#supply ;
    nft_item_lazy_supply = Int64.to_string 0L ;
    nft_item_owners = owners ;
    nft_item_royalties = [] ;
    nft_item_date = obj#last ;
    nft_item_pending = None ;
    nft_item_deleted = if obj#supply > 0L then Some false else Some true ;
    nft_item_meta = meta ;
  }

let mk_nft_items_continuation nft_item =
  Printf.sprintf "%Ld_%s"
    (Int64.of_float @@ CalendarLib.Calendar.to_unixfloat nft_item.nft_item_date)
    nft_item.nft_item_id

let get_nft_items_by_owner ?dbh ?include_meta ?continuation ?(size=50) owner =
  Format.eprintf "get_nft_items_by_owner %s %s %s %d@."
    owner
    (match include_meta with None -> "None" | Some s -> string_of_bool s)
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size ;
  use dbh @@ fun dbh ->
  let size64 = Int64.of_int size in
  let no_continuation, (ts, id) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  let>? l = [%pgsql.object dbh
      "select concat(contract, ':', token_id) as id, contract, token_id, \
       last, amount, supply, metadata \
       from tokens where \
       main and owner = $owner and \
       ($no_continuation or \
       (last = $ts and concat(contract, ':', token_id) > $id) or \
       (last < $ts)) \
       order by last desc, id asc limit $size64"] in
  let>? nft_items_total = [%pgsql dbh
      "select count(owner) from tokens where main"] in
  let>? nft_items_total = match nft_items_total with
    | [ None ] -> Lwt.return_ok 0L
    | [ Some i64 ] -> Lwt.return_ok i64
    | _ -> Lwt.return_error (`hook_error "count with more then one row") in
  map_rp (fun r -> mk_nft_item ?include_meta r) l >>=? fun nft_items_items ->
  let len = List.length nft_items_items in
  let nft_items_continuation =
    if len <> size then None
    else Some
        (mk_nft_items_continuation @@ List.hd (List.rev nft_items_items)) in
  Lwt.return_ok
    { nft_items_items ; nft_items_continuation ; nft_items_total }

let get_nft_items_by_creator ?dbh ?include_meta ?continuation ?(size=50) creator =
  Format.eprintf "get_nft_items_by_creator %s %s %s %d@."
    creator
    (match include_meta with None -> "None" | Some s -> string_of_bool s)
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size ;
  use dbh @@ fun dbh ->
  let size64 = Int64.of_int size in
  let no_continuation, (ts, id) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  let>? l = [%pgsql.object dbh
      "select concat(contract, ':', token_id) as id, contract, token_id, \
       last, amount, supply, metadata \
       from tokens, \
       jsonb_to_recordset((metadata -> 'creators')) as creators(account varchar, value int) \
       where creators.account = $creator and \
       main and \
       ($no_continuation or \
       (last = $ts and concat(contract, ':', token_id) > $id) or \
       (last < $ts)) \
       order by last desc, id asc limit $size64"] in
  let>? nft_items_total = [%pgsql dbh
      "select count(owner) from tokens where main"] in
  let>? nft_items_total = match nft_items_total with
    | [ None ] -> Lwt.return_ok 0L
    | [ Some i64 ] -> Lwt.return_ok i64
    | _ -> Lwt.return_error (`hook_error "count with more then one row") in
  map_rp (fun r -> mk_nft_item ?include_meta r) l >>=? fun nft_items_items ->
  let len = List.length nft_items_items in
  let nft_items_continuation =
    if len <> size then None
    else Some
        (mk_nft_items_continuation @@ List.hd (List.rev nft_items_items)) in
  Lwt.return_ok
    { nft_items_items ; nft_items_continuation ; nft_items_total }

let get_nft_item_by_id ?dbh ?include_meta contract token_id =
  Format.eprintf "get_nft_item_by_id %s %s %s@."
    contract
    token_id
    (match include_meta with None -> "None" | Some s -> string_of_bool s) ;
  use dbh @@ fun dbh ->
  let id64 = Int64.of_string token_id in
  let>? l = [%pgsql.object dbh
      "select concat(contract, ':', token_id) as id, contract, token_id, \
       last, amount, supply, metadata \
       from tokens where \
       main and contract = $contract and token_id = $id64"] in
  match l with
  | obj :: _ ->
    let>? nft_item = mk_nft_item ?include_meta obj in
    Lwt.return_ok nft_item
  | [] -> Lwt.return_error (`hook_error "nft_item not found")

let get_nft_items_by_collection ?dbh ?include_meta ?continuation ?(size=50) contract =
  Format.eprintf "get_nft_items_by_collection %s %s %s %d@."
    contract
    (match include_meta with None -> "None" | Some s -> string_of_bool s)
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size ;
  use dbh @@ fun dbh ->
  let size64 = Int64.of_int size in
  let no_continuation, (ts, id) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  let>? l = [%pgsql.object dbh
      "select concat(contract, ':', token_id) as id, contract, token_id, \
       last, amount, supply, metadata \
       from tokens where \
       main and contract = $contract and \
       ($no_continuation or \
       (last = $ts and concat(contract, ':', token_id) > $id) or \
       (last < $ts)) \
       order by last desc, id asc limit $size64"] in
  let>? nft_items_total = [%pgsql dbh
      "select count(owner) from tokens where main"] in
  let>? nft_items_total = match nft_items_total with
    | [ None ] -> Lwt.return_ok 0L
    | [ Some i64 ] -> Lwt.return_ok i64
    | _ -> Lwt.return_error (`hook_error "count with more then one row") in
  map_rp (fun r -> mk_nft_item ?include_meta r) l >>=? fun nft_items_items ->
  let len = List.length nft_items_items in
  let nft_items_continuation =
    if len <> size then None
    else Some
        (mk_nft_items_continuation @@ List.hd (List.rev nft_items_items)) in
  Lwt.return_ok
    { nft_items_items ; nft_items_continuation ; nft_items_total }

let get_nft_item_meta_by_id ?dbh contract token_id =
  Format.eprintf "get_nft_meta_by_id %s %s@." contract token_id ;
  let id64 = Int64.of_string token_id in
  use dbh @@ fun dbh ->
  let>? l = [%pgsql dbh
      "select metadata from tokens \
       where contract = $contract and token_id = $id64 and main"] in
  let>? metadata = one l in
  let>? meta = mk_nft_item_meta metadata in
  Lwt.return_ok meta

let get_nft_all_items
    ?dbh ?last_updated_to ?last_updated_from ?show_deleted ?include_meta
    ?continuation ?(size=50) () =
  Format.eprintf "get_nft_all_items %s %s %s %s %s %d@."
    (match last_updated_to with None -> "None" | Some s -> Tzfunc.Proto.A.cal_to_str s)
    (match last_updated_from with None -> "None" | Some s -> Tzfunc.Proto.A.cal_to_str s)
    (match show_deleted with None -> "None" | Some s -> string_of_bool s)
    (match include_meta with None -> "None" | Some s -> string_of_bool s)
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size ;
  use dbh @@ fun dbh ->
  let size64 = Int64.of_int size in
  let no_continuation, (ts, id) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  let no_last_updated_to, last_updated_to_v =
    last_updated_to = None,
    (match last_updated_to with None -> CalendarLib.Calendar.now () | Some ts -> ts) in
  let no_last_updated_from, last_updated_from_v =
    last_updated_from = None,
    (match last_updated_from with None -> CalendarLib.Calendar.now () | Some ts -> ts) in
  let no_show_deleted, show_deleted_v =
    show_deleted = None,
    (match show_deleted with None -> false | Some b -> b) in
  let>? l = [%pgsql.object dbh
      "select concat(contract, ':', token_id) as id, contract, token_id, \
       last, amount, supply, metadata \
       from tokens where \
       main and \
       (supply > 0 or (not $no_show_deleted and $show_deleted_v)) and \
       ($no_last_updated_to or (last <= $last_updated_to_v)) and \
       ($no_last_updated_from or (last >= $last_updated_from_v)) and \
       ($no_continuation or \
       (last = $ts and concat(contract, ':', token_id) > $id) or \
       (last < $ts)) \
       order by last desc, id asc limit $size64"] in
  let>? nft_items_total = [%pgsql dbh
      "select count(owner) from tokens where main"] in
  let>? nft_items_total = match nft_items_total with
    | [ None ] -> Lwt.return_ok 0L
    | [ Some i64 ] -> Lwt.return_ok i64
    | _ -> Lwt.return_error (`hook_error "count with more then one row") in
  map_rp (fun r -> mk_nft_item ?include_meta r) l >>=? fun nft_items_items ->
  let len = List.length nft_items_items in
  let nft_items_continuation =
    if len <> size then None
    else Some
        (mk_nft_items_continuation @@ List.hd (List.rev nft_items_items)) in
  Lwt.return_ok
    { nft_items_items ; nft_items_continuation ; nft_items_total }

let mk_nft_activity_continuation obj =
  Printf.sprintf "%Ld_%s"
    (Int64.of_float @@ CalendarLib.Calendar.to_unixfloat obj#date)
    obj#transaction

let mk_nft_activity_elt obj = {
  nft_activity_owner = obj#owner ;
  nft_activity_contract = obj#contract ;
  nft_activity_token_id = Int64.to_string obj#token_id ;
  nft_activity_value = Int64.to_string obj#amount ;
  nft_activity_transaction_hash = obj#transaction ;
  nft_activity_block_hash = obj#block ;
  nft_activity_block_number = Int64.of_int32 obj#level ;
}

let mk_nft_activity obj = match obj#activity_type with
  | "mint" ->
    let nft_activity_elt = mk_nft_activity_elt obj in
    Lwt.return_ok {
      nft_activity_type = NftActivityMint ;
      nft_activity_elt ;
    }
  | "burn" ->
    let nft_activity_elt = mk_nft_activity_elt obj in
    Lwt.return_ok {
      nft_activity_type = NftActivityBurn ;
      nft_activity_elt ;
    }
  | "transfer" ->
    let nft_activity_elt = mk_nft_activity_elt obj in
    let tr_from = Option.get obj#tr_from in
    Lwt.return_ok {
      nft_activity_type = NftActivityTransfer tr_from ;
      nft_activity_elt ;
    }
  | _ as t -> Lwt.return_error (`hook_error ("unknown nft activity type " ^ t))

let get_nft_activities_by_collection ?dbh ?continuation ?(size=50) filter =
  use dbh @@ fun dbh ->
  let contract = filter.nft_activity_by_collection_contract in
  let types = filter_all_type_to_array filter.nft_activity_by_collection_types in
  let size64 = Int64.of_int size in
  let no_continuation, (ts, h) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  let>? l = [%pgsql.object dbh
      "select activity_type, transaction, block, level, date, contract, \
       token_id, owner, amount, tr_from from nft_activities where \
       main and contract = $contract and activity_type = any($types) and \
       ($no_continuation or \
       (date = $ts and transaction > $h) or (date < $ts)) \
       order by date desc, transaction asc limit $size64"] in
  map_rp (fun r -> let|>? a = mk_nft_activity r in a, r) l >>=? fun activities ->
  let len = List.length activities in
  let nft_activities_continuation =
    if len <> size then None
    else Some
        (mk_nft_activity_continuation @@ snd @@ List.hd (List.rev activities)) in
  Lwt.return_ok
    { nft_activities_items = List.map fst activities ; nft_activities_continuation }

let get_nft_activities_by_item ?dbh ?continuation ?(size=50) filter =
  use dbh @@ fun dbh ->
  let contract = filter.nft_activity_by_item_contract in
  let token_id = Int64.of_string filter.nft_activity_by_item_token_id in
  let types = filter_all_type_to_array filter.nft_activity_by_item_types in
  let size64 = Int64.of_int size in
  let no_continuation, (ts, h) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  let>? l = [%pgsql.object dbh
      "select activity_type, transaction, block, level, date, contract, \
       token_id, owner, amount, tr_from from nft_activities where \
       main and contract = $contract and token_id = $token_id and \
       activity_type = any($types) and \
       ($no_continuation or \
       (date = $ts and transaction > $h) or (date < $ts)) \
       order by date desc, transaction asc limit $size64"] in
  map_rp (fun r -> let|>? a = mk_nft_activity r in a, r) l >>=? fun activities ->
  let len = List.length activities in
  let nft_activities_continuation =
    if len <> size then None
    else Some
        (mk_nft_activity_continuation @@ snd @@ List.hd (List.rev activities)) in
  Lwt.return_ok
    { nft_activities_items = List.map fst activities ; nft_activities_continuation }

let get_nft_activities_by_user ?dbh ?continuation ?(size=50) filter =
  use dbh @@ fun dbh ->
  let users = List.map Option.some filter.nft_activity_by_user_users in
  let types = filter_user_type_to_array filter.nft_activity_by_user_types in
  let size64 = Int64.of_int size in
  let no_continuation, (ts, h) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  let>? l = [%pgsql.object dbh
      "select activity_type, transaction, block, level, date, contract, \
       token_id, owner, amount, tr_from from nft_activities where \
       main and owner = any($users) and \
       activity_type = any($types) and \
       ($no_continuation or \
       (date = $ts and transaction > $h) or (date < $ts)) \
       order by date desc, transaction asc limit $size64"] in
  map_rp (fun r -> let|>? a = mk_nft_activity r in a, r) l >>=? fun activities ->
  let len = List.length activities in
  let nft_activities_continuation =
    if len <> size then None
    else Some
        (mk_nft_activity_continuation @@ snd @@ List.hd (List.rev activities)) in
  Lwt.return_ok
    { nft_activities_items = List.map fst activities ; nft_activities_continuation }

let get_nft_activities_all ?dbh ?continuation ?(size=50) types =
  use dbh @@ fun dbh ->
  let types = filter_all_type_to_array types in
  let size64 = Int64.of_int size in
  let no_continuation, (ts, h) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  let>? l = [%pgsql.object dbh
      "select activity_type, transaction, block, level, date, contract, \
       token_id, owner, amount, tr_from from nft_activities where \
       main and activity_type = any($types) and \
       ($no_continuation or \
       (date = $ts and transaction > $h) or (date < $ts)) \
       order by date desc, transaction asc limit $size64"] in
  map_rp (fun r -> let|>? a = mk_nft_activity r in a, r) l >>=? fun activities ->
  let len = List.length activities in
  let nft_activities_continuation =
    if len <> size then None
    else Some
        (mk_nft_activity_continuation @@ snd @@ List.hd (List.rev activities)) in
  Lwt.return_ok
    { nft_activities_items = List.map fst activities ; nft_activities_continuation }

let get_nft_activities ?dbh ?continuation ?size = function
  | ActivityFilterByCollection filter ->
    get_nft_activities_by_collection ?dbh ?continuation ?size filter
  | ActivityFilterByItem filter ->
    get_nft_activities_by_item ?dbh ?continuation ?size filter
  | ActivityFilterByUser filter ->
    get_nft_activities_by_user ?dbh ?continuation ?size filter
  | ActivityFilterAll filter ->
    get_nft_activities_all ?dbh ?continuation ?size filter

let mk_nft_ownerships_continuation nft_ownership =
  Printf.sprintf "%Ld_%s"
    (Int64.of_float @@ CalendarLib.Calendar.to_unixfloat nft_ownership.nft_ownership_date)
    nft_ownership.nft_ownership_id

let mk_nft_ownership obj =
  let creators = get_nft_item_creators_from_metadata obj#metadata in
  (* TODO : pending *)
  (* TODO : last <> mint date ? *)
  Lwt.return_ok {
  nft_ownership_id = Option.get obj#id ;
  nft_ownership_contract = obj#contract ;
  nft_ownership_token_id = Int64.to_string obj#token_id ;
  nft_ownership_owner = obj#owner ;
  nft_ownership_creators = creators ;
  nft_ownership_value = Int64.to_string obj#amount ;
  nft_ownership_lazy_value = "0" ;
  nft_ownership_date = obj#last ;
  nft_ownership_pending = [] ;
}

let get_nft_ownership_by_id ?dbh contract token_id owner =
  Format.eprintf "get_nft_ownership_by_id %s %s %s@." contract token_id owner ;
  let id64 = Int64.of_string token_id in
  use dbh @@ fun dbh ->
  let>? l = [%pgsql.object dbh
      "select concat(contract, ':', token_id, ':', owner) as id, \
       contract, token_id, owner, last, amount, supply, metadata \
       from tokens where \
       main and contract = $contract and token_id = $id64 and owner = $owner"] in
  let>? obj = one l in
  let>? nft_ownership = mk_nft_ownership obj in
  Lwt.return_ok nft_ownership

let get_nft_ownerships_by_item ?dbh ?continuation ?(size=50) contract token_id =
  Format.eprintf "get_nft_ownerships_by_item %s %s %s %d@."
    contract
    token_id
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size ;
  let id64 = Int64.of_string token_id in
  let size64 = Int64.of_int size in
  let no_continuation, (ts, id) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  use dbh @@ fun dbh ->
  let>? l = [%pgsql.object dbh
      "select concat(contract, ':', token_id, ':', owner) as id, \
       contract, token_id, owner, last, amount, supply, metadata \
       from tokens where \
       main and contract = $contract and token_id = $id64 and \
       ($no_continuation or \
       (last = $ts and concat(contract, ':', token_id, ':', owner) > $id) or \
       (last < $ts)) \
       order by last desc, id asc limit $size64"] in
  let>? nft_ownerships_total = [%pgsql dbh
      "select count(owner) from tokens where main"] in
  let>? nft_ownerships_total = match nft_ownerships_total with
    | [ None ] -> Lwt.return_ok 0L
    | [ Some i64 ] -> Lwt.return_ok i64
    | _ -> Lwt.return_error (`hook_error "count with more then one row") in
  map_rp (fun r -> mk_nft_ownership r) l >>=? fun nft_ownerships_ownerships ->
  let len = List.length nft_ownerships_ownerships in
  let nft_ownerships_continuation =
    if len <> size then None
    else Some
        (mk_nft_ownerships_continuation @@ List.hd (List.rev nft_ownerships_ownerships)) in
  Lwt.return_ok
    { nft_ownerships_ownerships ; nft_ownerships_continuation ; nft_ownerships_total }

let get_nft_all_ownerships ?dbh ?continuation ?(size=50) () =
  Format.eprintf "get_nft_all_ownerships %s %d@."
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size ;
  let size64 = Int64.of_int size in
  let no_continuation, (ts, id) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  use dbh @@ fun dbh ->
  let>? l = [%pgsql.object dbh
      "select concat(contract, ':', token_id, ':', owner) as id, \
       contract, token_id, owner, last, amount, supply, metadata \
       from tokens where \
       main and \
       ($no_continuation or \
       (last = $ts and concat(contract, ':', token_id, ':', owner) > $id) or \
       (last < $ts)) \
       order by last desc, id asc limit $size64"] in
  let>? nft_ownerships_total = [%pgsql dbh
      "select count(owner) from tokens where main"] in
  let>? nft_ownerships_total = match nft_ownerships_total with
    | [ None ] -> Lwt.return_ok 0L
    | [ Some i64 ] -> Lwt.return_ok i64
    | _ -> Lwt.return_error (`hook_error "count with more then one row") in
  map_rp (fun r -> mk_nft_ownership r) l >>=? fun nft_ownerships_ownerships ->
  let len = List.length nft_ownerships_ownerships in
  let nft_ownerships_continuation =
    if len <> size then None
    else Some
        (mk_nft_ownerships_continuation @@ List.hd (List.rev nft_ownerships_ownerships)) in
  Lwt.return_ok
    { nft_ownerships_ownerships ; nft_ownerships_continuation ; nft_ownerships_total }

let generate_nft_token_id ?dbh contract =
  Format.eprintf "generate_nft_token_id %s@."
    contract ;
  use dbh @@ fun dbh ->
  let>? r = [%pgsql dbh "select tokens_number from contracts where address = $contract"] in
  match r with
  | [ i ] -> Lwt.return_ok {
      nft_token_id = Int64.(to_string @@ succ i) ;
      nft_token_id_signatures = [] ;
    }
  | _ -> Lwt.return_error (`hook_error "no contracts entry for this contract")

let mk_nft_collection_name_symbol metadata =
  try
    let l = EzEncoding.destruct token_metadata_enc metadata in
    let name = List.assoc "name" l in
    let symbol = try Some (List.assoc "symbol" l) with Not_found -> None in
    Lwt.return_ok (name, symbol)
  with Not_found -> Lwt.return_error (`hook_error "no name in contract metadata")
     | EzEncoding.DestructError ->
       Lwt.return_error (`hook_error ("metadata destruct error"))

let mk_nft_collection obj =
  let|>? (name, symbol) = mk_nft_collection_name_symbol obj#metadata in
  {
    nft_collection_id = obj#address ;
    nft_collection_owner = Some (obj#owner) ;
    nft_collection_type = CTFA_2 ;
    nft_collection_name = name ;
    nft_collection_symbol = symbol ;
    nft_collection_features = [] ;
    nft_collection_supports_lazy_mint = false ;
  }

let get_nft_collection_by_id ?dbh collection =
  Format.eprintf "get_nft_collection_by_id %s@." collection ;
  use dbh @@ fun dbh ->
  let>? l = [%pgsql.object dbh
      "select address, owner, metadata \
       from contracts where address = $collection and main"] in
  let>? obj = one l in
  let>? nft_item = mk_nft_collection obj in
  Lwt.return_ok nft_item

let search_nft_collections_by_owner ?dbh ?continuation ?(size=50) owner =
  Format.eprintf "search_nft_collections_by_owner %s %s %d@."
    owner
    (match continuation with None -> "None" | Some c -> c)
    size ;
  use dbh @@ fun dbh ->
  let size64 = Int64.of_int size in
  let no_continuation, collection =
    continuation = None, (match continuation with None -> "" | Some c -> c) in
  let>? l = [%pgsql.object dbh
      "select address, owner, metadata \
       from contracts where \
       main and owner = $owner and metadata <> '{}' and \
       ($no_continuation or (address > $collection)) \
       order by address asc limit $size64"] in
  let>? nft_collections_total = [%pgsql dbh
      "select count(address) from contracts where main and owner = $owner "] in
  let>? nft_collections_total = match nft_collections_total with
    | [ None ] -> Lwt.return_ok 0L
    | [ Some i64 ] -> Lwt.return_ok i64
    | _ -> Lwt.return_error (`hook_error "count with more then one row") in
  map_rp (fun r -> mk_nft_collection r) l >>=? fun nft_collections_collections ->
  let len = List.length nft_collections_collections in
  let nft_collections_continuation =
    if len <> size then None
    else Some (List.hd (List.rev nft_collections_collections)).nft_collection_id in
  Lwt.return_ok
    { nft_collections_collections ; nft_collections_continuation ; nft_collections_total }

let get_nft_all_collections ?dbh ?continuation ?(size=50) () =
  Format.eprintf "get_nft_all_collections %s %d@."
    (match continuation with None -> "None" | Some c -> c)
    size ;
  use dbh @@ fun dbh ->
  let size64 = Int64.of_int size in
  let no_continuation, collection =
    continuation = None, (match continuation with None -> "" | Some c -> c) in
  let>? l = [%pgsql.object dbh
      "select address, owner, metadata \
       from contracts where main and metadata <> '{}' and \
       ($no_continuation or (address > $collection)) \
       order by address asc limit $size64"] in
  let>? nft_collections_total = [%pgsql dbh
      "select count(address) from contracts where main "] in
  let>? nft_collections_total = match nft_collections_total with
    | [ None ] -> Lwt.return_ok 0L
    | [ Some i64 ] -> Lwt.return_ok i64
    | _ -> Lwt.return_error (`hook_error "count with more then one row") in
  map_rp (fun r -> mk_nft_collection r) l >>=? fun nft_collections_collections ->
  let len = List.length nft_collections_collections in
  let nft_collections_continuation =
    if len <> size then None
    else Some (List.hd (List.rev nft_collections_collections)).nft_collection_id in
  Lwt.return_ok
    { nft_collections_collections ; nft_collections_continuation ; nft_collections_total }

let mk_asset asset_class contract token_id asset_value =
  let asset_value = Int64.to_string asset_value in
  match asset_class with
  (* For testing purposes*)
  | "ERC721" ->
    begin
      match contract, token_id with
      | Some c, Some id ->
        let asset_type =
          ATERC721
            { asset_type_nft_contract = c ; asset_type_nft_token_id = id } in
        Lwt.return_ok { asset_type; asset_value }
      | _, _ ->
        Lwt.return_error (`hook_error ("no contract addr or tokenId for ERC721 asset"))
    end
  | "ETH" ->
    begin
      match contract, token_id with
      | None, None ->
        Lwt.return_ok { asset_type = ATETH ; asset_value }
      | _, _ ->
        Lwt.return_error (`hook_error ("contract addr or tokenId for ETH asset"))
    end
    (* Tezos assets*)
  | "XTZ" ->
    begin
      match contract, token_id with
      | None, None ->
        Lwt.return_ok { asset_type = ATXTZ ; asset_value }
      | _, _ ->
        Lwt.return_error (`hook_error ("contract addr or tokenId for XTZ asset"))
    end
  | "FA_1_2" ->
    begin
      match contract, token_id with
      | Some c, None ->
        let asset_type = ATFA_1_2 c in
        Lwt.return_ok { asset_type; asset_value }
      | _, _ ->
        Lwt.return_error (`hook_error ("need contract and no tokenId for FA1.2 asset"))
    end
  | "FA_2" ->
    begin
      match contract, token_id with
      | Some c, Some id ->
        let asset_type =
          ATFA_2
            { asset_fa2_contract = c ; asset_fa2_token_id = id } in
        Lwt.return_ok { asset_type; asset_value }
      | _, _ ->
        Lwt.return_error (`hook_error ("no contract addr for FA2 asset"))
    end
  | _ ->
    Lwt.return_error (`hook_error ("invalid asset class " ^ asset_class))

let db_from_asset asset =
  let asset_value = Int64.of_string asset.asset_value in
  match asset.asset_type with
  (* For testing purposes*)
  | ATERC721 data ->
    Lwt.return_ok
      (string_of_asset_type asset.asset_type,
       Some data.asset_type_nft_contract,
       Some data.asset_type_nft_token_id,
       asset_value)
  | ATETH ->
    Lwt.return_ok
      (string_of_asset_type asset.asset_type, None, None, asset_value)
  (* Tezos assets*)
  | ATXTZ ->
    Lwt.return_ok
      (string_of_asset_type asset.asset_type, None, None, asset_value)
  | ATFA_1_2 c ->
    Lwt.return_ok
      (string_of_asset_type asset.asset_type,
       Some c,
       None,
       asset_value)
  | ATFA_2 fa2 ->
    Lwt.return_ok
      (string_of_asset_type asset.asset_type,
       Some fa2.asset_fa2_contract,
       Some fa2.asset_fa2_token_id,
       asset_value)

let get_order_pending ?dbh hash_key =
  use dbh @@ fun dbh ->
  let>? l = [%pgsql dbh
      "select type, make_asset_type_class, make_asset_type_contract, \
       make_asset_type_token_id, make_asset_value, \
       take_asset_type_class, take_asset_type_contract, \
       take_asset_type_token_id, take_asset_value, \
       date, maker, side, fill, taker, counter_hash, make_usd, take_usd, \
       make_price_usd, take_price_usd \
       from order_pending where hash = $hash_key"] in
  map_rp
    (fun
      (htype, make_class, make_contract, make_token_id, make_asset_value,
       take_class, take_contract, take_token_id, take_asset_value,
       date, maker, side, fill, taker, counter_hash, make_usd, take_usd,
       make_price_usd, take_price_usd) ->
      begin match make_class, make_asset_value with
        | Some ac, Some v ->
          mk_asset ac make_contract make_token_id v >>=? fun asset ->
          Lwt.return_ok @@ Some asset
        | _, _ -> Lwt.return_ok None
      end >>=? fun order_exchange_history_elt_make ->
      begin match take_class ,take_asset_value with
        | Some ac, Some v ->
          mk_asset ac take_contract take_token_id v >>=? fun asset ->
          Lwt.return_ok @@ Some asset
        | _, _ -> Lwt.return_ok None
      end >>=? fun order_exchange_history_elt_take ->
      let order_exchange_history_elt = {
        order_exchange_history_elt_hash = hash_key ;
        order_exchange_history_elt_make ;
        order_exchange_history_elt_take ;
        order_exchange_history_elt_date = date ;
        order_exchange_history_elt_maker = maker ;
      } in
      match htype with
      | "CANCEL" ->
        Lwt.return_ok @@ OrderCancel order_exchange_history_elt
      | "ORDER_SIDE_MATCH" ->
        begin
          match fill with
          | None ->
            Lwt.return_error (`hook_error "null fill with order_side_match")
          | Some f ->
            let order_side_match_fill = Int64.to_string f in
            let order_side_match = {
              order_side_match_elt = order_exchange_history_elt ;
              order_side_match_side = order_side_opt_of_string_opt side ;
              order_side_match_fill ;
              order_side_match_taker = taker ;
              order_side_match_counter_hash = counter_hash ;
              order_side_match_make_usd = string_opt_of_float_opt make_usd;
              order_side_match_take_usd = string_opt_of_float_opt take_usd ;
              order_side_match_make_price_usd = string_opt_of_float_opt make_price_usd ;
              order_side_match_take_price_usd = string_opt_of_float_opt take_price_usd ;
            } in
            Lwt.return_ok @@ OrderSideMatch order_side_match
        end
      | _ -> Lwt.return_error (`hook_error ("wrong pending type " ^ htype))) l

let get_order_price_history ?dbh hash_key =
  use dbh @@ fun dbh ->
  let|>? l = [%pgsql dbh
      "select date, make_value, take_value \
       from order_price_history where hash = $hash_key \
       order by date desc"] in
  List.map
    (fun (date, make_value, take_value) -> {
         order_price_history_record_date = date ;
         order_price_history_record_make_value = Int64.to_string make_value ;
         order_price_history_record_take_value = Int64.to_string take_value ;
       }) l

let get_order_origin_fees ?dbh hash_key =
  use dbh @@ fun dbh ->
  let|>? l = [%pgsql dbh
      "select account, value from origin_fees where hash = $hash_key"] in
  to_parts l

let get_order_payouts ?dbh hash_key =
  use dbh @@ fun dbh ->
  let|>? l = [%pgsql dbh
      "select account, value from payouts where hash = $hash_key"] in
  to_parts l

let mk_order ?dbh order_obj =
  mk_asset
    order_obj#make_asset_type_class
    order_obj#make_asset_type_contract
    order_obj#make_asset_type_token_id
    order_obj#make_asset_value
  >>=? fun order_elt_make ->
  mk_asset
    order_obj#take_asset_type_class
    order_obj#take_asset_type_contract
    order_obj#take_asset_type_token_id
    order_obj#take_asset_value
  >>=? fun order_elt_take ->
  get_order_pending ?dbh order_obj#hash >>=? fun pending ->
  get_order_price_history ?dbh order_obj#hash >>=? fun price_history ->
  get_order_origin_fees ?dbh order_obj#hash >>=? fun origin_fees ->
  get_order_payouts ?dbh order_obj#hash >>=? fun payouts ->
  let order_elt = {
    order_elt_maker = order_obj#maker ;
    order_elt_taker = order_obj#taker ;
    order_elt_make ;
    order_elt_take ;
    order_elt_fill = Int64.to_string order_obj#fill ;
    order_elt_start = order_obj#start_date ;
    order_elt_end = order_obj#end_date ;
    order_elt_make_stock = Int64.to_string order_obj#make_stock ;
    order_elt_cancelled = order_obj#cancelled ;
    order_elt_salt = order_obj#salt ;
    order_elt_signature = order_obj#signature ;
    order_elt_created_at = order_obj#created_at ;
    order_elt_last_update_at = order_obj#last_update_at ;
    order_elt_pending = Some pending ;
    order_elt_hash = order_obj#hash ;
    order_elt_make_balance = string_opt_of_int64_opt order_obj#make_balance ;
    order_elt_make_price_usd = string_opt_of_float_opt order_obj#make_price_usd ;
    order_elt_take_price_usd = string_opt_of_float_opt order_obj#take_price_usd ;
    order_elt_price_history = price_history ;
  } in
  let data = RaribleV2Order {
    order_rarible_v2_data_v1_data_type = "RARIBLE_V2_DATA_V1" ;
    order_rarible_v2_data_v1_payouts = payouts ;
    order_rarible_v2_data_v1_origin_fees = origin_fees ;
  } in
  let rarible_v2_order = {
    order_elt = order_elt ;
    order_data = data ;
  } in
  Lwt.return_ok rarible_v2_order

let get_order ?dbh hash_key =
  use dbh @@ fun dbh ->
  let>? l = [%pgsql.object dbh
      "select maker, taker, \
       make_asset_type_class, make_asset_type_contract, make_asset_type_token_id, \
       make_asset_value, \
       take_asset_type_class, take_asset_type_contract, take_asset_type_token_id, \
       take_asset_value, \
       fill, start_date, end_date, make_stock, cancelled, salt, \
       signature, created_at, last_update_at, hash, \
       make_balance, make_price_usd, take_price_usd \
       from orders where make_stock > 0 and hash = $hash_key"] in
  match l with
  | [] -> Lwt.return_ok None
  | _ ->
    one l >>=? fun r ->
    mk_order r >>=? fun order ->
    Lwt.return_ok @@ Some order

let mk_order_continuation order =
  Printf.sprintf "%Ld_%s"
    (Int64.of_float @@ CalendarLib.Calendar.to_unixfloat order.order_elt.order_elt_last_update_at)
    order.order_elt.order_elt_hash

let get_orders_all ?dbh ?origin ?continuation ?(size=50) () =
  Format.eprintf "get_orders_all %s %s %d@."
    (match origin with None -> "None" | Some s -> s)
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size ;
  use dbh @@ fun dbh ->
  let size64 = Int64.of_int size in
  let no_origin, origin_v = origin = None, (match origin with None -> "" | Some o -> o) in
  let no_continuation, (ts, h) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  let>? l = [%pgsql.object dbh
      "select maker, taker, \
       make_asset_type_class, make_asset_type_contract, make_asset_type_token_id, \
       make_asset_value, \
       take_asset_type_class, take_asset_type_contract, take_asset_type_token_id, \
       take_asset_value, \
       fill, start_date, end_date, make_stock, cancelled, salt, \
       signature, created_at, last_update_at, hash, \
       make_balance, make_price_usd, take_price_usd \
       from orders where \
       ($no_origin or (hash in (select hash from origin_fees where account = $origin_v))) and \
       ($no_continuation or (last_update_at = $ts and hash > $h) or (last_update_at < $ts)) and \
       make_stock > 0 \
       order by last_update_at desc, hash asc limit $size64"] in
  map_rp (fun r -> mk_order r) l >>=? fun orders ->
  let len = List.length orders in
  let orders_pagination_contination =
    if len <> size then None
    else Some
        (mk_order_continuation @@ List.hd (List.rev orders)) in
  Lwt.return_ok
    { orders_pagination_orders = orders ; orders_pagination_contination }

(* SELL ORDERS -> make asset = nft *)
let get_sell_orders_by_maker ?dbh ?origin ?continuation ?(size=50) maker =
  Format.eprintf "get_sell_orders_by_maker %s %s %s %d@."
    maker
    (match origin with None -> "None" | Some s -> s)
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size ;
  use dbh @@ fun dbh ->
  let size64 = Int64.of_int size in
  let no_origin, origin_v = origin = None, (match origin with None -> "" | Some o -> o) in
  let no_continuation, (ts, h) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  let>? l = [%pgsql.object dbh
      "select maker, taker, \
       make_asset_type_class, make_asset_type_contract, make_asset_type_token_id, \
       make_asset_value, \
       take_asset_type_class, take_asset_type_contract, take_asset_type_token_id, \
       take_asset_value, \
       fill, start_date, end_date, make_stock, cancelled, salt, \
       signature, created_at, last_update_at, hash, \
       make_balance, make_price_usd, take_price_usd \
       from orders where \
       (make_asset_type_class = 'FA_2') and \
       maker = $maker and make_stock > 0 and \
       ($no_origin or (hash in (select hash from origin_fees where account = $origin_v))) and \
       ($no_continuation or (last_update_at = $ts and hash > $h) or (last_update_at < $ts)) \
       order by last_update_at desc, hash asc limit $size64"] in
  map_rp (fun r -> mk_order r) l >>=? fun orders ->
  let len = List.length orders in
  let orders_pagination_contination =
    if len <> size then None
    else Some
        (mk_order_continuation @@ List.hd (List.rev orders)) in
  Lwt.return_ok
    { orders_pagination_orders = orders ; orders_pagination_contination }

let get_sell_orders_by_item ?dbh ?origin ?continuation ?(size=50) ?maker contract token_id =
  Format.eprintf "get_sell_orders_by_maker %s %s %s %d@."
    (match maker with None -> "None" | Some s -> s)
    (match origin with None -> "None" | Some s -> s)
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size ;
  use dbh @@ fun dbh ->
  let size64 = Int64.of_int size in
  let no_maker, maker_v = maker = None, (match maker with None -> "" | Some m -> m) in
  let no_origin, origin_v = origin = None, (match origin with None -> "" | Some o -> o) in
  let no_continuation, (ts, h) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  let>? l = [%pgsql.object dbh
      "select maker, taker, \
       make_asset_type_class, make_asset_type_contract, make_asset_type_token_id, \
       make_asset_value, \
       take_asset_type_class, take_asset_type_contract, take_asset_type_token_id, \
       take_asset_value, \
       fill, start_date, end_date, make_stock, cancelled, salt, \
       signature, created_at, last_update_at, hash, make_balance, \
       make_price_usd, take_price_usd \
       from orders where \
       make_asset_type_contract = $contract and make_stock > 0 and \
       make_asset_type_token_id = $token_id and \
       ($no_maker or (maker = $maker_v)) and \
       ($no_origin or (hash in (select hash from origin_fees where account = $origin_v))) and \
       ($no_continuation or ((last_update_at = $ts and hash > $h) or (last_update_at < $ts))) \
       order by last_update_at desc, hash asc limit $size64"]
  in
  map_rp (fun r -> mk_order r) l >>=? fun orders ->
  let len = List.length orders in
  let orders_pagination_contination =
    if len <> size then None
    else Some
        (mk_order_continuation @@ List.hd (List.rev orders)) in
  Lwt.return_ok
    { orders_pagination_orders = orders ; orders_pagination_contination }

let get_sell_orders_by_collection ?dbh ?origin ?continuation ?(size=50) collection =
  Format.eprintf "get_sell_orders_by_collection %s %s %s %d@."
    collection
    (match origin with None -> "None" | Some s -> s)
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size ;
  use dbh @@ fun dbh ->
  let size64 = Int64.of_int size in
  let no_origin, origin_v = origin = None, (match origin with None -> "" | Some o -> o) in
  let no_continuation, (ts, h) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  let>? l = [%pgsql.object dbh
      "select maker, taker, \
       make_asset_type_class, make_asset_type_contract, make_asset_type_token_id, \
       make_asset_value, \
       take_asset_type_class, take_asset_type_contract, take_asset_type_token_id, \
       take_asset_value, \
       fill, start_date, end_date, make_stock, cancelled, salt, \
       signature, created_at, last_update_at, hash, make_balance, \
       make_price_usd, take_price_usd \
       from orders where \
       make_asset_type_contract = $collection and make_stock > 0 and \
       ($no_origin or (hash in (select hash from origin_fees where account = $origin_v))) and \
       ($no_continuation or ((last_update_at = $ts and hash > $h) or (last_update_at < $ts))) \
       order by last_update_at desc, hash asc limit $size64"]
  in
  map_rp (fun r -> mk_order r) l >>=? fun orders ->
  let len = List.length orders in
  let orders_pagination_contination =
    if len <> size then None
    else Some
        (mk_order_continuation @@ List.hd (List.rev orders)) in
  Lwt.return_ok
    { orders_pagination_orders = orders ; orders_pagination_contination }

let get_sell_orders ?dbh ?origin ?continuation ?(size=50) () =
  Format.eprintf "get_sell_orders %s %s %d@."
    (match origin with None -> "None" | Some s -> s)
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size ;
  use dbh @@ fun dbh ->
  let size64 = Int64.of_int size in
  let no_origin, origin_v = origin = None, (match origin with None -> "" | Some o -> o) in
  let no_continuation, (ts, h) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  let>? l = [%pgsql.object dbh
      "select maker, taker, \
       make_asset_type_class, make_asset_type_contract, make_asset_type_token_id, \
       make_asset_value, \
       take_asset_type_class, take_asset_type_contract, take_asset_type_token_id, \
       take_asset_value, \
       fill, start_date, end_date, make_stock, cancelled, salt, \
       signature, created_at, last_update_at, hash, make_balance, \
       make_price_usd, take_price_usd \
       from orders where \
       make_stock > 0 and \
       ($no_origin or (hash in (select hash from origin_fees where account = $origin_v))) and \
       ($no_continuation or ((last_update_at = $ts and hash > $h) or (last_update_at < $ts))) \
       order by last_update_at desc, hash asc limit $size64"]
  in
  map_rp (fun r -> mk_order r) l >>=? fun orders ->
  let len = List.length orders in
  let orders_pagination_contination =
    if len <> size then None
    else Some
        (mk_order_continuation @@ List.hd (List.rev orders)) in
  Lwt.return_ok
    { orders_pagination_orders = orders ; orders_pagination_contination }

(* BID ORDERS -> take asset = nft *)
let get_bid_orders_by_maker ?dbh ?origin ?continuation ?(size=50) maker =
  Format.eprintf "get_sell_orders_by_maker %s %s %s %d@."
    maker
    (match origin with None -> "None" | Some s -> s)
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size ;
  use dbh @@ fun dbh ->
  let size64 = Int64.of_int size in
  let no_origin, origin_v = origin = None, (match origin with None -> "" | Some o -> o) in
  let no_continuation, (ts, h) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  let>? l = [%pgsql.object dbh
      "select maker, taker, \
       make_asset_type_class, make_asset_type_contract, make_asset_type_token_id, \
       make_asset_value, \
       take_asset_type_class, take_asset_type_contract, take_asset_type_token_id, \
       take_asset_value, \
       fill, start_date, end_date, make_stock, cancelled, salt, \
       signature, created_at, last_update_at, hash, \
       make_balance, make_price_usd, take_price_usd \
       from orders where \
       (take_asset_type_class = 'FA_2') and \
       maker = $maker and make_stock > 0 and \
       ($no_origin or (hash in (select hash from origin_fees where account = $origin_v))) and \
       ($no_continuation or (last_update_at = $ts and hash > $h) or (last_update_at < $ts)) \
       order by last_update_at desc, hash asc limit $size64"] in
  map_rp (fun r -> mk_order r) l >>=? fun orders ->
  let len = List.length orders in
  let orders_pagination_contination =
    if len <> size then None
    else Some
        (mk_order_continuation @@ List.hd (List.rev orders)) in
  Lwt.return_ok
    { orders_pagination_orders = orders ; orders_pagination_contination }

let get_bid_orders_by_item ?dbh ?origin ?continuation ?(size=50) ?maker contract token_id =
  Format.eprintf "get_sell_orders_by_maker %s %s %s %d@."
    (match maker with None -> "None" | Some s -> s)
    (match origin with None -> "None" | Some s -> s)
    (match continuation with
     | None -> "None"
     | Some (ts, s) -> (Tzfunc.Proto.A.cal_to_str ts) ^ "_" ^ s)
    size ;
  use dbh @@ fun dbh ->
  let size64 = Int64.of_int size in
  let no_maker, maker_v = maker = None, (match maker with None -> "" | Some m -> m) in
  let no_origin, origin_v = origin = None, (match origin with None -> "" | Some o -> o) in
  let no_continuation, (ts, h) =
    continuation = None,
    (match continuation with None -> CalendarLib.Calendar.now (), "" | Some (ts, h) -> (ts, h)) in
  let>? l = [%pgsql.object dbh
      "select maker, taker, \
       make_asset_type_class, make_asset_type_contract, make_asset_type_token_id, \
       make_asset_value, \
       take_asset_type_class, take_asset_type_contract, take_asset_type_token_id, \
       take_asset_value, \
       fill, start_date, end_date, make_stock, cancelled, salt, \
       signature, created_at, last_update_at, hash, make_balance, \
       make_price_usd, take_price_usd \
       from orders where \
       take_asset_type_contract = $contract and make_stock > 0 and \
       take_asset_type_token_id = $token_id and \
       ($no_maker or (maker = $maker_v)) and \
       ($no_origin or (hash in (select hash from origin_fees where account = $origin_v))) and \
       ($no_continuation or ((last_update_at = $ts and hash > $h) or (last_update_at < $ts))) \
       order by last_update_at desc, hash asc limit $size64"]
  in
  map_rp (fun r -> mk_order r) l >>=? fun orders ->
  let len = List.length orders in
  let orders_pagination_contination =
    if len <> size then None
    else Some
        (mk_order_continuation @@ List.hd (List.rev orders)) in
  Lwt.return_ok
    { orders_pagination_orders = orders ; orders_pagination_contination }

let insert_pendings dbh pendings hash_key =
  iter_rp (fun pending ->
      let>? (ptype, make_class, make_contract, make_token_id, make_asset_value,
             take_class, take_contract, take_token_id, take_asset_value,
             date, maker, side, fill, taker, counter_hash, make_usd, take_usd,
             make_price_usd, taker_price_usd) = match pending with
        | OrderCancel elt ->
          let>? make_class, make_contract, make_token_id, make_asset_value =
            match elt.order_exchange_history_elt_make with
            | None -> Lwt.return_ok (None, None, None, None)
            | Some asset ->
              let|>? make_class, make_contract, make_token_id, make_asset_value =
                db_from_asset asset in
              (Some make_class, make_contract, make_token_id, Some make_asset_value)
          in
          let|>? take_class, take_contract, take_token_id, take_asset_value =
            match elt.order_exchange_history_elt_take with
            | None -> Lwt.return_ok (None, None, None, None)
            | Some asset ->
              let|>? take_class, take_contract, take_token_id, take_asset_value =
                db_from_asset asset in
              (Some take_class, take_contract, take_token_id, Some take_asset_value)
          in
          "CANCEL", make_class, make_contract, make_token_id, make_asset_value,
          take_class, take_contract, take_token_id, take_asset_value,
          elt.order_exchange_history_elt_date, elt.order_exchange_history_elt_maker,
          None, None, None, None, None, None, None, None
        | OrderSideMatch side_match ->
          let elt = side_match.order_side_match_elt in
          let>? make_class, make_contract, make_token_id, make_asset_value =
            match elt.order_exchange_history_elt_make with
            | None -> Lwt.return_ok (None, None, None, None)
            | Some asset ->
              let|>? make_class, make_contract, make_token_id, make_asset_value =
                db_from_asset asset in
              (Some make_class, make_contract, make_token_id, Some make_asset_value)
          in
          let|>? take_class, take_contract, take_token_id, take_asset_value =
            match elt.order_exchange_history_elt_take with
            | None -> Lwt.return_ok (None, None, None, None)
            | Some asset ->
              let|>? take_class, take_contract, take_token_id, take_asset_value =
                db_from_asset asset in
              (Some take_class, take_contract, take_token_id, Some take_asset_value)
          in
          "ORDER_SIDE_MATCH", make_class, make_contract, make_token_id, make_asset_value,
          take_class, take_contract, take_token_id, take_asset_value,
          elt.order_exchange_history_elt_date, elt.order_exchange_history_elt_maker,
          string_opt_of_order_side_opt side_match.order_side_match_side,
          Some (Int64.of_string side_match.order_side_match_fill),
          side_match.order_side_match_taker,
          side_match.order_side_match_counter_hash,
          float_opt_of_string_opt side_match.order_side_match_make_usd,
          float_opt_of_string_opt side_match.order_side_match_take_usd,
          float_opt_of_string_opt side_match.order_side_match_make_price_usd,
          float_opt_of_string_opt side_match.order_side_match_take_price_usd
      in
      [%pgsql dbh
          "insert into order_pending(\
           type, make_asset_type_class, make_asset_type_contract, \
           make_asset_type_token_id, make_asset_value, \
           take_asset_type_class, take_asset_type_contract, \
           take_asset_type_token_id, take_asset_value, \
           date, maker, side, fill, taker, counter_hash, make_usd, take_usd, \
           make_price_usd, take_price_usd, hash) values(\
           $ptype, $?make_class, $?make_contract, $?make_token_id, $?make_asset_value, \
           $?take_class, $?take_contract, $?take_token_id, $?take_asset_value, \
           $date, $?maker, $?side, $?fill, $?taker, $?counter_hash, $?make_usd, $?take_usd, \
           $?make_price_usd, $?taker_price_usd, $hash_key)"]
    ) pendings

let insert_price_history dbh date make_value take_value hash_key =
  [%pgsql dbh
      "insert into order_price_history (date, make_value, take_value, hash) \
       values ($date, $make_value, $take_value, $hash_key)"]

let insert_origin_fees dbh fees hash_key =
  iter_rp (fun part ->
      let account = part.part_account in
      let value = Int32.of_int part.part_value in
      [%pgsql dbh
          "insert into origin_fees (account, value, hash) \
           values ($account, $value, $hash_key)"])
    fees

let insert_payouts dbh p hash_key =
  iter_rp (fun part ->
      let account = part.part_account in
      let value = Int32.of_int part.part_value in
      [%pgsql dbh
          "insert into payouts (account, value, hash) \
           values ($account, $value, $hash_key)"])
    p

let upsert_order ?dbh order =
  let order_elt = order.order_elt in
  let order_data = order.order_data in
  let maker = order_elt.order_elt_maker in
  let taker = order_elt.order_elt_taker in
  let>? make_class, make_contract, make_token_id, make_asset_value =
    db_from_asset order_elt.order_elt_make in
  let>? take_class, take_contract, take_token_id, take_asset_value =
    db_from_asset order_elt.order_elt_take in
  let fill = Int64.of_string order_elt.order_elt_fill in
  let start_date = order_elt.order_elt_start in
  let end_date = order_elt.order_elt_end in
  let make_stock = Int64.of_string order_elt.order_elt_make_stock in
  let cancelled = order_elt.order_elt_cancelled in
  let salt = order_elt.order_elt_salt in
  let signature = order_elt.order_elt_signature in
  let created_at = order_elt.order_elt_created_at in
  let last_update_at = order_elt.order_elt_last_update_at in
  let payouts = match order_data with
    | RaribleV2Order data -> data.order_rarible_v2_data_v1_payouts
    | _ -> assert false in
  let origin_fees = match order_data with
    | RaribleV2Order data -> data.order_rarible_v2_data_v1_origin_fees
    | _ -> assert false in
  let make_balance = int64_opt_of_string_opt order_elt.order_elt_make_balance in
  let make_price_usd = float_opt_of_string_opt order_elt.order_elt_make_price_usd in
  let take_price_usd = float_opt_of_string_opt order_elt.order_elt_take_price_usd in
  let hash_key = order_elt.order_elt_hash in
  use dbh @@ fun dbh ->
  let>? () = [%pgsql dbh
      "insert into orders(maker, taker, \
       make_asset_type_class, make_asset_type_contract, make_asset_type_token_id, \
       make_asset_value, \
       take_asset_type_class, take_asset_type_contract, take_asset_type_token_id, \
       take_asset_value, \
       fill, start_date, end_date, make_stock, cancelled, salt, \
       signature, created_at, last_update_at, hash, \
       make_balance, make_price_usd, take_price_usd) \
       values($maker, $?taker, \
       $make_class, $?make_contract, $?make_token_id, $make_asset_value, \
       $take_class, $?take_contract, $?take_token_id, $take_asset_value, \
       $fill, $?start_date, $?end_date, $make_stock, \
       $cancelled, $salt, $signature, $created_at, $last_update_at, \
       $hash_key, $?make_balance, $?make_price_usd, $?take_price_usd) \
       on conflict (hash) do update set (\
       make_asset_value, take_asset_value, make_stock, signature, last_update_at) = \
       ($make_asset_value, $take_asset_value, $make_stock, $signature, $last_update_at)"] in
  begin match order_elt.order_elt_pending with
    | None -> Lwt.return_ok ()
    | Some pendings -> insert_pendings dbh pendings hash_key
  end >>=? fun () ->
  insert_price_history dbh last_update_at make_asset_value take_asset_value hash_key >>=? fun () ->
  begin
    if last_update_at = created_at then insert_origin_fees dbh origin_fees hash_key
    else Lwt.return_ok ()
  end >>=? fun () ->
  insert_payouts dbh payouts hash_key
