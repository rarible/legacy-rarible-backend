type z = Z.t [@encoding Json_encoding.(conv Z.to_string Z.of_string string)] [@@deriving encoding]

(** Config *)

type config = {
  admin_wallet: string; [@dft ""]
  exchange_v2: string; [@dft ""]
  validator: string; [@dft ""]
  royalties: string; [@dft ""]
  ft_fa2: string list; [@dft []]
  ft_fa1: string list; [@dft []]
} [@@deriving encoding]

type kafka_config = {
  kafka_broker : string;
  kafka_username : string;
  kafka_password : string;
} [@@deriving encoding]

(** Api *)

type erc20_balance = {
  contract: string;
  owner: string;
  balance: z;
  decimal_balance: z; [@camel]
} [@@deriving encoding]


(** Interaction with Tezos contract *)

type transfer_destination = {
  tr_destination: string;
  tr_token_id: int64;
  tr_amount: int64;
} [@@deriving encoding]

type transfer = {
  tr_source: string;
  tr_txs: transfer_destination list;
} [@@deriving encoding]

type operator_update = {
  op_owner: string;
  op_operator: string;
  op_token_id: int64;
  op_add: bool;
} [@@deriving encoding]

type token_metadata = ((string * string) list [@assoc])
[@@deriving encoding]

type token_royalties = ((string * int64) list [@assoc])
[@@deriving encoding]

type token_op = {
  tk_token_id: int64;
  tk_amount: int64;
} [@@deriving encoding]

type token_op_owner = {
  tk_op: token_op; [@merge]
  tk_owner: string;
} [@@deriving encoding {remove_prefix=3}]

type mint = {
  mi_op : token_op_owner;
  mi_royalties: token_royalties;
  mi_meta: token_metadata
} [@@deriving encoding]

type account_token = {
  at_token_id : int64;
  at_contract : string;
  at_amount : int64;
} [@@deriving encoding]

type nft_param =
  | Transfers of transfer list
  | Operator_updates of operator_update list
  | Operator_updates_all of (string * bool) list
  | Mint_tokens of mint
  | Burn_tokens of token_op_owner
  | Metadata_uri of string
  | Token_metadata of (int64 * (string * string) list)
[@@deriving encoding]

type set_royalties = {
  roy_contract: string;
  roy_token_id: int64;
  roy_royalties: token_royalties;
} [@@deriving encoding]


module A = struct
  let uint53 =
    Json_encoding.ranged_int53 ~minimum:0L ~maximum:(Int64.shift_left 1L 53) "uint53"

  type big_integer = string
  let big_integer_enc =
    let open Json_encoding in
    union [
      case string (fun x -> Some x) (fun x -> x);
      case uint53 Int64.of_string_opt Int64.to_string;
    ]

  (* TODO : B58CHECK ? *)
  type address = string [@@deriving encoding]
  (* TODO : B58CHECK ? EX TRANSACTION HASH*)
  type word = string [@@deriving encoding]

  type nonce = int64 [@encoding uint53] [@@deriving encoding]

  type block_number = int64 [@encoding uint53] [@@deriving encoding]

  type big_decimal = string [@@deriving encoding]

  type binary = string [@@deriving encoding]

  (* TODO : data format 2017-07-21T17:32:28Z *)
  type date = (Tzfunc.Proto.A.timestamp [@encoding Tzfunc.Proto.A.timestamp_enc.Tzfunc.Proto.Encoding.json]) [@@deriving encoding]
  let date_int64_enc =
    let open Json_encoding in
    conv
      (fun c -> Int64.of_float @@ CalendarLib.Calendar.to_unixfloat c)
      (fun i -> CalendarLib.Calendar.from_unixfloat (Int64.to_float i)) uint53
  type date_int64 = CalendarLib.Calendar.t

  type bytes_str = string [@@deriving encoding]

end

type part = {
  part_account : A.address;
  part_value : int ;
} [@@deriving encoding]


