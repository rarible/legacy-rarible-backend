open EzAPIServer
open Rtypes
open Let
open Utils
open Errors

let dir = Directory.empty

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
let last_updated_from_param = EzAPI.Param.string "lastUpdatedFrom"
let last_updated_to_param = EzAPI.Param.string "lastUpdatedTo"
let minter_param = EzAPI.Param.string "minter"
let origin_param = EzAPI.Param.string "origin"
(* TODO : ALL | RARIBLE | OPEN_SEA *)
let platform_param = EzAPI.Param.string "platform"
let fee_param = EzAPI.Param.int "fee"
let maker_param = EzAPI.Param.string "maker"
(* TODO : date-time *)
let start_date_param = EzAPI.Param.string "startDate"
(* TODO : date-time*)
let end_date_param = EzAPI.Param.string "endDate"
(* TODO : ALL | RARIBLE | OPEN_SEA *)
let source_param = EzAPI.Param.string "source"
let status_param = EzAPI.Param.string "status"

(* gateway-controller *)
let create_gateway_pending_transactions _req _input =
  return (Error (unknown_error ""))
[@@post
  {path="/v0.1/transactions";
   input=create_transaction_request_enc;
   output=log_events_enc;
   errors=[rarible_error_500]}]

(* currency-controller *)
let get_currency_rate req () =
  let _blockchain = EzAPI.Req.find_param blockchain_param req in
  let _address = EzAPI.Req.find_param address_param req in
  let _at = EzAPI.Req.find_param at_param req in
  return (Error (unknown_error ""))
[@@get
  {path="/v0.1/rate";
   output=currency_rate_enc;
   errors=[rarible_error_500]}]

(* erc20-balance-controller *)
let get_erc20_balance ((_, erc20_contract), erc20_owner) () =
  return_ok { erc20_contract;
              erc20_owner;
              erc20_balance = Z.zero;
              erc20_decimal_balance = Z.zero }
[@@get
  {path="/v0.1/balances/{contract:string}/{owner:string}";
   output=erc20_decimal_balance_enc}]

(* erc20-token-controller *)
let get_erc20_token_by_id (_, contract) () =
  return (Error (token_not_found contract))
[@@get
  {path="/v0.1/tokens/{contract:string}";
   output=erc20_token_enc;
   errors=[rarible_error_404]}]

(* nft-transaction-controller *)
let create_nft_pending_transaction _req _input =
  return (Error (bad_request ""))
[@@post
  {path="/v0.1/transactions";
   input=create_transaction_request_enc;
   output=log_events_enc;
   errors=[rarible_error_500]}]

(* nft-lazy-mint-controller *)
let mint_nft_asset _req _input =
  return (Error (bad_request ""))
[@@post
  {path="/v0.1/mints";
   input=lazy_nft_enc;
   output=nft_item_enc;
   errors=[rarible_error_500]}]

(* nft-activity-controller *)
let get_nft_activities req _input =
  let _continuation = EzAPI.Req.find_param continuation_param req in
  let _size = EzAPI.Req.find_param size_param req in
  return (Error (bad_request ""))
[@@get
  {path="/v0.1/activities/search";
   input=nft_activity_filter_enc;
   output=nft_activities_enc;
   errors=[rarible_error_500]}]

(* nft-ownership-controller *)
let get_nft_ownership_by_id (_, _ownership_id) () =
  return (Error (bad_request ""))
[@@get
  {path="/v0.1/ownerships/{ownershipId:string}";
   output=nft_ownership_enc;
   errors=[rarible_error_500]}]

let get_nft_ownerships_by_item req () =
  let _contract = EzAPI.Req.find_param contract_param req in
  let _token_id = EzAPI.Req.find_param token_id_param req in
  let _continuation = EzAPI.Req.find_param continuation_param req in
  let _size = EzAPI.Req.find_param size_param req in
  return (Error (bad_request ""))
[@@get
  {path="/v0.1/ownerships/byItem";
   output=nft_ownerships_enc;
   errors=[rarible_error_500]}]

let get_nft_all_ownerships req () =
  let _continuation = EzAPI.Req.find_param continuation_param req in
  let _size = EzAPI.Req.find_param size_param req in
  return (Error (bad_request ""))
