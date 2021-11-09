open Rtypes
open Let
open Common.Utils
open Script_types

let cwd = Sys.getcwd ()
let exe = Sys.argv.(0)

let api = ref "http://localhost:8080"
let sdk = ref false
let endpoint = ref "http://granada.tz.functori.com"

let royalties = "KT19cCmBCni8hRLX8zKd9uaxwQNwNRV98YY1"
let validator = "KT1JrWXMuHp7nkX7j3trtxckVBiTyggDNnU1"
let exchange_v2 = "KT1CfvTiEz9EVBLBLLYYFvRTwqyLsCvoZtWm"
let lugh_contract = "KT1HT3EbSPFA1MM2ZiMThB6P6Kky5jebNgAx"

let config = {
  admin_wallet = "" ;
  exchange_v2 ;
  validator ;
  royalties = "" ;
  contracts = SMap.empty;
  ft_contracts = SMap.empty;
}

let api_pid = ref None
let crawler_pid = ref None

let mk_account ~alias edsk =
  let open Tzfunc.Crypto in
  let pk = Sk.(to_public_key @@ Result.get_ok @@ b58dec edsk) in
  let pkh = Pk.hash pk in
  let edpk = Pk.b58enc ~curve:`ed25519 pk in
  let tz1 = Pkh.b58enc ~curve:`ed25519 pkh in
  { alias; edsk; edpk; tz1 }

(* ALIAS * EDPK * EDSK *)
let accounts = [
  mk_account ~alias:"rarible5" "edsk4XzV1K3Td1fVUhRv33iduTdNCxmHidUsCKRkvK2NgnersFdEUY" ;
  mk_account ~alias:"rarible4" "edsk3LVprL8yNHpVcbLrbaFm25njKkyjJrZEGCweuxqkCh7SiEyH4L" ;
  mk_account ~alias:"rarible3" "edsk49SC61Sb1QYRQQRW7M6SRmWMvjoaVsfCftkdoERv8BENe7ssV4" ;
  mk_account ~alias:"rarible2" "edsk35jq62PmRmRB5vH1rUE5W6wzE7P6sn3r58C3TKcDtnwx6MpFUU" ;
  mk_account ~alias:"rarible1" "edsk2kPLkNyYQi9kqQnh6VTip9MS7c6rEnUastw1BMb1hf9FgDfRBu";
]
let accounts_len = List.length accounts

let ft_contracts = [
  "KT1ENHtWh8umKktxT3wC3HbDjwopuuVmXJvD"
]
let ft_contracts_len = List.length ft_contracts

let nft_contracts = [
  "KT1BRQ73L3admx2NATrEHuPyy986g8wfgMqp" ;
  "KT1Ch6PstAQG32uNfQJUSL2bf2WvimvY5umk" ;
  "KT1McsKK4Y2GK369M9QQSzjux52EsSkfjcMJ" ;
]
let nft_contracts_len = List.length nft_contracts
let mt_contracts = []
let mt_contracts_len = List.length mt_contracts

let origins = [
  "tz1f6TuKe38VPURr6gA1xiQq9dzuVuzNZoP6" ;
  "tz1KiZygjrVaS1fjs9iW4YSKNiqoopHK8Hdj"
]
let origins_len = List.length origins

let royalties_contracts = [
  "KT1JPYtEMv8PHXfmLoMuWRLsVykoEou5AqKG"
]
let royalties_contracts_len = List.length royalties_contracts

let ipfs_metadatas = [
  "ipfs://Qma11k6ahPRXGVV7RgHNuLuwB9PqQB2MVJUtNNXJ7dQeAr";
  "ipfs://QmeaqRBUiw4cJiNKEcW2noc7egLd5GgBqLcHHqUhauJAHN";
  "ipfs://QmUKCfBnpN4CurChDS96wMcQ1akUJXiKtkZtHgHmieZUyL";
  "ipfs://QmTQdUJFn1yyRDcfZZVhUzbV8ucMEekihj42T7Pgua8SLe";
  "ipfs://QmbjcmWWzUFnD1CvPjvt5ZcrUD7SrYDyk9jnXeTuHQamsU";
  "ipfs://QmcAcT48iK6jgQpjTE8mhXeyM91xzPv5Sw3cRdDD3K7iTg";
]
let ipfs_metadatas_len = List.length ipfs_metadatas
let ipfs_metadatas_name = [
  "ipfs://Qma11k6ahPRXGVV7RgHNuLuwB9PqQB2MVJUtNNXJ7dQeAr", "hDAO";
  "ipfs://QmeaqRBUiw4cJiNKEcW2noc7egLd5GgBqLcHHqUhauJAHN", "dali tower";
  "ipfs://QmUKCfBnpN4CurChDS96wMcQ1akUJXiKtkZtHgHmieZUyL", "Non Fungible Taco";
  "ipfs://QmTQdUJFn1yyRDcfZZVhUzbV8ucMEekihj42T7Pgua8SLe", "jardim.2021-02-27-19.29.08";
  "ipfs://QmbjcmWWzUFnD1CvPjvt5ZcrUD7SrYDyk9jnXeTuHQamsU", "Russian Bath";
  "ipfs://QmcAcT48iK6jgQpjTE8mhXeyM91xzPv5Sw3cRdDD3K7iTg", "Bugsy Siegel";
]
let ipfs_metadatas_name_len = List.length ipfs_metadatas_name

let exchange_contracts = [
]
let exchange_contracts_len = List.length exchange_contracts

let validator_contracts = [
]
let validator_contracts_len = List.length exchange_contracts

let set_opt_string r = Arg.String (fun s -> r := Some s)
let set_opt_float r = Arg.Float (fun f -> r := Some f)
let set_opt_int r = Arg.Int (fun i -> r := Some i)

let arg_parse ~spec ~usage f =
  Arg.parse spec f usage

let js = ref false

let spec = [
  "--api", Arg.Set_string api, "api address (default: http://localhost:8080)";
  "--endpoint", Arg.Set_string endpoint, "node endpoint (default: http://granada.tz.functori.com)";
  "--client", Arg.Set_string Script.client, "tezos client" ;
  "--sdk", Arg.Set sdk, "use sdk to make tezos operations (default: false, uses tezos-client)";
  "--verbose", Arg.Set_int Script.verbose, "verbosity";
  "--js", Arg.Set js, "use js sdk";
]

let by_pk i =
  match List.find_opt (fun a -> a.edpk = i) accounts with
  | None -> failwith @@ Format.sprintf "Not_found by_pk %s\n%!" i
  | Some a -> a

let by_sk i =
  match List.find_opt (fun a -> a.edsk = i) accounts with
  | None -> failwith @@ Format.sprintf "Not_found by_sk %s\n%!" i
  | Some a -> a

let by_alias i =
  match List.find_opt (fun a -> a.alias = i) accounts with
  | None -> failwith @@ Format.sprintf "Not_found by_alias %s\n%!" i
  | Some a -> a

let rec sys_command ?(verbose=0) ?(retry=0) c =
  if verbose > 0 then Printf.eprintf "cmd: %s\n%!" c ;
  let oldstdout = Unix.dup Unix.stdout in
  let oldstderr = Unix.dup Unix.stderr in
  let temp_fn = Filename.temp_file "sys_command_" "" in
  let out_temp_fn = temp_fn ^ "_redirect_stdout" in
  let err_temp_fn = temp_fn ^ "_redirect_stderr" in
  let newstdout = open_out out_temp_fn in
  let newstderr = open_out err_temp_fn in
  Unix.dup2 (Unix.descr_of_out_channel newstdout) Unix.stdout;
  Unix.dup2 (Unix.descr_of_out_channel newstderr) Unix.stderr;
  let code = Sys.command c in
  flush newstdout ;
  flush newstderr ;
  Unix.dup2 oldstdout Unix.stdout ;
  Unix.dup2 oldstderr Unix.stderr ;
  close_out newstdout ;
  close_out newstderr ;
  if code <> 0 && retry > 0 then
    begin
    Printf.eprintf "Failure on Sys.command (%s)... retrying in 2sec\n%!" err_temp_fn ;
    Unix.sleep 2 ;
    sys_command ~verbose ~retry:(retry-1) c
  end
  else
    code, out_temp_fn, err_temp_fn

let pk_to_pkh_exn pk =
  Result.get_ok @@ Tzfunc.Crypto.pk_to_pkh pk

let generate_option f =
  if Random.bool () then Some (f ())
  else None

let generate_origin () =
  List.nth origins (Random.int origins_len)

let rec generate_address ?alias ?diff () =
  match alias with
  | Some a -> by_alias a
  | None ->
    match diff with
    | None -> List.nth accounts (Random.int accounts_len)
    | Some a ->
      let r = List.nth accounts (Random.int accounts_len) in
      if a = r.tz1 then generate_address ?diff ()
      else r

let generate_maker () =
  generate_address ()

let generate_taker () =
  generate_option generate_address

let tezos_asset () = {asset_type=ATXTZ; asset_value=Int64.to_string @@ Random.int64 10000000000L}

let generate_ft_asset () =
  let contract = List.nth ft_contracts (Random.int ft_contracts_len) in
  {asset_type=ATFT contract; asset_value=Int64.to_string @@ Random.int64 100L}

let generate_nft_asset () =
  let asset_contract = List.nth nft_contracts (Random.int nft_contracts_len) in
  let asset_token_id = string_of_int @@ (Random.int 1000) + 1 in
  {asset_type=ATNFT { asset_contract ; asset_token_id }; asset_value="1"}

let generate_asset () =
  match Random.int 3 with
  | 0 -> tezos_asset ()
  | 1 -> generate_ft_asset ()
  | 2 -> generate_nft_asset ()
  | _ -> assert false

let generate_salt () =
  string_of_int @@ (Random.int 10000) + 1

let generate_amount ?(max=100_000) () = Random.int max

let generate_token_id () = Int64.of_int @@ generate_amount ~max:1_000_000 ()

let generate_part () =
  let part_account = generate_origin () in
  let part_value = Int32.mul (Random.int32 50l) 100l in
  { part_account ; part_value }

let generate_parts () =
  [ generate_part () ]

let pick_royalties () =
  List.nth royalties_contracts (Random.int royalties_contracts_len)

let generate_alias prefix =
  Printf.sprintf "%s_%d" prefix (Random.int 100000)

let generate_royalties () =
  let rec aux royalties =
    let total =
      List.fold_left (fun acc (_addr, v) -> acc + v) 0 royalties in
    if total = 5000 then royalties
    else
      let a = generate_address () in
      let v = (Random.int 4999) + 1 in
      match List.assoc_opt a.edpk royalties with
      | None -> (a.edpk, v) :: royalties
      | Some old ->
        aux ((a.edpk, v + old) :: (List.remove_assoc a.edpk royalties)) in
  List.map (fun (addr, v) -> pk_to_pkh_exn addr, Int64.of_int v) @@ aux []

let generate_ipfs_metadata () =
  [ "", List.nth ipfs_metadatas (Random.int ipfs_metadatas_len) ]

let mk_order_form
    maker maker_edpk taker taker_edpk make take salt start_date end_date signature data_type payouts origin_fees =
  let elt = {
    order_form_elt_maker = maker ;
    order_form_elt_maker_edpk = maker_edpk ;
    order_form_elt_taker = taker ;
    order_form_elt_taker_edpk = taker_edpk ;
    order_form_elt_make = make ;
    order_form_elt_take = take ;
    order_form_elt_salt = salt ;
    order_form_elt_start = start_date ;
    order_form_elt_end = end_date ;
    order_form_elt_signature = signature ;
  } in
  let data = {
    order_rarible_v2_data_v1_data_type = data_type ;
    order_rarible_v2_data_v1_payouts = payouts ;
    order_rarible_v2_data_v1_origin_fees = origin_fees ;
  } in {
    order_form_elt = elt ;
    order_form_data = data ;
    order_form_type = ()
  }

let generate_order () =
  let maker = generate_maker () in
  (* let maker = maker_account.edpk in *)
  let taker = generate_taker () in
  let make = generate_asset () in
  let take = generate_asset () in
  let salt = generate_salt () in
  let start_date = None in
  let end_date = None in
  let data_type = "V1" in
  let payouts = [] in
  let origin_fees = generate_parts () in
  let taker, taker_edpk = Option.fold ~none:(None, None) ~some:(fun a -> Some a.tz1, Some a.edpk) taker in
  let$ to_sign =
    hash_order_form
      maker.edpk make taker_edpk take salt start_date end_date data_type payouts origin_fees in
  let$ signature = Tzfunc.Crypto.Ed25519.sign ~edsk:maker.edsk to_sign in
  let order_form =
    mk_order_form
      maker.tz1 maker.edpk taker taker_edpk make take salt start_date end_date signature data_type payouts origin_fees in
  Ok order_form

let maker_from_item it = it.it_owner

let asset_from_item asset_contract it =
  let asset_token_id = Int64.to_string it.it_token_id in
  match it.it_kind with
    | `nft ->
      { asset_type = ATNFT { asset_contract; asset_token_id }; asset_value = "1" }
    | `mt amount ->
      { asset_type = ATMT { asset_contract; asset_token_id };
        asset_value = Int64.to_string amount }