type rarible_error_500_code =
  | UNKNOWN
  | VALIDATION
  (* currency-controller *)
  | FIRST_TEMPLATE_OBJECT_NOT_FOUND
  | SECOND_TEMPLATE_OBJECT_NOT_FOUND
  (* nft-controllers *)
  | BAD_REQUEST
  | TOKEN_PROPERTIES_EXTRACT
  | INCORRECT_LAZY_NFT
  (* order-controllers *)
  | INVALID_ARGUMENT
  | ABSENCE_OF_REQUIRED_FIELD
  | UNLOCKABLE_API_ERROR
  | NFT_API_ERROR
  | ORDER_API_ERROR
  | UNEXPECTED_API_ERROR
[@@deriving encoding {enum}]

type rarible_error_500 = {
  rarible_error_500_status : int;
  rarible_error_500_message : string;
  rarible_error_500_code : rarible_error_500_code;
} [@@deriving encoding]

type rarible_error_404_status =
  (* erc20-controllers *)
  | TOKEN_NOT_FOUND
  | BALANCE_NOT_FOUND
  (* nft-controllers *)
  | ITEM_NOT_FOUND
  | LAZY_ITEM_NOT_FOUND
  | TOKEN_URI_NOT_FOUND
  | OWNERSHIP_NOT_FOUND
  | COLLECTION_NOT_FOUND
[@@deriving encoding {enum}]

type rarible_error_404 = {
  rarible_error_404_status : int;
  rarible_error_404_message : string;
  rarible_error_404_code : rarible_error_404_status;
} [@@deriving encoding]

type rarible_error_400_status =
  (* lock-controller *)
  | LOCK_EXISTS
  | OWNERSHIP_ERROR
[@@deriving encoding {enum}]

type rarible_error_400 = {
  rarible_error_400_status : int;
  rarible_error_400_message : string;
  rarible_error_400_code : rarible_error_400_status;
} [@@deriving encoding]

type create_transaction_request = {
  req_hash : string;
  req_from : A.address;
  req_nonce : A.nonce;
  req_to : A.address option; [@opt]
  req_input : string;
} [@@deriving encoding]

type gateway_pending_transactions_ouput_status =
  | GPTOPending
  | GPTOConfirmed
  | GPTOReverted
  | GPTODropped
  | GPTOInactive
[@@deriving encoding {enum}]

type log_event = {
  ev_transaction_hash : A.word;
  ev_status : gateway_pending_transactions_ouput_status;
  ev_address : A.address;
  ev_from : A.address option; [@opt]
  ev_topic : string;
  ev_nonce : A.nonce option; [@opt]
} [@@deriving encoding {camel}]

type log_events = log_event list [@@deriving encoding]

type currency_rate = {
  rate_from_currency_id : string;
  rate_to_currency_id : string;
  rate_rate : z;
  rate_date : A.big_decimal;
} [@@deriving encoding {camel}]

type erc20_decimal_balance = {
  erc20_contract : string;
  erc20_owner : string;
  erc20_balance : z;
  erc20_decimal_balance : z;
} [@@deriving encoding {camel}]

type erc20_token = {
  erc20_token_id : A.address;
  erc20_token_name : string;
  erc20_token_symbol : string;
} [@@deriving encoding]

type lazy_nft_common = {
  lazy_nft_contract : A.address;
  lazy_nft_tokenId : A.big_integer;
  lazy_nft_uri : string;
  lazy_nft_creators : part list;
  lazy_nft_royalties : part list;
  lazy_nft_signatures : A.binary;
} [@@deriving encoding]

(* type lazy_nft_diff =
 *   | LazyNft721 [@kind_label "ERC721"] [@kind "@type"]
 *   | LazyNft1155 of (A.big_integer [@wrap "supply"]) [@kind_label "ERC1155"] [@kind "@type"]
 * [@@deriving encoding] *)

(* type lazy_nft = {
 *   lazy_nft_diff : lazy_nft_diff ; [@merge]
 *   lazy_nft_common : lazy_nft_common ; [@merge]
 * } [@@deriving encoding] *)

type item_transfer = {
  item_transfer_type : unit [@encoding Json_encoding.constant "TRANSFER"];
  item_transfer_from : A.address;
} [@@deriving encoding]

type nft_item_attribute = {
  nft_item_attribute_key : string ;
  nft_item_attribute_value : string option ; [@opt]
} [@@deriving encoding]

