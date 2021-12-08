open EzAPIServer
open Rtypes
open Common
open Let
open Errors

module Errors = Errors

(* let _ =
 *   let s =
 *     Tzfunc.Crypto.Base58.encode
 *       Tzfunc.Crypto.Prefix.generic_signature
 *       (Hex.to_string @@
 *        `Hex
 *          "45461654b86e856686e7a2e9a9213b29f8dc32a731046e0c2f1aa01e4eaa991e41ebc67535fac14c333ad5b0d0d821ef518edc9ed08ad7efc0af572620c045ce1c") in
 *   Format.eprintf "XX %S\n%!" s *)

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
let signature_section =
  EzAPI.Doc.{section_name = "order-signature-controller"; section_docs = []}
let balance_section =
  EzAPI.Doc.{section_name = "ft-balance-controller"; section_docs = []}
let sections = [
  nft_section; ownerships_section; items_section; collections_section;
  orders_section; order_activities_section; aggregation_section; order_bid_section;
  signature_section; balance_section; Kafka_openapi.kafka_section ]

let pstring ?enc ?required name =
  let schema = Option.map (Json_encoding.schema ~definitions_path:"/components/schemas/") enc in
  EzAPI.Param.(make ?schema ?required PARAM_STRING name)

let pint ?enc ?required name =
  let schema = Option.map (Json_encoding.schema ~definitions_path:"/components/schemas/") enc in
  EzAPI.Param.(make ?schema ?required PARAM_INT name)

let pbool ?enc ?required name =
  let schema = Option.map (Json_encoding.schema ~definitions_path:"/components/schemas/") enc in
  EzAPI.Param.(make ?schema ?required PARAM_BOOL name)

let blockchain_param = pstring "blockchain"
let address_param = pstring ~enc:A.address_enc "address"
(* TODO : int64 ?*)
let at_param = pint "at"
let continuation_param = pstring "continuation"
let size_param = pint ~enc:A.uint53 "size"
let contract_param = pstring ~enc:A.address_enc "contract"
(* TODO : big_integer *)
let token_id_param = pstring ~enc:A.big_integer_enc "tokenId"
let include_meta_param = pbool "includeMeta"
let owner_param = pstring ~enc:A.address_enc "owner"
let creator_param = pstring ~enc:A.address_enc "creator"
let collection_param = pstring ~enc:A.address_enc "collection"
let show_deleted_param = pbool "showDeleted"
let last_updated_from_param = pstring "lastUpdateFrom"
let last_updated_to_param = pstring "lastUpdateTo"
let origin_param = pstring ~enc:A.address_enc "origin"
(* TODO : ALL | RARIBLE | OPEN_SEA *)
let platform_param = pstring "platform"
let maker_param = pstring ~enc:A.address_enc "maker"
let start_date_param = pint ~enc:A.uint53 "startDate"
let end_date_param = pint ~enc:A.uint53 "endDate"
(* TODO : ALL | RARIBLE | OPEN_SEA *)
let source_param = pstring "source"
let status_param = pstring ~enc:(Json_encoding.list order_status_enc) "status"
let currency_param = pstring "currencyId"
let sort_param = pstring ~enc:activity_sort_enc "sort"

let hash_arg = EzAPI.Arg.string "hash"
let item_id_arg = EzAPI.Arg.string "itemId"
let collection_arg = EzAPI.Arg.string "collection"
let ownership_id_arg = EzAPI.Arg.string "ownershipId"

let return = function
  | Error e ->
    let code = Errors.code_of_error e in
    return ~code (Error e)
  | Ok x -> return (Ok x)

let mk_invalid_argument param msg =
  Error {code=`BAD_REQUEST; message=Printf.sprintf "%s %s" param.EzAPI.Param.param_id msg}

let get_origin_param req =
  let open Tzfunc.Crypto in
  match EzAPI.Req.find_param origin_param req with
  | None -> Ok None
  | Some o ->
    try
      ignore @@ Pkh.b58dec o ;
      Ok (Some o)
    with _ ->
      mk_invalid_argument origin_param "must be an tz1"

let get_size_param req =
  match EzAPI.Req.find_param size_param req with
  | None -> Ok None
  | Some s ->
    try
      let s = int_of_string s in
      if s < 1001 then Ok (Some s)
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
        let ts = CalendarLib.Calendar.from_unixfloat (float_of_string ts /. 1000.) in
        Ok (Some (ts, h))
      | ts :: tl ->
        begin match tl with
          | [] -> mk_invalid_argument continuation_param "must be in format TIMETAMP_HASH"
          | _ ->
            let ts = CalendarLib.Calendar.from_unixfloat (float_of_string ts /. 1000.) in
            Ok (Some (ts, String.concat "_" tl))
        end
      | [] -> mk_invalid_argument continuation_param "must be in format TIMETAMP_HASH"
    with _ ->
      mk_invalid_argument continuation_param "must be in format TIMETAMP_HASH"

let get_required_maker_param req =
  let open Tzfunc.Crypto in
  match EzAPI.Req.find_param maker_param req with
  | None -> mk_invalid_argument maker_param "param is required"
  | Some o ->
    try
      ignore @@ Pkh.b58dec o ;
      Ok o
    with _ ->
      mk_invalid_argument maker_param "must be an tz1"

let get_maker_param req =
  let open Tzfunc.Crypto in
  match EzAPI.Req.find_param maker_param req with
  | None -> Ok None
  | Some o ->
    try
      ignore @@ Pkh.b58dec o ;
      Ok (Some o)
    with _ ->
      mk_invalid_argument maker_param "must be an tz1"

let get_required_contract_param req =
  let open Tzfunc.Crypto in
  match EzAPI.Req.find_param contract_param req with
  | None -> mk_invalid_argument contract_param "param is required"
  | Some o ->
    try
      ignore @@ Base58.decode ~prefix:Prefix.contract_public_key_hash o ;
      Ok o
    with _ ->
      mk_invalid_argument contract_param "must be a tezos smart contract address"

let get_required_token_id_param req =
  match EzAPI.Req.find_param token_id_param req with
  | None -> mk_invalid_argument token_id_param "param is required"
  | Some o -> Ok (Z.of_string o)

let get_required_collection_param req =
  let open Tzfunc.Crypto in
  match EzAPI.Req.find_param collection_param req with
  | None -> mk_invalid_argument collection_param "param is required"
  | Some o ->
    try
      ignore @@ Base58.decode ~prefix:Prefix.contract_public_key_hash o ;
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
      Ok (Some (CalendarLib.Calendar.from_unixfloat (float_of_string s /. 1000.)))
    with _ ->
      mk_invalid_argument last_updated_to_param "must be a date"

let get_last_updated_from_param req =
  match EzAPI.Req.find_param last_updated_from_param req with
  | None -> Ok None
  | Some s ->
    try
      Ok (Some (CalendarLib.Calendar.from_unixfloat (float_of_string s /. 1000.)))
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
      ignore @@ Base58.decode ~prefix:Prefix.contract_public_key_hash c ;
      Ok (c, Z.of_string tid)
    | _ ->
      Error {code=`BAD_REQUEST; message="itemId must be in format contract:token_id"}
  with _ ->
    Error {code=`BAD_REQUEST; message="itemId must be in format contract:token_id"}

let get_continuation_items_param req =
  match EzAPI.Req.find_param continuation_param req with
  | None -> Ok None
  | Some s ->
    try
      let l = String.split_on_char '_' s in
      match l with
      | ts :: id :: [] ->
        begin
          try
            let ts = CalendarLib.Calendar.from_unixfloat (float_of_string ts /. 1000.) in
            let l = String.split_on_char ':' id in
            match l with
            | _c :: _tid :: [] ->
              Ok (Some (ts, id))
            | _ ->
              mk_invalid_argument continuation_param "must be in format TIMESTAMP_CONTRACT:TOKEN_ID"
          with _ ->
            mk_invalid_argument continuation_param "must be in format TIMESTAMP_CONTRACT:TOKEN_ID"
        end
      | _ ->
        mk_invalid_argument continuation_param "must be in format TIMESTAMP_CONTRACT:TOKEN_ID"
    with _ ->
      mk_invalid_argument continuation_param "must be in format TIMESTAMP_CONTRACT:TOKEN_ID"

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
    ignore @@ Base58.decode ~prefix:Prefix.contract_public_key_hash s ;
    Ok s
  with _ ->
    Error {code=`BAD_REQUEST; message="collection must be a tezos smart contract address"}

let get_continuation_collections_param req =
  Ok (EzAPI.Req.find_param continuation_param req)

let parse_ownership_id s =
  let open Tzfunc.Crypto in
  try
    let l = String.split_on_char ':' s in
    match l with
    | c :: tid :: owner :: [] ->
      ignore @@ Base58.decode ~prefix:Prefix.contract_public_key_hash c ;
      ignore @@ Base58.decode ~prefix:Prefix.contract_public_key_hash owner ;
      Ok (c, Z.of_string tid, owner)
    | _ ->
      Error {code=`BAD_REQUEST; message="itemId must be in format contract:token_id:owner"}
  with _ ->
    Error {code=`BAD_REQUEST; message="itemId must be in format contract:token_id:owner"}

let get_continuation_ownerships_param req =
  match EzAPI.Req.find_param continuation_param req with
  | None -> Ok None
  | Some s ->
    try
      let l = String.split_on_char '_' s in
      match l with
      | ts :: id :: [] ->
        let ts = CalendarLib.Calendar.from_unixfloat (float_of_string ts /. 1000.) in
        begin
          try
            let l = String.split_on_char ':' id in
            match l with
            | _c :: _tid :: _owner :: [] ->
              Ok (Some (ts, id))
            | _ ->
              mk_invalid_argument
                continuation_param "must be in format TIMESTAMP_CONTRACT:TOKEN_ID:OWNER"

          with _ ->
            mk_invalid_argument
              continuation_param "must be in format TIMESTAMP_CONTRACT:TOKEN_ID:OWNER"

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
      let ts = CalendarLib.Calendar.from_unixfloat (float_of_string ts /. 1000.) in
      Ok ts
    with _ ->
      mk_invalid_argument owner_param "must be a date"

let get_end_date_param req =
  match EzAPI.Req.find_param end_date_param req with
  | None -> Ok None
  | Some ts ->
    try
      let ts = CalendarLib.Calendar.from_unixfloat (float_of_string ts /. 1000.) in
      Ok (Some ts)
    with _ ->
      mk_invalid_argument owner_param "must be a date"

let get_start_date_param req =
  match EzAPI.Req.find_param start_date_param req with
  | None -> Ok None
  | Some ts ->
    try
      let ts = CalendarLib.Calendar.from_unixfloat (float_of_string ts /. 1000.) in
      Ok (Some ts)
    with _ ->
      mk_invalid_argument owner_param "must be a date"

let get_required_end_date_param req =
  match EzAPI.Req.find_param end_date_param req with
  | None -> mk_invalid_argument end_date_param "param is required"
  | Some ts ->
    try
      let ts = CalendarLib.Calendar.from_unixfloat (float_of_string ts /. 1000.) in
      Ok ts
    with _ ->
      mk_invalid_argument owner_param "must be a date"

let get_required_status_param req =
  match EzAPI.Req.find_param status_param req with
  | None -> mk_invalid_argument status_param "param is required"
  | Some o ->
    try
      let l = List.map (fun s -> EzEncoding.destruct order_bid_status_enc (Format.sprintf "%S" s))
        @@ String.split_on_char ',' o in
      Ok (Some l)
    with _ ->
      mk_invalid_argument
        status_param
        "must be a ACTIVE, FILLED, HISTORICAL, INACTIVE OR CANCELLED separated with ','"

let get_status_param req =
  match EzAPI.Req.find_param status_param req with
  | None -> Ok None
  | Some o ->
    try
      let l = List.map (fun s -> EzEncoding.destruct order_status_enc (Format.sprintf "%S" s))
        @@ String.split_on_char ',' o in
      Ok (Some l)
    with _ ->
      mk_invalid_argument
        status_param
        "must be a ACTIVE, FILLED, HISTORICAL, INACTIVE OR CANCELLED separated with ','"

let get_continuation_price_param req =
  match EzAPI.Req.find_param continuation_param req with
  | None -> Ok None
  | Some s ->
    try
      let l = String.split_on_char '_' s in
      match l with
      | ts :: h :: [] ->
        Ok (Some (ts, h))
      | _ ->
        mk_invalid_argument continuation_param "must be in format PRICE_HASH"
    with _ ->
      mk_invalid_argument continuation_param "must be in format PRICE_HASH"

let get_currency_param req =
  let open Tzfunc.Crypto in
  match EzAPI.Req.find_param currency_param req with
  | None -> Ok None
  | Some "XTZ" -> Ok (Some ATXTZ)
  | Some str ->
    begin
      try
        match String.split_on_char ':' str with
        | "FT" :: contract :: l ->
          let token_id = match l with [] -> None | token_id :: _ -> Some (Z.of_string token_id) in
          ignore @@ Base58.decode ~prefix:Prefix.contract_public_key_hash contract ;
          Ok (Some (ATFT {contract; token_id}))
        | "NFT" :: contract :: token_id :: [] ->
          ignore @@ Base58.decode ~prefix:Prefix.contract_public_key_hash contract ;
          Ok (Some (ATNFT { asset_contract = contract ; asset_token_id = Z.of_string token_id }))
        | "MT" :: contract :: token_id :: [] ->
          ignore @@ Base58.decode ~prefix:Prefix.contract_public_key_hash contract ;
          Ok (Some (ATMT { asset_contract = contract ; asset_token_id = Z.of_string token_id }))
        | _ ->
          mk_invalid_argument currency_param "must be XTZ, FA_1_2:ADDRESS or FA_2:ADDRESS:TOKENID"
      with _ ->
        mk_invalid_argument currency_param "must be XTZ, FA_1_2:ADDRESS or FA_2:ADDRESS:TOKENID"
    end

let get_sort_param req =
  match EzAPI.Req.find_param sort_param req with
  | None -> Ok None
  | Some str ->
    try
      Ok (Some (EzEncoding.destruct activity_sort_enc (Format.sprintf "%S" str)))
    with _ ->
      mk_invalid_argument sort_param "must be LATEST_FIRST or EARLIEST_FIRST"

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
  match get_sort_param req with
  | Error err -> return @@ Error err
  | Ok sort ->
    match get_size_param req with
    | Error err -> return @@ Error err
    | Ok size ->
      match get_continuation_last_update_param req with
      | Error err -> return @@ Error err
      | Ok continuation ->
        Db.get_nft_activities ?sort ?continuation ?size input >>= function
        | Error db_err ->
          let message = Crawlori.Rp.string_of_error db_err in
          return (Error {code=`UNEXPECTED_API_ERROR; message})
        | Ok res ->
          let res = Balance.dec_nft_activities res in
          return (Ok res)