let order_form_from_items ?(salt=0) collection item1 item2 =
  let maker = maker_from_item item1 in
  let taker, taker_pk = None, None in
  let make = asset_from_item collection item1 in
  let take = asset_from_item collection item2 in
  let salt = string_of_int salt in
  let start_date = None in
  let end_date = None in
  let data_type = "V1" in
  let payouts = [] in
  let origin_fees = [] in
  let$ to_sign =
    hash_order_form
      maker.edpk make taker_pk take salt start_date end_date data_type payouts origin_fees in
  let$ signature = Tzfunc.Crypto.Ed25519.sign ~edsk:maker.edsk to_sign in
  let order_form =
    mk_order_form
      maker.tz1 maker.edpk taker taker_pk make take salt start_date end_date signature data_type payouts origin_fees in
  Ok order_form

let sell_order_form_from_item ?(salt=0) collection item1 take =
  let maker = maker_from_item item1 in
  let taker, taker_pk = None, None in
  let make = asset_from_item collection item1 in
  let salt = string_of_int salt in
  let start_date = None in
  let end_date = None in
  let data_type = "V1" in
  let payouts = [] in
  let origin_fees = [] in
  let$ to_sign =
    hash_order_form
      maker.edpk make taker_pk take salt start_date end_date data_type payouts origin_fees in
  let$ signature = Tzfunc.Crypto.Ed25519.sign ~edsk:maker.edsk to_sign in
  let order_form =
    mk_order_form
      maker.tz1 maker.edpk taker taker_pk make take salt start_date end_date signature data_type payouts origin_fees in
  Ok order_form

let buy_order_form_from_item ?(salt=0) collection item1 maker make =
  let taker, taker_pk = None, None in
  let take = asset_from_item collection item1 in
  let salt = string_of_int salt in
  let start_date = None in
  let end_date = None in
  let data_type = "V1" in
  let payouts = [] in
  let origin_fees = [] in
  let$ to_sign =
    hash_order_form
      maker.edpk make taker_pk take salt start_date end_date data_type payouts origin_fees in
  let$ signature = Tzfunc.Crypto.Ed25519.sign ~edsk:maker.edsk to_sign in
  let order_form =
    mk_order_form
      maker.tz1 maker.edpk taker taker_pk make take salt start_date end_date signature data_type payouts origin_fees in
  Ok order_form

let handle_ezreq_result = function
  | Ok x -> Ok x
  | Error (EzReq_lwt_S.UnknownError {msg; _}) ->
    Error (`UNKNOWN (match msg with None -> "" | Some s -> s))
  | Error (EzReq_lwt_S.KnownError {error; _}) -> Error error

let call_upsert_order order_form =
  let url = EzAPI.BASE !api in
  let|> r = EzReq_lwt.post0 ~input:order_form url Api.upsert_order_s in
  handle_ezreq_result r

let call_generate_token_id collection =
  let url = EzAPI.BASE !api in
  let> r = EzReq_lwt.get1 url Api.generate_nft_token_id_s collection in
  let|>? {nft_token_id; _} = Lwt.return @@ handle_ezreq_result r in
  Int64.of_string nft_token_id

let call_get_nft_collection_by_id collection =
  let url = EzAPI.BASE !api in
  let|> r = EzReq_lwt.get1 url Api.get_nft_collection_by_id_s collection in
  handle_ezreq_result r

let call_search_nft_collections_by_owner owner =
  let open EzAPI in
  let url = BASE !api in
  let rec aux ?continuation acc =
    let params = match continuation with
      | None -> [ Api.owner_param , S owner ]
      | Some c -> [ Api.owner_param , S owner ; Api.continuation_param, S c ] in
    let> r = EzReq_lwt.get0 url ~params Api.search_nft_collections_by_owner_s in
    let>? collections = Lwt.return @@ handle_ezreq_result r in
    match collections.nft_collections_continuation with
    | None -> Lwt.return_ok @@ collections.nft_collections_collections @ acc
    | Some continuation ->
      aux ~continuation (collections.nft_collections_collections @ acc) in
  aux []

let call_search_nft_all_collections () =
  let open EzAPI in
  let url = BASE !api in
  let rec aux ?continuation acc =
    let params = match continuation with
      | None -> []
      | Some c -> [ Api.continuation_param, S c ] in
    let> r = EzReq_lwt.get0 url ~params Api.search_nft_all_collections_s in
    let>? collections = Lwt.return @@ handle_ezreq_result r in
    match collections.nft_collections_continuation with
    | None -> Lwt.return_ok @@ collections.nft_collections_collections @ acc
    | Some continuation ->
      aux ~continuation (collections.nft_collections_collections @ acc) in
  aux []

let call_get_nft_item_by_id collection tid =
  let url = EzAPI.BASE !api in
  let|> r = EzReq_lwt.get1 url Api.get_nft_item_by_id_s
      (Printf.sprintf "%s:%s" collection tid) in
  handle_ezreq_result r
  (*  >>= fun res ->
   * begin match res with
   *   | Ok item ->
   *     Printf.eprintf "%s\n%!" @@ EzEncoding.construct nft_item_enc item ;
   *   | _ -> ()
   * end ;
   * Lwt.return res *)

let call_get_nft_items_by_owner ?(verbose=0) owner =
  let open EzAPI in
  let msg = if verbose > 0 then Some "debug" else None in
  let url = BASE !api in
  let rec aux ?continuation acc =
    let params = match continuation with
      | None -> [ Api.owner_param , S owner ]
      | Some c -> [ Api.owner_param , S owner ; Api.continuation_param, S c ] in
    let> r = EzReq_lwt.get0 ?msg url ~params Api.get_nft_items_by_owner_s in
    let>? items = Lwt.return @@ handle_ezreq_result r in
    match items.nft_items_continuation with
    | None -> Lwt.return_ok @@ items.nft_items_items @ acc
    | Some continuation ->
      aux ~continuation (items.nft_items_items @ acc) in
  aux []

let call_get_nft_items_by_collection collection =
  let open EzAPI in
  let url = BASE !api in
  let rec aux ?continuation acc =
    let params = match continuation with
      | None -> [ Api.collection_param , S collection ]
      | Some c -> [ Api.collection_param , S collection ; Api.continuation_param, S c ] in
    let> r = EzReq_lwt.get0 url ~params Api.get_nft_items_by_collection_s in
    let>? items = Lwt.return @@ handle_ezreq_result r in
    match items.nft_items_continuation with
    | None -> Lwt.return_ok @@ items.nft_items_items @ acc
    | Some continuation ->
      aux ~continuation (items.nft_items_items @ acc) in
  aux []

let call_get_nft_all_items () =
  let open EzAPI in
  let url = BASE !api in
  let rec aux ?continuation acc =
    let params = match continuation with
      | None -> [ ]
      | Some c -> [ Api.continuation_param, S c ] in
    let> r = EzReq_lwt.get0 url ~params Api.get_nft_all_items_s in
    let>? items = Lwt.return @@ handle_ezreq_result r in
    match items.nft_items_continuation with
    | None -> Lwt.return_ok @@ items.nft_items_items @ acc
    | Some continuation ->
      aux ~continuation (items.nft_items_items @ acc) in
  aux []

let call_get_nft_ownership_by_id collection tid owner  =
  let url = EzAPI.BASE !api in
  let|> r = EzReq_lwt.get1 url Api.get_nft_ownership_by_id_s
      (Printf.sprintf "%s:%s:%s" collection tid owner) in
  handle_ezreq_result r

let call_get_nft_ownerships_by_item contract tid =
  let open EzAPI in
  let url = BASE !api in
  let params = [ Api.contract_param, S contract ; Api.token_id_param, S tid  ] in
  let rec aux ?continuation acc =
    let params = match continuation with
      | None -> params
      | Some c -> params @ [ Api.continuation_param, S c ] in
    let> r = EzReq_lwt.get0 url ~params Api.get_nft_ownerships_by_item_s in
    let>? ownerships = Lwt.return @@ handle_ezreq_result r in
    match ownerships.nft_ownerships_continuation with
    | None -> Lwt.return_ok @@ ownerships.nft_ownerships_ownerships @ acc
    | Some continuation ->
      aux ~continuation (ownerships.nft_ownerships_ownerships @ acc) in
  aux []

let call_get_nft_all_ownerships () =
  let open EzAPI in
  let url = BASE !api in
  let rec aux ?continuation acc =
    let params = match continuation with
      | None -> [ ]
      | Some c -> [ Api.continuation_param, S c ] in
    let> r = EzReq_lwt.get0 url ~params Api.get_nft_all_ownerships_s in
    let>? ownerships = Lwt.return @@ handle_ezreq_result r in
    match ownerships.nft_ownerships_continuation with
    | None -> Lwt.return_ok @@ ownerships.nft_ownerships_ownerships @ acc
    | Some continuation ->
      aux ~continuation (ownerships.nft_ownerships_ownerships @ acc) in
  aux []

let call_get_activities filter =
  (* Format.eprintf "%s\n%!" (EzEncoding.construct nft_activity_filter_enc filter) ; *)
  let open EzAPI in
  let url = BASE !api in
  let rec aux ?continuation acc =
    let params = match continuation with
      | None -> [ ]
      | Some c -> [ Api.continuation_param, S c ] in
    let> r = EzReq_lwt.post0 ~input:filter ~params url Api.get_nft_activities_s in
    let>? activities = Lwt.return @@ handle_ezreq_result r in
    match activities.nft_activities_continuation with
    | None -> Lwt.return_ok @@ activities.nft_activities_items @ acc
    | Some continuation ->
      aux ~continuation (activities.nft_activities_items @ acc) in
  aux []
 (* >>= fun res ->
  *  begin match res with
  *    | Ok a ->
  *      Printf.eprintf "%s\n%!" @@ EzEncoding.construct (Json_encoding.list nft_activity_enc) a ;
  *    | _ -> ()
  *  end ;
  *  Lwt.return res *)

let call_get_nft_all_activities types =
  call_get_activities @@ ActivityFilterAll types

let call_get_nft_activities_by_user types user =
  call_get_activities @@
  ActivityFilterByUser {
    nft_activity_by_user_types = types ;
    nft_activity_by_user_users = [ user ] ;
}

let call_get_nft_activities_by_item types contract token_id =
  call_get_activities @@
  ActivityFilterByItem {
    nft_activity_by_item_types = types ;
    nft_activity_by_item_contract = contract ;
    nft_activity_by_item_token_id = token_id ;
}

let call_get_nft_activities_by_collection types collection =
  call_get_activities @@
  ActivityFilterByCollection {
    nft_activity_by_collection_types = types ;
    nft_activity_by_collection_contract = collection ;
}

let call_get_nft_all_activities_all () =
  call_get_nft_all_activities [ ALLTRANSFER; ALLMINT; ALLBURN ]

let call_get_nft_activities_by_user_all user =
  call_get_nft_activities_by_user
    [ USERMINT; USERBURN ; USERTRANSFER_FROM ; USERTRANSFER_TO ]
    user

let call_get_nft_activities_by_item_all contract token_id =
  call_get_nft_activities_by_item [ ALLTRANSFER; ALLMINT; ALLBURN ] contract token_id

let call_get_nft_activities_by_collection_all collection =
  call_get_nft_activities_by_collection [ ALLTRANSFER; ALLMINT; ALLBURN ] collection

let call_get_nft_all_activities_mint () =
  call_get_nft_all_activities [ ALLMINT ]

let call_get_nft_activities_by_user_mint user =
  call_get_nft_activities_by_user [ USERMINT ] user

let call_get_nft_activities_by_item_mint contract token_id =
  call_get_nft_activities_by_item [ ALLMINT ] contract token_id

let call_get_nft_activities_by_collection_mint collection =
  call_get_nft_activities_by_collection [ ALLMINT ] collection

let call_get_nft_all_activities_burn () =
  call_get_nft_all_activities [ ALLBURN ]

let call_get_nft_activities_by_user_burn user =
  call_get_nft_activities_by_user [ USERBURN ] user

let call_get_nft_activities_by_item_burn contract token_id =
  call_get_nft_activities_by_item [ ALLBURN ] contract token_id

let call_get_nft_activities_by_collection_burn collection =
  call_get_nft_activities_by_collection [ ALLBURN ] collection

let call_get_nft_all_activities_transfer () =
  call_get_nft_all_activities [ ALLTRANSFER ]

let call_get_nft_activities_by_user_transfer user =
  call_get_nft_activities_by_user [ USERTRANSFER_FROM ; USERTRANSFER_TO ] user

let call_get_nft_activities_by_item_transfer contract token_id =
  call_get_nft_activities_by_item [ ALLTRANSFER ] contract token_id

let call_get_nft_activities_by_collection_transfer collection =
  call_get_nft_activities_by_collection [ ALLTRANSFER ] collection

let upsert_order () =
  match generate_order () with
  | Ok order_form ->
    call_upsert_order order_form
  | Error err ->
    Lwt.fail_with (Printf.sprintf "error : %s" @@ Let.string_of_error err)

let call_get_order hash =
  let url = EzAPI.BASE !api in
  let|> r = EzReq_lwt.get1 url Api.get_order_by_hash_s hash in
  handle_ezreq_result r

(* let update_order_make_value hash make_value =
 *   Db.get_order hash >|= function
 *   | Error err -> Format.eprintf "ERROR %s\n%!" @@ Crp.string_of_error err ;
 *   | Ok None -> Format.eprintf "get_order None"
 *   | Ok (Some order) ->
 *     let order_form = order_form_from_order order in
 *     let maker = order_form.order_form_elt.order_form_elt_maker in
 *     let _, _, maker_sk = by_pk maker in
 *     let taker = order_form.order_form_elt.order_form_elt_taker in
 *     let make = order_form.order_form_elt.order_form_elt_make in
 *     let make = { make with asset_value = make_value } in
 *     let take = order_form.order_form_elt.order_form_elt_take in
 *     let salt = order_form.order_form_elt.order_form_elt_salt in
 *     let start_date = order_form.order_form_elt.order_form_elt_start in
 *     let end_date = order_form.order_form_elt.order_form_elt_end in
 *     match order_form.order_form_data with
 *     | RaribleV2Order data ->
 *       let data_type = data.order_rarible_v2_data_v1_data_type in
 *       let payouts = data.order_rarible_v2_data_v1_payouts in
 *       let origin_fees = data.order_rarible_v2_data_v1_origin_fees in
 *       begin match
 *           hash_order_form
 *             maker make taker take salt start_date end_date data_type payouts origin_fees with
 *       | Ok to_sign ->
 *         let signature = sign ~edsk:maker_sk ~bytes:to_sign in
 *         let order_form =
 *           mk_order_form
 *             maker taker make take salt start_date end_date signature data_type payouts origin_fees in
 *         call_upsert_order order_form
 *       | Error err -> Lwt.return_error err
 *       end
 *     | _ ->
 *       Format.eprintf "Wrong order type \n%!" *)

(* let update_order_take_value hash take_value =
 *   Db.get_order hash >|= function
 *   | Error err -> Format.eprintf "ERROR %s\n%!" @@ Crp.string_of_error err ;
 *   | Ok None -> Format.eprintf "get_order None"
 *   | Ok (Some order) ->
 *     let order_form = order_form_from_order order in
 *     let maker = order_form.order_form_elt.order_form_elt_maker in
 *     let _, _, maker_sk = by_pk maker in
 *     let taker = order_form.order_form_elt.order_form_elt_taker in
 *     let make = order_form.order_form_elt.order_form_elt_make in
 *     let take = order_form.order_form_elt.order_form_elt_take in
 *     let take = { take with asset_value = take_value } in
 *     let salt = order_form.order_form_elt.order_form_elt_salt in
 *     let start_date = order_form.order_form_elt.order_form_elt_start in
 *     let end_date = order_form.order_form_elt.order_form_elt_end in
 *     match order_form.order_form_data with
 *     | RaribleV2Order data ->
 *       let data_type = data.order_rarible_v2_data_v1_data_type in
 *       let payouts = data.order_rarible_v2_data_v1_payouts in
 *       let origin_fees = data.order_rarible_v2_data_v1_origin_fees in
 *       begin match
 *           hash_order_form
 *             maker make taker take salt start_date end_date data_type payouts origin_fees with
 *       | Ok to_sign ->
 *         let signature = sign ~edsk:maker_sk ~bytes:to_sign in
 *         let order_form =
 *           mk_order_form
 *             maker taker make take salt start_date end_date signature data_type payouts origin_fees in
 *         call_upsert_order order_form
 *       | Error err -> Format.eprintf "Error %s\n%!" @@ string_of_error err
 *       end
 *     | _ ->
 *       Format.eprintf "Wrong order type \n%!" *)

(* let update_order_taker hash taker =
 *   Db.get_order hash >|= function
 *   | Error err -> Format.eprintf "ERROR %s\n%!" @@ Crp.string_of_error err ;
 *   | Ok None -> Format.eprintf "get_order None"
 *   | Ok (Some order) ->
 *     let order_form = order_form_from_order order in
 *     let maker = order_form.order_form_elt.order_form_elt_maker in
 *     let _, _, maker_sk = by_pk maker in
 *     let taker = taker in
 *     let make = order_form.order_form_elt.order_form_elt_make in
 *     let take = order_form.order_form_elt.order_form_elt_take in
 *     let salt = order_form.order_form_elt.order_form_elt_salt in
 *     let start_date = order_form.order_form_elt.order_form_elt_start in
 *     let end_date = order_form.order_form_elt.order_form_elt_end in
 *     match order_form.order_form_data with
 *     | RaribleV2Order data ->
 *       let data_type = data.order_rarible_v2_data_v1_data_type in
 *       let payouts = data.order_rarible_v2_data_v1_payouts in
 *       let origin_fees = data.order_rarible_v2_data_v1_origin_fees in
 *       begin match
 *           hash_order_form
 *             maker make taker take salt start_date end_date data_type payouts origin_fees with
 *       | Ok to_sign ->
 *         let signature = sign ~edsk:maker_sk ~bytes:to_sign in
 *         let order_form =
 *           mk_order_form
 *             maker taker make take salt start_date end_date signature data_type payouts origin_fees in
 *         call_upsert_order order_form
 *       | Error err -> Format.eprintf "Error %s\n%!" @@ string_of_error err
 *       end
 *     | _ ->
 *       Format.eprintf "Wrong order type \n%!" *)

let may_import_key ?(verbose=0) a =
  let cmd = Script.import_key ~verbose a.alias a.edsk in
  ignore @@ sys_command cmd

let read_whole_file filename =
  let ch = open_in filename in
  let s = really_input_string ch (in_channel_length ch) in
  close_in ch;
  s

let create_descr prefix suffix =
  let temp_fn = Filename.temp_file prefix suffix in
  let c = open_out temp_fn in
  Unix.descr_of_out_channel c, temp_fn

let create_descr2 prefix =
  let temp_fn = Filename.temp_file prefix "" in
  let out_fn, err_fn = temp_fn ^ "out", temp_fn ^ "err" in
  let c_out = open_out out_fn in
  let c_err = open_out err_fn in
  Unix.descr_of_out_channel c_out, out_fn,
  Unix.descr_of_out_channel c_err, err_fn

let create_process ?(stdin=Unix.stdin) ?(stdout=Unix.stdout) ?(stderr=Unix.stderr) prog args =
  Unix.create_process prog args stdin stdout stderr

let show_address alias =
  let prog = !Script.client in
  let args = Array.of_list [prog ; "show" ; "address" ; alias ; "-S" ] in
  let stdout, temp_fn = create_descr "tezos-client" "show_address" in
  let pid = create_process ~stdout prog args in
  let _, status = Unix.waitpid [] pid in
  Unix.close stdout ;
  match status with
  | Unix.WEXITED code ->
    if code <> 0 then failwith "show address failure"
    else
      let content = read_whole_file temp_fn in
      begin match String.split_on_char ':' content with
      | _before :: tz1 :: pk :: _unencrypted :: sk :: [] ->
        String.sub tz1 1 36,
        String.sub pk 1 36,
        sk
      | _ -> failwith "show address : can't parse result"
      end
  | Unix.WSIGNALED _ | Unix.WSTOPPED _ -> failwith "show address failure"

let find_kt1 contract_alias =
  if !js then contract_alias
  else
    let prog = !Script.client in
    let args =
      Array.of_list
        [ prog ; "-E"; !endpoint; "list" ; "known" ; "contracts" ] in
    let stdout, out_temp_fn, stderr, _err_temp_fn =
      create_descr2 "tezos-client-list_known_contracts" in
    let pid = create_process ~stdout ~stderr prog args in
    let _, status = Unix.waitpid [] pid in
    Unix.close stdout ;
    Unix.close stderr ;
    match status with
    | Unix.WEXITED code ->
      begin if code <> 0 then failwith "list_known_contracts failure"
        else
          let contract = ref None in
          let ch = open_in out_temp_fn in
          begin try
              while true; do
                let line = input_line ch in
                match String.split_on_char ':' line with
                | alias :: kt1 :: [] ->
                  if alias = contract_alias then
                    begin
                      contract := Some (String.sub kt1 1 36) ;
                      raise End_of_file
                    end
                | _ -> ()
              done
            with End_of_file -> ()
          end ;
          close_in ch ;
          match !contract with
          | None -> failwith "can't find kt1"
          | Some kt1 -> kt1
      end
    | Unix.WSIGNALED _ | Unix.WSTOPPED _ -> failwith "list_known_address failure"

let deploy ?verbose ?burn_cap ~filename ~storage ~source alias =
  ignore verbose;
  let cmd =
    Script.deploy_aux
      ~verbose:!Script.verbose
      ~endpoint:!endpoint
      ~force:true
      ?burn_cap
      ~filename
      storage
      source.tz1
      alias in
  let code, out, err = sys_command ~verbose:!Script.verbose ~retry:1 cmd in
  if code <> 0 then
    failwith (Printf.sprintf "deploy failure : out %S err %S" out err)

let create_collection ?(royalties=pick_royalties ()) ?alias ?(kind=`nft) () =
  let col_alias = generate_alias "collection" in
  let col_admin = match alias with None -> generate_address () | Some a -> by_alias a in
  may_import_key col_admin;
  let col_source = generate_address () in
  may_import_key col_source;
  let name = Filename.basename @@ Filename.temp_file "collection" "name" in
  let symbol =
    if Random.bool () then None
    else
      Some (String.init 3 (fun _ -> Char.chr @@ Random.int 26 + 97)) in
  let col_metadata =
    EzEncoding.construct
      Json_encoding.(obj2 (req "name" string) (opt "symbol" string))
      (name, symbol) in
  {col_admin; col_source; col_alias; col_royalties_contract=royalties;
   col_metadata; col_kt1=""; col_kind=kind}