type meta = {
  meta_type : string;
  meta_width : int option; [@opt]
  meta_height : int option; [@opt]
} [@@deriving encoding]

type nft_media = {
  nft_media_url : (string * string) list ; [@assoc]
  nft_media_meta : (string * meta) list ; [@assoc]
} [@@deriving encoding]

type nft_item_meta = {
  nft_item_meta_name : string;
  nft_item_meta_description : string option; [@opt]
  nft_item_meta_attributes : nft_item_attribute list option; [@opt]
  nft_item_meta_image : nft_media option; [@opt]
  nft_item_meta_animation : nft_media option; [@opt]
} [@@deriving encoding]

type nft_item = {
  nft_item_id : string ;
  nft_item_contract : A.address;
  nft_item_token_id : A.big_integer;
  nft_item_creators : part list;
  nft_item_supply : A.big_integer;
  nft_item_lazy_supply : A.big_integer;
  nft_item_owners : A.address list;
  nft_item_royalties : part list;
  nft_item_date : A.date;
  nft_item_pending : item_transfer list option; [@opt]
  nft_item_deleted : bool option; [@opt]
  nft_item_meta : nft_item_meta option; [@opt]
} [@@deriving encoding {camel}]

type nft_items = {
  nft_items_total : int64; [@encoding A.uint53]
  nft_items_continuation : string option; [@opt]
  nft_items_items : nft_item list;
} [@@deriving encoding]

type nft_activity_filter_all_type =
  | ALLTRANSFER
  | ALLMINT
  | ALLBURN
[@@deriving encoding {enum}]

type nft_activity_filter_user_type =
  | USERTRANSFER_FROM
  | USERTRANSFER_TO
  | USERMINT
  | USERBURN
[@@deriving encoding {enum}]

type nft_activity_by_user = {
  nft_activity_by_user_types : nft_activity_filter_user_type list ;
  nft_activity_by_user_users : A.address list
} [@@deriving encoding]

type nft_activity_by_item = {
  nft_activity_by_item_types : nft_activity_filter_all_type list;
  nft_activity_by_item_contract : A.address;
  nft_activity_by_item_token_id : A.big_integer;
} [@@deriving encoding {camel}]

type nft_activity_by_collection = {
  nft_activity_by_collection_types : nft_activity_filter_all_type list;
  nft_activity_by_collection_contract : A.address;
} [@@deriving encoding]

type nft_activity_filter =
  | ActivityFilterAll of
      (nft_activity_filter_all_type list [@wrap "types"]) [@kind "all"] [@kind_label "@type"] [@title "NftActivityFilterAll"]
  | ActivityFilterByUser of
      nft_activity_by_user [@kind "by_user"] [@kind_label "@type"] [@title "NftActivityFilterByUser"]
  | ActivityFilterByItem of
      nft_activity_by_item [@kind "by_item"] [@kind_label "@type"]  [@title "NftActivityFilterByItem"]
  | ActivityFilterByCollection of
      nft_activity_by_collection [@kind "by_collection"] [@kind_label "@type"] [@title "NftActivityFilterByCollection"]
[@@deriving encoding]

type nft_activity_elt = {
  nft_activity_owner : A.address;
  nft_activity_contract : A.address ;
  nft_activity_token_id : A.big_integer ;
  nft_activity_value : A.big_integer ;
  nft_activity_transaction_hash : A.word ;
  nft_activity_block_hash : A.word ;
  nft_activity_block_number : A.block_number ;
} [@@deriving encoding {camel}]

type nft_activity =
  | NftActivityMint of nft_activity_elt [@kind "mint"] [@kind_label "@type"] [@title "Mint"]
  | NftActivityBurn of nft_activity_elt [@kind "burn"] [@kind_label "@type"] [@title "Burn"]
  | NftActivityTransfer of {elt: nft_activity_elt; transfer: A.address} [@kind "mint"] [@kind_label "@type"] [@title "Transfer"]
[@@deriving encoding]

type nft_activities = {
  nft_activities_continuation : string option ; [@opt]
  nft_activities_items : nft_activity list
} [@@deriving encoding]

type item_history_elt = {
  item_history_owner : A.address option; [@opt]
  item_history_contract : A.address;
  item_history_token_id : A.big_integer;
  item_history_value : A.big_integer option; [@opt]
  item_history_date : A.date;
} [@@deriving encoding {camel}]