[@@get
  {path="/v0.1/ownerships/all";
   output=nft_ownerships_enc;
   errors=[rarible_error_500]}]

(* nft-item-controller *)
let get_nft_item_meta_by_id (_req, _item_id) () =
  return (Error (bad_request ""))
[@@get
  {path="/v0.1/items/{itemId:string}/meta";
   output=nft_item_meta_enc;
   errors=[rarible_error_500]}]

let get_nft_lazy_item_by_id (_req, _item_id) () =
  return (Error (bad_request ""))
[@@get
  {path="/v0.1/items/{itemId:string}/lazy";
   output=lazy_nft_enc;
   errors=[rarible_error_500]}]

let get_nft_item_by_id (req, _item_id) () =
  let _include_meta = EzAPI.Req.find_param include_meta_param req in
  return (Error (bad_request ""))
[@@get
  {path="/v0.1/items/{itemId:string}";
   output=nft_item_enc;
   errors=[rarible_error_500]}]

let get_nft_items_by_owner req () =
  let _owner = EzAPI.Req.find_param owner_param req in
  let _continuation = EzAPI.Req.find_param continuation_param req in
  let _size = EzAPI.Req.find_param size_param req in
  let _include_meta = EzAPI.Req.find_param include_meta_param req in
  return (Error (bad_request ""))
[@@get
  {path="/v0.1/items/byOwner";
   output=nft_items_enc;
   errors=[rarible_error_500]}]

let get_nft_items_by_creator req () =
  let _creator = EzAPI.Req.find_param creator_param req in
  let _continuation = EzAPI.Req.find_param continuation_param req in
  let _size = EzAPI.Req.find_param size_param req in
  let _include_meta = EzAPI.Req.find_param include_meta_param req in
  return (Error (bad_request ""))
[@@get
  {path="/v0.1/items/byCreator";
   output=nft_items_enc;
   errors=[rarible_error_500]}]

let get_nft_items_by_collection req () =
  let _collection = EzAPI.Req.find_param collection_param req in
  let _continuation = EzAPI.Req.find_param continuation_param req in
  let _size = EzAPI.Req.find_param size_param req in
  let _include_meta = EzAPI.Req.find_param include_meta_param req in
  return (Error (bad_request ""))
[@@get
  {path="/v0.1/items/byCollection";
   output=nft_items_enc;
   errors=[rarible_error_500]}]

let get_nft_all_items req () =
  let _continuation = EzAPI.Req.find_param continuation_param req in
  let _size = EzAPI.Req.find_param size_param req in
  let _show_deleted = EzAPI.Req.find_param show_deleted_param req in
  let _last_updated_from = EzAPI.Req.find_param last_updated_from_param req in
  let _last_updated_to = EzAPI.Req.find_param last_updated_to_param req in
  let _include_meta = EzAPI.Req.find_param include_meta_param req in
  return (Error (bad_request ""))
[@@get
  {path="/v0.1/items/all";
   output=nft_items_enc;
   errors=[rarible_error_500]}]

(* nft-collection-controller *)
let generate_nft_token_id (req, _collection) () =
  let _minter = EzAPI.Req.find_param minter_param req in
  return (Error (bad_request ""))
[@@get
  {path="/v0.1/collections/{collection:string}/generate_token_id";
   output=nft_token_id_enc;
   errors=[rarible_error_500]}]

let get_nft_collection_by_id (_req, _collection) () =
  return (Error (bad_request ""))
[@@get
  {path="/v0.1/collections/{collection:string}";
   output=nft_collection_enc;
   errors=[rarible_error_500]}]

let search_nft_collections_by_owner req () =
  let _owner = EzAPI.Req.find_param owner_param req in
  let _continuation = EzAPI.Req.find_param continuation_param req in
  let _size = EzAPI.Req.find_param size_param req in
  return (Error (bad_request ""))
[@@get
  {path="/v0.1/collections/byOwner";
   output=nft_collections_enc;
   errors=[rarible_error_500]}]

let search_nft_all_collections req () =
  let _continuation = EzAPI.Req.find_param continuation_param req in
  let _size = EzAPI.Req.find_param size_param req in
  return (Error (bad_request ""))