let create_collections ?royalties nb =
  let rec aux acc cpt =
    if cpt = 0 then acc
    else aux ((create_collection ?royalties ()) :: acc) (cpt - 1) in
  aux [] nb

let set_metadata c =
  if !js then
    Script_js.set_metadata ~endpoint:!endpoint c
  else
    let cmd = Script.set_metadata_aux ~endpoint:!endpoint ~key:"" ~value:c.col_metadata
        c.col_admin.tz1 c.col_kt1 in
    let code, out, err = sys_command cmd in
    if code <> 0 then
      Printf.eprintf "set_metadata_uri failure (log %s err %s)\n%!" out err;
    Lwt.return_unit

let set_token_metadata c it =
  if !js then
    Script_js.set_token_metadata ~endpoint:!endpoint it
  else
    let cmd = Script.set_token_metadata_aux ~endpoint:!endpoint ~id:it.it_token_id
        ~metadata:it.it_metadata c.col_admin.tz1 it.it_collection in
    let code, out, err = sys_command cmd in
    if code <> 0 then
      Lwt.return @@ Printf.eprintf "set_token_metadata failure (log %s err %s)\n%!" out err
    else Lwt.return_unit

let deploy_collection c =
  Printf.eprintf "Deploying new collection\n%!" ;
  if !js then
    let col_kt1 = Script_js.deploy_collection ~endpoint:!endpoint c in
    Lwt.return { c with col_kt1 }
  else
    let filename = match c.col_kind with
      | `nft -> "contracts/arl/nft-private.arl"
      | `mt -> "contracts/arl/mt-private.arl" in
    let storage = Script.storage_nft c.col_admin.tz1 in
    deploy ~filename ~storage ~source:c.col_source c.col_alias;
    Printf.eprintf "  deployed collection %s\n%!" c.col_alias ;
    let col_kt1 = find_kt1 c.col_alias in
    let c = { c with col_kt1 } in
    let> () = set_metadata c in
    Printf.eprintf "  --> %s:%s\n%!" c.col_alias c.col_kt1 ;
    Lwt.return c

let deploy_ubi_collection c =
  Printf.eprintf "Deploying new collection\n%!" ;
  if !js then Lwt.fail_with "TODO"
  else
    let filename = "contracts/mich/ubi.tz" in
    let storage = Script.storage_ubi c.col_admin.tz1 in
    deploy ~filename ~storage ~source:c.col_source c.col_alias;
    Printf.eprintf "  deployed collection %s\n%!" c.col_alias ;
    let col_kt1 = find_kt1 c.col_alias in
    let c = { c with col_kt1 } in
    let> () = set_metadata c in
    Printf.eprintf "  --> %s:%s\n%!" c.col_alias c.col_kt1 ;
    Lwt.return c

let create_royalties () =
  Printf.eprintf "Creating new royalties\n%!" ;
  let admin = generate_address () in
  if !js then
    let kt1 = Script_js.deploy_royalties ~endpoint:!endpoint admin in
    kt1, admin
  else
    let alias = generate_alias "royalties" in
    may_import_key admin ;
    let source = generate_address () in
    may_import_key source ;
    let filename = "contracts/arl/royalties.arl" in
    let storage = Script.storage_royalties ~admin:admin.tz1 in
    deploy ~filename ~storage ~source alias ;
    alias, admin

let create_validator ~exchange ~royalties =
  Printf.eprintf "Creating new validator\n%!" ;
  let source = generate_address () in
  if !js then
    let kt1_validator =
      Script_js.deploy_validator ~endpoint:!endpoint ~exchange ~royalties source in
    kt1_validator, source
  else
    let alias = generate_alias "validator" in
    may_import_key source ;
    let filename = "contracts/arl/validator.arl" in
    let storage = Script.storage_validator ~exchange ~royalties in
    deploy ~burn_cap:4.67575 ~filename ~storage ~source alias ;
    alias, source

let create_exchange () =
  Printf.eprintf "Creating new exchange\n%!" ;
  let admin = generate_address () in
  may_import_key admin ;
  let source = generate_address () in
  may_import_key source ;
  let receiver = generate_address () in
  may_import_key receiver ;
  if !js then
    let kt1_exchange = Script_js.deploy_exchange ~endpoint:!endpoint ~admin
        ~receiver ~fee:300L source in
    kt1_exchange, admin, receiver
  else
    let filename = "contracts/arl/exchangeV2.arl" in
    let storage = Script.storage_exchange ~admin:admin.tz1 ~receiver:receiver.tz1 ~fee:300L in
    let alias = generate_alias "exchange" in
    deploy ~burn_cap:42.1 ~filename ~storage ~source alias ;
    alias, admin, receiver