type item_history_transfer = {
  iht_owner: A.address option ; [@opt]
  iht_value : A.address option ; [@opt]
  iht_from : A.address ;
} [@@deriving encoding]

type item_history =
  | IHRoyalty of (part list [@wrap "royalties"]) [@kind_label "type"] [@kind "ROYALTY"] [@title "ItemHistoryRoyalty"]
  | IHTransfer of item_history_transfer [@kind_label "type"] [@kind "TRANSFER"] [@title "ItemHistoryTransfer"]
[@@deriving encoding]

type nft_ownership = {
  nft_ownership_id : string ;
  nft_ownership_contract : A.address ;
  nft_ownership_token_id : A.big_integer ;
  nft_ownership_owner : A.address ;
  nft_ownership_creators : part list ;
  nft_ownership_value : A.big_integer ;
  nft_ownership_lazy_value : A.big_integer ;
  nft_ownership_date : A.date ;
  nft_ownership_pending : item_history list;
} [@@deriving encoding {camel}]

type nft_ownerships = {
  nft_ownerships_total : int64 ; [@encoding A.uint53]
  nft_ownerships_continuation : string option ; [@opt]
  nft_ownerships_ownerships : nft_ownership list ;
} [@@deriving encoding]

type nft_signature = {
  nft_signature_r : A.bytes_str ;
  nft_signature_s : A.binary ;
  nft_signature_v : A.binary ;
} [@@deriving encoding]

type nft_token_id = {
  nft_token_id : A.big_integer ; [@key "tokenId"]
  nft_token_id_signature : nft_signature option; [@key "signature"] [@opt]
} [@@deriving encoding]

type nft_collection_feature =
  | NCFAPPROVE_FOR_ALL
  | NCFSET_URI_PREFIX
  | NCFBURN
  | NCFMINT_WITH_ADDRESS
  | NCFSECONDARY_SALE_FEES
  | NCFMINT_AND_TRANSFER
[@@deriving encoding {enum}]

type nft_collection_type =
  | CTFA_2
  | CTPUNKS
[@@deriving encoding {enum}]

type nft_collection = {
  nft_collection_id : A.address ;
  nft_collection_owner : A.address option ; [@opt]
  nft_collection_type : nft_collection_type ;
  nft_collection_name : string ;
  nft_collection_symbol : string option ; [@opt]
  nft_collection_features : nft_collection_feature list ;
  nft_collection_supports_lazy_mint: bool ;
} [@@deriving encoding]

type nft_collections = {
  nft_collections_total : int64 ; [@encoding A.uint53]
  nft_collections_continuation : string option ; [@opt]
  nft_collections_collections : nft_collection list ;
} [@@deriving encoding]

type asset_type_nft = {
  asset_type_nft_contract : A.address ;
  asset_type_nft_token_id : A.big_integer ;
} [@@deriving encoding {camel}]

type asset_type_lazy_nft = {
  asset_type_lazy_nft_contract : A.address ;
  asset_type_lazy_nft_token_id : A.big_integer ;
  asset_type_lazy_nft_uri : string ;
  asset_type_lazy_nft_creators : part list ;
  asset_type_lazy_nft_royalties : part list ;
  asset_type_lazy_nft_signature : A.binary ;
} [@@deriving encoding {camel}]

type asset_fa2 = {
  asset_fa2_contract : A.address ;
  asset_fa2_token_id : A.big_integer ;
} [@@deriving encoding {camel}]

