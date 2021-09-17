open Rtypes
open Let
open Utils

let cwd = Sys.getcwd ()
let exe = Sys.argv.(0)

let api = ref "http://localhost:8080"
let verbose = ref 0

(* EDPK * EDSK *)
let accounts = [
  "edpktjwGH2VwKJkAVztZvr5Gkifg5bKx99GT6wDCctQL6xgRHB3pRc",
  "edsk4XzV1K3Td1fVUhRv33iduTdNCxmHidUsCKRkvK2NgnersFdEUY" ;
  "edpkuiqLaC3YvwMQTKezCV9pJs2vjqPxoonMJDBdNqnwQxiMx3ag8h",
  "edsk3LVprL8yNHpVcbLrbaFm25njKkyjJrZEGCweuxqkCh7SiEyH4L" ;
  "edpkuDUy4h4y2qqSHDgdid8WxESu3YwaPmWZ42p4G3ZCnE5epgtXhH",
  "edsk49SC61Sb1QYRQQRW7M6SRmWMvjoaVsfCftkdoERv8BENe7ssV4" ;
  "edpktoPwmCz9Wbr8BKByJPnasrPq1BfoAVURtAhxpw7WafbktMnkrp",
  "edsk35jq62PmRmRB5vH1rUE5W6wzE7P6sn3r58C3TKcDtnwx6MpFUU" ;
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

let set_opt_string r = Arg.String (fun s -> r := Some s)
let set_opt_float r = Arg.Float (fun f -> r := Some f)
let set_opt_int r = Arg.Int (fun i -> r := Some i)

let arg_parse ~spec ~usage f =
  Arg.parse spec f usage

let spec = [
  "--api", Arg.Set_string api, "api address (default: http://localhost:8080)";
  "--verbose", Arg.Set_int verbose, "verbosity";
]

let missing l =
  List.iter (fun (name, opt) ->
      match opt with
      | None ->
        let _, _, descr = List.find (fun (n, _, _) -> n = name) spec in
        Format.eprintf "Missing argument: %s %s@." name descr
      | _ -> ()) l

let command_result ?(f=(fun l -> String.concat " " @@ List.map String.trim l)) cmd =
  if !verbose > 0 then Format.printf "Command:\n%s@." cmd;
  let ic = Unix.open_process_in cmd in
  let rec aux acc =
    try aux ((input_line ic) :: acc)
    with End_of_file -> List.rev acc in
  let s = f (aux []) in
  match s, Unix.close_process_in ic with
  | "", _ -> failwith "Empty result"
  | _, Unix.WEXITED 0 -> s
  | _ -> failwith (Format.sprintf "Error processing %S" cmd)

let generate_option f =
  if Random.bool () then
    Some (f ())
  else None

let generate_origin () =
  List.nth origins (Random.int origins_len)

let generate_address () =
  List.nth accounts (Random.int accounts_len)

let generate_maker () =
  generate_address ()

let generate_taker () =
  generate_option (fun () -> fst @@ generate_address ())

let tezos_asset () = ATXTZ, Random.int64 10000000000L

let generate_fa1_2_asset () =
  let contract = List.nth fa1_2_contracts (Random.int fa1_2_contracts_len) in
  ATFA_1_2 contract, Random.int64 100L

let generate_fa2_asset () =
  let asset_fa2_contract = List.nth fa2_contracts (Random.int fa2_contracts_len) in
  let asset_fa2_token_id = generate_option (fun () -> string_of_int @@ (Random.int 1000) + 1) in
  ATFA_2 { asset_fa2_contract ; asset_fa2_token_id },
  match asset_fa2_token_id with
  | None -> Random.int64 100L
  | Some _id -> 1L

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

let generate_part () =
  let part_account = generate_origin () in
  let part_value = (Random.int 50) * 100 in
  { part_account ; part_value }

let generate_parts () =
  [ generate_part () ]

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
  let maker_pk, maker_sk = generate_maker () in
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
    Format.eprintf "%s@." (EzEncoding.construct order_form_enc order_form) ;
    let url = EzAPI.BASE !api in
    EzReq.post0
      ~input:order_form
      url
      ~error:(fun code msg ->
          Format.eprintf "ERROR %d %s@." code (match msg with None -> "None" | Some s -> s))
      Api.upsert_order_s
      (function
        | Ok order -> Format.eprintf "RES %s@." order.order_elt.order_elt_hash
        | Error _err -> Format.eprintf "ERROR" )

let upsert_order () =
  Random.self_init () ;
  match generate_order () with
  | Ok order_form -> call_upsert_order order_form
  | Error err ->
    Format.eprintf "Error %s@." @@ Let.string_of_error err

let get_order hash =
  let url = EzAPI.BASE !api in
  EzReq.get1
    url
    ~error:(fun code msg ->
        Format.eprintf "ERROR %d %s@." code (match msg with None -> "None" | Some s -> s))
    Api.get_order_by_hash_s
    hash
    (function
      | Ok order -> Format.eprintf "RES %s@." order.order_elt.order_elt_hash
      | Error _err -> Format.eprintf "ERROR" )

let update_order_make_value hash make_value =
  Db.get_order hash >|= function
  | Error err -> Format.eprintf "ERROR %s@." @@ Crp.string_of_error err ;
  | Ok None -> Format.eprintf "get_order None"
  | Ok (Some order) ->
    let order_form = order_form_from_order order in
    let maker = order_form.order_form_elt.order_form_elt_maker in
    let maker_sk = List.assoc maker accounts in
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
      | Error err -> Format.eprintf "Error %s@." @@ string_of_error err
      end
    | _ ->
      Format.eprintf "Wrong order type @."

let update_order_take_value hash take_value =
  Db.get_order hash >|= function
  | Error err -> Format.eprintf "ERROR %s@." @@ Crp.string_of_error err ;
  | Ok None -> Format.eprintf "get_order None"
  | Ok (Some order) ->
    let order_form = order_form_from_order order in
    let maker = order_form.order_form_elt.order_form_elt_maker in
    let maker_sk = List.assoc maker accounts in
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
      | Error err -> Format.eprintf "Error %s@." @@ string_of_error err
      end
    | _ ->
      Format.eprintf "Wrong order type @."

let update_order_taker hash taker =
  Db.get_order hash >|= function
  | Error err -> Format.eprintf "ERROR %s@." @@ Crp.string_of_error err ;
  | Ok None -> Format.eprintf "get_order None"
  | Ok (Some order) ->
    let order_form = order_form_from_order order in
    let maker = order_form.order_form_elt.order_form_elt_maker in
    let maker_sk = List.assoc maker accounts in
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
      | Error err -> Format.eprintf "Error %s@." @@ string_of_error err
      end
    | _ ->
      Format.eprintf "Wrong order type @."

(** main *)

let actions = [
  ["call_upsert_order"], "call upsert endpoint with randomly generated order";
  ["update_order_make_value <order_hash> <new_make_value>"], "change order's make value";
  ["update_order_take_value <order_hash> <new_take_value>"], "change order's take value";
  (* ["update_order_date <order_hash> <start_date> <end_date>"], "change order's start date and end date"; *)
  ["update_order_taker <order_hash> <new_taker>"], "change order's taker (should fail)";
]

let usage =
  "usage: rarible_api.mlt <options> <actions>\nactions:\n  " ^
  (String.concat "\n  " @@ List.map (fun (cmds, descr) ->
       Format.sprintf "- %s -> %s" (String.concat " | " cmds) descr) actions) ^ "\noptions:"

let main () =
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
    | _ -> Arg.usage spec usage

let _ = main ()