let set_validator validator source contract =
  if !js then
    Script_js.set_validator ~endpoint:!endpoint ~source ~contract validator
  else
    let cmd = Script.set_validator_aux ~endpoint:!endpoint validator source.tz1 contract in
    let code, out, err = sys_command cmd in
    if code <> 0 then
      Lwt.return @@
      Printf.eprintf "set_validator failure (log %s err %s)\n%!" out err
    else Lwt.return_unit

let set_royalties id royalties source contract =
  if !js then
    Lwt.fail_with "TODO"
  else
    let cmd =
      Script.set_royalties_aux ~endpoint:!endpoint ~id ~royalties source.tz1 contract in
    let code, out, err = sys_command cmd in
    if code <> 0 then
      Lwt.return @@
      Printf.eprintf "set_validator failure (log %s err %s)\n%!" out err
    else Lwt.return_unit

let update_operators_for_all operator source contract =
  Printf.eprintf "update_operators_for_all %s for %s on %s\n%!" operator source.tz1 contract ;
  if !js then
    Script_js.update_operators_for_all ~endpoint:!endpoint ~contract ~operator source
  else
    let cmd =
      Script.update_operators_for_all_aux ~endpoint:!endpoint [ operator, true ] source.tz1 contract in
    let code, out, err = sys_command cmd in
    if code <> 0 then
      Lwt.return @@
      Printf.eprintf "update_operator_for_all failure (log %s err %s)\n%!" out err
    else Lwt.return_unit

let update_operators token_id owner operator source contract =
  Printf.eprintf "update_operators %s for %s on %s\n%!" operator (fst source) contract ;
  if !js then
    Lwt.fail_with "TODO"
  else
    let cmd =
      Script.update_operators_aux ~endpoint:!endpoint
        [ {Script.uo_id=token_id; uo_owner=owner; uo_operator=operator; uo_add=true} ]
        (fst source) contract in
    let code, out, err = sys_command cmd in
    if code <> 0 then
      Lwt.return @@
      Printf.eprintf "update_operator failure (log %s err %s)\n%!" out err
    else Lwt.return_unit

let mint_tokens c it =
  if !js then Script_js.mint_tokens ~endpoint:!endpoint c it
  else
    let cmd = Script.mint_tokens_aux
        ~endpoint:!endpoint ~id:it.it_token_id
        ~owner:it.it_owner.tz1 ~kind:it.it_kind
        ~royalties:it.it_royalties ~metadata:it.it_metadata
        c.col_admin.tz1 c.col_kt1 in
    let code, out, err = sys_command cmd in
    if code <> 0 then
      Lwt.return @@
      Printf.eprintf "mint failure (log %s err %s)\n%!" out err
    else Lwt.return_unit

let mint_ubi_tokens c it =
  if !js then
    Lwt.fail_with "TODO"
  else
    let cmd =
      Script.mint_ubi_tokens_aux ~endpoint:!endpoint it.it_token_id it.it_owner.tz1
        c.col_admin.tz1 c.col_kt1 in
    let code, out, err = sys_command cmd in
    if code <> 0 then
      Lwt.return @@
      Printf.eprintf "mint failure (log %s err %s)\n%!" out err
    else Lwt.return_unit

let burn_tokens it kind =
  if !js then
    Script_js.burn_tokens ~endpoint:!endpoint it kind
  else
    let cmd = Script.burn_tokens_aux ~endpoint:!endpoint ~id:it.it_token_id
        ~kind it.it_owner.tz1 it.it_collection in
    let code, out, err = sys_command cmd in
    if code <> 0 then
      Lwt.return @@
      Printf.eprintf "burn failure (log %s err %s)\n%!" out err
    else Lwt.return_unit

let transfer_tokens it amount new_owner =
  if !js then
    Script_js.transfer_tokens ~endpoint:!endpoint it ~amount new_owner
  else
    let cmd =
      Script.transfer_aux ~endpoint:!endpoint
        [ {Script.tr_src=it.it_owner.tz1; tr_txs=[
              {Script.trd_id=it.it_token_id; trd_amount=amount; trd_dst=new_owner.tz1 }]}]
        it.it_owner.tz1 it.it_collection in
    let code, out, err = sys_command cmd in
    if code <> 0 then
      Lwt.return @@
      Printf.eprintf "transfer failure (log %s err %s)\n%!" out err
    else Lwt.return_unit

let mint_with_random_token_id c =
  Printf.eprintf "mint_with_random_token_id for %s on %s\n%!" c.col_admin.tz1 c.col_kt1 ;
  let it_owner = generate_address () in
  let it_token_id = generate_token_id () in
  let it_kind = match c.col_kind with
    | `nft -> `nft
    | `mt -> `mt (Int64.of_int @@ generate_amount ~max:10 () + 1) in
  let it_royalties = generate_royalties () in
  let it_metadata = generate_ipfs_metadata () in
  let item = {it_owner; it_token_id; it_kind; it_royalties; it_metadata; it_collection=c.col_kt1} in
  mint_tokens c item >>= fun () ->
  Lwt.return_ok item

let mint_one_with_token_id_from_api ?diff ?alias c =
  Printf.eprintf "mint_one_with_token_id_from_api for %s on %s\n%!" c.col_admin.tz1 c.col_kt1 ;
  let it_owner =
    match alias with None -> generate_address ?diff () | Some a -> by_alias a in
  let it_royalties = generate_royalties () in
  let it_metadata = generate_ipfs_metadata () in
  let>? it_token_id = call_generate_token_id c.col_kt1 in
  let it_kind = match c.col_kind with `nft -> `nft | `mt -> `mt 1L in
  let item = {it_owner; it_token_id; it_kind; it_royalties; it_metadata; it_collection=c.col_kt1} in
  let> () = mint_tokens c item in
  Lwt.return_ok item

let mint_ubi_with_token_id_from_api ?diff ?alias c =
  Printf.eprintf "mint_one_with_token_id_from_api for %s on %s\n%!" c.col_admin.tz1 c.col_kt1 ;
  let it_owner =
    match alias with None -> generate_address ?diff () | Some a -> by_alias a in
  let name = Filename.basename @@ Filename.temp_file "item" "name" in
  let it_metadata = [ "name", name ] in
  let>? it_token_id = call_generate_token_id c.col_kt1 in
  let it_kind = match c.col_kind with `nft -> `nft | `mt -> `mt 1L in
  let item =
    {it_owner; it_token_id; it_kind; it_royalties=[]; it_metadata; it_collection=c.col_kt1} in
  let> () = mint_ubi_tokens c item in
  (* let> () = set_token_metadata tid.nft_token_id metadata source contract in *)
  Lwt.return_ok item

let mint_with_token_id_from_api c =
  Printf.eprintf "mint_with_token_id_from_api for %s on %s\n%!" c.col_admin.tz1 c.col_kt1 ;
  let it_owner = generate_address () in
  let it_kind = match c.col_kind with
    | `nft -> `nft
    | `mt ->
      let amount = generate_amount ~max:10 () + 1 in
      `mt (Int64.of_int amount) in
  let it_royalties = generate_royalties () in
  let it_metadata = generate_ipfs_metadata () in
  let>? it_token_id = call_generate_token_id c.col_kt1 in
  let item = {it_owner; it_token_id; it_kind; it_royalties; it_metadata; it_collection=c.col_kt1} in
  let> () = mint_tokens c item in
  Lwt.return_ok item

let burn_with_token_id it kind =
  Printf.eprintf "burn_with_token_id for %s on %s\n%!" it.it_owner.tz1 it.it_collection ;
  burn_tokens it kind

let transfer_with_token_id it amount new_owner =
  Printf.eprintf "transfer_with_token_id %Ld from %s to %s on %s\n%!"
    it.it_token_id it.it_owner.tz1 new_owner.tz1 it.it_collection ;
  transfer_tokens it amount new_owner

let mint ?(with_token_id=false) c =
  let random = if with_token_id then false else Random.bool () in
  if random then
    let>? r = mint_with_random_token_id c in
    Lwt.return_ok r
  else mint_with_token_id_from_api c

let burn it =
  let kind, new_kind = match it.it_kind with
    | `nft -> `nft, None
    | `mt max_amount ->
      if Random.bool () then `mt max_amount, None
      else
        let a = Random.int64 max_amount in
        `mt a, Some (`mt (Int64.sub max_amount a)) in
  let|> () = burn_with_token_id it kind in
  match new_kind with None -> None | Some it_kind -> Some { it with it_kind }

let transfer it =
  let new_owner = generate_address ~diff:(it.it_owner.tz1) () in
  let old_item, new_item, amount = match it.it_kind with
    | `nft -> None, { it with it_owner = new_owner }, 1L
    | `mt max_amount ->
      if Random.bool () then
        None, { it with it_owner = new_owner }, max_amount
      else
        let a = Random.int64 max_amount in
        Some { it with it_kind = `mt (Int64.sub max_amount a) },
        { it with it_kind = `mt a; it_owner = new_owner }, a in
  let|> () = transfer_with_token_id it amount new_owner in
  old_item, new_item

let make_tr ?entrypoint ?(fee= -1L) ?(gas_limit=Z.minus_one)
    ?(storage_limit=Z.minus_one) ?(counter=Z.zero) ?(amount=0L) ~source ~contract p =
  let open Tzfunc.Proto in
  let entrypoint = EPnamed (Option.get entrypoint) in
  let parameters = Some {entrypoint; value = Micheline p} in
  {
    man_info = {source; kind = Transaction {amount; destination=contract; parameters}};
    man_numbers = {fee; gas_limit; storage_limit; counter};
    man_metadata = None
  }

let forge_tr ?entrypoint ?fee ?gas_limit ?storage_limit ?counter
    ?amount ?remove_failed ?local_forge ~base ~get_pk ~source ~contract p =
  let op = make_tr ?entrypoint ?fee ?gas_limit ?storage_limit
      ?counter ?amount ~source ~contract p in
  Tzfunc.Node.forge_manager_operations ?remove_failed ?local_forge ~base
    ~get_pk ~src:source [ op ]

let call ?entrypoint ?fee ?gas_limit ?storage_limit ?counter
    ?amount ?remove_failed ?local_forge ~base ~get_pk ~source ~contract ~sign p =
  Lwt.bind (forge_tr ?entrypoint ?fee ?gas_limit ?storage_limit
              ?counter ?amount ?remove_failed ?local_forge ~base ~get_pk ~source ~contract p) @@ function
  | Error e ->
    Printf.eprintf "forge_tr error %s" @@ Tzfunc.Rp.string_of_error e ;
    Lwt.return_error e
  | Ok (bytes, protocol, branch, ops) ->
    Tzfunc.Node.inject ~base ~sign ~bytes ~branch ~protocol ops

let mich_order order =
  let maker = order.order_elt.order_elt_maker in
  let make = order.order_elt.order_elt_make in
  let taker = order.order_elt.order_elt_taker in
  let take = order.order_elt.order_elt_take in
  let salt = order.order_elt.order_elt_salt in
  let start_date = order.order_elt.order_elt_start in
  let end_date = order.order_elt.order_elt_end in
  mich_order_form
    ~maker ~make ~taker ~take ~salt ~start_date ~end_date
    ~data_type:"V1"
    ~payouts:order.order_data.order_rarible_v2_data_v1_payouts
    ~origin_fees:order.order_data.order_rarible_v2_data_v1_origin_fees