type asset_type =
  | ATXTZ [@kind_label "assetClass"] [@kind "XTZ"] [@title "AssetTypeXTZ"]
  | ATFA_1_2 of (A.address [@wrap "contract"]) [@kind_label "assetClass"] [@kind "FA_1_2"] [@title "AssetTypeFA_1_2"]
  | ATFA_2 of asset_fa2 [@kind_label "assetClass"] [@kind "FA_2"] [@title "AssetTypeFA_2"]
  (* | ATETH [@kind_label "assetClass"] [@kind "ETH"]
   * | ATERC721 of asset_type_nft [@kind_label "assetClass"] [@kind "ERC721"] *)
  (* | ATETH [@kind "assetClass"] [@kind_label "ETH"]
   * | ATFLOW [@kind "assetClass"] [@kind_label "FLOW"]
   * | ATERC20 of (A.address [@wrap "contract"])[@kind "assetClass"] [@kind_label "ERC20"]
   * | ATERC721 of asset_type_nft [@kind "assetClass"] [@kind_label "ERC721"]
   * | ATERC1155 of asset_type_nft [@kind "assetClass"] [@kind_label "ERC1155"]
   * | ATERC721_LAZY of asset_type_lazy_nft [@kind "assetClass"] [@kind_label "ERC721_LAZY"]
   * | ATERC1155_LAZY of asset_type_lazy_nft [@kind "assetClass"] [@kind_label "ERC1155_LAZY"] *)
[@@deriving encoding]

type asset = {
  asset_type : asset_type [@key "assetType"] ;
  asset_value : A.big_integer [@key "value"] ;
} [@@deriving encoding]

type order_form_elt = {
  order_form_elt_maker : A.address ;
  order_form_elt_taker : A.address option ; [@opt]
  order_form_elt_make : asset ;
  order_form_elt_take : asset ;
  order_form_elt_salt : A.big_integer ;
  order_form_elt_start : A.date_int64 option ; [@opt]
  order_form_elt_end : A.date_int64 option ; [@opt]
  order_form_elt_signature : A.binary ;
} [@@deriving encoding]

type order_open_sea_v1_data_v1_fee_method =
  | OSPROTOCOL_FEE
  | OSSPLIT_FEE
[@@deriving encoding {enum}]

type order_open_sea_v1_data_v1_type =
  | OSBUY
  | OSSELL
[@@deriving encoding {enum}]

type order_open_sea_v1_data_v1_kind =
  | OSFIXED_PRICE
  | OSDUTCH_AUCTION
[@@deriving encoding {enum}]

type order_open_sea_v1_data_v1_how_to_call =
  | OSCALL
  | OSDUTCH_AUCTION
[@@deriving encoding {enum}]

type order_open_sea_v1_data_v1 = {
  order_open_sea_v1_data_v1_data_type: string ;
  order_open_sea_v1_data_v1_exchange : A.address ;
  order_open_sea_v1_data_v1_maker_relayer_fee : A.big_integer ;
  order_open_sea_v1_data_v1_taker_relayer_fee : A.big_integer ;
  order_open_sea_v1_data_v1_maker_protocol_fee : A.big_integer ;
  order_open_sea_v1_data_v1_taker_protocol_fee : A.big_integer ;
  order_open_sea_v1_data_v1_fee_recipient : A.address ;
  order_open_sea_v1_data_v1_fee_method : order_open_sea_v1_data_v1_fee_method ;
  order_open_sea_v1_data_v1_type: order_open_sea_v1_data_v1_type ;
  order_open_sea_v1_data_v1_sale_kind : order_open_sea_v1_data_v1_kind ;
  order_open_sea_v1_data_v1_how_to_call : order_open_sea_v1_data_v1_how_to_call ;
  order_open_sea_v1_data_v1_call_data : A.binary ;
  order_open_sea_v1_data_v1_replacement_pattern : A.binary ;
  order_open_sea_v1_data_v1_static_target: A.address ;
  order_open_sea_v1_data_v1_static_extra_data: A.binary ;
  order_open_sea_v1_data_v1_extra: A.big_integer;
} [@@deriving encoding {camel}]

type order_data_legacy = {
  order_data_legacy_data_type : string ;
  order_data_legacy_fee : int ;
} [@@deriving encoding {camel}]

type order_rarible_v2_data_v1 = {
  order_rarible_v2_data_v1_data_type : string ;
  order_rarible_v2_data_v1_payouts : part list ;
  order_rarible_v2_data_v1_origin_fees : part list ;
} [@@deriving encoding {camel}]

type order_form = {
  order_form_data: order_rarible_v2_data_v1;
  order_form_elt: order_form_elt [@merge];
  order_form_type: unit [@encoding Json_encoding.constant "RARIBLE_V2"]
} [@@deriving encoding]

