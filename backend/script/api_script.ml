open Rtypes
open Let
open Utils

let cwd = Sys.getcwd ()
let exe = Sys.argv.(0)

let api = ref "http://localhost:8080"
let sdk = ref false
let endpoint = ref "http://granada.tz.functori.com"

let validator = "KT1Vx7UddodXEVAjvgC2et267JqKSYX7WAr7"
let exchange_v2 = "KT1C5kWbfzASApxCMHXFLbHuPtnRaJXE4WMu"

let config = {
  admin_wallet = "" ;
  exchange_v2 ;
  validator ;
  royalties = "" ;
  ft_fa2 = [];
  ft_fa1 = [];
}

let api_pid = ref None
let crawler_pid = ref None

(* ALIAS * EDPK * EDSK *)
let accounts = [
  "rarible5",
  "edpktjwGH2VwKJkAVztZvr5Gkifg5bKx99GT6wDCctQL6xgRHB3pRc",
  "edsk4XzV1K3Td1fVUhRv33iduTdNCxmHidUsCKRkvK2NgnersFdEUY" ;
  "rarible4",
  "edpkuiqLaC3YvwMQTKezCV9pJs2vjqPxoonMJDBdNqnwQxiMx3ag8h",
  "edsk3LVprL8yNHpVcbLrbaFm25njKkyjJrZEGCweuxqkCh7SiEyH4L" ;
  "rarible3",
  "edpkuDUy4h4y2qqSHDgdid8WxESu3YwaPmWZ42p4G3ZCnE5epgtXhH",
  "edsk49SC61Sb1QYRQQRW7M6SRmWMvjoaVsfCftkdoERv8BENe7ssV4" ;
  "rarible2",
  "edpktoPwmCz9Wbr8BKByJPnasrPq1BfoAVURtAhxpw7WafbktMnkrp",
  "edsk35jq62PmRmRB5vH1rUE5W6wzE7P6sn3r58C3TKcDtnwx6MpFUU" ;
  "rarible1",
  "edpku7dXXEdSPb2nMJMEbGSuPZtPcfRZ8RLpX5FGKZ629ezW1YjaWa" ,
  "edsk2kPLkNyYQi9kqQnh6VTip9MS7c6rEnUastw1BMb1hf9FgDfRBu";
]
let accounts_len = List.length accounts

let fa1_2_contracts = [
  "KT1ENHtWh8umKktxT3wC3HbDjwopuuVmXJvD"
]
let fa1_2_contracts_len = List.length fa1_2_contracts

let fa2_contracts = [
  "KT1BRQ73L3admx2NATrEHuPyy986g8wfgMqp" ;
  "KT1Ch6PstAQG32uNfQJUSL2bf2WvimvY5umk" ;
  "KT1McsKK4Y2GK369M9QQSzjux52EsSkfjcMJ" ;
]
let fa2_contracts_len = List.length fa2_contracts

let origins = [
  "tz1f6TuKe38VPURr6gA1xiQq9dzuVuzNZoP6" ;
  "tz1KiZygjrVaS1fjs9iW4YSKNiqoopHK8Hdj"
]
let origins_len = List.length origins

let royalties_contracts = [
  "KT1EZBkhGkRDxP6N1opkN8ULvnssG7f3PWoH" ;
  "KT1VCEefbNuB8iBuuu2tganKmMu4ex548ewG"
]
let royalties_contracts_len = List.length royalties_contracts

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