[@@get
  {path="/v0.1/collections/all";
   output=nft_collections_enc;
   errors=[rarible_error_500]}]

(* order-transaction-controller *)
let create_order_pending_transaction _req _input =
  return (Error (unexpected_api_error ""))
[@@post
  {path="/v0.1/transactions";
   input=create_transaction_request_enc;
   output=log_events_enc;
   errors=[rarible_error_500]}]

let (let$>) r f = match r with
  | Error e -> Lwt.return_error (invalid_argument (string_of_error e))
  | Ok x -> f x

let validate_signature order =
  let order_elt = order.order_elt in
  let$> msg = hash_order order in
  let signature =
    Bigstring.of_string @@
    Crypto.Base58.decode Crypto.Prefix.ed25519_signature order_elt.order_elt_signature in
  let pk =
    Hacl.Sign.unsafe_pk_of_bytes @@
    Bigstring.of_string @@
    Crypto.Pk.b58dec order_elt.order_elt_maker in
  if Hacl.Sign.verify ~pk ~msg:(Bigstring.of_string msg) ~signature then
    Lwt.return_ok ()
  else
    Lwt.return_error (invalid_argument "Incorrect signature")

let validate_order order =
  (* No need to check form.data as other combinations are not accepted by the input encoding *)
  validate_signature order >>=? fun () ->
  Lwt.return @@ Ok ()

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
    Lwt.return (Error (invalid_argument "Invalide update can't reduce make asset value"))
  else
    let new_max_take = (Z.div (Z.mul update_make_value existing_take_value) existing_make_value) in
    if new_max_take < update_take_value then
      Lwt.return (Error (invalid_argument "Invalide update new max take"))
    else Lwt.return @@ Ok ()

let get_existing_order _order_elt =
  (* SELECT FROM ORDER WITH ORDER_ELT.xxx & order_elt.yyy*)
  assert false



(* order-controller *)
let upset_order _req input = match input with
  | LegacyOrderForm _ ->
    return (Error (invalid_argument "Legacy order not supported"))
  | OpenSeav1OrderForm _ ->
    return (Error (invalid_argument "OpenSea order not supported"))
  | RaribleV2OrderFrom order_form ->
    match rarible_v2_order_from_rarible_v2_order_form order_form with
    | Error e -> return (Error (invalid_argument @@ string_of_error e))
    | Ok order ->
      validate_order order >>= function
      | Ok () ->
        begin
          begin match get_existing_order order with
            | Some existing_order ->
              begin
                validate existing_order order >>= function
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
                | Error err -> Lwt.return @@ Error err
              end
            | None -> Lwt.return @@ Ok order
          end >>= function
          | Ok _order ->
            (* TODO : USDVALUES *)
            (* TODO : pricehistory *)
            (* insert_order order >>=? fun () ->
             * kafkta.push order *)
            return (Error (unexpected_api_error ""))
          | Error _err ->
            return (Error (unexpected_api_error ""))
        end


      | Error _err ->
        return (Error (unexpected_api_error ""))
[@@post
  {path="/v0.1/orders";
   input=order_form_enc;
   output=order_enc;
   errors=[rarible_error_500]}]

let prepare_order_transaction _req _input =
  return (Error (unexpected_api_error ""))
[@@post
  {path="/v0.1/orders/{hash:string}/prepareTx";
   input=prepare_order_tx_form_enc;
   output=prepare_order_tx_response_enc;
   errors=[rarible_error_500]}]

(* let prepare_order_v2_transaction _req _input =
 *   return (Error (unexpected_api_error ""))
 * [@@post {path="/v0.1/orders/{hash:string}/prepareV2Tx"; input=order_form_enc; output=prepare_order_tx_response_enc;errors=[rarible_error_500]}] *)

(* let invert_order _req _input =
 *   assert false
 * [@@post {path="/v0.1/orders/{hash:string}/invert"; input=invert_order_form_enc; output=order_form_enc;errors=[rarible_error_500]}] *)

let prepare_order_cancel_transaction _req () =
  return (Error (unexpected_api_error ""))
