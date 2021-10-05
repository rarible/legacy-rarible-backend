open EzAPIServer
open Rtypes
open Let
open Utils
open Errors

(* let _ =
 *   let s =
 *     Tzfunc.Crypto.Base58.encode
 *       Tzfunc.Crypto.Prefix.generic_signature
 *       (Hex.to_string @@
 *        `Hex
 *          "45461654b86e856686e7a2e9a9213b29f8dc32a731046e0c2f1aa01e4eaa991e41ebc67535fac14c333ad5b0d0d821ef518edc9ed08ad7efc0af572620c045ce1c") in
 *   Format.eprintf "XX %S\n%!" s *)

let (let$>) r f = match r with
  | Error e -> Lwt.return_error (invalid_argument (string_of_error e))
  | Ok x -> f x

let nft_section = EzAPI.Doc.{section_name = "nft-activity-controller"; section_docs = []}
let ownerships_section = EzAPI.Doc.{section_name = "nft-ownership-controller"; section_docs = []}
let items_section = EzAPI.Doc.{section_name = "nft-item-controller"; section_docs = []}
let collections_section = EzAPI.Doc.{section_name = "nft-collection-controller"; section_docs = []}
let orders_section = EzAPI.Doc.{section_name = "order-controller"; section_docs = []}
let order_activities_section =
  EzAPI.Doc.{section_name = "order-activity-controller"; section_docs = []}
let aggregation_section =
  EzAPI.Doc.{section_name = "order-aggregation-controller"; section_docs = []}
let order_bid_section =
  EzAPI.Doc.{section_name = "order-bid-controller"; section_docs = []}
let sections = [
  nft_section; ownerships_section; items_section; collections_section;
  orders_section; order_activities_section; aggregation_section; order_bid_section ]

let blockchain_param = EzAPI.Param.string "blockchain"
let address_param = EzAPI.Param.string "address"
(* TODO : int64 ?*)
let at_param = EzAPI.Param.int "at"
let continuation_param = EzAPI.Param.string "continuation"
let size_param = EzAPI.Param.int "size"
let contract_param = EzAPI.Param.string "contract"
(* TODO : big_integer *)
let token_id_param = EzAPI.Param.int "tokenId"
let include_meta_param = EzAPI.Param.string "includeMeta"
let owner_param = EzAPI.Param.string "owner"
let creator_param = EzAPI.Param.string "creator"
let collection_param = EzAPI.Param.string "collection"
let show_deleted_param = EzAPI.Param.bool "showDeleted"
let last_updated_from_param = EzAPI.Param.string "lastUpdateFrom"
let last_updated_to_param = EzAPI.Param.string "lastUpdateTo"
let origin_param = EzAPI.Param.string "origin"
(* TODO : ALL | RARIBLE | OPEN_SEA *)
let platform_param = EzAPI.Param.string "platform"
let fee_param = EzAPI.Param.int "fee"
let maker_param = EzAPI.Param.string "maker"
let start_date_param = EzAPI.Param.string "startDate"
let end_date_param = EzAPI.Param.string "endDate"
(* TODO : ALL | RARIBLE | OPEN_SEA *)
let source_param = EzAPI.Param.string "source"
let status_param = EzAPI.Param.string "status"

let hash_arg = EzAPI.Arg.string "hash"
let item_id_arg = EzAPI.Arg.string "itemId"
let collection_arg = EzAPI.Arg.string "collection"
let ownership_id_arg = EzAPI.Arg.string "ownershipId"


let mk_invalid_argument param msg =
  Error (invalid_argument (Printf.sprintf "%s %s" param.EzAPI.Param.param_id msg))

let get_origin_param req =
  let open Tzfunc.Crypto in
  match EzAPI.Req.find_param origin_param req with
  | None -> Ok None
  | Some o ->
    try
      ignore @@ Base58.decode Prefix.ed25519_public_key o ;
      Ok (Some o)
    with _ ->
      mk_invalid_argument origin_param "must be an edpk"

let get_size_param req =
  match EzAPI.Req.find_param size_param req with
  | None -> Ok None
  | Some s ->
    try
      let s = int_of_string s in
      if s < 1000 then Ok (Some s)
      else mk_invalid_argument size_param "maximum is 1000"
    with _ ->
      mk_invalid_argument size_param "must be an int"

let get_continuation_last_update_param req =
  match EzAPI.Req.find_param continuation_param req with
  | None -> Ok None
  | Some s ->
    try
      let l = String.split_on_char '_' s in
      match l with
      | ts :: h :: [] ->
        let ts = CalendarLib.Calendar.from_unixfloat (float_of_string ts) in
        Ok (Some (ts, h))
      | _ ->
        mk_invalid_argument continuation_param "must be in format TIMETAMP_HASH"
    with _ ->
      mk_invalid_argument continuation_param "must be in format TIMETAMP_HASH"

let get_required_maker_param req =
  let open Tzfunc.Crypto in
  match EzAPI.Req.find_param maker_param req with
  | None -> mk_invalid_argument maker_param "param is required"
  | Some o ->
    try
      ignore @@ Base58.decode Prefix.ed25519_public_key o ;
      Ok o
    with _ ->
      mk_invalid_argument maker_param "must be an epdk"

let get_maker_param req =
  let open Tzfunc.Crypto in
  match EzAPI.Req.find_param maker_param req with
  | None -> Ok None
  | Some o ->
    try
      ignore @@ Base58.decode Prefix.ed25519_public_key o ;
      Ok (Some o)
    with _ ->
      mk_invalid_argument maker_param "must be an epdk"

let get_required_contract_param req =
  let open Tzfunc.Crypto in
  match EzAPI.Req.find_param contract_param req with
  | None -> mk_invalid_argument contract_param "param is required"
  | Some o ->
    try
      ignore @@ Base58.decode Prefix.contract_public_key_hash o ;
      Ok o
    with _ ->
      mk_invalid_argument contract_param "must be a tezos smart contract address"

let get_required_token_id_param req =
  match EzAPI.Req.find_param token_id_param req with
  | None -> mk_invalid_argument token_id_param "param is required"
  | Some o -> Ok o

let get_required_collection_param req =
  let open Tzfunc.Crypto in
  match EzAPI.Req.find_param collection_param req with
  | None -> mk_invalid_argument collection_param "param is required"
  | Some o ->
    try
      ignore @@ Base58.decode Prefix.contract_public_key_hash o ;
      Ok o
    with _ ->
      mk_invalid_argument collection_param "must be a tezos smart contract address"

let get_required_owner_param req =
  match EzAPI.Req.find_param owner_param req with
  | None -> mk_invalid_argument owner_param "param is required"
  | Some o ->
    try
      match Tzfunc.Binary.Writer.contract o with
      | Error _ -> mk_invalid_argument owner_param "must be a pkh"
      | Ok _o -> Ok o
    with _ ->
      mk_invalid_argument owner_param "must be a pkh"

let get_include_meta_param req =
  match EzAPI.Req.find_param include_meta_param req with
  | None -> Ok None
  | Some s ->
    try
      Ok (Some (bool_of_string s))
    with _ ->
      mk_invalid_argument include_meta_param "must be a boolean"

let get_last_updated_to_param req =
  match EzAPI.Req.find_param last_updated_to_param req with
  | None -> Ok None
  | Some s ->
    try
      Ok (Some (CalendarLib.Calendar.from_unixfloat (float_of_string s)))
    with _ ->
      mk_invalid_argument last_updated_to_param "must be a date"

let get_last_updated_from_param req =
  match EzAPI.Req.find_param last_updated_from_param req with
  | None -> Ok None
  | Some s ->
    try
      Ok (Some (CalendarLib.Calendar.from_unixfloat (float_of_string s)))
    with _ ->
      mk_invalid_argument last_updated_from_param "must be a date"

let get_show_deleted_param req =
  match EzAPI.Req.find_param show_deleted_param req with
  | None -> Ok None
  | Some s ->
    try
      Ok (Some (bool_of_string s))
    with _ ->
      mk_invalid_argument show_deleted_param "must be a boolean"

let parse_item_id s =
  let open Tzfunc.Crypto in
  try
    let l = String.split_on_char ':' s in
    match l with
    | c :: tid :: [] ->
      ignore @@ Base58.decode Prefix.contract_public_key_hash c ;
      Ok (c, Int64.(to_string @@ of_string tid))
    | _ ->
      Error (invalid_argument "itemId must be in format contract:token_id")
  with _ ->
    Error (invalid_argument "itemId must be in format contract:token_id")

let get_continuation_items_param req =
  match EzAPI.Req.find_param continuation_param req with
  | None -> Ok None
  | Some s ->
    try
      let l = String.split_on_char '_' s in
      match l with
      | ts :: id:: [] ->
        let ts = CalendarLib.Calendar.from_unixfloat (float_of_string ts) in
        begin match parse_item_id id with
          | Error _ ->
            mk_invalid_argument continuation_param "must be in format TIMESTAMP_CONTRACT:TOKEN_ID"
          | Ok (_contract, _token_id) ->
            Ok (Some (ts, id))
        end
      | _ ->
        mk_invalid_argument continuation_param "must be in format TIMESTAMP_CONTRACT:TOKEN_ID"
    with _ ->
      mk_invalid_argument continuation_param "must be in format TIMESTAMP_"

let get_required_creator_param req =
  let param = creator_param in
  match EzAPI.Req.find_param param req with
  | None -> mk_invalid_argument param "param is required"
  | Some o ->
    try
      match Tzfunc.Binary.Writer.contract o with
      | Error _ -> mk_invalid_argument param "must be a pkh"
      | Ok _o -> Ok o
    with _ ->
      mk_invalid_argument param "must be a pkh"

let parse_collection_id s =
  let open Tzfunc.Crypto in
  try
    ignore @@ Base58.decode Prefix.contract_public_key_hash s ;
    Ok s
  with _ ->
    Error (invalid_argument  "collection must be a tezos smart contract address")

let get_continuation_collections_param req =
  match EzAPI.Req.find_param continuation_param req with
  | None -> Ok None
  | Some s ->
    try
      match parse_collection_id s with
      | Error _ -> mk_invalid_argument continuation_param "must be a tezos smart contract address"
      | Ok c -> Ok (Some c)
    with _ ->
      mk_invalid_argument continuation_param "must be a tezos smart contract address"

let parse_ownership_id s =
  let open Tzfunc.Crypto in
  try
    let l = String.split_on_char ':' s in
    match l with
    | c :: tid :: owner :: [] ->
      ignore @@ Base58.decode Prefix.contract_public_key_hash c ;
      ignore @@ Base58.decode Prefix.contract_public_key_hash owner ;
      Ok (c, Int64.(to_string @@ of_string tid), owner)
    | _ ->
      Error (invalid_argument "itemId must be in format contract:token_id:owner")
  with _ ->
    Error (invalid_argument "itemId must be in format contract:token_id:owner")

let get_continuation_ownerships_param req =
  match EzAPI.Req.find_param continuation_param req with
  | None -> Ok None
  | Some s ->
    try
      let l = String.split_on_char '_' s in
      match l with
      | ts :: id :: [] ->
        let ts = CalendarLib.Calendar.from_unixfloat (float_of_string ts) in
        begin match parse_ownership_id id with
          | Error _ ->
            mk_invalid_argument
              continuation_param "must be in format TIMESTAMP_CONTRACT:TOKEN_ID:OWNER"
          | Ok (_contract, _token_id, _owner) ->
            Ok (Some (ts, id))
        end
      | _ ->
        mk_invalid_argument
          continuation_param "must be in format TIMESTAMP_CONTRACT:TOKEN_ID:OWNER"
    with _ ->
      mk_invalid_argument
        continuation_param "must be in format TIMESTAMP_CONTRACT:TOKEN_ID:OWNER"

let get_required_start_date_param req =
  match EzAPI.Req.find_param start_date_param req with
  | None -> mk_invalid_argument start_date_param "param is required"
  | Some ts ->
    try
      let ts = CalendarLib.Calendar.from_unixfloat (float_of_string ts) in
      Ok ts
    with _ ->
      mk_invalid_argument owner_param "must be a date"

let get_end_date_param req =
  match EzAPI.Req.find_param end_date_param req with
  | None -> Ok None
  | Some ts ->
    try
      let ts = CalendarLib.Calendar.from_unixfloat (float_of_string ts) in
      Ok (Some ts)
    with _ ->
      mk_invalid_argument owner_param "must be a date"

let get_start_date_param req =
  match EzAPI.Req.find_param start_date_param req with
  | None -> Ok None
  | Some ts ->
    try
      let ts = CalendarLib.Calendar.from_unixfloat (float_of_string ts) in
      Ok (Some ts)
    with _ ->
      mk_invalid_argument owner_param "must be a date"

let get_required_end_date_param req =
  match EzAPI.Req.find_param end_date_param req with
  | None -> mk_invalid_argument end_date_param "param is required"
  | Some ts ->
    try
      let ts = CalendarLib.Calendar.from_unixfloat (float_of_string ts) in
      Ok ts
    with _ ->
      mk_invalid_argument owner_param "must be a date"

let get_required_status_param req =
  match EzAPI.Req.find_param status_param req with
  | None -> mk_invalid_argument status_param "param is required"
  | Some o ->
    try
      match String.split_on_char ',' o with
      | [] -> Ok [ EzEncoding.destruct order_bid_status_enc o ]
      | l -> Ok (List.map (EzEncoding.destruct order_bid_status_enc) l)
    with _ ->
      mk_invalid_argument
        status_param
        "must be a ACTIVE FILLED HISTORICAL, INACTIVE OR CANCELLED separated with ','"

let get_continuation_price_param req =
  match EzAPI.Req.find_param continuation_param req with
  | None -> Ok None
  | Some s ->
    try
      let l = String.split_on_char '_' s in
      match l with
      | ts :: h :: [] ->
        let f = (float_of_string ts) in
        Ok (Some (f, h))
      | _ ->
        mk_invalid_argument continuation_param "must be in format PRICE_HASH"
    with _ ->
      mk_invalid_argument continuation_param "must be in format PRICE_HASH"

(* (\* gateway-controller *\)
 * let create_gateway_pending_transactions _req _input =
 *   return (Error (unknown_error ""))
 * [@@post
 *   {path="/v0.1/transactions";
 *    input=create_transaction_request_enc;
 *    output=log_events_enc;
 *    errors=[rarible_error_500]}] *)

(* (\* currency-controller *\)
 * let get_currency_rate req () =
 *   let _blockchain = EzAPI.Req.find_param blockchain_param req in
 *   let _address = EzAPI.Req.find_param address_param req in
 *   let _at = EzAPI.Req.find_param at_param req in
 *   return (Error (unknown_error ""))
 * [@@get
 *   {path="/v0.1/rate";
 *    output=currency_rate_enc;
 *    errors=[rarible_error_500]}] *)

(* (\* erc20-balance-controller *\)
 * let get_erc20_balance ((_, erc20_contract), erc20_owner) () =
 *   return_ok { erc20_contract;
 *               erc20_owner;
 *               erc20_balance = Z.zero;
 *               erc20_decimal_balance = Z.zero }
 * [@@get
 *   {path="/v0.1/balances/{contract:string}/{owner:string}";
 *    output=erc20_decimal_balance_enc}] *)

(* (\* erc20-token-controller *\)
 * let get_erc20_token_by_id (_, contract) () =
 *   return (Error (token_not_found contract))
 * [@@get
 *   {path="/v0.1/tokens/{contract:string}";
 *    output=erc20_token_enc;
 *    errors=[rarible_error_404]}] *)

(* (\* nft-transaction-controller *\)
 * let create_nft_pending_transaction _req _input =
 *   return (Error (bad_request ""))
 * [@@post
 *   {path="/v0.1/nft/transactions";
 *    input=create_transaction_request_enc;
 *    output=log_events_enc;
 *    errors=[rarible_error_500]}] *)

(* nft-activity-controller *)
let get_nft_activities req input =
  match get_size_param req with
  | Error err -> return @@ Error err
  | Ok size ->
    match get_continuation_ownerships_param req with
    | Error err -> return @@ Error err
    | Ok continuation ->
      Db.get_nft_activities ?continuation ?size input >>= function
      | Error db_err ->
        let str = Crawlori.Rp.string_of_error db_err in
        return (Error (unexpected_api_error str))
      | Ok res -> return_ok res
[@@post
  {path="/v0.1/nft/activities/search";
   params=[size_param;continuation_param];
   input=nft_activity_filter_enc;
   output=nft_activities_enc;
   errors=[rarible_error_500];
   name="search_activities";
   section=nft_section}]

(* nft-ownership-controller *)
let get_nft_ownership_by_id (_, ownership_id) () =
  match parse_ownership_id ownership_id with
  | Error err -> return @@ Error err
  | Ok (contract, token_id, owner) ->
    Db.get_nft_ownership_by_id contract token_id owner >>= function
    | Error db_err ->
      let str = Crawlori.Rp.string_of_error db_err in
      return (Error (unexpected_api_error str))
    | Ok res -> return_ok res
[@@get
  {path="/v0.1/ownerships/{ownership_id_arg}";
   output=nft_ownership_enc;
   errors=[rarible_error_500];
   name="ownerships";
   section=ownerships_section}]

let get_nft_ownerships_by_item req () =
  match get_required_contract_param req with
  | Error err -> return @@ Error err
  | Ok contract ->
    match get_required_token_id_param req with
    | Error err -> return @@ Error err
    | Ok token_id ->
      match get_size_param req with
      | Error err -> return @@ Error err
      | Ok size ->
        match get_continuation_ownerships_param req with
        | Error err -> return @@ Error err
        | Ok continuation ->
          Db.get_nft_ownerships_by_item ?continuation ?size contract token_id >>= function
          | Error db_err ->
            let str = Crawlori.Rp.string_of_error db_err in
            return (Error (unexpected_api_error str))
          | Ok res -> return_ok res
[@@get
  {path="/v0.1/ownerships/byItem";
   params=[contract_param;token_id_param;size_param;continuation_param];
   output=nft_ownerships_enc;
   errors=[rarible_error_500];
   name="ownerships_by_item";
   section=ownerships_section}]

let get_nft_all_ownerships req () =
  match get_size_param req with
  | Error err -> return @@ Error err
  | Ok size ->
    match get_continuation_items_param req with
    | Error err -> return @@ Error err
    | Ok continuation ->
      Db.get_nft_all_ownerships ?continuation ?size () >>= function
      | Error db_err ->
        let str = Crawlori.Rp.string_of_error db_err in
        return (Error (unexpected_api_error str))
      | Ok res -> return_ok res
[@@get
  {path="/v0.1/ownerships/all";
   params=[size_param;continuation_param];
   output=nft_ownerships_enc;
   errors=[rarible_error_500];
   name="ownerships_all";
   section=ownerships_section}]

(* nft-item-controller *)
let get_nft_item_meta_by_id (_req, item_id) () =
  match parse_item_id item_id with
  | Error err -> return @@ Error err
  | Ok (contract, token_id) ->
    Db.get_nft_item_meta_by_id contract token_id >>= function
    | Error db_err ->
      let str = Crawlori.Rp.string_of_error db_err in
      return (Error (unexpected_api_error str))
    | Ok res -> return_ok res
[@@get
  {path="/v0.1/items/{item_id_arg}/meta";
   output=nft_item_meta_enc;
   errors=[rarible_error_500];
   name="items_meta";
   section=items_section
  }]

let get_nft_item_by_id (req, item_id) () =
  match parse_item_id item_id with
  | Error err -> return @@ Error err
  | Ok (contract, token_id) ->
    match get_include_meta_param req with
    | Error err -> return @@ Error err
    | Ok include_meta ->
      Db.get_nft_item_by_id ?include_meta contract token_id >>= function
      | Error db_err ->
        let str = Crawlori.Rp.string_of_error db_err in
        return (Error (unexpected_api_error str))
      | Ok res -> return_ok res
[@@get
  {path="/v0.1/items/{item_id_arg}";
   params=[include_meta_param];
   output=nft_item_enc;
   errors=[rarible_error_500];
   name="items_by_id";
   section=items_section}]

let get_nft_items_by_owner req () =
  match get_required_owner_param req with
  | Error err -> return (Error err)
  | Ok owner ->
    match get_include_meta_param req with
    | Error err -> return @@ Error err
    | Ok include_meta ->
      match get_size_param req with
      | Error err -> return @@ Error err
      | Ok size ->
        match get_continuation_items_param req with
        | Error err -> return @@ Error err
        | Ok continuation ->
          Db.get_nft_items_by_owner ?include_meta ?continuation ?size owner >>= function
          | Error db_err ->
            let str = Crawlori.Rp.string_of_error db_err in
            return (Error (unexpected_api_error str))
          | Ok res -> return_ok res
[@@get
  {path="/v0.1/items/byOwner";
   params=[owner_param;include_meta_param;size_param;continuation_param];
   output=nft_items_enc;
   errors=[rarible_error_500];
   name="items_by_owner";
   section=items_section}]

let get_nft_items_by_creator req () =
  match get_required_creator_param req with
  | Error err -> return (Error err)
  | Ok creator ->
    match get_include_meta_param req with
    | Error err -> return @@ Error err
    | Ok include_meta ->
      match get_size_param req with
      | Error err -> return @@ Error err
      | Ok size ->
        match get_continuation_items_param req with
        | Error err -> return @@ Error err
        | Ok continuation ->
          Db.get_nft_items_by_creator ?include_meta ?continuation ?size creator >>= function
          | Error db_err ->
            let str = Crawlori.Rp.string_of_error db_err in
            return (Error (unexpected_api_error str))
          | Ok res -> return_ok res
[@@get
  {path="/v0.1/items/byCreator";
   params=[creator_param;include_meta_param;size_param;continuation_param];
   output=nft_items_enc;
   errors=[rarible_error_500];
   name="items_by_creator";
   section=items_section}]

let get_nft_items_by_collection req () =
  match get_required_collection_param req with
  | Error err -> return (Error err)
  | Ok collection ->
    match get_include_meta_param req with
    | Error err -> return @@ Error err
    | Ok include_meta ->
      match get_size_param req with
      | Error err -> return @@ Error err
      | Ok size ->
        match get_continuation_items_param req with
        | Error err -> return @@ Error err
        | Ok continuation ->
          Db.get_nft_items_by_collection ?include_meta ?continuation ?size collection >>= function
          | Error db_err ->
            let str = Crawlori.Rp.string_of_error db_err in
            return (Error (unexpected_api_error str))
          | Ok res -> return_ok res
[@@get
  {path="/v0.1/items/byCollection";
   params=[collection_param;include_meta_param;size_param;continuation_param];
   output=nft_items_enc;
   errors=[rarible_error_500];
   name="items_by_collection";
   section=items_section}]

let get_nft_all_items req () =
  match get_last_updated_from_param req with
  | Error err -> return (Error err)
  | Ok last_updated_from ->
    match get_last_updated_to_param req with
    | Error err -> return (Error err)
    | Ok last_updated_to ->
      match get_show_deleted_param req with
      | Error err -> return (Error err)
      | Ok show_deleted ->
        match get_include_meta_param req with
        | Error err -> return @@ Error err
        | Ok include_meta ->
          match get_size_param req with
          | Error err -> return @@ Error err
          | Ok size ->
            match get_continuation_items_param req with
            | Error err -> return @@ Error err
            | Ok continuation ->
              Db.get_nft_all_items
                ?last_updated_to
                ?last_updated_from
                ?show_deleted
                ?include_meta
                ?continuation
                ?size
                () >>= function
              | Error db_err ->
                let str = Crawlori.Rp.string_of_error db_err in
                return (Error (unexpected_api_error str))
              | Ok res -> return_ok res
[@@get
  {path="/v0.1/items/all";
   params=[last_updated_from_param;last_updated_to_param;show_deleted_param;
           include_meta_param;size_param;continuation_param];
   output=nft_items_enc;
   errors=[rarible_error_500]}]

(* nft-collection-controller *)
let generate_nft_token_id (_req, collection) () =
  match parse_collection_id collection with
  | Error err -> return @@ Error err
  | Ok collection ->
    Db.generate_nft_token_id collection >>= function
    | Error db_err ->
      let str = Crawlori.Rp.string_of_error db_err in
      return (Error (unexpected_api_error str))
    | Ok res -> return_ok res
[@@get
  {path="/v0.1/collections/{collection_arg}/generate_token_id";
   output=nft_token_id_enc;
   errors=[rarible_error_500];
   name="collections_generate_id";
   section=collections_section}]

let get_nft_collection_by_id (_req, collection) () =
  match parse_collection_id collection with
  | Error err -> return @@ Error err
  | Ok collection ->
    Db.get_nft_collection_by_id collection >>= function
    | Error db_err ->
      let str = Crawlori.Rp.string_of_error db_err in
      return (Error (unexpected_api_error str))
    | Ok res -> return_ok res
[@@get
  {path="/v0.1/collections/{collection_arg}";
   output=nft_collection_enc;
   errors=[rarible_error_500];
   name="collections_by_id";
   section=collections_section}]

let search_nft_collections_by_owner req () =
  match get_required_owner_param req with
  | Error err -> return (Error err)
  | Ok owner ->
    match get_size_param req with
    | Error err -> return @@ Error err
    | Ok size ->
      match get_continuation_collections_param req with
      | Error err -> return @@ Error err
      | Ok continuation ->
        Db.search_nft_collections_by_owner ?continuation ?size owner >>= function
        | Error db_err ->
          let str = Crawlori.Rp.string_of_error db_err in
          return (Error (unexpected_api_error str))
        | Ok res -> return_ok res
[@@get
  {path="/v0.1/collections/byOwner";
   params=[owner_param;size_param;continuation_param];
   output=nft_collections_enc;
   errors=[rarible_error_500];
   name="collections_by_owner";
   section=collections_section}]

let search_nft_all_collections req () =
  match get_size_param req with
  | Error err -> return @@ Error err
  | Ok size ->
    match get_continuation_collections_param req with
    | Error err -> return @@ Error err
    | Ok continuation ->
      Db.get_nft_all_collections ?continuation ?size () >>= function
      | Error db_err ->
        let str = Crawlori.Rp.string_of_error db_err in
        return (Error (unexpected_api_error str))
      | Ok res -> return_ok res
[@@get
  {path="/v0.1/collections/all";
   params=[size_param;continuation_param];
   output=nft_collections_enc;
   errors=[rarible_error_500];
   name="collections_all";
   section=collections_section}]

(* (\* order-transaction-controller *\)
 * let create_order_pending_transaction _req _input =
 *   return (Error (unexpected_api_error ""))
 * [@@post
 *   {path="/v0.1/order/transactions";
 *    input=create_transaction_request_enc;
 *    output=log_events_enc;
 *    errors=[rarible_error_500]}] *)

(* order-controller *)

let validate_signature order =
  let order_elt = order.order_elt in
  let data_type, payouts, origin_fees = match order.order_data with
    | RaribleV2Order d ->
      d.order_rarible_v2_data_v1_data_type, d.order_rarible_v2_data_v1_payouts,
      d.order_rarible_v2_data_v1_origin_fees
    | _ -> assert false in
  let$> msg = hash_order_form order_elt.order_elt_maker order_elt.order_elt_make
      order_elt.order_elt_taker order_elt.order_elt_take
      order_elt.order_elt_salt order_elt.order_elt_start order_elt.order_elt_end
      data_type payouts origin_fees in
  Format.eprintf "validate_signature\n%!";
  let signature = order_elt.order_elt_signature in
  let edpk = order_elt.order_elt_maker in
  Format.eprintf "validate_signature1\n%!";
  if check ~edpk ~signature ~bytes:msg then
    Lwt.return_ok ()
  else
    Lwt.return_error (invalid_argument "Incorrect signature")

let validate_order order =
  Format.eprintf "validate_order\n%!";
  (* No need to check form.data as other combinations are not accepted by the input encoding *)
  validate_signature order >>=? fun () ->
  Lwt.return_ok ()

let validate existing update =
  let existing_make_value = existing.order_elt.order_elt_make.asset_value in
  let update_make_value = update.order_elt.order_elt_make.asset_value in
  let existing_take_value = existing.order_elt.order_elt_take.asset_value in
  let update_take_value = update.order_elt.order_elt_take.asset_value in
  if existing.order_elt.order_elt_cancelled then
    Lwt.return (Error (invalid_argument "Order is cancelled"))
  else if existing.order_data <> update.order_data then
    Lwt.return (Error (invalid_argument "Invalide update data"))
  else if existing.order_elt.order_elt_start <>
          update.order_elt.order_elt_start then
    Lwt.return (Error (invalid_argument "Invalide update start date"))
  else if existing.order_elt.order_elt_end <>
          update.order_elt.order_elt_end then
    Lwt.return (Error (invalid_argument "Invalide update end date"))
  else if existing.order_elt.order_elt_taker <>
          update.order_elt.order_elt_taker then
    Lwt.return (Error (invalid_argument "Invalide update taker"))
  else if update_make_value < existing_make_value then
    Lwt.return (Error (invalid_argument "Invalide update can't decrease make asset value"))
  else
    let new_max_take =
      Z.(div
           (mul (of_string update_make_value) (of_string existing_take_value))
           (of_string existing_make_value)) in
    if new_max_take < Z.of_string update_take_value then
      Lwt.return (Error (invalid_argument "Invalide update new max take"))
    else Lwt.return_ok ()

let get_existing_order hash_key_order =
  Format.eprintf "get_existing_order\n%!";
  Db.get_order hash_key_order

let upsert_order _req input =
  Format.eprintf "upsert_order\n%!";
  match order_from_order_form input with
  | Error err -> return (Error (unexpected_api_error @@ string_of_error err))
  | Ok order ->
    validate_order order >>= function
    | Error err -> return (Error err)
    | Ok () ->
      get_existing_order order.order_elt.order_elt_hash >>= function
      | Error db_err ->
        let str = Crawlori.Rp.string_of_error db_err in
        return (Error (unexpected_api_error str))
      | Ok existing_order ->
        begin match existing_order with
          | None -> Lwt.return @@ Ok order
          | Some existing_order ->
            validate existing_order order >>= function
            | Error err -> Lwt.return @@ Error err
            | Ok () ->
              let now = CalendarLib.Calendar.now () in
              let asset_value = order.order_elt.order_elt_make.asset_value in
              let old_make_asset = existing_order.order_elt.order_elt_make in
              let order_elt_make = { old_make_asset with asset_value } in
              let asset_value = order.order_elt.order_elt_take.asset_value in
              let old_take_asset = existing_order.order_elt.order_elt_take in
              let order_elt_take = { old_take_asset with asset_value } in
              let order_elt_make_stock = order.order_elt.order_elt_make_stock in
              let order_elt_signature = order.order_elt.order_elt_signature in
              Lwt.return @@ Ok
                { existing_order with
                  order_elt =
                    { existing_order.order_elt with
                      order_elt_make ;
                      order_elt_take ;
                      order_elt_make_stock ;
                      order_elt_signature ;
                      order_elt_last_update_at = now ;
                    }
                }
        end >>= function
        | Error err ->
          return (Error err)
        | Ok order ->
          (* TODO : USDVALUES *)
          (* TODO : pricehistory *)
          Db.upsert_order order >>= function
          | Error db_err ->
            let str = Crawlori.Rp.string_of_error db_err in
            return (Error (unexpected_api_error str))
          | Ok () ->
            Db.get_order order.order_elt.order_elt_hash >>= function
            | Error db_err ->
              let str = Crawlori.Rp.string_of_error db_err in
              return (Error (unexpected_api_error str))
            | Ok None ->
              return (Error (unexpected_api_error "order not registered"))
            | Ok Some (order) ->
              return_ok order
(* kafkta.push order *)
[@@post
  {path="/v0.1/orders";
   input=order_form_enc;
   output=order_enc;
   errors=[rarible_error_500];
   name="orders_upsert";
   section=orders_section}]

let get_orders_all req () =
  (* let _platform = EzAPI.Req.find_param platform_param req in *)
  Format.eprintf "get_orders_all\n%!";
  match get_origin_param req with
  | Error err -> return @@ Error err
  | Ok origin ->
    match get_size_param req with
    | Error err -> return @@ Error err
    | Ok size ->
      match get_continuation_last_update_param req with
      | Error err -> return @@ Error err
      | Ok continuation ->
        Db.get_orders_all ?origin ?continuation ?size () >>= function
        | Error db_err ->
          let str = Crawlori.Rp.string_of_error db_err in
          return (Error (unexpected_api_error str))
        | Ok res -> return_ok res
[@@get
  {path="/v0.1/orders/all";
   params=[origin_param;size_param;continuation_param];
   output=orders_pagination_enc;
   errors=[rarible_error_500];
   name="orders_all";
   section=orders_section}]

let get_order_by_hash (_req, hash) () =
  Db.get_order hash >>= function
  | Ok (Some order) -> return_ok order
  | Ok None -> return (Error (invalid_argument "No order with this hash"))
  | Error db_err ->
    let str = Crawlori.Rp.string_of_error db_err in
    return (Error (unexpected_api_error str))
[@@get
  {path="/v0.1/orders/{hash_arg}";
   output=order_enc;
   errors=[rarible_error_500];
   name="orders_by_hash";
   section=orders_section}]

(* let update_order_make_stock _req () =
 *   return (Error (unexpected_api_error ""))
 * [@@get
 *   {path="/v0.1/orders/{hash_arg}/updateMakeStock";
 *    output=order_enc;
 *    errors=[rarible_error_500]}]
 *
 * let buyer_fee_signature req _input =
 *   let _fee = EzAPI.Req.find_param fee_param req in
 *   return (Error (unexpected_api_error ""))
 * [@@post
 *   {path="/v0.1/orders/buyerFeeSignature";
 *    input=order_form_enc;
 *    output=A.binary_enc;
 *    errors=[rarible_error_500]}] *)

let get_sell_orders_by_maker req () =
  (* let _platform = EzAPI.Req.find_param platform_param req in *)
  Format.eprintf "get_sell_orders_by_maker\n%!";
  match get_required_maker_param req with
  | Error err -> return @@ Error err
  | Ok maker ->
    match get_origin_param req with
    | Error err -> return @@ Error err
    | Ok origin ->
      match get_size_param req with
      | Error err -> return @@ Error err
      | Ok size ->
        match get_continuation_last_update_param req with
        | Error err -> return @@ Error err
        | Ok continuation ->
          Db.get_sell_orders_by_maker ?origin ?continuation ?size maker >>= function
          | Error db_err ->
            let str = Crawlori.Rp.string_of_error db_err in
            return (Error (unexpected_api_error str))
          | Ok res -> return_ok res
[@@get
  {path="/v0.1/orders/sell/byMaker";
   params=[maker_param;origin_param;size_param;continuation_param];
   output=orders_pagination_enc;
   errors=[rarible_error_500];
   name="orders_by_maker";
   section=orders_section}]

let get_sell_orders_by_item req () =
  (* let _platform = EzAPI.Req.find_param platform_param req in *)
  Format.eprintf "get_sell_orders_by_item\n%!";
  match get_required_contract_param req with
  | Error err -> return @@ Error err
  | Ok contract ->
    match get_required_token_id_param req with
    | Error err -> return @@ Error err
    | Ok token_id ->
      match get_maker_param req with
      | Error err -> return @@ Error err
      | Ok maker ->
        match get_origin_param req with
        | Error err -> return @@ Error err
        | Ok origin ->
          match get_size_param req with
          | Error err -> return @@ Error err
          | Ok size ->
            match get_continuation_last_update_param req with
            | Error err -> return @@ Error err
            | Ok continuation ->
              Db.get_sell_orders_by_item
                ?origin ?continuation ?size ?maker contract token_id >>= function
              | Error db_err ->
                let str = Crawlori.Rp.string_of_error db_err in
                return (Error (unexpected_api_error str))
              | Ok res -> return_ok res
[@@get
  {path="/v0.1/orders/sell/byItem";
   params=[contract_param;token_id_param;maker_param;origin_param;
           size_param;continuation_param];
   output=orders_pagination_enc;
   errors=[rarible_error_500];
   name="orders_sell_by_item";
   section=orders_section}]

let get_sell_orders_by_collection req () =
  (* let _platform = EzAPI.Req.find_param platform_param req in *)
  Format.eprintf "get_sell_orders_by_collection\n%!";
  match get_required_collection_param req with
  | Error err -> return @@ Error err
  | Ok collection ->
    match get_origin_param req with
    | Error err -> return @@ Error err
    | Ok origin ->
      match get_size_param req with
      | Error err -> return @@ Error err
      | Ok size ->
        match get_continuation_last_update_param req with
        | Error err -> return @@ Error err
        | Ok continuation ->
          Db.get_sell_orders_by_collection
            ?origin ?continuation ?size collection >>= function
          | Error db_err ->
            let str = Crawlori.Rp.string_of_error db_err in
            return (Error (unexpected_api_error str))
          | Ok res -> return_ok res
[@@get
  {path="/v0.1/orders/sell/byCollection";
   params=[collection_param;origin_param;size_param;continuation_param];
   output=orders_pagination_enc;
   errors=[rarible_error_500];
   name="orders_sell_by_collection";
   section=orders_section}]

let get_sell_orders req () =
  (* let _platform = EzAPI.Req.find_param platform_param req in *)
  Format.eprintf "get_sell_orders\n%!";
  match get_origin_param req with
  | Error err -> return @@ Error err
  | Ok origin ->
    match get_size_param req with
    | Error err -> return @@ Error err
    | Ok size ->
      match get_continuation_last_update_param req with
      | Error err -> return @@ Error err
      | Ok continuation ->
        Db.get_sell_orders ?origin ?continuation ?size () >>= function
        | Error db_err ->
          let str = Crawlori.Rp.string_of_error db_err in
          return (Error (unexpected_api_error str))
        | Ok res -> return_ok res
[@@get
  {path="/v0.1/orders/sell";
   params=[origin_param;size_param;continuation_param];
   output=orders_pagination_enc;
   errors=[rarible_error_500];
   name="orders_sell";
   section=orders_section}]

let get_order_bids_by_maker req () =
  (* let _platform = EzAPI.Req.find_param platform_param req in *)
  Format.eprintf "get_order_bids_by_maker\n%!";
  match get_required_maker_param req with
  | Error err -> return @@ Error err
  | Ok maker ->
    match get_origin_param req with
    | Error err -> return @@ Error err
    | Ok origin ->
      match get_size_param req with
      | Error err -> return @@ Error err
      | Ok size ->
        match get_continuation_last_update_param req with
        | Error err -> return @@ Error err
        | Ok continuation ->
          Db.get_bid_orders_by_maker ?origin ?continuation ?size maker >>= function
          | Error db_err ->
            let str = Crawlori.Rp.string_of_error db_err in
            return (Error (unexpected_api_error str))
          | Ok res -> return_ok res
[@@get
  {path="/v0.1/orders/bids/byMaker";
   params=[maker_param;origin_param;size_param;continuation_param];
   output=orders_pagination_enc;
   errors=[rarible_error_500];
   name="orders_bids_by_maker";
   section=orders_section}]

let get_order_bids_by_item req () =
  (* let _platform = EzAPI.Req.find_param platform_param req in *)
  Format.eprintf "get_order_bids_by_item\n%!";
  match get_required_contract_param req with
  | Error err -> return @@ Error err
  | Ok contract ->
    match get_required_token_id_param req with
    | Error err -> return @@ Error err
    | Ok token_id ->
      match get_maker_param req with
      | Error err -> return @@ Error err
      | Ok maker ->
        match get_origin_param req with
        | Error err -> return @@ Error err
        | Ok origin ->
          match get_size_param req with
          | Error err -> return @@ Error err
          | Ok size ->
            match get_continuation_last_update_param req with
            | Error err -> return @@ Error err
            | Ok continuation ->
              Db.get_bid_orders_by_item
                ?origin ?continuation ?size ?maker contract token_id >>= function
              | Error db_err ->
                let str = Crawlori.Rp.string_of_error db_err in
                return (Error (unexpected_api_error str))
              | Ok res -> return_ok res
[@@get
  {path="/v0.1/orders/bids/byItem";
   params=[contract_param;token_id_param;maker_param;origin_param;
           size_param;continuation_param];
   output=orders_pagination_enc;
   errors=[rarible_error_500];
   name="orders_bids_by_item";
   section=orders_section}]

(* order-aggregation-controller *)
let aggregate_nft_sell_by_maker req () =
  (* let _source = EzAPI.Req.find_param source_param req in *)
  match get_required_start_date_param req with
  | Error err -> return @@ Error err
  | Ok start_date ->
    match get_required_end_date_param req with
    | Error err -> return @@ Error err
    | Ok end_date ->
      match get_size_param req with
      | Error err -> return @@ Error err
      | Ok size ->
        if start_date >= end_date then
          return (Error (invalid_argument "startDate must be greater the endDate"))
        else
          Db.aggregate_nft_sell_by_maker ?size start_date end_date >>= function
          | Error db_err ->
            let str = Crawlori.Rp.string_of_error db_err in
            return (Error (unexpected_api_error str))
          | Ok res -> return_ok res
[@@get
  {path="/v0.1/aggregations/nftSellByMaker";
   params=[start_date_param;end_date_param;size_param];
   output=aggregation_datas_enc;
   errors=[rarible_error_500];
   name="aggregate_nft_sell_by_maker";
   section=aggregation_section}]

let aggregate_nft_purchase_by_taker req () =
  (* let _source = EzAPI.Req.find_param source_param req in *)
  match get_required_start_date_param req with
  | Error err -> return @@ Error err
  | Ok start_date ->
    match get_required_end_date_param req with
    | Error err -> return @@ Error err
    | Ok end_date ->
      match get_size_param req with
      | Error err -> return @@ Error err
      | Ok size ->
        if start_date >= end_date then
          return (Error (invalid_argument "startDate must be greater the endDate"))
        else
          Db.aggregate_nft_sell_by_taker ?size start_date end_date >>= function
          | Error db_err ->
            let str = Crawlori.Rp.string_of_error db_err in
            return (Error (unexpected_api_error str))
          | Ok res -> return_ok res
[@@get
  {path="/v0.1/aggregations/nftPurchaseByTaker";
   output=aggregation_datas_enc;
   params=[start_date_param;end_date_param;size_param];
   errors=[rarible_error_500];
   name="aggregate_nft_sell_by_taker";
   section=aggregation_section}]

let aggregate_nft_purchase_buy_collection req () =
  (* let _source = EzAPI.Req.find_param source_param req in *)
  match get_required_start_date_param req with
  | Error err -> return @@ Error err
  | Ok start_date ->
    match get_required_end_date_param req with
    | Error err -> return @@ Error err
    | Ok end_date ->
      match get_size_param req with
      | Error err -> return @@ Error err
      | Ok size ->
        if start_date >= end_date then
          return (Error (invalid_argument "startDate must be greater the endDate"))
        else
          Db.aggregate_nft_sell_by_collection ?size start_date end_date >>= function
          | Error db_err ->
            let str = Crawlori.Rp.string_of_error db_err in
            return (Error (unexpected_api_error str))
          | Ok res -> return_ok res
[@@get
  {path="/v0.1/aggregations/nftPurchaseByCollection";
   params=[start_date_param;end_date_param;size_param];
   output=aggregation_datas_enc;
   errors=[rarible_error_500];
   name="aggregate_nft_sell_by_collection";
   section=aggregation_section}]

(* order-activity-controller *)
let get_order_activities req input =
  match get_size_param req with
  | Error err -> return @@ Error err
  | Ok size ->
    match get_continuation_last_update_param req with
    | Error err -> return @@ Error err
    | Ok continuation ->
      Db.get_order_activities ?continuation ?size input >>= function
      | Error db_err ->
        let str = Crawlori.Rp.string_of_error db_err in
        return (Error (unexpected_api_error str))
      | Ok res -> return_ok res
[@@post
  {path="/v0.1/order/activities/search";
   params=[size_param;continuation_param];
   name="get_order_activities";
   input=order_activity_filter_enc;
   output=order_activities_enc;
   errors=[rarible_error_500];
   section=order_activities_section}]

(* order-bid-controller *)
let get_bids_by_item req () =
  (* let _platform = EzAPI.Req.find_param platform_param req in *)
  match get_required_contract_param req with
  | Error err -> return @@ Error err
  | Ok contract ->
    match get_required_token_id_param req with
    | Error err -> return @@ Error err
    | Ok token_id ->
      match get_required_status_param req with
      | Error err -> return @@ Error err
      | Ok status ->
        match get_start_date_param req with
        | Error err -> return @@ Error err
        | Ok start_date ->
          match get_end_date_param req with
          | Error err -> return @@ Error err
          | Ok end_date ->
            match get_size_param req with
            | Error err -> return @@ Error err
            | Ok size ->
              match get_continuation_price_param req with
              | Error err -> return @@ Error err
              | Ok continuation ->
                Db.get_bids_by_item
                  ?start_date ?end_date ?continuation ?size contract token_id status >>= function
                | Error db_err ->
                  let str = Crawlori.Rp.string_of_error db_err in
                  return (Error (unexpected_api_error str))
                | Ok res -> return_ok res
[@@get
  {path="/v0.1/bids/byItem";
   params=[contract_param;token_id_param;start_date_param;end_date_param;
           status_param;continuation_param;size_param];
   name="get_bids_by_item";
   output=order_bids_pagination_enc;
   errors=[rarible_error_500];
   section=order_bid_section}]

(* module V_0_1 = struct
 *
 *   module Acontroller = struct
 *     let dir = empty
 *   end
 *
 *   module Bcontroller = struct
 *     let dir = Acontroller.dir
 *   end
 *   module Ccontroler = struct
 *     let dur = Bcontroller.dir
 *   end
 *
 * end *)

(* Update Order *)
(* - core/service/OrderReduceService: event of exchange contract
 * - listener/job/OrderPricesUpdateJob: daemon that updates the usd price of erc20 assets
 * - listener/service/order/OrderUpdateTaskHandler: deamon that updates make_balance field
 * - listener/service/order/OrderBalanceService: deamon that updates make_balance field (in case of ownerhsip event or erc20 balance event)
 * - api/service/order/OrderService: upsert *)

(* Update OrderVersion *)
(* - listener/listener/job/OrderPricesUpdateJob *)
(* - api/service/order/OrderService: upsert *)

(* Order Activities *)
(* Merge de history et Orderversion *)

(* ExchangeHistoryRepo saves *)
(* Log event of exchange contract *)
(* -> ENTRYPOINT CANCEL MATCH_ORDERS *)
(* VOIR ExchangeOrderMatchDescriptor OnExchangeLogEventListener et OrderReduceService *)