[@@post
  {path="/v0.1/nft/activities/search";
   params=[sort_param;size_param;continuation_param];
   input=nft_activity_filter_enc;
   output=nft_activities_enc A.big_decimal_enc;
   errors=[bad_request_case; unexpected_case];
   name="search_activities";
   section=nft_section}]

(* nft-ownership-controller *)
let get_nft_ownership_by_id (_, ownership_id) () =
  match parse_ownership_id ownership_id with
  | Error err -> return @@ Error err
  | Ok (contract, token_id, owner) ->
    Db.get_nft_ownership_by_id contract token_id owner >>= function
    | Error (`hook_error "not found") ->
      return (Error {code=`OWNERSHIP_NOT_FOUND; message=ownership_id})
    | Error db_err ->
      let message = Crawlori.Rp.string_of_error db_err in
      return (Error {code=`UNEXPECTED_API_ERROR; message})
    | Ok res -> return_ok res
[@@get
  {path="/v0.1/ownerships/{ownership_id_arg}";
   output=nft_ownership_enc;
   errors=[bad_request_case;entity_not_found_case;unexpected_case];
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
            let message = Crawlori.Rp.string_of_error db_err in
            return (Error {code=`UNEXPECTED_API_ERROR; message})
          | Ok res -> return_ok res