type order_exchange_history_elt = {
  order_exchange_history_elt_hash : A.word ;
  order_exchange_history_elt_make : asset option; [@opt]
  order_exchange_history_elt_take : asset option ; [@opt]
  order_exchange_history_elt_date : A.date ;
  order_exchange_history_elt_maker : A.address option ; [@opt]
} [@@deriving encoding]

type order_side =
  | OSLEFT
  | OSRIGHT
[@@deriving encoding {enum}]

type order_side_match = {
  order_side_match_elt : order_exchange_history_elt [@merge];
  order_side_match_side : order_side option ; [@opt]
  order_side_match_fill : A.big_integer ;
  order_side_match_taker : A.address option ; [@opt]
  order_side_match_counter_hash : A.word option ; [@opt]
  order_side_match_make_usd : A.big_decimal option ; [@opt]
  order_side_match_take_usd : A.big_decimal option ; [@opt]
  order_side_match_make_price_usd : A.big_decimal option ; [@opt]
  order_side_match_take_price_usd : A.big_decimal option ; [@opt]
} [@@deriving encoding {camel}]

type order_exchange_history =
  | OrderCancel of order_exchange_history_elt [@kind_label "type"] [@kind "CANCEL"] [@title "OrderCancel"]
  | OrderSideMatch of order_side_match [@kind_label "type"] [@kind "ORDER_SIDE_MATCH"] [@title "OrderSideMatch"]
[@@deriving encoding]

type order_price_history_record = {
  order_price_history_record_date : A.date ;
  order_price_history_record_make_value : A.big_decimal ;
  order_price_history_record_take_value : A.big_decimal ;
} [@@deriving encoding {camel}]

type order_elt = {
  order_elt_maker : A.address;
  order_elt_taker: A.address option; [@opt]
  order_elt_make: asset;
  order_elt_take: asset;
  order_elt_fill: A.big_integer;
  order_elt_start: A.date_int64 option; [@opt]
  order_elt_end: A.date_int64 option; [@opt]
  order_elt_make_stock: A.big_integer;
  order_elt_cancelled: bool ;
  order_elt_salt: A.word;
  order_elt_signature: A.binary;
  order_elt_created_at: A.date;
  order_elt_last_update_at: A.date;
  order_elt_pending: order_exchange_history list option ; [@opt]
  order_elt_hash: A.word;
  order_elt_make_balance: A.big_integer option; [@opt]
  order_elt_make_price_usd: A.big_decimal;
  order_elt_take_price_usd: A.big_decimal;
  order_elt_price_history: order_price_history_record list ;
} [@@deriving encoding {camel}]

type order = {
  order_data: order_rarible_v2_data_v1;
  order_elt: order_elt [@merge];
  order_type: unit [@encoding Json_encoding.constant "RARIBLE_V2"]
} [@@deriving encoding]

type prepare_order_tx_form = {
  prepare_order_tx_form_maker : A.address ;
  prepare_order_tx_form_amount : A.big_integer ;
  prepare_order_tx_form_payouts : part list ;
  prepare_order_tx_form_origin_fees : part list ;
} [@@deriving encoding {camel}]

type prepared_order_tx = {
  prepared_order_tx_to : A.address ;
  prepared_order_tx_data : A.binary ;
} [@@deriving encoding]

type prepare_order_tx_response = {
  prepare_order_tx_response_transfer_proxy_address : A.address option ; [@opt]
  prepare_order_tx_response_asset : asset ;
  prepare_order_tx_response_transaction : prepared_order_tx ;
} [@@deriving encoding {camel}]

type invert_order_form = {
  invert_order_form_maker : A.address ;
  invert_order_form_amount : A.big_integer ;
  invert_order_form_salt : A.big_integer ;
  invert_order_form_origin_fees : part list ;
} [@@deriving encoding {camel}]

type orders_pagination = {
  orders_pagination_orders : order list ;
  orders_pagination_contination : string option ; [@opt]
} [@@deriving encoding]

type aggregation_data = {
  aggregation_data_address : A.address ;
  aggregation_data_sum : A.big_decimal ;
  aggregation_data_count : int64 ; [@encoding A.uint53]
} [@@deriving encoding]

type aggregation_datas = aggregation_data list [@@deriving encoding]