let ko_colored = Fmt.styled (`Fg (`Hi `Red)) Format.pp_print_string
let ok_colored = Fmt.styled (`Fg `Green) Format.pp_print_string
(* let print_ok msg = Printf.eprintf "%a %s" ok_colored "[Ok]" msg *)


let by_pk i =
  try
    List.find (fun (_, pk, _) -> pk = i) accounts
  with Not_found ->
    Printf.eprintf "Not_found by_alias %s\n%!" i ;
    raise Not_found

let by_sk i =
  try
    List.find (fun (_, _, sk) -> sk = i) accounts
  with Not_found ->
    Printf.eprintf "Not_found by_sk %s\n%!" i ;
    raise Not_found
let by_alias i =
  try
    List.find (fun (alias, _, _) -> alias = i) accounts
  with Not_found ->
    Printf.eprintf "Not_found by_alias %s\n%!" i ;
    raise Not_found

let rec sys_command ?(verbose=0) ?(retry=0) c =
  if verbose > 0 then Printf.eprintf "cmd: %s\n%!" c ;
  let oldstdout = Unix.dup Unix.stdout in
  let oldstderr = Unix.dup Unix.stderr in
  let out_temp_fn = Filename.temp_file "sys_command" "stdout_redirect" in
  let err_temp_fn = Filename.temp_file "sys_command" "stderr_redirect" in
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

let generate_option f =
  if Random.bool () then
    Some (f ())
  else None

let generate_origin () =
  List.nth origins (Random.int origins_len)

let rec generate_address ?(diff=None) () = match diff with
  | None ->
    List.nth accounts (Random.int accounts_len)
  | Some a ->
    let (_, pk, _) as r = List.nth accounts (Random.int accounts_len) in
    let tz1 = Tzfunc.Crypto.pk_to_tz1 pk in
    if a = tz1 then generate_address ~diff ()
    else r

let generate_maker () =
  generate_address ()

let generate_taker () =
  generate_option (fun () -> let _, pk, _ = generate_address () in pk)

let tezos_asset () = ATXTZ, Random.int64 10000000000L

let generate_fa1_2_asset () =
  let contract = List.nth fa1_2_contracts (Random.int fa1_2_contracts_len) in
  ATFA_1_2 contract, Random.int64 100L

let generate_fa2_asset () =
  let asset_fa2_contract = List.nth fa2_contracts (Random.int fa2_contracts_len) in
  let asset_fa2_token_id = string_of_int @@ (Random.int 1000) + 1 in
  ATFA_2 { asset_fa2_contract ; asset_fa2_token_id }, 1L

let generate_asset () =
  let kind = Random.int 3 in
  let at, value =
    match kind with
    | 0 -> tezos_asset ()
    | 1 -> generate_fa1_2_asset ()
    | 2 -> generate_fa2_asset ()
    | _ -> assert false in
  { asset_type = at; asset_value = Int64.to_string value }

let generate_salt () =
  string_of_int @@ (Random.int 10000) + 1

let generate_amount ?(max=100_000) () = Random.int max

let generate_token_id () = string_of_int @@ generate_amount ~max:1_000_000 ()

let generate_part () =
  let part_account = generate_origin () in
  let part_value = (Random.int 50) * 100 in
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
    if total = 10000 then royalties
    else
      let _, addr_pk, _ = generate_address () in
      let v = (Random.int 9999) + 1 in
      try
        let old = List.assoc addr_pk royalties in
        aux ((addr_pk, v + old) :: (List.remove_assoc addr_pk royalties))
      with Not_found ->
        (addr_pk, v) :: royalties in
  List.map (fun (addr, v) -> Tzfunc.Crypto.pk_to_tz1 addr, Int64.of_int v) @@ aux []

let mk_order_form
    maker taker make take salt start_date end_date signature data_type payouts origin_fees =
  let elt = {
    order_form_elt_maker = maker ;
    order_form_elt_taker = taker ;
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
    order_form_data = RaribleV2Order data ;
  }

let generate_order () =
  let _alias, maker_pk, maker_sk = generate_maker () in
  let taker = generate_taker () in
  let make = generate_asset () in
  let take = generate_asset () in
  let salt = generate_salt () in
  let start_date = None in
  let end_date = None in
  let data_type = "RARIBLE_V2_DATA_V1" in
  let payouts = [] in
  let origin_fees = generate_parts () in
  let$ to_sign =
    hash_order_form
      maker_pk make taker take salt start_date end_date data_type payouts origin_fees in
  let signature = sign ~edsk:maker_sk ~bytes:to_sign in
  let order_form =
    mk_order_form
      maker_pk taker make take salt start_date end_date signature data_type payouts origin_fees in
  Ok order_form

let call_upsert_order order_form =
    Format.eprintf "%s\n%!" (EzEncoding.construct order_form_enc order_form) ;
    let url = EzAPI.BASE !api in
    EzReq.post0
      ~input:order_form
      url
      ~error:(fun code msg ->
          Format.eprintf "ERROR %d %s\n%!" code (match msg with None -> "None" | Some s -> s))
      Api.upsert_order_s
      (function
        | Ok order -> Format.eprintf "RES %s\n%!" order.order_elt.order_elt_hash
        | Error _err -> Format.eprintf "ERROR" )

let call_generate_token_id collection =
  let url = EzAPI.BASE !api in
  EzReq_lwt.get1
    url
    Api.generate_nft_token_id_s
    collection

let call_get_nft_collection_by_id collection =
  let url = EzAPI.BASE !api in
  EzReq_lwt.get1
    url
    Api.get_nft_collection_by_id_s
    collection

let call_search_nft_collections_by_owner owner =
  let open EzAPI in
  let url = EzAPI.BASE !api in
  let rec aux ?continuation acc =
    let params = match continuation with
      | None -> [ Api.owner_param , S owner ]
      | Some c -> [ Api.owner_param , S owner ; Api.continuation_param, S c ] in
    EzReq_lwt.get0
      url
      ~params
      Api.search_nft_collections_by_owner_s
      >>=? fun collections ->
      match collections.nft_collections_continuation with
      | None -> Lwt.return_ok @@ collections.nft_collections_collections @ acc
      | Some continuation ->
        aux ~continuation (collections.nft_collections_collections @ acc) in
  aux []

let call_search_nft_all_collections () =
  let open EzAPI in
  let url = EzAPI.BASE !api in
  let rec aux ?continuation acc =
    let params = match continuation with
      | None -> []
      | Some c -> [ Api.continuation_param, S c ] in
    EzReq_lwt.get0
      url
      ~params
       Api.search_nft_all_collections_s
    >>=? fun collections ->
    match collections.nft_collections_continuation with
    | None -> Lwt.return_ok @@ collections.nft_collections_collections @ acc
    | Some continuation ->
      aux ~continuation (collections.nft_collections_collections @ acc) in
  aux []

let call_get_nft_item_by_id collection tid =
  let url = EzAPI.BASE !api in
  EzReq_lwt.get1
    url
    Api.get_nft_item_by_id_s
    (Printf.sprintf "%s:%s" collection tid)(*  >>= fun res ->
   * begin match res with
   *   | Ok item ->
   *     Printf.eprintf "%s\n%!" @@ EzEncoding.construct nft_item_enc item ;
   *   | _ -> ()
   * end ;
   * Lwt.return res *)

let call_get_nft_items_by_owner owner =
  let open EzAPI in
  let url = EzAPI.BASE !api in
  let rec aux ?continuation acc =
    let params = match continuation with
      | None -> [ Api.owner_param , S owner ]
      | Some c -> [ Api.owner_param , S owner ; Api.continuation_param, S c ] in
    EzReq_lwt.get0
      url
      ~params
      Api.get_nft_items_by_owner_s >>=? fun items ->
    match items.nft_items_continuation with
    | None -> Lwt.return_ok @@ items.nft_items_items @ acc
    | Some continuation ->
      aux ~continuation (items.nft_items_items @ acc) in
  aux []

let call_get_nft_items_by_collection collection =
  let open EzAPI in
  let url = EzAPI.BASE !api in
  let rec aux ?continuation acc =
    let params = match continuation with
      | None -> [ Api.collection_param , S collection ]
      | Some c -> [ Api.collection_param , S collection ; Api.continuation_param, S c ] in
    EzReq_lwt.get0
      url
      ~params
      Api.get_nft_items_by_collection_s >>=? fun items ->
    match items.nft_items_continuation with
    | None -> Lwt.return_ok @@ items.nft_items_items @ acc
    | Some continuation ->
      aux ~continuation (items.nft_items_items @ acc) in
  aux []

let call_get_nft_all_items () =
  let open EzAPI in
  let url = EzAPI.BASE !api in
  let rec aux ?continuation acc =
    let params = match continuation with
      | None -> [ ]
      | Some c -> [ Api.continuation_param, S c ] in
    EzReq_lwt.get0
      url
      ~params
      Api.get_nft_all_items_s >>=? fun items ->
    match items.nft_items_continuation with
    | None -> Lwt.return_ok @@ items.nft_items_items @ acc
    | Some continuation ->
      aux ~continuation (items.nft_items_items @ acc) in
  aux []

let call_get_nft_ownership_by_id collection tid owner  =
  let url = EzAPI.BASE !api in
  EzReq_lwt.get1
    url
    Api.get_nft_ownership_by_id_s
    (Printf.sprintf "%s:%s:%s" collection tid owner)

let call_get_nft_ownerships_by_item contract tid =
  let open EzAPI in
  let url = EzAPI.BASE !api in
  let params = [ Api.contract_param, S contract ; Api.token_id_param, S tid  ] in
  let rec aux ?continuation acc =
    let params = match continuation with
      | None -> params
      | Some c -> params @ [ Api.continuation_param, S c ] in
    EzReq_lwt.get0
      url
      ~params
      Api.get_nft_ownerships_by_item_s >>=? fun ownerships ->
    match ownerships.nft_ownerships_continuation with
    | None -> Lwt.return_ok @@ ownerships.nft_ownerships_ownerships @ acc
    | Some continuation ->
      aux ~continuation (ownerships.nft_ownerships_ownerships @ acc) in
  aux []

let call_get_nft_all_ownerships () =
  let open EzAPI in
  let url = EzAPI.BASE !api in
  let rec aux ?continuation acc =
    let params = match continuation with
      | None -> [ ]
      | Some c -> [ Api.continuation_param, S c ] in
    EzReq_lwt.get0
      url
      ~params
      Api.get_nft_all_ownerships_s >>=? fun ownerships ->
    match ownerships.nft_ownerships_continuation with
    | None -> Lwt.return_ok @@ ownerships.nft_ownerships_ownerships @ acc
    | Some continuation ->
      aux ~continuation (ownerships.nft_ownerships_ownerships @ acc) in
  aux []

let call_get_activities filter =
  (* Format.eprintf "%s\n%!" (EzEncoding.construct nft_activity_filter_enc filter) ; *)
  let open EzAPI in
  let url = EzAPI.BASE !api in
  let rec aux ?continuation acc =
    let params = match continuation with
      | None -> [ ]
      | Some c -> [ Api.continuation_param, S c ] in
    EzReq_lwt.post0
      ~input:filter
      ~params
      url
      Api.get_nft_activities_s >>=? fun activities ->
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
  | Ok order_form -> call_upsert_order order_form
  | Error err ->
    Format.eprintf "Error %s\n%!" @@ Let.string_of_error err

let get_order hash =
  let url = EzAPI.BASE !api in
  EzReq.get1
    url
    ~error:(fun code msg ->
        Format.eprintf "ERROR %d %s\n%!" code (match msg with None -> "None" | Some s -> s))
    Api.get_order_by_hash_s
    hash
    (function
      | Ok order -> Format.eprintf "RES %s\n%!" order.order_elt.order_elt_hash
      | Error _err -> Format.eprintf "ERROR" )

let update_order_make_value hash make_value =
  Db.get_order hash >|= function
  | Error err -> Format.eprintf "ERROR %s\n%!" @@ Crp.string_of_error err ;
  | Ok None -> Format.eprintf "get_order None"
  | Ok (Some order) ->
    let order_form = order_form_from_order order in
    let maker = order_form.order_form_elt.order_form_elt_maker in
    let _, _, maker_sk = by_pk maker in
    let taker = order_form.order_form_elt.order_form_elt_taker in
    let make = order_form.order_form_elt.order_form_elt_make in
    let make = { make with asset_value = make_value } in
    let take = order_form.order_form_elt.order_form_elt_take in
    let salt = order_form.order_form_elt.order_form_elt_salt in
    let start_date = order_form.order_form_elt.order_form_elt_start in
    let end_date = order_form.order_form_elt.order_form_elt_end in
    match order_form.order_form_data with
    | RaribleV2Order data ->
      let data_type = data.order_rarible_v2_data_v1_data_type in
      let payouts = data.order_rarible_v2_data_v1_payouts in
      let origin_fees = data.order_rarible_v2_data_v1_origin_fees in
      begin match
          hash_order_form
            maker make taker take salt start_date end_date data_type payouts origin_fees with
      | Ok to_sign ->
        let signature = sign ~edsk:maker_sk ~bytes:to_sign in
        let order_form =
          mk_order_form
            maker taker make take salt start_date end_date signature data_type payouts origin_fees in
        call_upsert_order order_form
      | Error err -> Format.eprintf "Error %s\n%!" @@ string_of_error err
      end
    | _ ->
      Format.eprintf "Wrong order type \n%!"

let update_order_take_value hash take_value =
  Db.get_order hash >|= function
  | Error err -> Format.eprintf "ERROR %s\n%!" @@ Crp.string_of_error err ;
  | Ok None -> Format.eprintf "get_order None"
  | Ok (Some order) ->
    let order_form = order_form_from_order order in
    let maker = order_form.order_form_elt.order_form_elt_maker in
    let _, _, maker_sk = by_pk maker in
    let taker = order_form.order_form_elt.order_form_elt_taker in
    let make = order_form.order_form_elt.order_form_elt_make in
    let take = order_form.order_form_elt.order_form_elt_take in
    let take = { take with asset_value = take_value } in
    let salt = order_form.order_form_elt.order_form_elt_salt in
    let start_date = order_form.order_form_elt.order_form_elt_start in
    let end_date = order_form.order_form_elt.order_form_elt_end in
    match order_form.order_form_data with
    | RaribleV2Order data ->
      let data_type = data.order_rarible_v2_data_v1_data_type in
      let payouts = data.order_rarible_v2_data_v1_payouts in
      let origin_fees = data.order_rarible_v2_data_v1_origin_fees in
      begin match
          hash_order_form
            maker make taker take salt start_date end_date data_type payouts origin_fees with
      | Ok to_sign ->
        let signature = sign ~edsk:maker_sk ~bytes:to_sign in
        let order_form =
          mk_order_form
            maker taker make take salt start_date end_date signature data_type payouts origin_fees in
        call_upsert_order order_form
      | Error err -> Format.eprintf "Error %s\n%!" @@ string_of_error err
      end
    | _ ->
      Format.eprintf "Wrong order type \n%!"

let update_order_taker hash taker =
  Db.get_order hash >|= function
  | Error err -> Format.eprintf "ERROR %s\n%!" @@ Crp.string_of_error err ;
  | Ok None -> Format.eprintf "get_order None"
  | Ok (Some order) ->
    let order_form = order_form_from_order order in
    let maker = order_form.order_form_elt.order_form_elt_maker in
    let _, _, maker_sk = by_pk maker in
    let taker = taker in
    let make = order_form.order_form_elt.order_form_elt_make in
    let take = order_form.order_form_elt.order_form_elt_take in
    let salt = order_form.order_form_elt.order_form_elt_salt in
    let start_date = order_form.order_form_elt.order_form_elt_start in
    let end_date = order_form.order_form_elt.order_form_elt_end in
    match order_form.order_form_data with
    | RaribleV2Order data ->
      let data_type = data.order_rarible_v2_data_v1_data_type in
      let payouts = data.order_rarible_v2_data_v1_payouts in
      let origin_fees = data.order_rarible_v2_data_v1_origin_fees in
      begin match
          hash_order_form
            maker make taker take salt start_date end_date data_type payouts origin_fees with
      | Ok to_sign ->
        let signature = sign ~edsk:maker_sk ~bytes:to_sign in
        let order_form =
          mk_order_form
            maker taker make take salt start_date end_date signature data_type payouts origin_fees in
        call_upsert_order order_form
      | Error err -> Format.eprintf "Error %s\n%!" @@ string_of_error err
      end
    | _ ->
      Format.eprintf "Wrong order type \n%!"

let may_import_key ?(verbose=0) alias sk =
  let cmd = Script.import_key ~verbose alias sk in
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
    let stdout, out_temp_fn = create_descr "tezos-client" "list_known_contracts" in
    let stderr, _err_temp_fn = create_descr "tezos-client" "list_known_contracts" in
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

let deploy ?verbose filename storage source alias =
  ignore verbose;
  let cmd =
    Script.deploy_aux ~verbose:!Script.verbose ~endpoint:!endpoint ~force:true ~filename storage source alias in
  let code, out, err = sys_command ~verbose:!Script.verbose ~retry:1 cmd in
  if code <> 0 then
    failwith (Printf.sprintf "deploy failure : out %S err %S" out err)

let create_collection ?(royalties=pick_royalties ()) () =
  let alias_new = generate_alias "collection" in
  let alias_admin, pk_admin, sk_admin = generate_address () in
  may_import_key alias_admin sk_admin ;
  let alias_source, _pk_source, sk_source = generate_address () in
  let admin = Tzfunc.Crypto.pk_to_tz1 pk_admin in
  may_import_key alias_source sk_source ;
  (admin, sk_admin), alias_source, alias_new, royalties

let create_collections ?royalties nb =
  let rec aux acc cpt =
    if cpt = 0 then acc
    else aux ((create_collection ?royalties ()) :: acc) (cpt - 1) in
  aux [] nb

let deploy_collection admin alias_source alias_new royalties =
  Printf.eprintf "Deploying new collection\n%!" ;
  if !js then
    Script_js.deploy_collection ~endpoint:!endpoint
      ~source:admin ~royalties_contract:royalties ()
  else
    let filename = "contracts/arl/fa2.arl" in
    let storage = Script.storage_fa2 ~admin:(fst admin) ~royalties in
    deploy filename storage alias_source alias_new ;
    Printf.eprintf "  deployed collection %s\n%!" alias_new ;
    let kt1 = find_kt1 alias_new in
    Printf.eprintf "  --> %s:%s\n%!" alias_new kt1 ;
    alias_new, kt1, admin, royalties

let create_royalties () =
  Printf.eprintf "Creating new royalties\n%!" ;
  let alias_admin, pk_admin, sk_admin = generate_address () in
  let admin = Tzfunc.Crypto.pk_to_tz1 pk_admin in
  if !js then
    Script_js.deploy_royalties ~endpoint:!endpoint (admin, sk_admin)
  else
    let alias_new = generate_alias "royalties" in
    may_import_key alias_admin sk_admin ;
    let alias_source, _pk_source, sk_source = generate_address () in
    may_import_key alias_source sk_source ;
    let filename = "contracts/arl/royalties.arl" in
    let storage = Script.storage_royalties ~admin:admin in
    deploy filename storage alias_source alias_new ;
    alias_new, alias_admin

let mint_tokens id owner amount royalties source contract =
  if !js then
    Script_js.mint_tokens ~endpoint:!endpoint ~amount ~royalties ~contract ~source id
  else
    let cmd = Script.mint_tokens_aux ~endpoint:!endpoint id owner amount
        royalties (fst source) contract in
    let code, out, err = sys_command ~retry:1 cmd in
    if code <> 0 then
      Lwt.fail_with ("mint failure : log " ^ out ^ " & " ^ err)
    else Lwt.return_ok ()

let burn_tokens id amount source contract =
  if !js then
    Script_js.burn_tokens ~endpoint:!endpoint ~amount ~contract ~source id
  else
    let cmd = Script.burn_tokens_aux ~endpoint:!endpoint id amount (fst source) contract in
    let code, out, err = sys_command ~retry:1 cmd in
    if code <> 0 then
      Lwt.fail_with ("burn failure : log " ^ out ^ " & " ^ err)
    else Lwt.return_ok ()

let transfer_tokens id amount source contract new_owner =
  if !js then
    Script_js.transfer_tokens ~endpoint:!endpoint ~amount ~contract ~source ~token_id:id new_owner
  else
    let param = [ fst source ; Printf.sprintf "%s*%s=%s" id amount new_owner ] in
    let cmd = Script.transfer_aux ~endpoint:!endpoint param (fst source) contract in
    let code, out, err = sys_command ~retry:1 cmd in
    if code <> 0 then
      Lwt.fail_with ("transfer failure : log " ^ out ^ " & " ^ err)
    else Lwt.return_ok ()

let mint_with_random_token_id ~source ~contract =
  Printf.eprintf "mint_with_random_token_id for %s on %s\n%!" (fst source) contract ;
  let _owner_alias, owner_pk, owner_sk = generate_address () in
  let owner =  Tzfunc.Crypto.pk_to_tz1 owner_pk in
  let tid = generate_token_id () in
  let amount = string_of_int @@ generate_amount ~max:10 () in
  let royalties = generate_royalties () in
  let metadata = [] in
  mint_tokens tid owner amount royalties source contract >|=? fun () ->
  ((owner, owner_sk), amount, tid, royalties, metadata)

let mint_with_token_id_from_api ~source ~contract =
  Printf.eprintf "mint_with_token_id_from_api for %s on %s\n%!" (fst source) contract ;
  let _owner_alias, owner_pk, owner_sk = generate_address () in
  let owner =  Tzfunc.Crypto.pk_to_tz1 owner_pk in
  let amount = string_of_int @@ generate_amount ~max:10 () in
  let royalties = generate_royalties () in
  let metadata = [] in
  call_generate_token_id contract >>=? fun tid ->
  mint_tokens tid.nft_token_id owner amount royalties source contract >|=? fun () ->
  ((owner, owner_sk), amount, tid.nft_token_id, royalties, metadata)

let burn_with_token_id ~source ~contract tid amount =
  Printf.eprintf "burn_with_token_id for %s on %s\n%!" (fst source) contract ;
  burn_tokens tid amount source contract

let transfer_with_token_id ~source ~contract tid amount new_owner =
  Printf.eprintf "transfer_with_token_id for %s on %s\n%!" (fst source) contract ;
  transfer_tokens tid amount source contract new_owner

let mint ~source ~contract =
  let random = Random.bool () in
  if random then mint_with_random_token_id ~source ~contract
  else
    mint_with_token_id_from_api ~source ~contract

let burn ~source ~contract tid max_amount =
  let full = Random.bool () in
  let amount =
    if full then max_amount else Random.int max_amount + 1 in
  burn_with_token_id ~source ~contract tid (string_of_int amount) >|=? fun () ->
  max_amount - amount

let transfer ~source ~contract tid max_amount =
  let full = Random.bool () in
  let _alias, pk, sk = generate_address ~diff:(Some (fst source)) () in
  let new_owner =  Tzfunc.Crypto.pk_to_tz1 pk in
  let new_owner_amount =
    if full then max_amount else generate_amount ~max:max_amount () + 1 in
  transfer_with_token_id ~source ~contract tid (string_of_int new_owner_amount) new_owner
  >|=? fun () -> (new_owner_amount, (new_owner, sk))

let random_mint collections =
  let _alias_collection, kt1, admin, _owner =
    List.nth collections (Random.int @@ List.length collections) in
  mint ~source:admin ~contract:kt1
  >|=? fun infos -> kt1, infos

let random_burn items =
  let selected = Random.int @@ List.length items in
  let (kt1, (owner, amount, tid, royalties, metadata)) = List.nth items selected in
  burn ~source:owner ~contract:kt1 tid (int_of_string amount) >|=? fun new_amount ->
  let new_item = kt1, (owner, string_of_int new_amount, tid, royalties, metadata) in
  List.mapi (fun i itm -> if i = selected then new_item else itm) items,
  new_item

let random_transfer items =
  let selected = Random.int @@ List.length items in
  let (kt1, (owner, amount_str, tid, royalties, metadata)) = List.nth items selected in
  transfer ~source:owner ~contract:kt1 tid (int_of_string amount_str)
  >|=? fun (new_owner_amount_i, new_owner) ->
  let new_owner_amount_str = string_of_int new_owner_amount_i in
  let amount_i = int_of_string amount_str in
  let new_item = kt1, (new_owner, new_owner_amount_str, tid, royalties, metadata) in
  let updated_source_item =
    kt1, (owner, string_of_int (amount_i - new_owner_amount_i), tid, royalties, metadata) in
  if amount_i = new_owner_amount_i then
    (* full transfer *)
    List.mapi (fun i itm -> if i = selected then new_item else itm) items,
    updated_source_item, new_item
  else
    new_item :: (List.mapi (fun i itm -> if i = selected then updated_source_item else itm) items),
    updated_source_item, new_item

let check_royalties item_royalties royalties =
  List.for_all (fun p ->
      try
        let v = List.assoc p.part_account royalties in
        v = Int64.of_int p.part_value
      with Not_found ->
  false) item_royalties

let check_owners item_owners owner =
  List.exists (fun o -> owner = o) item_owners

let check_strict_owners item_owners owner = match item_owners with
  | [ o ] when o = owner -> true
  | _ -> false

let check_supply item_supply amount =
  item_supply >= amount

let check_strict_supply item_supply amount =
  item_supply = amount

let check_metadata itm_metadata metadata = match itm_metadata, metadata with
  | Some im, Some m ->
    im.nft_item_meta_name = m.nft_item_meta_name &&
    im.nft_item_meta_description = m.nft_item_meta_description &&
    im.nft_item_meta_attributes = m.nft_item_meta_attributes &&
    im.nft_item_meta_image = m.nft_item_meta_image &&
    im.nft_item_meta_animation = m.nft_item_meta_animation
  | _, _ -> false

let check_nft_item ?(verbose=0) ?(strict=true) itm kt1 owner amount tid _royalties _metadata =
  if verbose > 0 then
    Printf.eprintf "%s\n%s %s %s %s\n%!"
      (EzEncoding.construct nft_item_enc itm)
      kt1
      owner
      amount
      tid
      (* (String.concat "\n  " @@
       *  List.map (fun (acc, i64) ->
       *      Printf.sprintf "%s -> %Ld" acc i64) royalties) *) ;
  if verbose > 0 then
  Printf.eprintf "%b %b %b %b %b\n%!"
    (itm.nft_item_id = (Printf.sprintf "%s:%s" kt1 tid))
    (itm.nft_item_contract = kt1)
    (itm.nft_item_token_id = tid)
    (if strict then check_strict_owners itm.nft_item_owners owner
     else check_owners itm.nft_item_owners owner)
    (if strict then check_strict_supply itm.nft_item_supply amount
     else check_supply itm.nft_item_supply amount) ;

  itm.nft_item_id = (Printf.sprintf "%s:%s" kt1 tid) &&
  itm.nft_item_contract = kt1 &&
  itm.nft_item_token_id = tid &&
  (* check_royalties itm.nft_item_royalties royalties && *)
  (if strict then check_strict_owners itm.nft_item_owners owner
   else check_owners itm.nft_item_owners owner) &&
  (if strict then check_strict_supply itm.nft_item_supply amount
   else check_supply itm.nft_item_supply amount)(*  &&
   * check_metadata itm.nft_item_meta metadata *)

let check_nft_ownership ow kt1 owner amount tid _metadata =
  ow.nft_ownership_id = (Printf.sprintf "%s:%s:%s" kt1 tid owner) &&
  ow.nft_ownership_contract = kt1 &&
  ow.nft_ownership_token_id = tid &&
  ow.nft_ownership_owner = owner &&
  ow.nft_ownership_value = amount(*  &&
   * check_creators ow.nft_ownership_creators metadata *)

let check_item ?strict (kt1, (owner, amount, tid, royalties, metadata)) =
  let owner = fst owner in
  let nft_item_exists ?verbose items =
    List.exists (fun i ->
        check_nft_item ?verbose ?strict i kt1 owner amount tid royalties metadata) items in
  let nft_ownership_exists ownerships =
    List.exists (fun o ->
        check_nft_ownership o kt1 owner amount tid metadata) ownerships in
  call_get_nft_item_by_id kt1 tid >|= begin function
  | Ok nft_item ->
    if check_nft_item ~verbose:1 nft_item kt1 owner amount tid royalties metadata then
      Printf.eprintf "[OK] API: get_nft_item_by_id\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_item_by_id (no matching nft_item)\n%!"
  | Error err ->
    Printf.eprintf
      "[KO] API: get_nft_item_by_id (error : %s)\n%!" @@
    EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
  end >>= fun () ->
  call_get_nft_items_by_owner owner >|= begin function
  | Ok nft_items ->
    if nft_item_exists nft_items then
      Printf.eprintf "[OK] API: get_nft_items_by_owner\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_items_by_owner (no matching nft_item)\n%!"
  | Error err ->
    Printf.eprintf
      "[KO] API: get_nft_items_by_owner (error : %s)\n%!" @@
    EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
  end >>= fun () ->
  call_get_nft_items_by_collection kt1 >|= begin function
  | Ok nft_items ->
    if nft_item_exists nft_items then
      Printf.eprintf "[OK] API: get_nft_items_by_collection\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_items_by_collection (no matching nft_item)\n%!"
  | Error err ->
    Printf.eprintf
      "[KO] API: get_nft_items_by_owner (error : %s)\n%!" @@
    EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
  end >>= fun () ->
  call_get_nft_all_items () >|= begin function
  | Ok nft_items ->
    if nft_item_exists nft_items then
      Printf.eprintf "[OK] API: get_nft_all_items\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_all_items (no matching nft_item)\n%!"
  | Error err ->
    Printf.eprintf
      "[KO] API: get_nft_all_items (error : %s)\n%!" @@
    EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
  end >>= fun () ->
  call_get_nft_ownership_by_id kt1 tid owner >|= begin function
  | Ok nft_ownership ->
    if check_nft_ownership nft_ownership kt1 owner amount tid metadata then
      Printf.eprintf "[OK] API: get_nft_ownership_by_id\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_ownership_by_id (no matching nft_item)\n%!"
  | Error err ->
    Printf.eprintf
      "[KO] API: get_nft_ownership_by_id (error : %s)\n%!" @@
    EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
  end >>= fun () ->
  call_get_nft_ownerships_by_item kt1 tid >|= begin function
  | Ok nft_ownerships ->
    if nft_ownership_exists nft_ownerships then
      Printf.eprintf "[OK] API: get_nft_ownerships_by_item\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_ownerships_by_item (no matching nft_ownership)\n%!"
  | Error err ->
    Printf.eprintf
      "[KO] API: get_nft_ownerships_by_item (error : %s)\n%!" @@
    EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
  end >>= fun () ->
  call_get_nft_all_ownerships () >|= begin function
  | Ok nft_ownerships ->
    if nft_ownership_exists nft_ownerships then
      Printf.eprintf "[OK] API: get_nft_all_ownerships\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_all_ownerships (no matching nft_ownership)\n%!"
  | Error err ->
    Printf.eprintf
      "[KO] API: get_nft_all_ownerships (error : %s)\n%!" @@
    EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
  end
  (* get_nft_item_meta_by_id ;
   * get_nft_items_by_creator ; *)

let check_nft_activity ?(from=false) activity kt1 owner amount tid =
  (* Printf.eprintf "check_nft_activity %s %s %s %s\n%!" kt1 owner amount tid ; *)
  if from then
    activity.nft_activity_contract = kt1 &&
    activity.nft_activity_owner <> owner &&
    activity.nft_activity_token_id = tid
  else
    activity.nft_activity_contract = kt1 &&
    activity.nft_activity_owner = owner &&
    activity.nft_activity_value = amount &&
    activity.nft_activity_token_id = tid

let check_mint_activity (kt1, (owner, amount, tid, _royalties, _metadata)) =
  let owner = fst owner in
  let mint_activity_exists activities =
    List.exists (fun act -> match act.nft_activity_type with
        | NftActivityMint -> check_nft_activity act.nft_activity_elt kt1 owner amount tid
        | _ -> false) activities in
  (* MINT ONLY ACTIVITIES *)
  call_get_nft_activities_by_item_mint kt1 tid >|= begin function
  | Ok nft_activities ->
    if mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_item_mint\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_item_mint (no matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf
      "[KO] API: get_nft_activities_by_item_mint (error : %s)\n%!" @@
    EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
  end >>= fun () ->
  call_get_nft_activities_by_user_mint owner >|= begin function
  | Ok nft_activities ->
    if mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_user_mint\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_user_mint (no matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf
      "[KO] API: get_nft_activities_by_user_mint (error : %s)\n%!" @@
    EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
  end >>= fun () ->
  call_get_nft_activities_by_collection_mint kt1 >|= begin function
  | Ok nft_activities ->
    if mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_collection_mint\n%!"
    else
      Printf.eprintf
        "[KO] API: get_nft_activities_by_collection_mint (no matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf
      "[KO] API: get_nft_activities_by_collection_mint (error : %s)\n%!" @@
    EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
  end >>= fun () ->
  call_get_nft_all_activities_mint () >|= begin function
  | Ok nft_activities ->
    if mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_all_activities_mint\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_all_activities_mint (no matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf
      "[KO] API: get_nft_all_activities_mint (error : %s)\n%!" @@
    EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
  end >>= fun () ->

  (* ALL ACTIVITIES *)
  call_get_nft_activities_by_item_all kt1 tid >|= begin function
  | Ok nft_activities ->
    if mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_item_all\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_item_all (no matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf
      "[KO] API: get_nft_activities_by_item_all (error : %s)\n%!" @@
    EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
  end >>= fun () ->
  call_get_nft_activities_by_user_all owner >|= begin function
  | Ok nft_activities ->
    if mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_user_all\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_user_all (no matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf
      "[KO] API: get_nft_activities_by_user_all (error : %s)\n%!" @@
    EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
  end >>= fun () ->
  call_get_nft_activities_by_collection_all kt1 >|= begin function
  | Ok nft_activities ->
    if mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_collection_all\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_collection_all (no matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf
      "[KO] API: get_nft_activities_by_collection_all (error : %s)\n%!" @@
    EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
  end >>= fun () ->
  call_get_nft_all_activities_all () >|= begin function
  | Ok nft_activities ->
    if mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_all_activities_all\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_all_activities_all (no matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf
      "[KO] API: get_nft_all_activities_all (error : %s)\n%!" @@
    EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
  end >>= fun () ->

  (* BURN ONLY ACTIVITIES *)
  call_get_nft_activities_by_item_burn kt1 tid >|= begin function
  | Ok nft_activities ->
    if not @@ mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_item_burn\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_item_burn (matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf
      "[KO] API: get_nft_activities_by_item_burn (error : %s)\n%!" @@
    EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
  end >>= fun () ->
  call_get_nft_activities_by_user_burn owner >|= begin function
  | Ok nft_activities ->
    if not @@ mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_user_burn\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_user_burn (matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf
      "[KO] API: get_nft_activities_by_user_burn (error : %s)\n%!" @@
    EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
  end >>= fun () ->
  call_get_nft_activities_by_collection_burn kt1 >|= begin function
  | Ok nft_activities ->
    if not @@ mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_collection_burn\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_collection_burn (matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf
      "[KO] API: get_nft_activities_by_collection_burn (error : %s)\n%!" @@
    EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
  end >>= fun () ->
  call_get_nft_all_activities_burn () >|= begin function
  | Ok nft_activities ->
    if not @@ mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_all_activities_burn\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_all_activities_burn (matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf
      "[KO] API: get_nft_all_activities_burn (error : %s)\n%!" @@
    EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
  end >>= fun () ->

  (* TRANSFER ONLY ACTIVITIES *)
  call_get_nft_activities_by_item_transfer kt1 tid >|= begin function
  | Ok nft_activities ->
    if not @@ mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_item_transfer\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_item_transfer (matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf
      "[KO] API: get_nft_activities_by_item_transfer (error : %s)\n%!" @@
    EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
  end >>= fun () ->
  call_get_nft_activities_by_user_transfer owner >|= begin function
  | Ok nft_activities ->
    if not @@ mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_user_transfer\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_user_transfer (matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf
      "[KO] API: get_nft_activities_by_user_transfer (error : %s)\n%!" @@
    EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
  end >>= fun () ->
  call_get_nft_activities_by_collection_transfer kt1 >|= begin function
  | Ok nft_activities ->
    if not @@ mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_collection_transfer\n%!"
    else
      Printf.eprintf
        "[KO] API: get_nft_activities_by_collection_transfer (matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf
      "[KO] API: get_nft_activities_by_collection_transfer (error : %s)\n%!" @@
    EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
  end >>= fun () ->
  call_get_nft_all_activities_transfer () >|= begin function
  | Ok nft_activities ->
    if not @@ mint_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_all_activities_transfer\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_all_activities_transfer (matching mint activity)\n%!"
  | Error err ->
    Printf.eprintf
      "[KO] API: get_nft_all_activities_transfer (error : %s)\n%!" @@
    EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
  end

let check_transfer_activity ?(from=false) (kt1, (owner, amount, tid, _royalties, _metadata)) =
  let owner = fst owner in
  let transfer_activity_exists activities =
    List.exists (fun act -> match act.nft_activity_type with
        | NftActivityTransfer addr ->
          if from then
            check_nft_activity ~from act.nft_activity_elt kt1 addr amount tid
          else check_nft_activity act.nft_activity_elt kt1 owner amount tid
        | _ -> false) activities in
  (* MINT ONLY ACTIVITIES *)
  call_get_nft_activities_by_item_mint kt1 tid >|= begin function
  | Ok nft_activities ->
    if not @@ transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_item_mint\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_item_mint (matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf
      "[KO] API: get_nft_activities_by_item_mint (error : %s)\n%!" @@
    EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
  end >>= fun () ->
  call_get_nft_activities_by_user_mint owner >|= begin function
  | Ok nft_activities ->
    if not @@ transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_user_mint\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_user_mint (matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf
      "[KO] API: get_nft_activities_by_user_mint (error : %s)\n%!" @@
    EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
  end >>= fun () ->
  call_get_nft_activities_by_collection_mint kt1 >|= begin function
  | Ok nft_activities ->
    if not @@ transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_collection_mint\n%!"
    else
      Printf.eprintf
        "[KO] API: get_nft_activities_by_collection_mint (matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf
      "[KO] API: get_nft_activities_by_collection_mint (error : %s)\n%!" @@
    EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
  end >>= fun () ->
  call_get_nft_all_activities_mint () >|= begin function
  | Ok nft_activities ->
    if not @@ transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_all_activities_mint\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_all_activities_mint (matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf
      "[KO] API: get_nft_all_activities_mint (error : %s)\n%!" @@
    EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
  end >>= fun () ->

  (* ALL ACTIVITIES *)
  call_get_nft_activities_by_item_all kt1 tid >|= begin function
  | Ok nft_activities ->
    if transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_item_all\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_item_all (no matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf
      "[KO] API: get_nft_activities_by_item_all (error : %s)\n%!" @@
    EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
  end >>= fun () ->
  call_get_nft_activities_by_user_all owner >|= begin function
  | Ok nft_activities ->
    if transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_user_all\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_user_all (no matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf
      "[KO] API: get_nft_activities_by_user_all (error : %s)\n%!" @@
    EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
  end >>= fun () ->
  call_get_nft_activities_by_collection_all kt1 >|= begin function
  | Ok nft_activities ->
    if transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_collection_all\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_collection_all (no matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf
      "[KO] API: get_nft_activities_by_collection_all (error : %s)\n%!" @@
    EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
  end >>= fun () ->
  call_get_nft_all_activities_all () >|= begin function
  | Ok nft_activities ->
    if transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_all_activities_all\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_all_activities_all (no matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf
      "[KO] API: get_nft_all_activities_all (error : %s)\n%!" @@
    EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
  end >>= fun () ->

  (* BURN ONLY ACTIVITIES *)
  call_get_nft_activities_by_item_burn kt1 tid >|= begin function
  | Ok nft_activities ->
    if not @@ transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_item_burn\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_item_burn (matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf
      "[KO] API: get_nft_activities_by_item_burn (error : %s)\n%!" @@
    EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
  end >>= fun () ->
  call_get_nft_activities_by_user_burn owner >|= begin function
  | Ok nft_activities ->
    if not @@ transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_user_burn\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_user_burn (matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf
      "[KO] API: get_nft_activities_by_user_burn (error : %s)\n%!" @@
    EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
  end >>= fun () ->
  call_get_nft_activities_by_collection_burn kt1 >|= begin function
  | Ok nft_activities ->
    if not @@ transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_collection_burn\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_collection_burn (matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf
      "[KO] API: get_nft_activities_by_collection_burn (error : %s)\n%!" @@
    EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
  end >>= fun () ->
  call_get_nft_all_activities_burn () >|= begin function
  | Ok nft_activities ->
    if not @@ transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_all_activities_burn\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_all_activities_burn (matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf
      "[KO] API: get_nft_all_activities_burn (error : %s)\n%!" @@
    EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
  end >>= fun () ->

  (* TRANSFER ONLY ACTIVITIES *)
  call_get_nft_activities_by_item_transfer kt1 tid >|= begin function
  | Ok nft_activities ->
    if transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_item_transfer\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_item_transfer (no matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf
      "[KO] API: get_nft_activities_by_item_transfer (error : %s)\n%!" @@
    EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
  end >>= fun () ->
  call_get_nft_activities_by_user_transfer owner >|= begin function
  | Ok nft_activities ->
    if transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_user_transfer\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_activities_by_user_transfer (no matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf
      "[KO] API: get_nft_activities_by_user_transfer (error : %s)\n%!" @@
    EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
  end >>= fun () ->
  call_get_nft_activities_by_collection_transfer kt1 >|= begin function
  | Ok nft_activities ->
    if transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_activities_by_collection_transfer\n%!"
    else
      Printf.eprintf
        "[KO] API: get_nft_activities_by_collection_transfer (no matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf
      "[KO] API: get_nft_activities_by_collection_transfer (error : %s)\n%!" @@
    EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
  end >>= fun () ->
  call_get_nft_all_activities_transfer () >|= begin function
  | Ok nft_activities ->
    if transfer_activity_exists nft_activities then
      Printf.eprintf "[OK] API: get_nft_all_activities_transfer\n%!"
    else
      Printf.eprintf "[KO] API: get_nft_all_activities_transfer (no matching transfer activity)\n%!"
  | Error err ->
    Printf.eprintf
      "[KO] API: get_nft_all_activities_transfer (error : %s)\n%!" @@
    EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
  end

let mint_check_random collections =
  random_mint collections >>=? fun item ->
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  Unix.sleep 6 ;
  check_item item >>= fun () ->
  check_mint_activity item >>= fun () ->
  Lwt.return_ok item

let burn_check_random items =
  random_burn items >>=? fun (items, updated_item) ->
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  Unix.sleep 6 ;
  check_item updated_item >>= fun () ->
  Lwt.return_ok items

let transfer_check_random items =
  random_transfer items >>=? fun (items, updated_item, new_item) ->
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  Unix.sleep 6 ;
  let (kt1, (owner1, owner_1_amount, token_id, royalties, metadata)) = updated_item in
  let (_, (owner2, owner_2_amount, _, _, _)) = new_item in
  let total_amount =
    string_of_int @@
    (int_of_string owner_1_amount) +
    (int_of_string owner_2_amount) in
  begin
    if owner_1_amount <> "0" then
      check_item ~strict:false (kt1, (owner1, total_amount, token_id, royalties, metadata))
    else Lwt.return_unit
  end >>= fun () ->
  check_item ~strict:false (kt1, (owner2, total_amount, token_id, royalties, metadata)) >>= fun () ->
  check_transfer_activity ~from:true updated_item >>= fun () ->
  check_transfer_activity new_item >>= fun () ->
  Lwt.return_ok items

let mints_check_random ?(max=30) collections =
  let nb = Random.int max + 1 in
  let rec aux acc cpt =
    if cpt = 0 then Lwt.return_ok acc
    else
      mint_check_random collections >>=? fun item ->
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

let check_collection alias kt1 owner =
  let owner = fst owner in
  Printf.eprintf "Checking new collection %s of %s\n%!" alias owner ;
  let collection_exists collections =
    List.find_all (fun c ->
        c.nft_collection_id = kt1 &&
        c.nft_collection_owner = Some owner) collections in
  call_get_nft_collection_by_id kt1 >>=? fun c ->
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

let set_metadata _source _kt1 =
  Lwt.return_unit

let deploy_check_random_collections ?royalties ?(max=10) () =
  let nb = Random.int max + 1 in
  Printf.eprintf "Deploying and checking %d collection(s)\n%!" nb ;
  let collections = create_collections ?royalties nb in
  let agg =
    List.fold_left (fun acc ((admin, _alias_source, _alias_new, _royalties) as collection) ->
        try
          let old = List.assoc admin acc in
          (admin, (collection :: old)) :: (List.remove_assoc admin acc)
        with Not_found ->
          (admin, [ collection ]) ::  acc)
      [] collections in
  Lwt_list.map_p (fun (admin, collections) ->
      Printf.eprintf "  deploying %d collection for %s\n%!" (List.length collections) (fst admin) ;
      Lwt_list.map_s (fun (admin, alias_source, alias_new, royalties) ->
          Lwt.return @@
          deploy_collection admin alias_source alias_new royalties) collections)
    agg >>= fun new_collections ->
  let new_collections = List.flatten new_collections in
  Printf.eprintf "Waiting 6sec for crawler to catch up...\n%!" ;
  Lwt_unix.sleep 6. >>= fun () ->
  Lwt_list.map_p (fun (alias, kt1, admin, _) ->
      check_collection alias kt1 admin) new_collections >>= fun res ->
  Lwt_list.iter_s (function
      | Ok _ -> Lwt.return_unit
      | Error err ->
        Lwt.return @@
        Printf.eprintf
          "[KO] API: check_collection (error : %s)\n%!" @@
        EzReq_lwt.string_of_error (fun r ->
            Some (EzEncoding.construct rarible_error_500_enc r)) err)
    res >>= fun () ->
  Lwt.return new_collections

let reset_db () =
  Printf.eprintf "Resetting db\n%!" ;
  let c, o, e = sys_command "make drop" in
  if c <> 0 then failwith ("failure when resetting db : log " ^ o ^ " & " ^ e)
  else
    let c, o, e =  sys_command "make" in
    if c <> 0 then failwith ("failure when resetting db : log " ^ o ^ " & " ^ e)

let start_api () =
  let prog = "./_bin/api" in
  let args = [| prog |] in
  let stdout, fn_out = create_descr "api" "out" in
  let stderr, fn_err = create_descr "api" "err" in
  let pid = create_process ~stdout ~stderr prog args in
  Printf.eprintf "API STARTED (out %s, err %s)\n%!" fn_out fn_err ;
  pid

let get_head () =
  EzReq_lwt.get
    (EzAPI.URL "https://api.granadanet.tzkt.io/v1/blocks/count")

let make_config admin_wallet validator exchange_v2 royalties ft_fa1 ft_fa2 =
  let open Crawlori.Config in
  get_head () >>= function
  | Error (code, str) ->
    failwith (Printf.sprintf "get_head error %d %s" code (Option.value ~default:"" str))
  | Ok level ->
    let config = {
      nodes = [ "https://granadanet.smartpy.io" ] ;
      start = Some Int32.(sub (of_string level) 30l)  ;
      db_kind = `pg ;
      step_forward = 30 ;
      accounts = None ;
      sleep = 5. ;
      forward = None ;
      confirmations_needed = 5l ;
      verbose = 0 ;
      register_kinds = None ;
      allow_no_metadata = false ;
      extra = { admin_wallet ; validator ; exchange_v2 ; royalties; ft_fa1; ft_fa2 } ;
    } in
    let temp_fn = Filename.temp_file "config" "" in
    let json = EzEncoding.construct (Cconfig.enc Rtypes.config_enc) config in
    Printf.eprintf "Crawler config:\n%s\n\n%!" json ;
    let c = open_out temp_fn in
    output_string c json ;
    close_out c ;
    Lwt.return temp_fn

