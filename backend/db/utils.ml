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

let is_op_included ?dbh hash =
  use dbh @@ fun dbh ->
  let>? t =
    [%pgsql.object dbh "select hash from transactions where hash = $hash and main"] in
  let>? o =
    [%pgsql.object dbh "select hash from originations where hash = $hash and main"] in
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

let set_crawled ?dbh contract =
  use dbh @@ fun dbh ->
  [%pgsql dbh "update ft_contracts set crawled = true where address = $contract"]

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

let unknown_token_metadata ?dbh ?contract () =
  let no_contract = Option.is_none contract in
  use dbh @@ fun dbh ->
  [%pgsql.object dbh
      "select i.contract, i.token_id, i.block, i.level, i.tsp, metadata, \
       metadata_uri, null as token_metadata_id \
       from token_info i left join tzip21_metadata t on \
       i.token_id = t.token_id and i.contract = t.contract where \
       i.main and t.contract is null and ($no_contract or i.contract = $?contract)"]

let contract_token_metadata ?dbh contract =
  use dbh @@ fun dbh ->
  [%pgsql.object dbh
      "select contract, token_id, i.block, i.level, i.tsp, i.metadata, \
       metadata_uri, token_metadata_id \
       from token_info i inner join contracts c on c.address = i.contract \
       where i.main and contract = $contract"]

let update_metadata ?(set_metadata=false)
    ?metadata_uri ?dbh ~metadata ~contract ~token_id ~block ~level ~tsp () =
  let update_royalties dbh r =
    let shares = Metadata.to_4_decimals r in
    let royalties = EzEncoding.construct parts_enc shares in
    [%pgsql dbh
        "update token_info set royalties_metadata = $royalties \
         where contract = $contract and token_id = $token_id"] in
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
  match metadata_uri with
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
          | Some r -> update_royalties dbh r in
        Format.eprintf "  OK@." ;
        Lwt.return_ok ()
      with _ ->
        Format.eprintf "  can't find uri or metadata in %s@." metadata ;
        Lwt.return_ok ()
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
          | Some r -> update_royalties dbh r in
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

let find_hash ?dbh h =
  let h = h ^ "%s" in
  use dbh @@ fun dbh ->
  match String.get h 0 with
  | 'B' -> [%pgsql dbh "select hash from predecessors where hash like $h"]
  | 'o' -> [%pgsql dbh "select transaction from token_balance_updates where transaction like $h"]
  | 't' | 'K' ->
    [%pgsql dbh "select contract from token_balance_updates where contract like $h"]
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
