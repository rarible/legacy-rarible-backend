open Let
open Rtypes
open Misc

let get_level ?dbh () =
  use dbh @@ fun dbh ->
  let>? res =
    [%pgsql dbh
        "select max(level) FROM blocks"] in
  let>? res = one res in
  match res with
  | Some level -> Lwt.return_ok @@ Int32.to_int level
  | None -> Lwt.return_error (`hook_error "no level")

let is_transaction_included ?dbh hash =
  use dbh @@ fun dbh ->
  let>? t =
    [%pgsql dbh "select transaction from contract_updates where transaction = $hash and main"] in
  let>? o =
    [%pgsql dbh "select transaction from token_updates where transaction = $hash and main"] in
  Lwt.return_ok (o <> [] || t <> [])

let is_collection_crawled ?dbh hash =
  use dbh @@ fun dbh ->
  let>? o =
    [%pgsql.object dbh "select address from contracts where address = $hash and main"] in
  Lwt.return_ok (o <> [])

let set_main_recrawl ?dbh hash =
  use dbh @@ fun dbh ->
  [%pgsql dbh
      "update token_balance_updates set main = true where \
       block = $hash and (kind='ft' or kind='ft_multiple')"]

let get_ft_contract ?dbh contract =
  use dbh @@ fun dbh ->
  let>? l = [%pgsql.object dbh "select * from ft_contracts where address = $contract"] in
  one @@ List.map Config.db_ft_contract l

let get_unknown_bm_id ?dbh ?(kind=`token) () =
  use dbh @@ fun dbh ->
  match kind with
  | `token -> [%pgsql dbh "select address from contracts where token_metadata_id is null"]
  | `contract -> [%pgsql dbh "select address from contracts where metadata_id is null"]
  | `royalties -> [%pgsql dbh "select address from contracts where royalties_id is null"]

let set_bm_id ?dbh ?(kind=`token) ~contract id =
  use dbh @@ fun dbh ->
  match kind with
  | `token ->
    [%pgsql dbh "update contracts set token_metadata_id = ${Z.to_string id} where address = $contract"]
  | `contract ->
    [%pgsql dbh "update contracts set metadata_id = ${Z.to_string id} where address = $contract"]
  | `royalties ->
    [%pgsql dbh "update contracts set royalties_id = ${Z.to_string id} where address = $contract"]

let update_royalties dbh ~contract ~token_id r =
  let token_id = Z.to_string token_id in
  let shares = Metadata.to_4_decimals r in
  let royalties = EzEncoding.construct parts_enc shares in
  [%pgsql dbh
      "update token_info set royalties_metadata = $royalties \
       where contract = $contract and token_id = $token_id"]

let fetch_metadata_from_source ?(verbose=0) ~timeout ~source l =
  let cpt = ref 0 in
  let err = ref 0 in
  let empty = ref 0 in
  let oks = ref 0 in
  let len = List.length l in
  if verbose > 0 then
    Format.eprintf "fetching metadata for %d item(s) from %s @." (List.length l) source ;
  use None @@ fun dbh ->
  iter_rp (fun r ->
      if !cpt <> 0 then
        Format.eprintf "[%d / %d | \027[0;91mErr %d\027[0m | \
                        \027[0;93mEmpty %d\027[0m | \027[0;92mOk %d\027[0m] %s@."
          !cpt len !err !empty !oks source;
      incr cpt ;
      if verbose > 0 then
        Format.eprintf "%s %s %s@." source r#contract r#token_id;
      let metadata_uri = match r#metadata_uri with
        | None ->
          let l = EzEncoding.destruct Json_encoding.(assoc string) r#metadata in
          begin match List.assoc_opt "" l with
            | None -> None
            | Some uri -> Some uri
          end
        | Some uri -> Some uri in
      match metadata_uri with
      | None ->
        if verbose > 0 then
          Format.eprintf "  can't find uri for metadata, try to decode@." ;
        begin try
            if r#metadata <> "{}" then
              let metadata = EzEncoding.destruct tzip21_token_metadata_enc r#metadata in
              let block, level, tsp, contract, token_id =
                r#block, r#level, r#tsp, r#contract, Z.of_string r#token_id in
              let>? () =
                Metadata.insert_mint_metadata dbh ~forward:true ~contract ~token_id ~block ~level ~tsp metadata in
              let>? () =
                match metadata.tzip21_tm_royalties with
                | None -> Lwt.return_ok ()
                | Some r -> update_royalties dbh ~contract ~token_id r in
              if verbose > 0 then Format.eprintf "  OK@." ;
              incr oks ;
              Lwt.return_ok ()
            else
              begin
                if verbose > 0 then Format.eprintf "  empty metadata@." ;
                incr empty ;
                Lwt.return_ok ()
              end
          with _ ->
            if verbose > 0 then Format.eprintf "  can't decode metadata in %s@." r#metadata ;
            incr err ;
            Lwt.return_ok ()
        end
      | Some uri ->
        if uri <> "" then
          let> re = Metadata.get_json ~quiet:true ~source ~timeout uri in
          match re with
          | Ok (_json, metadata, _uri) ->
            let block, level, tsp, contract, token_id =
              r#block, r#level, r#tsp, r#contract, Z.of_string r#token_id in
            let>? () = Metadata.insert_mint_metadata dbh ~forward:true ~contract ~token_id ~block ~level ~tsp metadata in
            let>? () =
              match metadata.tzip21_tm_royalties with
              | None -> Lwt.return_ok ()
              | Some r -> update_royalties dbh ~contract ~token_id r in
            if verbose > 0 then Format.eprintf "  OK@." ;
            incr oks ;
            Lwt.return_ok ()
          | Error (code, str) ->
            incr err ;
            (if verbose > 0 then Format.eprintf "  fetch metadata error %d:%s@." code @@
               Option.value ~default:"None" str);
            if code = 429 then
              (* TOO MANY REQUESTS *)
              Lwt_unix.sleep 30. >>= fun () ->
              Lwt.return_ok ()
            else
              Lwt.return_ok ()
        else
          begin
            if verbose > 0 then Format.eprintf "  can't find uri for metadata %s@." r#metadata ;
            incr err ;
            Lwt.return_ok ()
          end)
    l

let empty_token_metadata ?dbh ?contract () =
  let no_contract = Option.is_none contract in
  use dbh @@ fun dbh ->
  [%pgsql.object dbh
      "select contract, token_id, t.block, t.level, t.tsp, t.metadata, \
       t.metadata_uri, c.token_metadata_id from token_info t \
       inner join contracts c on t.contract = c.address \
       where t.main and metadata_uri is null and t.metadata = '{}' \
       and ($no_contract or contract = $?contract) and token_metadata_id is not null"]

let decimals_0_token_metadata ?dbh () =
  use dbh @@ fun dbh ->
  [%pgsql.object dbh
      "select distinct contract, token_id, tmp.block, tmp.level, tmp.tsp, tmp.metadata, \
       tmp.metadata_uri, null as token_metadata_id from \
       (select contract, token_id, block, level, tsp, \
       metadata, metadata_uri, r::jsonb->'value' as v from token_info t, \
       jsonb_array_elements_text(royalties_metadata) r) as tmp where tmp.v::int = 0"]

let unknown_token_metadata ?dbh ?contract ?levels () =
  let no_contract = Option.is_none contract in
  use dbh @@ fun dbh ->
  match levels with
  | None ->
    [%pgsql.object dbh
        "select i.contract, i.token_id, i.block, i.level, i.tsp, metadata, \
         metadata_uri, null as token_metadata_id \
         from token_info i left join tzip21_metadata t on i.id = t.id \
         where i.main and t.contract is null and ($no_contract or i.contract = $?contract)"]
  | Some levels ->
    let levels = Int32.of_int levels in
    let>? _, level = Pg.head (Some dbh) in
    [%pgsql.object dbh
        "select i.contract, i.token_id, i.block, i.level, i.tsp, metadata, \
         metadata_uri, null as token_metadata_id \
         from token_info i left join tzip21_metadata t on i.id = t.id \
         where i.main and t.contract is null and ($no_contract or i.contract = $?contract) \
         and i.level > $level::int - $levels::int"]


let contract_token_metadata ?dbh ?(royalties=false) contract =
  use dbh @@ fun dbh ->
  [%pgsql.object dbh
      "select contract, token_id, i.block, i.level, i.tsp, i.metadata, \
       metadata_uri, token_metadata_id \
       from token_info i inner join contracts c on c.address = i.contract \
       where i.main and contract = $contract and \
       (not $royalties or \
       (royalties_metadata is null or royalties_metadata = '[]' or royalties_metadata = '{}'))"]

let no_royalties_token_metadata ?dbh () =
  use dbh @@ fun dbh ->
  [%pgsql.object dbh
      "select contract, token_id, block, level, tsp, metadata, \
       metadata_uri, null as token_metadata_id \
       from token_info i \
       where main and metadata <> '{}' and \
       royalties_metadata is null and royalties = '{}'"]

let contract_metadata ?dbh ?(retrieve=false) () =
  use dbh @@ fun dbh ->
  [%pgsql.object dbh
      "select address, c.block, c.level, c.tsp, c.metadata, c.metadata_id \
       from contracts c left join tzip16_metadata m on c.address = m.contract \
       where c.main and \
       (metadata <> '{}' or $retrieve) and (m.contract is null or $retrieve)"]

let contract_metadata_no_name ?dbh () =
  use dbh @@ fun dbh ->
  [%pgsql.object dbh
      "select address, c.block, c.level, c.tsp, c.metadata, c.metadata_id \
       from contracts c left join tzip16_metadata m on c.address = m.contract \
       where c.main and m.contract is null"]

let update_metadata ?(set_metadata=false)
    ?metadata_uri ?dbh ~metadata ~contract ~token_id ~block ~level ~tsp () =
  Format.eprintf "%s[%s]@." contract token_id;
  if set_metadata then
    use dbh @@ fun dbh ->
    [%pgsql dbh "update token_info set metadata = $metadata \
                 where contract = $contract and token_id = ${token_id}"]
  else
    let metadata_uri = match metadata_uri with
      | None ->
        let l = EzEncoding.destruct Json_encoding.(assoc string) metadata in
        List.assoc_opt "" l
      | Some uri -> Some uri in
    let>? success = match metadata_uri with
      | None ->
        Format.eprintf "  can't find uri for metadata, try to decode@." ;
        begin try
            let metadata_tzip = EzEncoding.destruct tzip21_token_metadata_enc metadata in
            let token_id = Z.of_string token_id in
            use dbh @@ fun dbh ->
            let>? () =
              Metadata.insert_mint_metadata dbh ~forward:true ~contract ~token_id ~block ~level ~tsp metadata_tzip in
            let>? () =
              match metadata_tzip.tzip21_tm_royalties with
              | None -> Lwt.return_ok ()
              | Some r -> update_royalties dbh ~contract ~token_id r in
            Format.eprintf "  OK@." ;
            Lwt.return_ok true
          with _ ->
            Format.eprintf "  can't find uri or metadata in %s@." metadata ;
            Lwt.return_ok false
        end
      | Some uri ->
        if uri <> "" then
          let> re = Metadata.get_json ~quiet:true uri in
          match re with
          | Ok (_json, metadata_tzip, _uri) ->
            let token_id = Z.of_string token_id in
            use dbh @@ fun dbh ->
            let>? () =
              Metadata.insert_mint_metadata dbh ~forward:true ~contract ~token_id ~block ~level ~tsp metadata_tzip in
            let>? () =
              match metadata_tzip.tzip21_tm_royalties with
              | None -> Lwt.return_ok ()
              | Some r -> update_royalties dbh ~contract ~token_id r in
            Format.eprintf "  OK@." ;
            Lwt.return_ok true
          | Error (code, str) ->
            (Format.eprintf "  fetch metadata error %d:%s@." code @@
             Option.value ~default:"None" str);
            Lwt.return_ok false
        else
          begin
            Format.eprintf "  can't find uri for metadata %s@." metadata ;
            Lwt.return_ok false
          end in
    if success then
      use None @@ fun dbh -> Produce.nft_item_event dbh contract (Z.of_string token_id) ()
    else Lwt.return_ok ()

let update_supply ?dbh () =
  use dbh @@ fun dbh ->
  Format.eprintf "[update_supply] updating balances..@." ;
  let>? () =
    [%pgsql dbh
        "update tokens set amount = balance \
         where balance is not null and amount <> balance"] in
  Format.eprintf "[update_supply] updating supplies..@." ;
  [%pgsql dbh
      "with tmp(tid, supply) as (\
       select tid, sum(amount) from tokens group by tid) \
       update token_info i set supply = tmp.supply from tmp \
       where i.id = tmp.tid and i.supply <> tmp.supply"]

let random_tokens ?dbh ?contract ?token_id ?owner ?(number=100L) () =
  let no_contract, no_token_id, no_owner =
    Option.is_none contract, Option.is_none token_id, Option.is_none owner in
  use dbh @@ fun dbh ->
  [%pgsql.object dbh
      "select contract, token_id, t.owner, amount, balance, \
       ledger_id, ledger_key, ledger_value \
       from tokens t \
       inner join contracts on address = contract
       where ($no_contract or contract = $?contract) and \
       ($no_token_id or token_id = $?{Option.map Z.to_string token_id}) and \
       ($no_owner or t.owner = $?owner) and ledger_key is not null and \
       ledger_value is not null \
       order by random() limit $number"]

let find_hash ?dbh ?(collection=true) h =
  let h = h ^ "%s" in
  use dbh @@ fun dbh ->
  match String.get h 0, collection with
  | 'B', _ -> [%pgsql dbh "select hash from predecessors where hash like $h"]
  | 'o', _ -> [%pgsql dbh "select transaction from token_balance_updates where transaction like $h"]
  | 't', _ | 'K', false ->
    [%pgsql dbh "select contract from token_balance_updates where contract like $h"]
  | 'K', true ->
    [%pgsql dbh "select address from contracts where address like $h"]
  | _ -> Lwt.return_ok []

let hen_token_ids ?dbh ?(limit=10000L) ?(offset=0L) contract =
  use dbh @@ fun dbh ->
  [%pgsql dbh
      "select token_id from token_info where contract = $contract \
       offset $offset limit $limit"]

let hen_token_ids_count ?dbh contract =
  use dbh @@ fun dbh ->
  let|>? l = [%pgsql dbh "select count(token_id) from token_info where contract = $contract"] in
  match l with
  | [ Some n ] -> n
  | _ -> 0L

let update_hen_royalties ?dbh ~contract ~token_id ~account ~value () =
  let part_value =
    Z.to_int32 @@ Common.Utils.absolute_balance ~decimals:4l @@
    Common.Utils.decimal_balance ~decimals:(Int32.of_int 3) value in
  let royalties = EzEncoding.construct parts_enc [ {part_account=account; part_value} ] in
  use dbh @@ fun dbh ->
  [%pgsql dbh
      "update token_info set royalties = $royalties \
       where contract = $contract and token_id = ${Z.to_string token_id}"]

let clean_balance_updates ?level ?dbh () =
  let no_level = Option.is_none level in
  use dbh @@ fun dbh ->
  [%pgsql dbh
      "with t1(ablock, aindex, contract, token_id, account) as (\
       select array_agg(block order by level desc, index desc), \
       array_agg(index order by level desc, index desc), \
       contract, token_id, account from token_balance_updates \
       where ($no_level or level < $?level) \
       group by contract, token_id, account), \
       t2(block, index, contract, token_id, account) as (\
       select unnest(ablock[2:]), unnest(aindex[2:]), contract, token_id, account from t1) \
       delete from token_balance_updates t using t2 \
       where t2.contract = t.contract and t2.token_id = t.token_id and \
       t2.account = t.account and t2.block = t.block and t2.index = t.index"]

let expr key =
  let open Proto in
  match Forge.(pack (prim `string) (Mstring key)) with
  | Error _ -> None
  | Ok b ->
    Some Tzfunc.Crypto.(Base58.encode ~prefix:Prefix.script_expr_hash @@ Blake2b_32.hash [ b ])