[@@get
  {path="/v0.1/ownerships/byItem";
   params=[contract_param;token_id_param;size_param;continuation_param];
   output=nft_ownerships_enc;
   errors=[bad_request_case;unexpected_case];
   name="ownerships_by_item";
   section=ownerships_section}]

let get_nft_all_ownerships req () =
  match get_size_param req with
  | Error err -> return @@ Error err
  | Ok size ->
    match get_continuation_ownerships_param req with
    | Error err -> return @@ Error err
    | Ok continuation ->
      Db.get_nft_all_ownerships ?continuation ?size () >>= function
      | Error db_err ->
        let message = Crawlori.Rp.string_of_error db_err in
        return (Error {code=`UNEXPECTED_API_ERROR; message})
      | Ok res -> return_ok res
[@@get
  {path="/v0.1/ownerships/all";
   params=[size_param;continuation_param];
   output=nft_ownerships_enc;
   errors=[bad_request_case;unexpected_case];
   name="ownerships_all";
   section=ownerships_section}]

(* nft-item-controller *)
let reset_nft_item_meta_by_id (_req, item_id) () =
  match parse_item_id item_id with
  | Error err -> return @@ Error err
  | Ok (contract, token_id) ->
    Db.reset_nft_item_meta_by_id contract token_id >>= function
    | Error db_err ->
      let message = Crawlori.Rp.string_of_error db_err in
      return (Error {code=`UNEXPECTED_API_ERROR; message})
    | Ok res -> return_ok res