type order_activity_filter_all_type =
  | OALLBID
  | OALLLIST
  | OALLMATCH
[@@deriving encoding {enum}]

type order_activity_filter_user_type =
  | OUserMAKE_BID
  | OUserGET_BID
  | OUserLIST
  | OUserBUY
  | OUserSELL
[@@deriving encoding {enum}]

type order_activity_by_user = {
  order_activity_by_user_types : order_activity_filter_user_type list ;
  order_activity_by_user_users : A.address list
} [@@deriving encoding]

type order_activity_by_item = {
  order_activity_by_item_types : order_activity_filter_all_type list;
  order_activity_by_item_contract : A.address;
  order_activity_by_item_token_id : A.big_integer;
} [@@deriving encoding {camel}]

type order_activity_by_collection = {
  order_activity_by_collection_types : order_activity_filter_all_type list;
  order_activity_by_collection_contract : A.address;
} [@@deriving encoding]

type order_activity_filter =
  | OrderActivityFilterAll of
      (order_activity_filter_all_type list [@wrap "types"]) [@kind "all"] [@kind_label "@type"] [@title "OrderActivityFilterAll"]
  | OrderActivityFilterByUser of
      order_activity_by_user [@kind "by_user"] [@kind_label "@type"] [@title "OrderActivityFilterByUser"]
  | OrderActivityFilterByItem of
      order_activity_by_item [@kind "by_item"] [@kind_label "@type"] [@title "OrderActivityFilterByItem"]
  | OrderActivityFilterByCollection of
      order_activity_by_collection [@kind "by_collection"] [@kind_label "@type"] [@title "OrderActivityFilterByCollection"]
[@@deriving encoding]

type order_activity_source =
  | SourceRARIBLE
  | SourceOPEN_SEA
[@@deriving encoding {enum}]

type order_activity_elt = {
  order_activity_elt_id : string ;
  order_activity_elt_date : A.date ;
  order_activity_elt_source : order_activity_source ;
} [@@deriving encoding]

type order_activity_side_type =
  | STSELL
  | STBID
[@@deriving encoding {enum}]

type order_activity_match_side = {
  order_activity_match_side_maker : A.address ;
  order_activity_match_side_hash : A.word ;
  order_activity_match_side_asset : asset ;
  order_activity_match_side_type : order_activity_side_type ;
} [@@deriving encoding]

type order_activity_match = {
  order_activity_match_left: order_activity_match_side ;
  order_activity_match_right: order_activity_match_side ;
  order_activity_match_price: A.big_decimal ;
  order_activity_match_price_usd: A.big_decimal option ; [@opt]
  order_activity_match_transaction_hash: A.word ;
  order_activity_match_block_hash: A.word ;
  order_activity_match_block_number: A.block_number ;
  order_activity_match_log_index: int ;
} [@@deriving encoding {camel}]

type order_activity_bid = {
  order_activity_bid_hash : A.word ;
  order_activity_bid_maker : A.address ;
  order_activity_bid_make : asset ;
  order_activity_bid_take : asset ;
  order_activity_bid_price : A.big_decimal ;
  order_activity_bid_price_usd : A.big_decimal option ; [@opt]
} [@@deriving encoding {camel}]

type order_activity_cancel_bid = {
  order_activity_cancel_bid_hash : A.word ;
  order_activity_cancel_bid_maker : A.address ;
  order_activity_cancel_bid_make : asset_type ;
  order_activity_cancel_bid_take : asset_type ;
  order_activity_cancel_bid_transaction_hash : A.word ;
  order_activity_cancel_bid_block_hash : A.word ;
  order_activity_cancel_bid_block_number : A.block_number ;
  order_activity_cancel_bid_log_index : int ;
} [@@deriving encoding {camel}]

type order_activity =
  | OrderActivityMatch of order_activity_match [@kind "match"] [@kind_label "@type"] [@title "OrderActivityMatch"]
  | OrderActivityList of order_activity_bid [@kind "list"] [@kind_label "@type"] [@title "OrderActivityList"]
  | OrderActivityBid of order_activity_bid [@kind "bid"] [@kind_label "@type"] [@title "OrderActivityBid"]
  | OrderActivityCancelBid of order_activity_cancel_bid [@kind "cancel_bid"] [@kind_label "@type"] [@title "OrderActivityCancelBid"]
  | OrderActivityCancelList of order_activity_cancel_bid [@kind "cancel_list"] [@kind_label "@type"] [@title "OrderActivityCancelList"]