let retrieve_contract_metadata ~source ~metadata_id key =
  let open Common in
  let open Proto in
  match expr key with
  | None -> Lwt.return None
  | Some hash ->
    let> r = Tzfunc.Node.(
        get_bigmap_value_raw ~base:(EzAPI.BASE source) metadata_id hash) in
    match r with
    | Error e ->
      Format.eprintf "Cannot retrieve metadata:\n%s@." (Tzfunc.Rp.string_of_error e);
      Lwt.return None
    | Ok None | Ok (Some (Bytes _)) | Ok (Some (Other _)) ->
      Format.eprintf "Wrong metadata format@.";
      Lwt.return None
    | Ok ((Some Micheline m)) ->
      match Typed_mich.parse_value Contract_spec.metadata_field.Rtypes.bmt_value m with
      | Ok (`bytes v) ->
        let s = (Tzfunc.Crypto.hex_to_raw v :> string) in
        if Parameters.decode s then Lwt.return @@ Some s
        else Lwt.return None
      | _ ->
        Format.eprintf "Wrong metadata type@.";
        Lwt.return None

let update_contract_metadata
    ?(set_metadata=false) ?metadata_uri ?dbh ~source ?metadata_id ~metadata ~contract ~block ~level ~tsp () =
  Format.eprintf "%s@." contract;
  if set_metadata then
    let metadata = match metadata_uri with
      | None -> metadata
      | Some value ->
        Ezjsonm.value_to_string @@
        Json_query.(replace [`Field ""] (`String value) (Ezjsonm.value_from_string metadata)) in
    use dbh @@ fun dbh ->
    [%pgsql dbh
        "update contracts set metadata = $metadata where address = $contract"]
  else
    match metadata_uri with
    | None ->
      Format.eprintf "  can't find uri for metadata, try to decode@." ;
      begin try
          let metadata_tzip = EzEncoding.destruct tzip16_metadata_enc metadata in
          use dbh @@ fun dbh ->
          let>? () =
            Metadata.insert_tzip16_metadata_data
              ~dbh ~forward:true ~contract ~block ~level ~tsp metadata_tzip in
          Format.eprintf "  OK@." ;
          Lwt.return_ok ()
        with _ ->
          Format.eprintf "  can't find uri or metadata in %s@." metadata ;
          Lwt.return_ok ()
      end
    | Some uri ->
      if uri <> "" then
        let storage = try String.sub uri 0 14 with _ -> "" in
        match storage with
        | "tezos-storage:" ->
          let key = String.sub uri 14 (String.length uri - 14) in
          let l = EzEncoding.destruct Json_encoding.(assoc string) metadata in
          begin match List.assoc_opt key l with
            | None ->
              let> v = match metadata_id with
                | None -> Lwt.return None
                | Some id ->
                  let id = Z.of_string id in
                  retrieve_contract_metadata ~source ~metadata_id:id key in
              begin match v with
                | None ->
                  Format.eprintf "  can't find tezos-storage for metadata %s@." key ;
                  Lwt.return_ok ()
                | Some v ->
                  try
                    let metadata_tzip = EzEncoding.destruct tzip16_metadata_enc v in
                    use dbh @@ fun dbh ->
                    let>? () =
                      Metadata.insert_tzip16_metadata_data
                        ~dbh ~forward:true ~contract ~block ~level ~tsp metadata_tzip in
                    Format.eprintf "  OK@." ;
                    Lwt.return_ok ()
                  with _ ->
                    Format.eprintf "  can't parse tzip16 metadata in %s@." v ;
                    Lwt.return_ok ()
              end
            | Some m ->
              try
                let metadata_tzip = EzEncoding.destruct tzip16_metadata_enc m in
                use dbh @@ fun dbh ->
                let>? () =
                  Metadata.insert_tzip16_metadata_data
                    ~dbh ~forward:true ~contract ~block ~level ~tsp metadata_tzip in
                Format.eprintf "  OK@." ;
                Lwt.return_ok ()
              with _ ->
                Format.eprintf "  can't parse tzip16 metadata in %s@." m ;
                Lwt.return_ok ()
          end
        | _ ->
          let> re = Metadata.get_contract_metadata ~quiet:true uri in
          match re with
          | Ok metadata_tzip ->
            use dbh @@ fun dbh ->
            let>? () =
              Metadata.insert_tzip16_metadata_data
                ~dbh ~forward:true ~contract ~block ~level ~tsp metadata_tzip in
            Format.eprintf "  OK@." ;
            Lwt.return_ok ()
          | Error (code, str) ->
            (Format.eprintf "  fetch metadata error %d:%s@." code @@
             Option.value ~default:"None" str);
            Lwt.return_ok ()
      else
        begin
          Format.eprintf "  can't find uri for metadata %s@." metadata ;
          Lwt.return_ok ()
        end

let update_contract_metadata_name ?dbh ~metadata ~contract ~block ~level ~tsp name =
  Format.eprintf "%s@." contract;
  let metadata =
    Ezjsonm.value_to_string @@
    Json_query.(replace [`Field ""] (`String name) (Ezjsonm.value_from_string metadata)) in
  use dbh @@ fun dbh ->
  let>? () =
    [%pgsql dbh
        "update contracts set metadata = $metadata where address = $contract"] in
  Metadata.insert_tzip16_metadata_name
    ~dbh ~forward:true ~contract ~block ~level ~tsp name

let update_contract_metadata_symbol ?dbh ~metadata ~contract symbol =
  Format.eprintf "%s@." contract;
  let metadata =
    Ezjsonm.value_to_string @@
    Json_query.(replace [`Field ""] (`String symbol) (Ezjsonm.value_from_string metadata)) in
  use dbh @@ fun dbh ->
  [%pgsql dbh
      "update contracts set metadata = $metadata where address = $contract"]

let collection_items ?dbh ?offset ?limit contract =
  use dbh @@ fun dbh ->
  match offset, limit with
  | Some offset, Some limit ->
    [%pgsql dbh
        "select token_id from token_info where contract = $contract and royalties = '{}' \
         order by token_id::numeric limit $limit offset $offset"]
  | _ ->
    [%pgsql dbh
        "select token_id from token_info where contract = $contract and royalties = '{}' \
         order by token_id::numeric"]

let collection_items_count ?dbh contract =
  use dbh @@ fun dbh ->
  let|>? l = [%pgsql dbh
      "select count(token_id) from token_info \
       where contract = $contract and royalties = '{}'"] in
  match l with
  | [ Some n ] -> n
  | _ -> 0L

let get_contracts ?dbh contracts =
  let contracts = List.map Option.some contracts in
  use dbh @@ fun dbh ->
  [%pgsql.object dbh
      "select address, ledger_id, ledger_key, ledger_value, metadata_id, \
       token_metadata_id, royalties_id, crawled \
       from contracts where main and address = any($contracts)"]

let tokens_without_creators ?dbh () =
  use dbh @@ fun dbh ->
  let|>? l = [%pgsql dbh
      "select contract, token_id from token_info where creators = '{}'"] in
  List.fold_left (fun acc (c, id) -> TIMap.add (c, Z.of_string id) false acc) TIMap.empty l

let update_token_info ?dbh ~contract ~token_id ~account ~block ~level ~tsp ~transaction () =
  let tid = Common.Utils.tid ~contract ~token_id in
  use dbh @@ fun dbh ->
  let>? l = [%pgsql dbh "select sum(balance) from tokens where tid = $tid"] in
  match l with
  | [ Some supply ] ->
    let creator = { part_account = account; part_value = 10000l } in
    let creators = [ Some (EzEncoding.construct Rtypes.part_enc creator) ] in
    let supply = Z.of_string supply in
    let>? () = [%pgsql dbh
        "insert into token_info(id, contract, token_id, transaction, block, \
         level, tsp, main, last_block, last_level, last, creators, supply) \
         values($tid, $contract, ${Z.to_string token_id}, $transaction, $block, \
         $level, $tsp, true, $block, $level, $tsp, $creators, $supply) \
         on conflict (id) do update set supply = $supply"] in
    Crawl.insert_creators ~dbh ~contract ~token_id ~forward:true ~block [ creator ]
  | _ -> Lwt.return_ok ()

let update_token ?dbh ~contract ~token_id ~account balance =
  let tid = Common.Utils.tid ~contract ~token_id in
  let oid = Common.Utils.oid ~contract ~token_id ~owner:account in
  use dbh @@ fun dbh ->
  [%pgsql dbh
      "insert into tokens(tid, oid, contract, token_id, owner, balance, amount) \
       values($tid, $oid, $contract, ${Z.to_string token_id}, \
       $account, $balance, $balance) on conflict (contract, token_id, owner) \
       do update set amount = $balance, balance = $balance"]

let get_alt_token_balance_updates ?dbh () =
  use dbh @@ fun dbh ->
  [%pgsql.object dbh
      "select contract, ledger_id, ledger_key, ledger_value, token_id, account, balance, \
       t.tsp, t.block, transaction, t.level \
       from token_balance_updates t \
       inner join contracts on contract = address where not t.main order by t.tsp"]

let clear_contract ?dbh contract =
  use dbh @@ fun dbh ->
  let>? () = [%pgsql dbh "delete from contracts where address = $contract"] in
  let>? () = [%pgsql dbh "delete from tokens where contract = $contract"] in
  let>? () = [%pgsql dbh "delete from token_info where contract = $contract"] in
  let>? () = [%pgsql dbh "delete from token_balance_updates where contract = $contract"] in
  let>? () = [%pgsql dbh "delete from token_updates where contract = $contract"] in
  let>? () = [%pgsql dbh "delete from contract_updates where contract = $contract"] in
  [%pgsql dbh "delete from creators where contract = $contract"]

let clear_contracts ?dbh contracts =
  let contracts2 = List.map Option.some contracts in
  use dbh @@ fun dbh ->
  Format.printf "clearing contracts@.";
  let>? () = [%pgsql dbh "delete from contracts where address = any($contracts2)"] in
  Format.printf "clearing tokens@.";
  let>? () = [%pgsql dbh "delete from tokens where contract = any($contracts2)"] in
  Format.printf "clearing token_info@.";
  let>? () = [%pgsql dbh "delete from token_info where contract = any($contracts2)"] in
  Format.printf "clearing contract_updates@.";
  let>? () = [%pgsql dbh "create index contract_updates_contract_index on contract_updates(contract)"] in
  let>? () = [%pgsql dbh "delete from contract_updates where contract = any($contracts2)"] in
  let>? () = [%pgsql dbh "drop index contract_updates_contract_index"] in
  Format.printf "clearing creators@.";
  let>? () = [%pgsql dbh "create index creators_contract_index on creators(contract)"] in
  let>? () = [%pgsql dbh "delete from creators where contract = any($contracts2)"] in
  let>? () = [%pgsql dbh "drop index creators_contract_index"] in
  let>? () = [%pgsql dbh "create index token_updates_contract_index on token_updates(contract)"] in
  let>? () = [%pgsql dbh "create index token_balance_updates_contract_index on token_balance_updates(contract)"] in
  Format.printf "clearing token_balance_updates %d@." @@ List.length contracts;
  let>? _ = fold_rp (fun i c ->
      Format.printf "%d %s\r@?" i c;
      let>? () = [%pgsql dbh "delete from token_updates where contract = $c"] in
      let|>? () = [%pgsql dbh "delete from token_balance_updates where contract = $c"] in
      i + 1) 0 contracts in
  let>? () = [%pgsql dbh "drop index token_updates_contract_index"] in
  let|>? () = [%pgsql dbh "drop index token_balance_updates_contract_index"] in
  ()