let match_orders ?amount ~source ~contract order_left order_right =
  match flat_order order_left with
  | Error err -> Lwt.fail_with @@ Printf.sprintf "mich order %s" @@ string_of_error err
  | Ok m_left ->
    match flat_order order_right with
    | Error err -> Lwt.fail_with @@ Printf.sprintf "mich order %s" @@ string_of_error err
    | Ok m_right ->
      let signature_left =
        prim `Some ~args:[Proto.Mstring order_left.order_elt.order_elt_signature] in
      let signature_right =
        prim `Some ~args:[Proto.Mstring order_right.order_elt.order_elt_signature] in
      let mich = prim `Pair ~args:[m_left; signature_left; m_right; signature_right] in
      call
        ?amount
        ~local_forge:false
        ~entrypoint:"matchOrders"
        ~base:(EzAPI.BASE !endpoint)
        ~get_pk:(fun () -> Lwt.return_ok source.edpk)
        ~source:source.tz1
        ~contract
        ~sign:(Tzfunc.Node.sign ~edsk:source.edsk)
        mich

let cancel_order ~source ~contract order =
  match flat_order order with
  | Error err -> Lwt.fail_with @@ Printf.sprintf "mich order %s" @@ string_of_error err
  | Ok m ->
    call
      ~local_forge:false
      ~entrypoint:"cancel"
      ~base:(EzAPI.BASE !endpoint)
      ~get_pk:(fun () -> Lwt.return_ok source.edpk)
      ~source:source.tz1
      ~contract
      ~sign:(Tzfunc.Node.sign ~edsk:source.edsk)
      m

let random_mint ?with_token_id collections =
  let c = List.nth collections (Random.int @@ List.length collections) in
  mint ?with_token_id c

let random_burn items =
  let selected = Random.int @@ List.length items in
  let it = List.nth items selected in
  let|> new_item = burn it in
  match new_item with
  | None ->
    let l = List.mapi (fun i it -> if i = selected then None else Some it) items in
    List.filter_map (fun x -> x) l, new_item
  | Some item ->
    List.mapi (fun i it -> if i = selected then item else it) items, new_item

let random_transfer items =
  let selected = Random.int @@ List.length items in
  let it = List.nth items selected in
  let|> old_item, new_item = transfer it  in
  match old_item with
    | None ->
      let l = List.mapi (fun i it -> if i = selected then None else Some it) items in
      new_item :: List.filter_map (fun x -> x) l, old_item, new_item
    | Some item ->
      new_item :: List.mapi (fun i it -> if i = selected then item else it) items, old_item, new_item

let check_royalties item_royalties royalties =
  List.for_all (fun p ->
      try
        let v = List.assoc p.part_account royalties in
        v = Int64.of_int32 p.part_value
      with Not_found ->
  false) item_royalties

let check_owners item_owners owner =
  List.exists (fun o -> owner = o) item_owners

let check_strict_owners item_owners owner = match item_owners with
  | [ o ] when o = owner -> true
  | _ -> false

let check_supply item_supply kind =
  let amount = match kind with `nft -> 1L | `mt a -> a in
  Int64.of_string item_supply >= amount

let check_strict_supply item_supply kind =
  let amount = match kind with `nft -> 1L | `mt a -> a in
  Int64.of_string item_supply = amount

let check_metadata itm_metadata metadata = match itm_metadata, metadata with
  | Some im, Some m ->
    im.nft_item_meta_name = m.nft_item_meta_name &&
    im.nft_item_meta_description = m.nft_item_meta_description &&
    im.nft_item_meta_attributes = m.nft_item_meta_attributes &&
    im.nft_item_meta_image = m.nft_item_meta_image &&
    im.nft_item_meta_animation = m.nft_item_meta_animation
  | _, _ -> false

let check_nft_item ?(verbose=0) ?(strict=true) itm it =
  if verbose > 0 then
    Printf.eprintf "%s\n%s %s %Ld %s\n%!"
      (EzEncoding.construct nft_item_enc itm) it.it_collection it.it_owner.tz1 it.it_token_id
      (match it.it_kind with `nft -> "NFT" | `mt amount -> Format.sprintf "MT(%Ld)" amount);
  if verbose > 0 then
  Printf.eprintf "%b %b %b %b %b\n%!"
    (itm.nft_item_id = (Printf.sprintf "%s:%Ld" it.it_collection it.it_token_id))
    (itm.nft_item_contract = it.it_collection)
    (itm.nft_item_token_id = Int64.to_string it.it_token_id)
    (if strict then check_strict_owners itm.nft_item_owners it.it_owner.tz1
     else check_owners itm.nft_item_owners it.it_owner.tz1)
    (if strict then check_strict_supply itm.nft_item_supply it.it_kind
     else check_supply itm.nft_item_supply it.it_kind) ;
  itm.nft_item_id = (Printf.sprintf "%s:%Ld" it.it_collection it.it_token_id) &&
  itm.nft_item_contract = it.it_collection &&
  itm.nft_item_token_id = Int64.to_string it.it_token_id &&
  (* check_royalties itm.nft_item_royalties royalties && *)
  (if strict then check_strict_owners itm.nft_item_owners it.it_owner.tz1
   else check_owners itm.nft_item_owners it.it_owner.tz1) &&
  (if strict then check_strict_supply itm.nft_item_supply it.it_kind
   else check_supply itm.nft_item_supply it.it_kind)(*  &&
   * check_metadata itm.nft_item_meta metadata *)

let check_nft_ownership ow it =
  ow.nft_ownership_id = (Printf.sprintf "%s:%Ld:%s" it.it_collection it.it_token_id it.it_owner.tz1) &&
  ow.nft_ownership_contract = it.it_collection &&
  ow.nft_ownership_token_id = Int64.to_string it.it_token_id &&
  ow.nft_ownership_owner = it.it_owner.tz1 &&
  ow.nft_ownership_value = (match it.it_kind with `nft -> "1" | `mt a -> Int64.to_string a)(*  &&
   * check_creators ow.nft_ownership_creators metadata *)

let check_not_item ?verbose ?strict it =
  let nft_item_exists ?verbose items =
    List.exists (fun i -> check_nft_item ?verbose ?strict i it) items in
  let nft_ownership_exists ownerships =
    List.exists (fun o ->  check_nft_ownership o it) ownerships in
  call_get_nft_item_by_id it.it_collection (Int64.to_string it.it_token_id) >|= begin function
    | Error _err -> Printf.eprintf "[OK] check_not_item : item_by_id\n%!"
    | Ok nft_item ->
      if not @@ check_nft_item nft_item it then
        Printf.eprintf "[OK] check_not_item : item_by_id\n%!"
      else
        Printf.eprintf "[KO] check_not_item : item_by_id\n%!"
  end >>= fun () ->
  call_get_nft_items_by_owner ?verbose it.it_owner.tz1 >|= begin function
    | Error _err ->
      Printf.eprintf "[OK] check_not_item : items_by_owner\n%!"
    | Ok nft_items ->
      if not @@ nft_item_exists ?verbose nft_items then
        Printf.eprintf "[OK] check_not_item : items_by_owner\n%!"
      else
        Printf.eprintf "[KO] check_not_item : items_by_owner\n%!"
  end >>= fun () ->
  call_get_nft_items_by_collection it.it_collection >|= begin function
    | Error _err -> Printf.eprintf "[OK] check_not_item : items_by_collection\n%!"
    | Ok nft_items ->
      if not @@ nft_item_exists nft_items then
        Printf.eprintf "[OK] check_not_item : items_by_collection\n%!"
      else
        Printf.eprintf "[KO] check_not_item : items_by_collection\n%!"
  end >>= fun () ->
  call_get_nft_all_items () >|= begin function
    | Error _err -> Printf.eprintf "[OK] check_not_item : all_items\n%!"
    | Ok nft_items ->
      if not @@ nft_item_exists nft_items then
        Printf.eprintf "[OK] check_not_item : all_items\n%!"
      else
        Printf.eprintf "[KO] check_not_item : all_items\n%!"
  end >>= fun () ->
  call_get_nft_ownership_by_id it.it_collection (Int64.to_string it.it_token_id) it.it_owner.tz1
  >|= begin function
    | Error _err -> Printf.eprintf "[OK] check_not_item : ownership_by_id\n%!"
    | Ok nft_ownership ->
      if not @@ check_nft_ownership nft_ownership it then
        Printf.eprintf "[OK] check_not_item : ownership_by_id\n%!"
      else
        Printf.eprintf "[KO] check_not _item : ownership_by_id\n%!"
  end >>= fun () ->
  call_get_nft_ownerships_by_item it.it_collection (Int64.to_string it.it_token_id)
  >|= begin function
    | Error _err -> Printf.eprintf "[OK] check_not_item : ownerships_by_item\n%!"
    | Ok nft_ownerships ->
      if not @@ nft_ownership_exists nft_ownerships then
        Printf.eprintf "[OK] check_not_item : ownerships_by_item\n%!"
      else
        Printf.eprintf "[KO] check_not_item : ownerships_by_item\n%!"
  end >>= fun () ->
  call_get_nft_all_ownerships () >|= begin function
    | Error _err -> Printf.eprintf "[OK] check_not_item : all_ownerships\n%!"
    | Ok nft_ownerships ->
      if not @@ nft_ownership_exists nft_ownerships then
        Printf.eprintf "[OK] check_not_item : all_ownerships\n%!"
      else
        Printf.eprintf "[KO] check_not_item : all_ownerships\n%!"
  end
(* get_nft_item_meta_by_id ;
 * get_nft_items_by_creator ; *)

let check_item ?verbose ?strict it =
  let nft_item_exists ?verbose items =
    List.exists (fun i -> check_nft_item ?verbose ?strict i it) items in
  let nft_ownership_exists ownerships =
    List.exists (fun o ->  check_nft_ownership o it) ownerships in
  call_get_nft_item_by_id it.it_collection (Int64.to_string it.it_token_id) >|= begin function
    | Ok nft_item ->
      if check_nft_item nft_item it then
        Printf.eprintf "[OK] check_item : item_by_id\n%!"
      else
        Printf.eprintf "[KO] check_item : item_by_id\n%!"
    | Error err ->
      Printf.eprintf "[KO] check_item : item_by_id (error : %s)\n%!" @@
      Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_items_by_owner ?verbose it.it_owner.tz1 >|= begin function
    | Ok nft_items ->
      if nft_item_exists ?verbose nft_items then
        Printf.eprintf "[OK] check_item : items_by_owner\n%!"
      else
        Printf.eprintf "[KO] check_item : items_by_owner\n%!"
    | Error err ->
      Printf.eprintf "[KO] check_item : items_by_owner (error : %s)\n%!" @@
      Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_items_by_collection it.it_collection >|= begin function
    | Ok nft_items ->
      if nft_item_exists nft_items then
        Printf.eprintf "[OK] check_item : items_by_collection\n%!"
      else
        Printf.eprintf "[KO] check_item : items_by_collection\n%!"
    | Error err ->
      Printf.eprintf "[KO] check_item : items_by_owner (error : %s)\n%!" @@
      Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_all_items () >|= begin function
    | Ok nft_items ->
      if nft_item_exists nft_items then
        Printf.eprintf "[OK] check_item : all_items\n%!"
      else
        Printf.eprintf "[KO] check_item : all_items\n%!"
    | Error err ->
      Printf.eprintf "[KO] check_item : all_items (error : %s)\n%!" @@
      Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_ownership_by_id it.it_collection (Int64.to_string it.it_token_id) it.it_owner.tz1 >|= begin function
    | Ok nft_ownership ->
      if check_nft_ownership nft_ownership it then
        Printf.eprintf "[OK] check_item : ownership_by_id\n%!"
      else
        Printf.eprintf "[KO] check_item : ownership_by_id\n%!"
    | Error err ->
      Printf.eprintf "[KO] check_item : ownership_by_id (error : %s)\n%!" @@
      Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_ownerships_by_item it.it_collection (Int64.to_string it.it_token_id) >|= begin function
    | Ok nft_ownerships ->
      if nft_ownership_exists nft_ownerships then
        Printf.eprintf "[OK] check_item : ownerships_by_item\n%!"
      else
        Printf.eprintf "[KO] check_item : ownerships_by_item\n%!"
    | Error err ->
      Printf.eprintf "[KO] check_item : ownerships_by_item (error : %s)\n%!" @@
      Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_all_ownerships () >|= begin function
    | Ok nft_ownerships ->
      if nft_ownership_exists nft_ownerships then
        Printf.eprintf "[OK] check_item : all_ownerships\n%!"
      else
        Printf.eprintf "[KO] check_item : all_ownerships\n%!"
    | Error err ->
      Printf.eprintf "[KO] check_item : all_ownerships (error : %s)\n%!" @@
      Api.Errors.string_of_error err
  end
(* get_nft_item_meta_by_id ;
 * get_nft_items_by_creator ; *)

let check_nft_activity ?(from=false) activity it =
  (* Printf.eprintf "check_nft_activity %s %s %s %s\n%!" kt1 owner amount tid ; *)
  if from then
    activity.nft_activity_contract = it.it_collection &&
    activity.nft_activity_owner <> it.it_owner.tz1 &&
    activity.nft_activity_token_id = Int64.to_string it.it_token_id
  else
    activity.nft_activity_contract = it.it_collection &&
    activity.nft_activity_owner = it.it_owner.tz1 &&
    activity.nft_activity_value = (match it.it_kind with `nft -> "1" | `mt a -> Int64.to_string a) &&
    activity.nft_activity_token_id = Int64.to_string it.it_token_id

let check_mint_activity it =
  let owner = it.it_owner.tz1 in
  let kt1 = it.it_collection in
  let tid = Int64.to_string it.it_token_id in
  let mint_activity_exists activities =
    List.exists (fun act -> match act with
        | NftActivityMint elt -> check_nft_activity elt it
        | _ -> false) activities in
  (* MINT ONLY ACTIVITIES *)
  call_get_nft_activities_by_item_mint kt1 tid >|= begin function
  | Ok nft_activities ->
    if mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_item_mint\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_item_mint (no matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_item_mint (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_activities_by_user_mint owner >|= begin function
  | Ok nft_activities ->
    if mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_user_mint\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_user_mint (no matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_user_mint (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_activities_by_collection_mint kt1 >|= begin function
  | Ok nft_activities ->
    if mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_collection_mint\n%!"
    else
      Printf.eprintf
        "[KO] API: get_nft_activities_by_collection_mint (no matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_collection_mint (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_all_activities_mint () >|= begin function
  | Ok nft_activities ->
    if mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_all_activities_mint\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_all_activities_mint (no matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_all_activities_mint (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->

  (* ALL ACTIVITIES *)
  call_get_nft_activities_by_item_all kt1 tid >|= begin function
  | Ok nft_activities ->
    if mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_item_all\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_item_all (no matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_item_all (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_activities_by_user_all owner >|= begin function
  | Ok nft_activities ->
    if mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_user_all\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_user_all (no matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_user_all (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_activities_by_collection_all kt1 >|= begin function
  | Ok nft_activities ->
    if mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_collection_all\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_collection_all (no matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_collection_all (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_all_activities_all () >|= begin function
  | Ok nft_activities ->
    if mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_all_activities_all\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_all_activities_all (no matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_all_activities_all (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->

  (* BURN ONLY ACTIVITIES *)
  call_get_nft_activities_by_item_burn kt1 tid >|= begin function
  | Ok nft_activities ->
    if not @@ mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_item_burn\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_item_burn (matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_item_burn (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_activities_by_user_burn owner >|= begin function
  | Ok nft_activities ->
    if not @@ mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_user_burn\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_user_burn (matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_user_burn (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_activities_by_collection_burn kt1 >|= begin function
  | Ok nft_activities ->
    if not @@ mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_collection_burn\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_collection_burn (matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_collection_burn (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_all_activities_burn () >|= begin function
  | Ok nft_activities ->
    if not @@ mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_all_activities_burn\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_all_activities_burn (matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_all_activities_burn (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->

  (* TRANSFER ONLY ACTIVITIES *)
  call_get_nft_activities_by_item_transfer kt1 tid >|= begin function
  | Ok nft_activities ->
    if not @@ mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_item_transfer\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_item_transfer (matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_item_transfer (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_activities_by_user_transfer owner >|= begin function
  | Ok nft_activities ->
    if not @@ mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_user_transfer\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_user_transfer (matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_user_transfer (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_activities_by_collection_transfer kt1 >|= begin function
  | Ok nft_activities ->
    if not @@ mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_collection_transfer\n%!"
    else
      Printf.eprintf
        "[KO] API: get_nft_activities_by_collection_transfer (matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_collection_transfer (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_all_activities_transfer () >|= begin function
  | Ok nft_activities ->
    if not @@ mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_all_activities_transfer\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_all_activities_transfer (matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_all_activities_transfer (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end

let check_transfer_activity ?(from=false) it =
  let owner = it.it_owner.tz1 in
  let kt1 = it.it_collection in
  let tid = Int64.to_string it.it_token_id in
  let transfer_activity_exists activities =
    List.exists (fun act -> match act with
        | NftActivityTransfer {from=addr; elt} ->
          if from then
            check_nft_activity ~from elt {it with it_owner={tz1=addr; edsk=""; edpk=""; alias=""}}
          else check_nft_activity elt it
        | _ -> false) activities in
  (* MINT ONLY ACTIVITIES *)
  call_get_nft_activities_by_item_mint kt1 tid >|= begin function
  | Ok nft_activities ->
    if not @@ transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_item_mint\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_item_mint (matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_item_mint (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_activities_by_user_mint owner >|= begin function
  | Ok nft_activities ->
    if not @@ transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_user_mint\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_user_mint (matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_user_mint (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_activities_by_collection_mint kt1 >|= begin function
  | Ok nft_activities ->
    if not @@ transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_collection_mint\n%!"
    else
      Printf.eprintf
        "[KO] API: get_nft_activities_by_collection_mint (matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_collection_mint (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_all_activities_mint () >|= begin function
  | Ok nft_activities ->
    if not @@ transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_all_activities_mint\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_all_activities_mint (matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_all_activities_mint (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->

  (* ALL ACTIVITIES *)
  call_get_nft_activities_by_item_all kt1 tid >|= begin function
  | Ok nft_activities ->
    if transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_item_all\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_item_all (no matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_item_all (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_activities_by_user_all owner >|= begin function
  | Ok nft_activities ->
    if transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_user_all\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_user_all (no matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_user_all (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_activities_by_collection_all kt1 >|= begin function
  | Ok nft_activities ->
    if transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_collection_all\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_collection_all (no matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_collection_all (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_all_activities_all () >|= begin function
  | Ok nft_activities ->
    if transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_all_activities_all\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_all_activities_all (no matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_all_activities_all (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->

  (* BURN ONLY ACTIVITIES *)
  call_get_nft_activities_by_item_burn kt1 tid >|= begin function
  | Ok nft_activities ->
    if not @@ transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_item_burn\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_item_burn (matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_item_burn (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_activities_by_user_burn owner >|= begin function
  | Ok nft_activities ->
    if not @@ transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_user_burn\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_user_burn (matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_user_burn (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_activities_by_collection_burn kt1 >|= begin function
  | Ok nft_activities ->
    if not @@ transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_collection_burn\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_collection_burn (matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_collection_burn (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_all_activities_burn () >|= begin function
  | Ok nft_activities ->
    if not @@ transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_all_activities_burn\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_all_activities_burn (matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_all_activities_burn (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->

  (* TRANSFER ONLY ACTIVITIES *)
  call_get_nft_activities_by_item_transfer kt1 tid >|= begin function
  | Ok nft_activities ->
    if transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_item_transfer\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_item_transfer (no matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_item_transfer (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_activities_by_user_transfer owner >|= begin function
  | Ok nft_activities ->
    if transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_user_transfer\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_user_transfer (no matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_user_transfer (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_activities_by_collection_transfer kt1 >|= begin function
  | Ok nft_activities ->
    if transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_collection_transfer\n%!"
    else
      Printf.eprintf
        "[KO] API: get_nft_activities_by_collection_transfer (no matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_activities_by_collection_transfer (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end >>= fun () ->
  call_get_nft_all_activities_transfer () >|= begin function
  | Ok nft_activities ->
    if transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_all_activities_transfer\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_all_activities_transfer (no matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf "[KO] API: get_nft_all_activities_transfer (error : %s)\n%!" @@
    Api.Errors.string_of_error err
  end

let mint_check_random ?verbose ?with_token_id collections =
  random_mint ?with_token_id collections >>=? fun item ->
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  Unix.sleep 6 ;
  check_item ?verbose item >>= fun () ->
  check_mint_activity item >>= fun () ->
  Lwt.return_ok item

let burn_check_random items =
  let> (items, updated_item) = random_burn items in
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  Unix.sleep 6 ;
  let> () = match updated_item with
    | None -> Lwt.return_unit (* todo: check if amount is 0 *)
    | Some it -> check_item it in
  Lwt.return_ok items

let transfer_check_random items =
  Printf.eprintf "before [%s]\n%!" @@ String.concat " ; " @@
  List.map (fun it -> Printf.sprintf "%Ld:%s" it.it_token_id it.it_owner.tz1) items ;
  let> (items, updated_item, new_item) = random_transfer items in
  Printf.eprintf "after [%s]\n%!" @@ String.concat " ; " @@
  List.map (fun it -> Printf.sprintf "%Ld:%s" it.it_token_id it.it_owner.tz1) items ;
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  Unix.sleep 6 ;
  let> () = match updated_item with
    | None -> Lwt.return_unit (* todo: check if amount is 0 *)
    | Some it ->
      let> () = check_item it in
      check_transfer_activity ~from:true it in
  let> () = check_item new_item in
  check_transfer_activity new_item >>= fun () ->
  Lwt.return_ok items

let mints_check_random ?verbose ?(max=30) ?with_token_id collections =
  let nb = Random.int max + 1 in
  let rec aux acc cpt =
    if cpt = 0 then Lwt.return_ok acc
    else
      mint_check_random ?verbose ?with_token_id collections >>=? fun item ->
      aux (item :: acc) (cpt - 1) in
  aux [] nb

let burns_check_random ?(max=30) items =
  let nb = Random.int max + 1 in
  let rec aux acc cpt =
    if cpt = 0 then Lwt.return_ok acc
    else
      burn_check_random items >>=? fun item ->
      aux (item :: acc) (cpt - 1) in
  aux [] nb

let transfers_check_random ?(max=30) items =
  let nb = Random.int max + 1 in
  let rec aux acc cpt =
    if cpt = 0 then Lwt.return_ok acc
    else
      transfer_check_random items >>=? fun items ->
      aux (items @ acc) (cpt - 1) in
  aux [] nb

let check_collection co =
  let owner = co.col_admin.tz1 in
  let alias = co.col_alias in
  let kt1 = co.col_kt1 in
  Printf.eprintf "Checking new collection %s(%s) of %s\n%!" alias kt1 owner ;
  let collection_exists collections =
    List.find_all (fun c ->
        c.nft_collection_id = kt1 &&
        c.nft_collection_owner = Some owner) collections in
  let>? c = call_get_nft_collection_by_id kt1 in
  begin
    if c.nft_collection_id = kt1 &&
       c.nft_collection_owner = Some owner then
      Printf.eprintf "[Ok] API: get_nft_collection_by_id %s\n%!" alias
    else
      Printf.eprintf "[KO] API: get_nft_collection_by_id %s (no matching collection)\n%!" alias
  end ;
  call_search_nft_collections_by_owner owner >>=? fun c ->
  begin match collection_exists c with
    | [ _ ] -> Printf.eprintf "[OK] API: search_nft_collection_by_owner %s\n%!" alias
    | [] ->
      Printf.eprintf "[KO] API: search_nft_collection_by_owner %s (no matching collection)\n%!" alias
    | _ ->
      Printf.eprintf
        "[KO] API: search_nft_collection_by_owner %s (more than 1 matching collection)\n%!" alias
  end ;
  call_search_nft_all_collections () >|=? fun c ->
  begin match collection_exists c with
  | [ _ ] -> Printf.eprintf "[OK] API: search_nft_all_collection %s\n%!" alias
  | [] ->
    Printf.eprintf "[KO] API: search_nft_all_collection %s (no matching collection)\n%!" alias
  | _ ->
    Printf.eprintf
      "[KO] API: search_nft_all_collection %s (more than 1 matching collection)\n%!" alias
  end

let deploy_check_random_collections ?royalties ?(max=10) () =
  let nb = Random.int max + 1 in
  Printf.eprintf "Deploying and checking %d collection(s)\n%!" nb ;
  let collections = create_collections ?royalties nb in
  let> new_collections = Lwt_list.map_s deploy_collection collections in
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  let> () = Lwt_unix.sleep 6. in
  let> res = Lwt_list.map_s check_collection new_collections in
  Lwt_list.iter_s (function
      | Ok _ -> Lwt.return_unit
      | Error err ->
        Lwt.return @@
        Printf.eprintf "[KO] API: check_collection (error : %s)\n%!" @@
        Api.Errors.string_of_error err)
    res >>= fun () ->
  Lwt.return new_collections

let reset_db () =
  Printf.eprintf "Resetting db\n%!" ;
  let c, o, e = sys_command "make drop" in
  if c <> 0 then failwith ("failure when resetting db : log " ^ o ^ " & " ^ e)
  else
    let c, o, e =  sys_command "make" in
    if c <> 0 then failwith ("failure when resetting db : log " ^ o ^ " & " ^ e)

let start_api kafka_config =
  let prog = "./_bin/api" in
  let args =
    [ prog ] @
    match kafka_config with
    | None -> []
    | Some f ->  [ "--kafka-config" ; f ] in
  let args = Array.of_list args in
  let stdout, fn_out, stderr, fn_err = create_descr2 "api" in
  let pid = create_process ~stdout ~stderr prog args in
  Printf.eprintf "API STARTED (out %s, err %s)\n%!" fn_out fn_err ;
  pid

let get_head () =
  EzReq_lwt.get
    (EzAPI.URL "https://api.granadanet.tzkt.io/v1/blocks/count")

let make_config admin_wallet validator exchange_v2 royalties contracts ft_contracts
    kafka_broker kafka_username kafka_password =
  let open Crawlori.Config in
  get_head () >>= function
  | Error (code, str) ->
    failwith (Printf.sprintf "get_head error %d %s" code (Option.value ~default:"" str))
  | Ok level ->
    let config = {
      nodes = [ "https://granadanet.smartpy.io" ] ;
      start =  Some Int32.(sub (of_string level) 30l)  ;
      db_kind = `pg ;
      step_forward = 30 ;
      accounts = None ;
      sleep = 5. ;
      forward = None ;
      confirmations_needed = 5l ;
      verbose = 0 ;
      register_kinds = None ;
      allow_no_metadata = false ;
      extra = {
        admin_wallet ; validator ; exchange_v2 ; royalties; contracts; ft_contracts;
      } ;
    } in
    let temp_fn = Filename.temp_file "config" "" in
    let json = EzEncoding.construct (Cconfig.enc Rtypes.config_enc) config in
    Printf.eprintf "Crawler config:\n%s\n\n%!" json ;
    let c = open_out temp_fn in
    output_string c json ;
    close_out c ;
    if kafka_broker = "" || kafka_username = "" then
      Lwt.return (temp_fn, None)
    else
      let kafka_config = { kafka_broker; kafka_username; kafka_password; } in
      let kafka_temp_fn = Filename.temp_file "kafka_config" "" in
      let kafka_json = EzEncoding.construct Rtypes.kafka_config_enc kafka_config in
      Printf.eprintf "Crawler kafka config:\n%s\n\n%!" kafka_json ;
      let c = open_out kafka_temp_fn in
      output_string c kafka_json ;
      close_out c ;
      Lwt.return (temp_fn, Some kafka_temp_fn)