[@@delete
  {path="/v0.1/items/{item_id_arg}/reset";
   errors=[bad_request_case;unexpected_case];
   name="item_reset_meta";
   section=items_section}]

let get_nft_item_meta_by_id (_req, item_id) () =
  match parse_item_id item_id with
  | Error err -> return @@ Error err
  | Ok (contract, token_id) ->
    Db.get_nft_item_meta_by_id contract token_id >>= function
    | Error db_err ->
      let message = Crawlori.Rp.string_of_error db_err in
      return (Error {code=`UNEXPECTED_API_ERROR; message})
    | Ok res -> return_ok res
[@@get
  {path="/v0.1/items/{item_id_arg}/meta";
   output=nft_item_meta_enc;
   errors=[bad_request_case;unexpected_case];
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
      | Error (`hook_error "not found") ->
        return (Error {code=`ITEM_NOT_FOUND; message=item_id})
      | Error db_err ->
        let message = Crawlori.Rp.string_of_error db_err in
        return (Error {code=`UNEXPECTED_API_ERROR; message})
      | Ok res -> return_ok res
[@@get
  {path="/v0.1/items/{item_id_arg}";
   params=[include_meta_param];
   output=nft_item_enc;
   errors=[bad_request_case;unexpected_case;entity_not_found_case];
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
            let message = Crawlori.Rp.string_of_error db_err in
            return (Error {code=`UNEXPECTED_API_ERROR; message})
          | Ok res -> return_ok res
[@@get
  {path="/v0.1/items/byOwner";
   params=[owner_param;include_meta_param;size_param;continuation_param];
   output=nft_items_enc;
   errors=[bad_request_case;unexpected_case];
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
            let message = Crawlori.Rp.string_of_error db_err in
            return (Error {code=`UNEXPECTED_API_ERROR; message})
          | Ok res -> return_ok res
[@@get
  {path="/v0.1/items/byCreator";
   params=[creator_param;include_meta_param;size_param;continuation_param];
   output=nft_items_enc;
   errors=[bad_request_case;unexpected_case];
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
            let message = Crawlori.Rp.string_of_error db_err in
            return (Error {code=`UNEXPECTED_API_ERROR; message})
          | Ok res -> return_ok res
[@@get
  {path="/v0.1/items/byCollection";
   params=[collection_param;include_meta_param;size_param;continuation_param];
   output=nft_items_enc;
   errors=[bad_request_case;unexpected_case];
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
                let message = Crawlori.Rp.string_of_error db_err in
                return (Error {code=`UNEXPECTED_API_ERROR; message})
              | Ok res -> return_ok res
[@@get
  {path="/v0.1/items/all";
   params=[last_updated_from_param;last_updated_to_param;show_deleted_param;
           include_meta_param;size_param;continuation_param];
   output=nft_items_enc;
   errors=[bad_request_case;unexpected_case];
   name="items_all";
   section=items_section}]

(* nft-collection-controller *)
let generate_nft_token_id (_req, collection) () =
  match parse_collection_id collection with
  | Error err -> return @@ Error err
  | Ok collection ->
    Db.generate_nft_token_id collection >>= function
    | Error db_err ->
      let message = Crawlori.Rp.string_of_error db_err in
      return (Error {code=`UNEXPECTED_API_ERROR; message})
    | Ok res -> return_ok res
[@@get
  {path="/v0.1/collections/{collection_arg}/generate_token_id";
   output=nft_token_id_enc;
   errors=[bad_request_case;unexpected_case];
   name="collections_generate_id";
   section=collections_section}]

let get_nft_collection_by_id (_req, collection) () =
  match parse_collection_id collection with
  | Error err -> return @@ Error err
  | Ok collection ->
    Db.get_nft_collection_by_id collection >>= function
    | Error (`hook_error "not found") ->
      return (Error {code=`COLLECTION_NOT_FOUND; message=collection})
    | Error db_err ->
      let message = Crawlori.Rp.string_of_error db_err in
      return (Error {code=`UNEXPECTED_API_ERROR; message})
    | Ok res -> return_ok res
[@@get
  {path="/v0.1/collections/{collection_arg}";
   output=nft_collection_enc;
   errors=[bad_request_case;unexpected_case;entity_not_found_case];
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
          let message = Crawlori.Rp.string_of_error db_err in
          return (Error {code=`UNEXPECTED_API_ERROR; message})
        | Ok res -> return_ok res
[@@get
  {path="/v0.1/collections/byOwner";
   params=[owner_param;size_param;continuation_param];
   output=nft_collections_enc;
   errors=[bad_request_case;unexpected_case];
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
        let message = Crawlori.Rp.string_of_error db_err in
        return (Error {code=`UNEXPECTED_API_ERROR; message})
      | Ok res -> return_ok res
[@@get
  {path="/v0.1/collections/all";
   params=[size_param;continuation_param];
   output=nft_collections_enc;
   errors=[bad_request_case;unexpected_case];
   name="collections_all";
   section=collections_section}]

(* (\* order-transaction-controller *\)
 * let create_order_pending_transaction _req _input =
 *   return (Error (unknown ""))
 * [@@post
 *   {path="/v0.1/order/transactions";
 *    input=create_transaction_request_enc;
 *    output=log_events_enc;
 *    errors=[rarible_error_500]}] *)

(* order-controller *)

let validate_signature order =
  let order_elt = order.order_elt in
  let data_type, payouts, origin_fees =
    let d = order.order_data in
    d.order_rarible_v2_data_v1_data_type, d.order_rarible_v2_data_v1_payouts,
    d.order_rarible_v2_data_v1_origin_fees in
  let$ msg =
    Result.map_error (fun e -> {code=`INCORRECT_SIGNATURE; message=Let.string_of_error e}) @@
    Utils.hash_order_form order_elt.order_elt_maker_edpk order_elt.order_elt_make
      order_elt.order_elt_taker_edpk order_elt.order_elt_take
      order_elt.order_elt_salt order_elt.order_elt_start order_elt.order_elt_end
      data_type payouts origin_fees in
  let edsig = order_elt.order_elt_signature in
  let edpk = order_elt.order_elt_maker_edpk in
  match Tzfunc.Crypto.Ed25519.verify ~edpk ~edsig ~bytes:msg with
  | Ok true -> Ok ()
  | _ -> Error {code=`INCORRECT_SIGNATURE; message=order_elt.order_elt_hash}

let validate_order order =
  Format.eprintf "validate_order\n%!";
  (* No need to check form.data as other combinations are not accepted by the input encoding *)
  validate_signature order

let validate existing update =
  let existing_make_value = existing.order_elt.order_elt_make.asset_value in
  let update_make_value = update.order_elt.order_elt_make.asset_value in
  let existing_take_value = existing.order_elt.order_elt_take.asset_value in
  let update_take_value = update.order_elt.order_elt_take.asset_value in
  if existing.order_elt.order_elt_cancelled then
    Lwt.return (Error {code=`ORDER_CANCELED; message=existing.order_elt.order_elt_hash})
  else if existing.order_data <> update.order_data then
    Lwt.return (Error {code=`ORDER_INVALID_UPDATE; message="data"})
  else if existing.order_elt.order_elt_start <>
          update.order_elt.order_elt_start then
    Lwt.return (Error {code=`ORDER_INVALID_UPDATE; message="start date"})
  else if existing.order_elt.order_elt_end <>
          update.order_elt.order_elt_end then
    Lwt.return (Error {code=`ORDER_INVALID_UPDATE; message="end date"})
  else if existing.order_elt.order_elt_taker <>
          update.order_elt.order_elt_taker then
    Lwt.return (Error {code=`ORDER_INVALID_UPDATE; message="taker"})
  else if update_make_value < existing_make_value then
    Lwt.return (Error {code=`ORDER_INVALID_UPDATE; message="can't decrease make asset value"})
  else
    let new_max_take =
      Z.(div
           (mul update_make_value existing_take_value) existing_make_value) in
    if new_max_take < update_take_value then
      Lwt.return (Error {code=`ORDER_INVALID_UPDATE; message="new max take"})
    else Lwt.return_ok ()

let get_existing_order hash_key_order =
  Format.eprintf "get_existing_order\n%!";
  Db.get_order hash_key_order

let z_order_form order =
  let>? maked = Db.get_decimals order.order_form_elt.order_form_elt_make.asset_type in
  let|>? taked = Db.get_decimals order.order_form_elt.order_form_elt_take.asset_type in
  Balance.z_order_form ?maked ?taked order

let upsert_order _req input =
  Format.eprintf "upsert_order\n%!";
  z_order_form input >>= function
  | Error err ->
    return (Error {code=`UNEXPECTED_API_ERROR; message=Crawlori.Rp.string_of_error err})
  | Ok order ->
    match Utils.order_from_order_form order with
    | Error err -> return (Error {code=`UNEXPECTED_API_ERROR; message=Let.string_of_error err})
    | Ok order ->
      match validate_order order with
      | Error e -> return (Error e)
      | Ok () ->
        get_existing_order order.order_elt.order_elt_hash >>= function
        | Error db_err ->
          let message = Crawlori.Rp.string_of_error db_err in
          return (Error {code=`UNEXPECTED_API_ERROR; message})
        | Ok existing_order ->
          begin match existing_order with
            | None -> Lwt.return @@ Ok order
            | Some (existing_order, _) ->
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
              let message = Crawlori.Rp.string_of_error db_err in
              return (Error {code=`UNEXPECTED_API_ERROR; message})
            | Ok () ->
              Db.get_order order.order_elt.order_elt_hash >>= function
              | Error db_err ->
                let message = Crawlori.Rp.string_of_error db_err in
                return (Error {code=`UNEXPECTED_API_ERROR; message})
              | Ok None ->
                return (Error {code=`UNEXPECTED_API_ERROR; message="order not registered"})
              | Ok Some (order, (maked, taked)) ->
                let order = Balance.dec_order ?maked ?taked order in
                return_ok order
(* kafkta.push order *)
[@@post
  {path="/v0.1/orders";
   input=order_form_enc A.big_decimal_enc;
   output=order_enc A.big_decimal_enc;
   errors=[unexpected_case;order_error_case];
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
          let message = Crawlori.Rp.string_of_error db_err in
          return (Error {code=`UNEXPECTED_API_ERROR; message})
        | Ok (res, d) ->
          let res = Balance.dec_orders_pagination ~d res in
          return_ok res
[@@get
  {path="/v0.1/orders/all";
   params=[origin_param;size_param;continuation_param];
   output=orders_pagination_enc A.big_decimal_enc;
   errors=[bad_request_case;unexpected_case];
   name="orders_all";
   section=orders_section}]

let get_order_by_hash (_req, hash) () =
  Db.get_order hash >>= function
  | Ok (Some (order, (maked, taked))) ->
    let order = Balance.dec_order ?maked ?taked order in
    return_ok order
  | Ok None -> return @@ Error {code=`ORDER_NOT_FOUND; message=hash}
  | Error db_err ->
    let message = Crawlori.Rp.string_of_error db_err in
    return (Error {code=`UNEXPECTED_API_ERROR; message})
[@@get
  {path="/v0.1/orders/{hash_arg}";
   output=order_enc A.big_decimal_enc;
   errors=[bad_request_case;unexpected_case;entity_not_found_case];
   name="orders_by_hash";
   section=orders_section}]

let get_order_by_ids _req ids =
  Lwt_list.fold_left_s (fun res id -> match res with
      | Ok list ->
        Db.get_order id >>= begin function
          | Ok (Some (order, (maked, taked))) ->
            Lwt.return @@ Ok ((Balance.dec_order ?maked ?taked order) :: list)
          | Ok None -> Lwt.return @@ Ok list
          | Error db_err ->
            let message = Crawlori.Rp.string_of_error db_err in
            Lwt.return (Error {code=`UNEXPECTED_API_ERROR; message})
        end
      | _ -> Lwt.return res)
    (Ok []) ids.ids >>= function
  | Ok orders -> return_ok orders
  | Error api_err -> return (Error api_err)
[@@post
  {path="/v0.1/orders/byIds";
   input=ids_enc;
   output=(Json_encoding.list (order_enc A.big_decimal_enc));
   errors=[bad_request_case;unexpected_case];
   name="orders_by_ids";
   section=orders_section}]

(* let update_order_make_stock _req () =
 *   return (Error (unknown ""))
 * [@@get
 *   {path="/v0.1/orders/{hash_arg}/updateMakeStock";
 *    output=order_enc;
 *    errors=[rarible_error_500]}]
 *
 * let buyer_fee_signature req _input =
 *   let _fee = EzAPI.Req.find_param fee_param req in
 *   return (Error (unknown ""))
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
            let message = Crawlori.Rp.string_of_error db_err in
            return (Error {code=`UNEXPECTED_API_ERROR; message})
          | Ok (res, d) ->
            return_ok (Balance.dec_orders_pagination ~d res)
[@@get
  {path="/v0.1/orders/sell/byMaker";
   params=[maker_param;origin_param;size_param;continuation_param];
   output=orders_pagination_enc A.big_decimal_enc;
   errors=[bad_request_case;unexpected_case];
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
          match get_currency_param req with
          | Error err -> return @@ Error err
          | Ok currency ->
            match get_status_param req with
            | Error err -> return @@ Error err
            | Ok statuses ->
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
                      Db.get_sell_orders_by_item
                        ?origin ?continuation ?size ?maker ?currency
                        ?statuses ?start_date ?end_date contract token_id >>= function
                      | Error db_err ->
                        let message = Crawlori.Rp.string_of_error db_err in
                        return (Error {code=`UNEXPECTED_API_ERROR; message})
                      | Ok (res, d) -> return_ok (Balance.dec_orders_pagination ~d res)
[@@get
  {path="/v0.1/orders/sell/byItem";
   params=[contract_param;token_id_param;maker_param;origin_param;
           currency_param;status_param;start_date_param;end_date_param;
           size_param;continuation_param];
   output=orders_pagination_enc A.big_decimal_enc;
   errors=[bad_request_case;unexpected_case];
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
            let message = Crawlori.Rp.string_of_error db_err in
            return (Error {code=`UNEXPECTED_API_ERROR; message})
          | Ok (res, d) -> return_ok (Balance.dec_orders_pagination ~d res)
[@@get
  {path="/v0.1/orders/sell/byCollection";
   params=[collection_param;origin_param;size_param;continuation_param];
   output=orders_pagination_enc A.big_decimal_enc;
   errors=[bad_request_case;unexpected_case];
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
          let message = Crawlori.Rp.string_of_error db_err in
          return (Error {code=`UNEXPECTED_API_ERROR; message})
        | Ok (res, d) -> return_ok (Balance.dec_orders_pagination ~d res)
[@@get
  {path="/v0.1/orders/sell";
   params=[origin_param;size_param;continuation_param];
   output=orders_pagination_enc A.big_decimal_enc;
   errors=[bad_request_case;unexpected_case];
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
            let message = Crawlori.Rp.string_of_error db_err in
            return (Error {code=`UNEXPECTED_API_ERROR; message})
          | Ok (res, d) -> return_ok (Balance.dec_orders_pagination ~d res)
[@@get
  {path="/v0.1/orders/bids/byMaker";
   params=[maker_param;origin_param;size_param;continuation_param];
   output=orders_pagination_enc A.big_decimal_enc;
   errors=[bad_request_case; unexpected_case];
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
          match get_currency_param req with
          | Error err -> return @@ Error err
          | Ok currency ->
            match get_status_param req with
            | Error err -> return @@ Error err
            | Ok statuses ->
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
                      Db.get_bid_orders_by_item
                        ?origin ?continuation ?size ?maker ?currency
                        ?statuses ?start_date ?end_date contract token_id
                      >>= function
                      | Error db_err ->
                        let message = Crawlori.Rp.string_of_error db_err in
                        return (Error {code=`UNEXPECTED_API_ERROR; message})
                      | Ok (res, d) -> return_ok (Balance.dec_orders_pagination ~d res)
[@@get
  {path="/v0.1/orders/bids/byItem";
   params=[contract_param;token_id_param;maker_param;origin_param;
           currency_param;status_param;start_date_param;end_date_param;
           size_param;continuation_param];
   output=orders_pagination_enc A.big_decimal_enc;
   errors=[bad_request_case;unexpected_case];
   name="orders_bids_by_item";
   section=orders_section}]

let get_currencies_by_bid_orders_of_item req () =
  Format.eprintf "get_currencies_by_bid_orders_of_item\n%!";
  match get_required_contract_param req with
  | Error err -> return @@ Error err
  | Ok contract ->
    match get_required_token_id_param req with
    | Error err -> return @@ Error err
    | Ok token_id ->
      Db.get_currencies_by_bid_orders_of_item contract token_id >>= function
      | Error db_err ->
        let message = Crawlori.Rp.string_of_error db_err in
        return (Error {code=`UNEXPECTED_API_ERROR; message})
      | Ok res -> return_ok res
[@@get
  {path="/v0.1/order/orders/currencies/byBidOrdersOfItem";
   params=[contract_param;token_id_param];
   output=order_currencies_enc;
   errors=[bad_request_case;unexpected_case];
   name="get_currencies_by_bid_orders_of_item";
   section=orders_section}]

let get_currencies_by_sell_orders_of_item req () =
  Format.eprintf "get_currencies_by_sell_orders_of_item\n%!";
  match get_required_contract_param req with
  | Error err -> return @@ Error err
  | Ok contract ->
    match get_required_token_id_param req with
    | Error err -> return @@ Error err
    | Ok token_id ->
      Db.get_currencies_by_sell_orders_of_item contract token_id >>= function
      | Error db_err ->
        let message = Crawlori.Rp.string_of_error db_err in
        return (Error {code=`UNEXPECTED_API_ERROR; message})
      | Ok res -> return_ok res
[@@get
  {path="/v0.1/order/orders/currencies/bySellOrdersOfItem";
   params=[contract_param;token_id_param];
   output=order_currencies_enc;
   errors=[bad_request_case;unexpected_case];
   name="get_currencies_by_sell_orders_of_item";
   section=orders_section}]

(* order-activity-controller *)
let get_order_activities req input =
  match get_sort_param req with
  | Error err -> return @@ Error err
  | Ok sort ->
    match get_size_param req with
    | Error err -> return @@ Error err
    | Ok size ->
      match get_continuation_last_update_param req with
      | Error err -> return @@ Error err
      | Ok continuation ->
        Db.get_order_activities ?sort ?continuation ?size input >>= function
        | Error db_err ->
          let message = Crawlori.Rp.string_of_error db_err in
          return (Error {code=`UNEXPECTED_API_ERROR; message})
        | Ok (res, d) ->
          return_ok (Balance.dec_order_activities ~d res)
[@@post
  {path="/v0.1/order/activities/search";
   params=[sort_param;size_param;continuation_param];
   name="get_order_activities";
   input=order_activity_filter_enc;
   output=order_activities_enc A.big_decimal_enc;
   errors=[bad_request_case;unexpected_case];
   section=order_activities_section}]

let verify ~pk58 ~sig58 ~bytes =
  let open Tzfunc.Crypto in
  Result.bind (Pk.b58dec pk58) @@ fun pk ->
  Result.bind (Signature.b58dec sig58) @@ fun signature ->
  match Curve.from_b58 pk58, Curve.from_b58 sig58 with
  | Ok `ed25519, Ok `ed25519 -> Ed25519.verify_bytes ~pk ~signature ~bytes
  | Ok `secp256k1, Ok `secp256k1 -> Secp256k1.verify_bytes ~pk ~signature ~bytes
  | Error e, _ | _, Error e -> Error e
  | _ -> Error `unmatched_curve



let validate _req input =
  let message = input.svf_prefix ^ input.svf_message in
  match Tzfunc.Crypto.pk_to_pkh input.svf_edpk with
  | Error e -> return (Error {code=`BAD_REQUEST; message=Let.string_of_error e})
  | Ok addr ->
    if addr <> input.svf_address then return_ok false
    else
      match verify ~pk58:input.svf_edpk ~sig58:input.svf_signature
              ~bytes:(Tzfunc.Raw.mk message) with
      | Ok true -> return_ok true
      | Error e -> return (Error {code=`BAD_REQUEST; message=Let.string_of_error e})
      | Ok false ->
        match Tzfunc.Forge.(pack (prim `string) (Proto.Mstring message)) with
        | Error e -> return (Error {code=`BAD_REQUEST; message=Let.string_of_error e})
        | Ok bytes ->
          match verify ~pk58:input.svf_edpk ~sig58:input.svf_signature
                  ~bytes with
          | Ok b -> return_ok b
          | Error e -> return (Error {code=`BAD_REQUEST; message=Let.string_of_error e})

[@@post
  {path="/v0.1/order/signature/validate";
   name="validate";
   input=signature_validation_form_enc;
   output=Json_encoding.bool;
   errors=[bad_request_case;unexpected_case];
   section=signature_section}]

(* ft-balance-controller *)
let get_ft_balance ((_, contract), ft_owner) () =
  let> r = Db.get_ft_balance ~contract ft_owner in
  match r with
  | Error (`hook_error "contract_not_found") ->
    return (Error {code=`TOKEN_NOT_FOUND; message=contract})
  | Error (`hook_error "balance_not_found") ->
    return (Error {code=`BALANCE_NOT_FOUND; message=contract ^ " - " ^ ft_owner})
  | Error e ->
    let message = Crawlori.Rp.string_of_error e in
    return (Error {code=`UNEXPECTED_API_ERROR; message})
  | Ok (ft_balance, d) ->
    return_ok (Balance.dec_ft_balance ?d {
      ft_contract = contract;
      ft_owner;
      ft_balance })
[@@get
  {path="/v0.1/balances/{contract : string}/{owner : string}";
   name="ft_balance";
   output=ft_balance_enc A.big_decimal_enc;
   errors=[unexpected_case;entity_not_found_case];
   section=balance_section}]

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