let start_crawler admin_wallet validator exchange_v2 royalties ft_fa1 ft_fa2 =
  make_config admin_wallet validator exchange_v2 royalties ft_fa1 ft_fa2 >>= fun config ->
  let prog = "./_bin/crawler" in
  let args = [| prog ; config |] in
  let stdout, fn_out = create_descr "crawler" "out" in
  let stderr, fn_err = create_descr "crawler" "err" in
  let pid = create_process ~stdout ~stderr prog args in
  Printf.eprintf "CRAWLER STARTED (out %S err %S)\n%!" fn_out fn_err ;
  Lwt.return pid

let random_test () =
  reset_db () ;
  (* let r_kt1 = List.hd royalties_contracts in *)
  let r_alias, _r_source = create_royalties () in
  let r_kt1 = find_kt1 r_alias in
  Printf.eprintf "New royalties %s\n%!" r_kt1 ;
  api_pid := Some (start_api ()) ;
  start_crawler "" validator exchange_v2 r_kt1 [] [] >>= fun cpid ->
  crawler_pid := Some cpid ;
  Printf.eprintf "Waiting 6sec to let crawler catch up...\n%!" ;
  Lwt_unix.sleep 6. >>= fun () ->
  deploy_check_random_collections ~royalties:r_kt1 ~max:1 () >>= fun collections ->
  (* let collections = [ "collection_19760", "KT1MvNHPsHpHZDJ7HfkUDx71qyYvU7nLi9N7", "tz1KiZygjrVaS1fjs9iW4YSKNiqoopHK8Hdj", r_kt1 ] in *)
  mints_check_random ~max:1 collections >>= begin function
    | Error err ->
      Lwt.return @@
      Printf.eprintf "mint error %s" @@
      EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err
    | Ok items ->
      transfers_check_random ~max:1 items >|= begin function
        | Error err ->
          Printf.eprintf "burn error %s" @@
          EzReq_lwt.string_of_error (fun r ->
              Some (EzEncoding.construct rarible_error_500_enc r)) err
        | Ok _items -> ()
      end
  end >>= fun () ->
  (* let (_alias, contract, source, _r) = List.hd collections in *)
  (* let source = "tz1f6TuKe38VPURr6gA1xiQq9dzuVuzNZoP6" in
   * let contract = "KT1RYUvuCP7YgoXihfEXWNKgzkZgxPYCWWUi" in
   * mint_with_token_id_from_api ~source ~contract >>= begin function
   *   | Ok infos ->
   *     Printf.eprintf "Waiting 6sec to let crawler catch up...\n%!" ;
   *     Lwt_unix.sleep 6. >>= fun () ->
   *     check_mint contract infos
   *   | Error err ->
   *     Printf.eprintf "mint error %s" @@
   *     EzReq_lwt.string_of_error (fun r -> Some (EzEncoding.construct rarible_error_500_enc r)) err ;
   *     Lwt.return_unit
   * end >>= fun () -> *)

  begin match !api_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
  begin match !crawler_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
  Lwt.return_unit


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
    | [ "call_upsert_order" ] -> upsert_order ()
    | "update_order_make_value" :: hash :: make_value :: [] ->
      Lwt_main.run (update_order_make_value hash make_value)
    | "update_order_take_value" :: hash :: take_value :: [] ->
      Lwt_main.run (update_order_take_value hash take_value)
    (* | "update_order_date" :: hash :: start_date :: end_date :: [] ->
     *   update_order_date hash start_date end_date *)
    | "update_order_taker" :: hash :: taker :: [] ->
      Lwt_main.run (update_order_taker hash (Some taker))
    | [ "create_collection" ] -> ignore @@ create_collection ()
    | "create_collection" :: royalties :: [] -> ignore @@ create_collection ~royalties ()
    (* | "mint_token_id" :: contract :: token_id :: [] -> mint contract token_id
     * | "mint" :: contract :: [] -> mint_with_random_token_id contract *)
    (* | "transfer_nft" :: contract :: token_id :: dest :: [] ->
     *   transfer_nft contract token_id dest
     * | "transfer_multi" :: contract :: token_id :: dest :: amount :: [] ->
     *   transfer_multi contract token_id dest amount *)
    | [ "run_test" ] -> Lwt_main.run (
        Lwt.catch random_test (fun exn ->
            Printf.eprintf "CATCH %S\n%!" @@ Printexc.to_string exn ;
            begin match !api_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
            begin match !crawler_pid with None -> () | Some pid -> Unix.kill pid 9 end ;
            Lwt.return_unit))
    | _ -> Arg.usage spec usage

let _ = main ()