let start_crawler admin_wallet validator exchange_v2 royalties
    contracts ft_contracts kafka_broker kafka_username kafka_password =
  make_config
    admin_wallet validator exchange_v2 royalties contracts ft_contracts
    kafka_broker kafka_username kafka_password  >>= fun (config, kafka_config) ->
  let prog = "./_bin/crawler" in
  let args =
    [ prog ; config ] @
    match kafka_config with
    | None -> []
    | Some f ->  [ "--kafka-config" ; f ] in
  let args = Array.of_list args in
  let stdout, fn_out, stderr, fn_err = create_descr2 "crawler" in
  let pid = create_process ~stdout ~stderr prog args in
  Printf.eprintf "CRAWLER STARTED %d (out %S err %S)\n%!" pid fn_out fn_err ;
  Lwt.return (pid, kafka_config)

let setup_test_env ?(spawn_exchange_infra=false) () =
  reset_db () ;
  if spawn_exchange_infra then
    let r_alias, _r_source = create_royalties () in
    let r_kt1 = find_kt1 r_alias in
    Printf.eprintf "New royalties %s\n%!" r_kt1 ;
    let ex_alias, ex_admin, _ex_receiver = create_exchange () in
    let ex_kt1 = find_kt1 ex_alias in
    Printf.eprintf "New exchange %s\n%!" ex_kt1 ;
    let v_alias, _v_source = create_validator ~exchange:ex_kt1 ~royalties:r_kt1 in
    let v_kt1 = find_kt1 v_alias in
    Printf.eprintf "New validator %s\n%!" v_kt1 ;
    start_crawler "" v_kt1 ex_kt1 r_kt1 SMap.empty SMap.empty "" "" ""
    >>= fun (cpid, kafka_config) ->
    api_pid := Some (start_api kafka_config) ;
    crawler_pid := Some cpid ;
    set_validator v_kt1 ex_admin ex_kt1 >>= fun () ->
    Printf.eprintf "Waiting 6sec to let crawler catch up...\n%!" ;
    Lwt_unix.sleep 6.
  else
    start_crawler ""
      validator exchange_v2 royalties
      SMap.empty SMap.empty "" "" ""
    >>= fun (cpid, kafka_config) ->
    api_pid := Some (start_api kafka_config) ;
    crawler_pid := Some cpid ;
    Printf.eprintf "Waiting 6sec to let crawler catch up...\n%!" ;
    Lwt_unix.sleep 6.