[@@post
  {path="/v0.1/orders/{hash:string}/prepareCancelTx";
   output=prepared_order_tx_enc;
   errors=[rarible_error_500]}]

let get_order_by_hash _req () =
  return (Error (unexpected_api_error ""))
[@@get
  {path="/v0.1/orders/{hash:string}";
   output=order_enc;
   errors=[rarible_error_500]}]

let update_order_make_stock _req () =
  return (Error (unexpected_api_error ""))
[@@get
  {path="/v0.1/orders/{hash:string}/updateMakeStock";
   output=order_enc;
   errors=[rarible_error_500]}]

let get_orders_all req () =
  let _origin = EzAPI.Req.find_param origin_param req in
  let _platform = EzAPI.Req.find_param platform_param req in
  let _continuation = EzAPI.Req.find_param continuation_param req in
  let _size = EzAPI.Req.find_param size_param req in
  return (Error (unexpected_api_error ""))
[@@get
  {path="/v0.1/orders/all";
   output=orders_pagination_enc;
   errors=[rarible_error_500]}]

let buyer_fee_signature req _input =
  let _fee = EzAPI.Req.find_param fee_param req in
  return (Error (unexpected_api_error ""))
[@@post
  {path="/v0.1/orders/buyerFeeSignature";
   input=order_form_enc;
   output=A.binary_enc;
   errors=[rarible_error_500]}]

let get_sell_orders_by_maker req () =
  let _maker = EzAPI.Req.find_param maker_param req in
  let _origin = EzAPI.Req.find_param origin_param req in
  let _platform = EzAPI.Req.find_param platform_param req in
  let _continuation = EzAPI.Req.find_param continuation_param req in
  let _size = EzAPI.Req.find_param size_param req in
  return (Error (unexpected_api_error ""))
[@@get
  {path="/v0.1/orders/sell/byMaker";
   output=orders_pagination_enc;
   errors=[rarible_error_500]}]

let get_sell_orders_by_item req () =
  let _contract = EzAPI.Req.find_param contract_param req in
  let _token_id = EzAPI.Req.find_param token_id_param req in
  let _maker = EzAPI.Req.find_param maker_param req in
  let _origin = EzAPI.Req.find_param origin_param req in
  let _platform = EzAPI.Req.find_param platform_param req in
  let _continuation = EzAPI.Req.find_param continuation_param req in
  let _size = EzAPI.Req.find_param size_param req in
  return (Error (unexpected_api_error ""))
[@@get
  {path="/v0.1/orders/sell/byItem";
   output=orders_pagination_enc;
   errors=[rarible_error_500]}]

let get_sell_orders_by_collection req () =
  let _collection = EzAPI.Req.find_param collection_param req in
  let _origin = EzAPI.Req.find_param origin_param req in
  let _platform = EzAPI.Req.find_param platform_param req in
  let _continuation = EzAPI.Req.find_param continuation_param req in
  let _size = EzAPI.Req.find_param size_param req in
  return (Error (unexpected_api_error ""))
[@@get
  {path="/v0.1/orders/sell/byCollection";
   output=orders_pagination_enc;
   errors=[rarible_error_500]}]

let get_sell_orders req () =
  let _origin = EzAPI.Req.find_param origin_param req in
  let _platform = EzAPI.Req.find_param platform_param req in
  let _continuation = EzAPI.Req.find_param continuation_param req in
  let _size = EzAPI.Req.find_param size_param req in
  return (Error (unexpected_api_error ""))
[@@get
  {path="/v0.1/orders/sell";
   output=orders_pagination_enc;
   errors=[rarible_error_500]}]

let get_order_bids_by_maker req () =
  let _maker = EzAPI.Req.find_param maker_param req in
  let _origin = EzAPI.Req.find_param origin_param req in
  let _platform = EzAPI.Req.find_param platform_param req in
  let _continuation = EzAPI.Req.find_param continuation_param req in
  let _size = EzAPI.Req.find_param size_param req in
  return (Error (unexpected_api_error ""))
[@@get
  {path="/v0.1/orders/bids/byMaker";
   output=orders_pagination_enc;
   errors=[rarible_error_500]}]

