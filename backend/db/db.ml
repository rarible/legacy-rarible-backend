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

let filter_contracts dbh ori =
  let|>? r = [%pgsql.object dbh "select admin_wallet, royalties_contract from state"] in
  match r with
  | [ r ] ->
    let open Utils in
    if match_entrypoints (fa2_entrypoints @ fa2_ext_entrypoints) ori.script.code then
      match match_fields [ "ledger"; "owner"; "royaltiesContract" ] ori.script with
      | Ok [ Some (Mint ledger_id); Some (Mstring owner); Some (Mstring royalties_contract) ] ->
        if r#admin_wallet = owner && r#royalties_contract = royalties_contract then
          Some (`nft (Z.to_int64 ledger_id))
        else None
      | _ -> None
    else None
  | _ -> None

let set_origination config dbh op ori =
  let>? r = filter_contracts dbh ori in
  match r with
  | None -> Lwt.return_ok ()
  | Some (`nft ledger_id) ->
    let kt1 = Tzfunc.Crypto.op_to_KT1 op.bo_hash in
    let|>? () = [%pgsql dbh
        "insert into contracts(kind, address, block, level, last, ledger_id) \
         values('nft', $kt1, ${op.bo_block}, ${op.bo_level}, ${op.bo_tsp}, $ledger_id) \
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
        Lwt.return_error (`hook_error ("no contract or tokenId for ERC721 asset"))
    end
  | "ETH" ->
    begin
      match contract, token_id with
      | None, None ->
        Lwt.return_ok { asset_type = ATETH ; asset_value }
      | _, _ ->
        Lwt.return_error (`hook_error ("contract or tokenId for ETH asset"))
    end
    (* Tezos assets*)
    (* | "XTZ"
     * | "FA1.2"
     * | "FA2" *)
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
  (* | "XTZ"
   * | "FA1.2"
   * | "FA2" *)
  | _ ->
    Lwt.return_error (`hook_error ("invalid asset"))

let get_order_pending ?dbh hash_key =
  use dbh @@ fun dbh ->
  let>? l =
    [%pgsql dbh
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
  let|>? l =
    [%pgsql dbh
        "select date, make_value, take_value \
         from order_price_history where hash = $hash_key"] in
  List.map
    (fun (date, make_value, take_value) -> {
         order_price_history_record_date = date ;
         order_price_history_record_make_value = Int64.to_string make_value ;
         order_price_history_record_take_value = Int64.to_string take_value ;
       }) l

let mk_order order_obj =
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
  get_order_pending order_obj#hash >>=? fun pending ->
  get_order_price_history order_obj#hash >>=? fun price_history ->
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
    order_elt_last_updated_at = order_obj#last_updated_at ;
    order_elt_pending = Some pending ;
    order_elt_hash = order_obj#hash ;
    order_elt_make_balance = string_opt_of_int64_opt order_obj#make_balance ;
    order_elt_make_price_usd = string_opt_of_float_opt order_obj#make_price_usd ;
    order_elt_take_price_usd = string_opt_of_float_opt order_obj#take_price_usd ;
    order_elt_price_history = price_history ;
  } in
  let data = RaribleV2Order {
    order_rarible_v2_data_v1_data_type = "RARIBLE_V2_DATA_V1" ;
    order_rarible_v2_data_v1_payouts =
      begin match order_obj#payouts with
        | None -> []
        | Some json -> (EzEncoding.destruct (Json_encoding.list part_enc) json)
      end ;
    order_rarible_v2_data_v1_origin_fees =
      match order_obj#origin_fees with
      | None -> []
      | Some json -> (EzEncoding.destruct (Json_encoding.list part_enc) json) ;
  } in
  let rarible_v2_order = {
    order_elt = order_elt ;
    order_data = data ;
  } in
  Lwt.return_ok rarible_v2_order

let get_order ?dbh hash_key =
  use dbh @@ fun dbh ->
  let>? l =
    [%pgsql.object dbh
        "select maker, taker, \
         make_asset_type_class, make_asset_type_contract, make_asset_type_token_id, \
         make_asset_value, \
         take_asset_type_class, take_asset_type_contract, take_asset_type_token_id, \
         take_asset_value, \
         fill, start_date, end_date, make_stock, cancelled, salt, \
         signature, created_at, last_updated_at, hash, payouts, origin_fees, \
         make_balance, make_price_usd, take_price_usd \
         from orders where hash = $hash_key"] in
  match l with
  | [] -> Lwt.return_ok None
  | _ ->
    one l >>=? fun r ->
    mk_order r >>=? fun order ->
    Lwt.return_ok @@ Some order

let insert_pendings ?dbh pendings hash_key =
  use dbh @@ fun dbh ->
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

let insert_price_history ?dbh price_history hash_key =
  use dbh @@ fun dbh ->
  iter_rp (fun ph ->
      let date = ph.order_price_history_record_date in
      let make_value = Int64.of_string ph.order_price_history_record_make_value in
      let take_value = Int64.of_string ph.order_price_history_record_take_value in
      [%pgsql dbh
          "insert into order_price_history (date, make_value, take_value, hash) \
           values ($date, $make_value, $take_value, $hash_key)"])
    price_history

let upsert_order ?dbh order hash_key =
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
  let last_updated_at = order_elt.order_elt_last_updated_at in
  let payouts = match order_data with
    | RaribleV2Order data ->
      EzEncoding.construct
        (Json_encoding.list part_enc)
        data.order_rarible_v2_data_v1_payouts
    | _ -> assert false in
  let origin_fees = match order_data with
    | RaribleV2Order data ->
      EzEncoding.construct
        (Json_encoding.list part_enc)
        data.order_rarible_v2_data_v1_origin_fees
    | _ -> assert false in
  let make_balance = int64_opt_of_string_opt order_elt.order_elt_make_balance in
  let make_price_usd = float_opt_of_string_opt order_elt.order_elt_make_price_usd in
  let take_price_usd = float_opt_of_string_opt order_elt.order_elt_take_price_usd in
  use dbh @@ fun dbh ->
  let>? () =
    [%pgsql dbh
        "insert into \
         orders(maker, taker, \
         make_asset_type_class, make_asset_type_contract, make_asset_type_token_id, \
         make_asset_value, \
         take_asset_type_class, take_asset_type_contract, take_asset_type_token_id, \
         take_asset_value, \
         fill, start_date, end_date, make_stock, cancelled, salt, \
         signature, created_at, last_updated_at, hash, payouts, origin_fees, \
         make_balance, make_price_usd, take_price_usd) \
         values($maker, $?taker, \
         $make_class, $?make_contract, $?make_token_id, $make_asset_value, \
         $take_class, $?take_contract, $?take_token_id, $take_asset_value, \
         $fill, $?start_date, $?end_date, $make_stock, \
         $cancelled, $salt, $signature, $created_at, $last_updated_at, \
         $hash_key, $payouts, $origin_fees, \
         $?make_balance, $?make_price_usd, $?take_price_usd) \
         on conflict (hash) do update set (\
         make_asset_value, take_asset_value, make_stock, signature, last_updated_at) = \
         ($make_asset_value, $take_asset_value, $make_stock, $signature, $last_updated_at)"] in
  begin match order_elt.order_elt_pending with
    | None -> Lwt.return_ok ()
    | Some pendings -> insert_pendings pendings hash_key
  end >>=? fun () ->
  insert_price_history order_elt.order_elt_price_history hash_key