let clean_test_env () =
  begin match !api_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
  match !crawler_pid with None -> () | Some pid -> Unix.kill pid 9

let transfer_test () =
  let c = create_collection () in
  let> c = deploy_collection c in
  let>? () = check_collection c in
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  let> () = Lwt_unix.sleep 6. in
  let>? item1 = mint_one_with_token_id_from_api c in
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  let> () = Lwt_unix.sleep 6. in
  let> () = check_item item1 in
  let>? item2 = mint_one_with_token_id_from_api c in
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  let> () = Lwt_unix.sleep 6. in
  let> () = check_item item2 in
  transfers_check_random ~max:2 [item1 ; item2] >>= begin function
    | Error err ->
      Lwt.return_ok @@
      Printf.eprintf "transfer error %s" @@
      Api.Errors.string_of_error err
    | Ok _items -> Lwt.return_ok ()
  end

let burn_test () =
  let c = create_collection () in
  let> c = deploy_collection c in
  let>? () = check_collection c in
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  let> () = Lwt_unix.sleep 6. in
  let>? item1 = mint_one_with_token_id_from_api c in
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  let> () = Lwt_unix.sleep 6. in
  let> () = check_item item1 in
  let> new_item1 = burn item1 in
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  let> () = Lwt_unix.sleep 6. in
  let> () = match new_item1 with
    | None -> check_not_item item1
    | Some it -> check_item it in
  Lwt.return_ok ()

let sell_nft_for_nft ?salt collection item1 item2 =
  match order_form_from_items ?salt collection item1 item2 with
  | Error _err -> Lwt.fail_with "order_from"
  | Ok form -> call_upsert_order form

let sell_nft_for_tezos ?(salt=0) collection item1 amount =
  let take = { asset_type = ATXTZ ; asset_value = string_of_int amount } in
  match sell_order_form_from_item ~salt collection item1 take with
  | Error _err -> Lwt.fail_with "order_from"
  | Ok form -> call_upsert_order form

let sell_nft_for_lugh ?(salt=0) collection item1 amount =
  let lugh = ATNFT { asset_contract = lugh_contract ; asset_token_id = "0" } in
  let take = { asset_type = lugh ; asset_value = string_of_int amount } in
  match sell_order_form_from_item ~salt collection item1 take with
  | Error _err -> Lwt.fail_with "order_from"
  | Ok form -> call_upsert_order form

let buy_nft_for_tezos ?(salt=0) collection maker item1 amount =
  let make = { asset_type = ATXTZ ; asset_value = string_of_int amount } in
  match buy_order_form_from_item ~salt collection item1 maker make with
  | Error _err -> Lwt.fail_with "order_from"
  | Ok form -> call_upsert_order form

let buy_nft_for_lugh ?(salt=0) collection maker item1 amount =
  let lugh = ATNFT { asset_contract = lugh_contract ; asset_token_id = "0" } in
  let make = { asset_type = lugh ; asset_value = string_of_int amount } in
  match buy_order_form_from_item ~salt collection item1 maker make with
  | Error _err -> Lwt.fail_with "order_from"
  | Ok form -> call_upsert_order form

let get_source_from_item ((owner, owner_sk), _amount, _token_id, _royalties, _metadata) =
  (owner, owner_sk)

let get_token_id_from_item (_owner, _amount, token_id, _royalties, _metadata) =
  token_id

let wait_next_block () =
  let rec aux level0 =
    Db.get_level () >>= function
    | Ok level ->
      Printf.eprintf "wait_next_block level0 %d level %d\n%!" level0 level ;
      if level <> level0 then Lwt.return_unit
      else
        Lwt_unix.sleep 20. >>= fun () ->
        aux level0
    | Error err ->
      Lwt.return @@ Format.eprintf "ERROR %s\n%!" @@ Crp.string_of_error err
  in
  Db.get_level () >>= function
  | Error err ->
    Lwt.return @@ Format.eprintf "wait_next_block error %s\n%!" @@ Crp.string_of_error err
  | Ok level ->
    aux level

let match_orders_nft () =
  reset_db () ;
  let r_alias, _r_source = create_royalties () in
  let r_kt1 = find_kt1 r_alias in
  Printf.eprintf "New royalties %s\n%!" r_kt1 ;
  let ex_alias, ex_admin, _ex_receiver = create_exchange () in
  let ex_kt1 = find_kt1 ex_alias in
  Printf.eprintf "New exchange %s\n%!" ex_kt1 ;
  let v_alias, _v_source = create_validator ~exchange:ex_kt1 ~royalties:r_kt1 in
  let v_kt1 = find_kt1 v_alias in
  Printf.eprintf "New validator %s\n%!" v_kt1 ;
  start_crawler "" v_kt1 ex_kt1 r_kt1 SMap.empty SMap.empty "" "" "" >>= fun (cpid, kafka_config) ->
  api_pid := Some (start_api kafka_config) ;
  crawler_pid := Some cpid ;
  set_validator v_kt1 ex_admin ex_kt1 >>= fun () ->
  Printf.eprintf "Waiting 6sec to let crawler catch up...\n%!" ;
  Lwt_unix.sleep 6. >>= fun () ->
  let c = create_collection ~royalties:r_kt1 () in
  let> c = deploy_collection c in
  let>? () = check_collection c in
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  let> () = Lwt_unix.sleep 6. in
  let>? item1 = mint_one_with_token_id_from_api c in
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  let> () = Lwt_unix.sleep 6. in
  let> () = check_item item1 in
  let> () = update_operators_for_all ex_kt1 item1.it_owner item1.it_collection in
  let>? item2 = mint_one_with_token_id_from_api ~diff:item1.it_owner.tz1 c in
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  let> () = Lwt_unix.sleep 6. in
  let> () = check_item item2 in
  let> () = update_operators_for_all ex_kt1 item2.it_owner item2.it_collection in
  (* let tid = get_token_id_from_item item1 in *)
  let>? order1 = sell_nft_for_nft c.col_kt1 item1 item2 in
  (* TODO : check order *)
  let>? order2 = sell_nft_for_nft ~salt:1 c.col_kt1 item2 item1 in
  (* TODO : check order *)
  let> r = match_orders ~source:item1.it_owner ~contract:ex_kt1 order1 order2 in
  let> () = match r with
    | Error err ->
      Printf.eprintf "match_orders error %s" @@ Tzfunc.Rp.string_of_error err ;
      Lwt.return_unit
    | Ok op_hash ->
    Printf.eprintf "HASH = %s\n%!" op_hash ;
    Printf.eprintf "Waiting next block...\n%!" ;
    let> () = wait_next_block () in
    Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
    let> () = Lwt_unix.sleep 6. in
    let> () = check_item {item2 with it_owner = item2.it_owner} in
    check_item {item1 with it_owner = item2.it_owner} in
  begin match !api_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
  begin match !crawler_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
  Lwt.return_ok ()

let match_orders_tezos () =
  reset_db () ;
  let r_alias, _r_source = create_royalties () in
  let r_kt1 = find_kt1 r_alias in
  Printf.eprintf "New royalties %s\n%!" r_kt1 ;
  let ex_alias, ex_admin, _ex_receiver = create_exchange () in
  let ex_kt1 = find_kt1 ex_alias in
  Printf.eprintf "New exchange %s\n%!" ex_kt1 ;
  let v_alias, _v_source = create_validator ~exchange:ex_kt1 ~royalties:r_kt1 in
  let v_kt1 = find_kt1 v_alias in
  Printf.eprintf "New validator %s\n%!" v_kt1 ;
  start_crawler "" v_kt1 ex_kt1 r_kt1 SMap.empty SMap.empty "" "" "" >>= fun (cpid, kafka_config) ->
  api_pid := Some (start_api kafka_config) ;
  crawler_pid := Some cpid ;
  set_validator v_kt1 ex_admin ex_kt1 >>= fun () ->
  Printf.eprintf "Waiting 6sec to let crawler catch up...\n%!" ;
  Lwt_unix.sleep 6. >>= fun () ->
  let c = create_collection ~royalties:r_kt1 () in
  let> c = deploy_collection c in
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  Lwt_unix.sleep 6. >>= fun () ->
  let>? () = check_collection c in
  let>? item1 = mint_one_with_token_id_from_api c in
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  let> () = Lwt_unix.sleep 6. in
  let> () = check_item item1 in
  let> () = update_operators_for_all ex_kt1 item1.it_owner c.col_kt1 in
  let>? order1 = sell_nft_for_tezos ~salt:1 c.col_kt1 item1 1 in
  (* TODO : check order *)
  let source2 = generate_address ~diff:item1.it_owner.tz1 () in
  let>? order2 = buy_nft_for_tezos c.col_kt1 source2 item1 1 in
  (* TODO : check order *)
  begin match_orders ~amount:1L ~source:source2 ~contract:ex_kt1 order2 order1 >>= function
    | Error err ->
      Printf.eprintf "match_orders error %s" @@ Tzfunc.Rp.string_of_error err ;
      Lwt.return_unit
  | Ok op_hash ->
      Printf.eprintf "HASH = %s\n%!" op_hash ;
      Printf.eprintf "Waiting next block...\n%!" ;
      wait_next_block () >>= fun () ->
      Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
      Lwt_unix.sleep 6. >>= fun () ->
      (* TODO : check_item not *)
      check_item {item1 with it_owner = source2}
      (* check_orders *)
  end >>= fun () ->
  begin match !api_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
  begin match !crawler_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
  Lwt.return_ok ()