let get_order_bids_by_item req () =
  let _contract = EzAPI.Req.find_param contract_param req in
  let _token_id = EzAPI.Req.find_param token_id_param req in
  let _maker = EzAPI.Req.find_param maker_param req in
  let _origin = EzAPI.Req.find_param origin_param req in
  let _platform = EzAPI.Req.find_param platform_param req in
  let _continuation = EzAPI.Req.find_param continuation_param req in
  let _size = EzAPI.Req.find_param size_param req in
  return (Error (unexpected_api_error ""))
[@@get
  {path="/v0.1/orders/bids/byItem";
   output=orders_pagination_enc;
   errors=[rarible_error_500]}]

(* order-aggregation-controller *)
let aggregate_nft_sell_by_maker req () =
  let _start_date = EzAPI.Req.find_param start_date_param req in
  let _end_date = EzAPI.Req.find_param end_date_param req in
  let _size = EzAPI.Req.find_param size_param req in
  let _source = EzAPI.Req.find_param source_param req in
  return (Error (unexpected_api_error ""))
[@@get
  {path="/v0.1/aggregations/nftSellByMaker";
   output=aggregation_datas_enc;
   errors=[rarible_error_500]}]

let aggregate_nft_purchase_by_taker req () =
  let _start_date = EzAPI.Req.find_param start_date_param req in
  let _end_date = EzAPI.Req.find_param end_date_param req in
  let _size = EzAPI.Req.find_param size_param req in
  let _source = EzAPI.Req.find_param source_param req in
  return (Error (unexpected_api_error ""))
[@@get
  {path="/v0.1/aggregations/nftPurchaseByTaker";
   output=aggregation_datas_enc;
   errors=[rarible_error_500]}]

let aggregate_nft_purchase_buy_collection req () =
  let _start_date = EzAPI.Req.find_param start_date_param req in
  let _end_date = EzAPI.Req.find_param end_date_param req in
  let _size = EzAPI.Req.find_param size_param req in
  let _source = EzAPI.Req.find_param source_param req in
  return (Error (unexpected_api_error ""))
[@@get
  {path="/v0.1/aggregations/nftPurchaseByCollection";
   output=aggregation_datas_enc;
   errors=[rarible_error_500]}]

(* order-activity-controller *)
let get_order_activities req _input =
  let _continuation = EzAPI.Req.find_param continuation_param req in
  let _size = EzAPI.Req.find_param size_param req in
  return (Error (unexpected_api_error ""))
[@@post
  {path="/v0.1/activities/search";
   input=order_activity_filter_enc;
   output=order_activities_enc;errors=[rarible_error_500]}]

(* order-bid-controller *)
let get_bids_by_item req () =
  let _contract = EzAPI.Req.find_param contract_param req in
  let _token_id = EzAPI.Req.find_param token_id_param req in
  let _maker = EzAPI.Req.find_param maker_param req in
  let _status =  EzAPI.Req.find_param status_param req in
  let _origin = EzAPI.Req.find_param origin_param req in
  let _platform = EzAPI.Req.find_param platform_param req in
  let _start_date = EzAPI.Req.find_param start_date_param req in
  let _end_date = EzAPI.Req.find_param end_date_param req in
  let _continuation = EzAPI.Req.find_param continuation_param req in
  let _size = EzAPI.Req.find_param size_param req in
  return (Error (unexpected_api_error ""))
[@@get
  {path="/v0.1/bids/byItem";
   output=order_bids_pagination_enc;
   errors=[rarible_error_500]}]

(* lock-controller *)
let create_lock _req _input =
  return (Error (lock_exists ""))
[@@post
  {path="/v0.1/item/{itemId:string}/lock";
   input=lock_form_enc;output=lock_enc;
   errors=[rarible_error_400]}]

let get_lock_content _req _input =
  return (Error (ownership_error ""))
[@@get
  {path="/v0.1/item/{itemId:string}/content";
   input=signature_form_enc;
   output=Json_encoding.string;
   errors=[rarible_error_400]}]

let is_unlockable _req () =
  return (Error (unknown_error ""))
[@@get
  {path="/v0.1/item/{itemId:string}/isUnlockable";
   output=Json_encoding.bool;
   errors=[rarible_error_500]}]

[@@@server 8080]

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