[@@deriving encoding]

type order_activities = {
  order_activities_items : order_activity list ;
  order_activities_continuation : string option ; [@opt]
} [@@deriving encoding]

type order_bid_status =
  | BSACTIVE
  | BSFILLED
  | BSHISTORICAL
  | BSINACTIVE
  | BSCANCELLED
[@@deriving encoding {enum}]

type order_bid_elt = {
  order_bid_elt_order_hash : A.word ;
  order_bid_elt_status : order_bid_status ;
  order_bid_elt_maker : A.address ;
  order_bid_elt_taker : A.address option ; [@opt]
  order_bid_elt_make : asset ;
  order_bid_elt_take : asset ;
  order_bid_elt_make_balance : A.big_integer option ;
  order_bid_elt_make_price_usd : A.big_decimal option ; [@opt]
  order_bid_elt_take_price_usd : A.big_decimal option ; [@opt]
  order_bid_elt_fill : A.big_integer ;
  order_bid_elt_make_stock : A.big_integer ;
  order_bid_elt_cancelled : bool ;
  order_bid_elt_salt : A.big_integer ;
  order_bid_elt_signature : A.binary ;
  order_bid_elt_created_at : A.date;
} [@@deriving encoding {camel}]

type order_bid = {
  order_bid_data: order_rarible_v2_data_v1;
  order_bid_elt: order_bid_elt [@merge];
  order_bid_type: unit [@encoding Json_encoding.constant "RARIBLE_V2"]
} [@@deriving encoding]

type order_bids_pagination = {
  order_bids_pagination_items : order_bid list ;
  order_bids_pagination_continuation : string option ; [@opt]
} [@@deriving encoding]

type signature_form = {
  signature_form_signature : A.binary option ; [@opt]
  signature_form_content : string ;
} [@@deriving encoding]

type fee_side = FeeSideMake | FeeSideTake

type exchange_param =
  | Cancel of string
  | DoTransfers of
      {left: string; left_maker : string option; left_asset: asset ;
       right: string ; right_maker: string option; right_asset: asset ;
       fill_make_value: int64; fill_take_value: int64}

type order_event = {
  order_event_event_id : string ;
  order_event_order_id : string ;
  order_event_order : order ;
  order_event_type : string ;
} [@@deriving encoding {camel}]

type nft_deleted_item = {
  nft_deleted_item_id : string ;
  nft_deleted_item_token : A.address ;
  nft_deleted_item_token_id : A.big_integer ;
} [@@deriving encoding {camel}]

type nft_event =
  | NftItemUpdateEvent of nft_item [@wrap "item"] [@kind "UPDATE"] [@kind_label "type"]
  | NftItemDeleteEvent of nft_deleted_item [@wrap "item"] [@kind "DELETE"] [@kind_label "type"]
 [@@deriving encoding]

type nft_item_event = {
  nft_item_event_event_id : string ;
  nft_item_event_item_id : string ;
  nft_item_event_event : nft_event ; [@merge]
} [@@deriving encoding {camel}]

type nft_deleted_ownership = {
  nft_deleted_ownership_id : string ;
  nft_deleted_ownership_token : A.address ;
  nft_deleted_ownership_token_id : A.big_integer ;
  nft_deleted_ownership_owner : A.address ;
} [@@deriving encoding {camel}]

type ownership_event =
  | NftOwnershipUpdateEvent of
      nft_ownership [@wrap "ownership"] [@kind "UPDATE"] [@kind_label "type"]
  | NftOwnershipDeleteEvent of
      nft_deleted_ownership [@wrap "ownership"] [@kind "DELTE"] [@kind_label "type"]
[@@deriving encoding]

type nft_ownership_event = {
  nft_ownership_event_event_id : string ;
  nft_ownership_event_ownership_id : string ;
  nft_ownership_event_event : ownership_event ; [@merge]
} [@@deriving encoding {camel}]