let match_orders_lugh () =
  reset_db () ;
  let r_kt1 = royalties in
  Printf.eprintf "Royalties %s\n%!" r_kt1 ;
  let ex_kt1 = exchange_v2 in
  Printf.eprintf "Exchange %s\n%!" ex_kt1 ;
  let v_kt1 = validator in
  Printf.eprintf "Validator %s\n%!" v_kt1 ;
  let>  (cpid, kafka_config) = start_crawler "" v_kt1 ex_kt1 r_kt1 SMap.empty
      (SMap.singleton "KT1HT3EbSPFA1MM2ZiMThB6P6Kky5jebNgAx"
         {ft_kind=Lugh; ft_crawled=true; ft_id=Z.of_int 94594}) "" "" "" in
  api_pid := Some (start_api kafka_config) ;
  crawler_pid := Some cpid ;
  Printf.eprintf "Waiting 30sec to let crawler catch up...\n%!" ;
  Lwt_unix.sleep 30. >>= fun () ->
  let contract =  "KT1KvxhtWWhEDQJjH6pENJA8HN5UjBLGHYSg" in
  let source = by_alias "rarible1" in
  let c = {
    col_kt1 = contract; col_alias = contract; col_kind=`nft;
    col_admin=source; col_source=source; col_royalties_contract=""; col_metadata="" } in
  (* let (admin, source, contract, royalties, uri) =
   *   create_collection ~royalties:r_kt1 () in
   * let> (admin, contract, source, _royalties) =
   *   deploy_ubi_collection admin source contract royalties uri in *)
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  Lwt_unix.sleep 6. >>= fun () ->
  (* let>? () = check_collection admin contract source in *)
  let>? item1 = mint_ubi_with_token_id_from_api c in
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  let> () = Lwt_unix.sleep 6. in
  let> () = check_item item1 in
  let royalties = generate_royalties () in
  let> () = set_royalties item1.it_token_id royalties item1.it_owner r_kt1 in
  let> () = update_operators_for_all ex_kt1 item1.it_owner contract in
  let>? order1 = sell_nft_for_lugh ~salt:1 contract item1 1 in
  (* TODO : check order *)
  let source2 = generate_address ~alias:"rarible1" () in
  let>? order2 = buy_nft_for_lugh contract source2 item1 1 in
  (* TODO : check order *)
  begin match_orders ~amount:1L ~source:source2 ~contract:ex_kt1 order2 order1 >>= function
    | Error err ->
      Printf.eprintf "match_orders error %s" @@ Tzfunc.Rp.string_of_error err ;
      Lwt.return_unit
  | Ok op_hash ->
      Printf.eprintf "HASH = %s\n%!" op_hash ;
      Printf.eprintf "Waiting next block...\n%!" ;
      wait_next_block () >>= fun () ->
      Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
      Lwt_unix.sleep 6. >>= fun () ->
      (* TODO : check_item not *)
      check_item {item1 with it_owner = source2}
      (* check_orders *)
  end >>= fun () ->
  begin match !api_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
  begin match !crawler_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
  Lwt.return_ok ()

let fill_orders_db r_kt1 ex_kt1 =
  let c = create_collection ~royalties:r_kt1 () in
  let> c = deploy_collection c in
  let>? () = check_collection c in
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  Lwt_unix.sleep 6. >>= fun () ->
  let>? item1 = mint_one_with_token_id_from_api c in
  let>? item2 = mint_one_with_token_id_from_api c in
  let>? item3 = mint_one_with_token_id_from_api c in
  let>? item4 = mint_one_with_token_id_from_api c in
  let>? item5 = mint_one_with_token_id_from_api c in
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  let> () = Lwt_unix.sleep 6. in
  let> () = check_item item1 in
  let> () = check_item item2 in
  let> () = check_item item3 in
  let> () = check_item item4 in
  let> () = check_item item5 in
  let> () = update_operators_for_all ex_kt1 item1.it_owner c.col_kt1 in
  (* SELL ORDERS *)
  let>? _sell1_1 = sell_nft_for_tezos ~salt:1 c.col_kt1 item1 5 in
  let> () = Lwt_unix.sleep 1. in
  let>? _sell2 = sell_nft_for_tezos ~salt:1 c.col_kt1 item2 1 in
  let> () = Lwt_unix.sleep 1. in
  let>? _sell3 = sell_nft_for_tezos ~salt:1 c.col_kt1 item3 1 in
  let> () = Lwt_unix.sleep 1. in
  let>? _sell4 = sell_nft_for_tezos ~salt:1 c.col_kt1 item4 1 in
  let> () = Lwt_unix.sleep 1. in
  let>? _sell5 = sell_nft_for_tezos ~salt:1 c.col_kt1 item5 1 in
  (* BIDS ORDERS *)
  let source2 = generate_address ~diff:item1.it_owner.tz1 () in
  let>? _buy1_1 = buy_nft_for_tezos c.col_kt1 source2 item1 1 in
  let> () = Lwt_unix.sleep 1. in
  let source3 = generate_address ~diff:item2.it_owner.tz1 () in
  let>? _buy1_2 = buy_nft_for_tezos c.col_kt1 source3 item1 1 in
  let> () = Lwt_unix.sleep 1. in
  let>? _buy4 = buy_nft_for_tezos c.col_kt1 source2 item4 1 in
  let> () = Lwt_unix.sleep 1. in
  Lwt.return_ok ()

let fill_orders () =
  reset_db () ;
  let r_alias, _r_source = create_royalties () in
  let r_kt1 = find_kt1 r_alias in
  Printf.eprintf "New royalties %s\n%!" r_kt1 ;
  let ex_alias, ex_admin, _ex_receiver = create_exchange () in
  let ex_kt1 = find_kt1 ex_alias in
  Printf.eprintf "New exchange %s\n%!" ex_kt1 ;
  let v_alias, _v_source = create_validator ~exchange:ex_kt1 ~royalties:r_kt1 in
  let v_kt1 = find_kt1 v_alias in
  Printf.eprintf "New validator %s\n%!" v_kt1 ;
  start_crawler "" v_kt1 ex_kt1 r_kt1 SMap.empty SMap.empty "" "" "" >>= fun (cpid, kafka_config) ->
  api_pid := Some (start_api kafka_config) ;
  crawler_pid := Some cpid ;
  set_validator v_kt1 ex_admin ex_kt1 >>= fun () ->
  Printf.eprintf "Waiting 6sec to let crawler catch up...\n%!" ;
  Lwt_unix.sleep 6. >>= fun () ->
  fill_orders_db r_kt1 ex_kt1 >>=? fun () ->
  fill_orders_db r_kt1 ex_kt1 >>=? fun () ->
  fill_orders_db r_kt1 ex_kt1 >>=? fun () ->
  (* TODO : check order *)

  begin match !api_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
  begin match !crawler_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
  Lwt.return_ok ()

let cancel_order () =
  reset_db () ;
  let r_alias, _r_source = create_royalties () in
  let r_kt1 = find_kt1 r_alias in
  Printf.eprintf "New royalties %s\n%!" r_kt1 ;
  let ex_alias, ex_admin, _ex_receiver = create_exchange () in
  let ex_kt1 = find_kt1 ex_alias in
  Printf.eprintf "New exchange %s\n%!" ex_kt1 ;
  let v_alias, _v_source = create_validator ~exchange:ex_kt1 ~royalties:r_kt1 in
  let v_kt1 = find_kt1 v_alias in
  Printf.eprintf "New validator %s\n%!" v_kt1 ;
  start_crawler "" v_kt1 ex_kt1 r_kt1 SMap.empty SMap.empty "" "" "" >>= fun (cpid, kafka_config) ->
  api_pid := Some (start_api kafka_config) ;
  crawler_pid := Some cpid ;
  set_validator v_kt1 ex_admin ex_kt1 >>= fun () ->
  Printf.eprintf "Waiting 6sec to let crawler catch up...\n%!" ;
  Lwt_unix.sleep 6. >>= fun () ->
  let c = create_collection ~royalties:r_kt1 () in
  let> c = deploy_collection c in
  let>? () = check_collection c in
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  let> () = Lwt_unix.sleep 6. in
  let>? item1 = mint_one_with_token_id_from_api c in
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  let> () = Lwt_unix.sleep 6. in
  let> () = check_item item1 in
  let>? order = sell_nft_for_tezos ~salt:1 c.col_kt1 item1 1 in
  (* TODO : check order *)
  begin cancel_order ~source:item1.it_owner ~contract:ex_kt1 order >>= function
    | Error err ->
      Printf.eprintf "cancel_order error %s" @@ Tzfunc.Rp.string_of_error err ;
      Lwt.return_unit
    | Ok op_hash ->
      Printf.eprintf "HASH = %s\n%!" op_hash ;
      Printf.eprintf "Waiting next block...\n%!" ;
      wait_next_block () >>= fun () ->
      Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
      Lwt_unix.sleep 6.
      (* check_orders *)
  end >>= fun () ->
  begin match !api_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
  begin match !crawler_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
  Lwt.return_ok ()

(** main *)

let actions = [
  ["call_upsert_order"], "call upsert endpoint with randomly generated order";
  ["update_order_make_value <order_hash> <new_make_value>"], "change order's make value";
  ["update_order_take_value <order_hash> <new_take_value>"], "change order's take value";
  (* ["update_order_date <order_hash> <start_date> <end_date>"], "change order's start date and end date"; *)
  ["update_order_taker <order_hash> <new_taker>"], "change order's taker (should fail)";
  ["create_collection <royalties_contract?>"], "create collection (optionnal royalties contract)" ;
  ["mint_nft <contract_alias> <dest>"], "mint an nft" ;
  ["mint_multi <contract_alias> <dest> <amount>"], "mint amount nfts in contract for dest" ;
  ["transfer_nft <contract_alias> <token_id> <dest>"], "transfer a nft" ;
  ["transfer_multi <contract_alias> <token_id> <dest> <amount>"], "transfer amount nft" ;
  ["run_test"], "will run some test (orig, mint, burn and trasnfer (will erase rarible db)";
  ["match_order_nft_bid"], "create sell orders then exchange the nfts (will erase rarible db)" ;
  ["match_order_tezos_bid"], "create sell orders then buy the nft for one tezos (will erase rarible db)" ;
  ["cancel_order"], "create sell orders then cancel it (will erase rarible db)" ;
  ["fill_orders"], "make random sell/bid orders (will erase rarible db)";
]

let usage =
  "usage: " ^ (Filename.basename Sys.executable_name) ^ " <options> <actions>\nactions:\n  " ^
  (String.concat "\n  " @@ List.map (fun (cmds, descr) ->
       Format.sprintf "- %s -> %s" (String.concat " | " cmds) descr) actions) ^ "\noptions:"

let main () =
  Random.self_init () ;
  let action = ref [] in
  Arg.parse spec (fun s -> action := s :: !action) usage;
  match List.rev !action with
  | [ "call_upsert_order" ] ->
    Lwt_main.run (upsert_order () >>= function
      | Ok _ -> Lwt.return_unit
      | Error err -> Lwt.fail_with @@ Api.Errors.string_of_error err)
  (* | "update_order_make_value" :: hash :: make_value :: [] ->
   *   Lwt_main.run (update_order_make_value hash make_value)
   * | "update_order_take_value" :: hash :: take_value :: [] ->
   *   Lwt_main.run (update_order_take_value hash take_value) *)
  (* | "update_order_date" :: hash :: start_date :: end_date :: [] ->
   *   update_order_date hash start_date end_date *)
  (* | "update_order_taker" :: hash :: taker :: [] ->
   *   Lwt_main.run (update_order_taker hash (Some taker))
   * | [ "create_collection" ] -> ignore @@ create_collection ()
   * | "create_collection" :: royalties :: [] -> ignore @@ create_collection ~royalties () *)
  (* | "mint_token_id" :: contract :: token_id :: [] -> mint contract token_id
   * | "mint" :: contract :: [] -> mint_with_random_token_id contract *)
  (* | "transfer_nft" :: contract :: token_id :: dest :: [] ->
   *   transfer_nft contract token_id dest
   * | "transfer_multi" :: contract :: token_id :: dest :: amount :: [] ->
   *   transfer_multi contract token_id dest amount *)
  | [ "private_nft_transfer" ] ->
    Lwt_main.run (
      Lwt.catch (fun () ->
          setup_test_env () >>= fun () ->
          transfer_test () >>= fun _ ->
          Lwt.return @@ clean_test_env ())
        (fun exn ->
           Printf.eprintf "CATCH %S\n%!" @@ Printexc.to_string exn ;
           Lwt.return @@ clean_test_env ()))
  | [ "private_nft_burn" ] ->
    Lwt_main.run (
      Lwt.catch (fun () ->
          setup_test_env () >>= fun () ->
          burn_test () >>= fun _ ->
          Lwt.return @@ clean_test_env ())
        (fun exn ->
           Printf.eprintf "CATCH %S\n%!" @@ Printexc.to_string exn ;
           Lwt.return @@ clean_test_env ()))
  | [ "private_nft" ] ->
    Lwt_main.run (
      Lwt.catch (fun () ->
          setup_test_env () >>= fun () ->
          transfer_test () >>= fun _ ->
          burn_test () >>= fun _ ->
          Lwt.return @@ clean_test_env ())
        (fun exn ->
           Printf.eprintf "CATCH %S\n%!" @@ Printexc.to_string exn ;
           Lwt.return @@ clean_test_env ()))
  | [ "match_order_nft_bid" ] ->
    Lwt_main.run (
      Lwt.catch (fun () ->
          match_orders_nft () >>= function
          | Ok _ -> Lwt.return_unit
          | Error err ->
            Lwt.fail_with @@ Api.Errors.string_of_error err)
        (fun exn ->
           Printf.eprintf "CATCH %S\n%!" @@ Printexc.to_string exn ;
           begin match !api_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
           begin match !crawler_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
           Lwt.return_unit))
  | [ "match_order_tezos_bid" ] ->
    Lwt_main.run (
      Lwt.catch (fun () ->
          match_orders_tezos () >>= function
          | Ok _ -> Lwt.return_unit
          | Error err ->
            Lwt.fail_with @@ Api.Errors.string_of_error err)
        (fun exn ->
           Printf.eprintf "CATCH %S\n%!" @@ Printexc.to_string exn ;
           begin match !api_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
           begin match !crawler_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
           Lwt.return_unit))
  | [ "match_order_lugh_bid" ] ->
    Lwt_main.run (
      Lwt.catch (fun () ->
          match_orders_lugh () >>= function
          | Ok _ -> Lwt.return_unit
          | Error err ->
            Lwt.fail_with @@ Api.Errors.string_of_error err)
        (fun exn ->
           Printf.eprintf "CATCH %S\n%!" @@ Printexc.to_string exn ;
           begin match !api_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
           begin match !crawler_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
           Lwt.return_unit))
  | [ "fill_orders" ] ->
    Lwt_main.run (
      Lwt.catch (fun () ->
          fill_orders () >>= function
          | Ok _ -> Lwt.return_unit
          | Error err ->
            Lwt.fail_with @@ Api.Errors.string_of_error err)
        (fun exn ->
           Printf.eprintf "CATCH %S\n%!" @@ Printexc.to_string exn ;
           begin match !api_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
           begin match !crawler_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
           Lwt.return_unit))
  | [ "cancel_order" ] ->
    Lwt_main.run (
      Lwt.catch (fun () ->
          cancel_order () >>= function
          | Ok _ -> Lwt.return_unit
          | Error err ->
            Lwt.fail_with @@ Api.Errors.string_of_error err)
        (fun exn ->
           Printf.eprintf "CATCH %S\n%!" @@ Printexc.to_string exn ;
           begin match !api_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
           begin match !crawler_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
           Lwt.return_unit))
  | _ -> Arg.usage spec usage

let _ = main ()
