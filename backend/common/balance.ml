open Rtypes

let dec_asset ?d a = {a with asset_value = Utils.decimal_balance ?decimals:d a.asset_value}
let z_asset ?d a = {a with asset_value = Utils.absolute_balance ?decimals:d a.asset_value}
let dec_order_form_elt ?maked ?taked o =
  { o with order_form_elt_make = dec_asset ?d:maked o.order_form_elt_make;
           order_form_elt_take = dec_asset ?d:taked o.order_form_elt_take }
let z_order_form_elt ?maked ?taked o =
  { o with order_form_elt_make = z_asset ?d:maked o.order_form_elt_make;
           order_form_elt_take = z_asset ?d:taked o.order_form_elt_take }
let dec_order_form ?maked ?taked o =
  { o with order_form_elt = dec_order_form_elt ?maked ?taked o.order_form_elt }
let z_order_form ?maked ?taked o =
  { o with order_form_elt = z_order_form_elt ?maked ?taked o.order_form_elt }
let dec_order_exchange_history_elt ?maked ?taked o =
  { o with order_exchange_history_elt_make = Option.map (dec_asset ?d:maked) o.order_exchange_history_elt_make;
           order_exchange_history_elt_take = Option.map (dec_asset ?d:taked) o.order_exchange_history_elt_take }
let z_order_exchange_history_elt ?maked ?taked o =
  { o with order_exchange_history_elt_make = Option.map (z_asset ?d:maked) o.order_exchange_history_elt_make;
           order_exchange_history_elt_take = Option.map (z_asset ?d:taked) o.order_exchange_history_elt_take }
let dec_order_side_match ?maked ?taked o =
  { o with order_side_match_elt = dec_order_exchange_history_elt ?maked ?taked o.order_side_match_elt }
let z_order_side_match ?maked ?taked o =
  { o with order_side_match_elt = z_order_exchange_history_elt ?maked ?taked o.order_side_match_elt }
let dec_order_exchange_history ?maked ?taked = function
  | OrderCancel o -> OrderCancel (dec_order_exchange_history_elt ?maked ?taked o)
  | OrderSideMatch o -> OrderSideMatch (dec_order_side_match ?maked ?taked o)
let z_order_exchange_history ?maked ?taked = function
  | OrderCancel o -> OrderCancel (z_order_exchange_history_elt ?maked ?taked o)
  | OrderSideMatch o -> OrderSideMatch (z_order_side_match ?maked ?taked o)
let dec_order_price_history_record ?maked ?taked o =
  { o with order_price_history_record_make_value = Utils.decimal_balance ?decimals:maked o.order_price_history_record_make_value;
           order_price_history_record_take_value = Utils.decimal_balance ?decimals:taked o.order_price_history_record_take_value }
let z_order_price_history_record ?maked ?taked o =
  { o with order_price_history_record_make_value = Utils.absolute_balance ?decimals:maked o.order_price_history_record_make_value;
           order_price_history_record_take_value = Utils.absolute_balance ?decimals:taked o.order_price_history_record_take_value }
let dec_order_elt ?maked ?taked o =
  { o with order_elt_make = dec_asset ?d:maked o.order_elt_make;
           order_elt_take = dec_asset ?d:taked o.order_elt_take;
           order_elt_price_history =
             List.map (dec_order_price_history_record ?maked ?taked)
               o.order_elt_price_history }
let z_order_elt ?maked ?taked o =
  { o with order_elt_make = z_asset ?d:maked o.order_elt_make;
           order_elt_take = z_asset ?d:taked o.order_elt_take;
           order_elt_price_history =
             List.map (z_order_price_history_record ?maked ?taked)
               o.order_elt_price_history }
let dec_order ?maked ?taked o =
  { o with order_elt = dec_order_elt ?maked ?taked o.order_elt }
let z_order ?maked ?taked o =
  { o with order_elt = z_order_elt ?maked ?taked o.order_elt }
let dec_orders_pagination ~d o =
  { o with orders_pagination_orders =
             List.map2 (fun o (maked, taked) ->
                 dec_order ?maked ?taked o) o.orders_pagination_orders d }
let z_orders_pagination ~d o =
  { o with orders_pagination_orders =
             List.map2 (fun o (maked, taked) ->
                 z_order ?maked ?taked o) o.orders_pagination_orders d }
let dec_order_activity_match_side ?d o =
  { o with order_activity_match_side_asset = dec_asset ?d o.order_activity_match_side_asset }
let z_order_activity_match_side ?d o =
  { o with order_activity_match_side_asset = z_asset ?d o.order_activity_match_side_asset }
let priced ?maked ?taked make take =
  match make.asset_type, take.asset_type with
  | ATNFT _, _ | ATMT _, _ -> maked
  | _ -> taked
let dec_order_activity_match ?maked ?taked o =
  let priced = priced ?maked ?taked
      o.order_activity_match_left.order_activity_match_side_asset
      o.order_activity_match_left.order_activity_match_side_asset in
  { o with order_activity_match_left = dec_order_activity_match_side ?d:maked o.order_activity_match_left;
           order_activity_match_right = dec_order_activity_match_side ?d:taked o.order_activity_match_right;
           order_activity_match_price = Utils.decimal_balance ?decimals:priced o.order_activity_match_price }
let z_order_activity_match ?maked ?taked o =
  let priced = priced ?maked ?taked
      o.order_activity_match_left.order_activity_match_side_asset
      o.order_activity_match_left.order_activity_match_side_asset in
  { o with order_activity_match_left = z_order_activity_match_side ?d:maked o.order_activity_match_left;
           order_activity_match_right = z_order_activity_match_side ?d:taked o.order_activity_match_right;
           order_activity_match_price = Utils.absolute_balance ?decimals:priced o.order_activity_match_price }
let dec_order_activity_bid ?maked ?taked o =
  let priced = priced ?maked ?taked o.order_activity_bid_make o.order_activity_bid_take in
  { o with order_activity_bid_make = dec_asset ?d:maked o.order_activity_bid_make;
           order_activity_bid_take = dec_asset ?d:taked o.order_activity_bid_take;
           order_activity_bid_price = Utils.decimal_balance ?decimals:priced o.order_activity_bid_price }
let z_order_activity_bid ?maked ?taked o =
  let priced = priced ?maked ?taked o.order_activity_bid_make o.order_activity_bid_take in
  { o with order_activity_bid_make = z_asset ?d:maked o.order_activity_bid_make;
           order_activity_bid_take = z_asset ?d:taked o.order_activity_bid_take;
           order_activity_bid_price = Utils.absolute_balance ?decimals:priced o.order_activity_bid_price }
let dec_order_activity_type ?maked ?taked = function
  | OrderActivityMatch o -> OrderActivityMatch (dec_order_activity_match ?maked ?taked o)
  | OrderActivityList o -> OrderActivityList (dec_order_activity_bid ?maked ?taked o)
  | OrderActivityBid o -> OrderActivityBid (dec_order_activity_bid ?maked ?taked o)
  | OrderActivityCancelBid o -> OrderActivityCancelBid o
  | OrderActivityCancelList o -> OrderActivityCancelList o
let z_order_activity_type ?maked ?taked = function
  | OrderActivityMatch o -> OrderActivityMatch (z_order_activity_match ?maked ?taked o)
  | OrderActivityList o -> OrderActivityList (z_order_activity_bid ?maked ?taked o)
  | OrderActivityBid o -> OrderActivityBid (z_order_activity_bid ?maked ?taked o)
  | OrderActivityCancelBid o -> OrderActivityCancelBid o
  | OrderActivityCancelList o -> OrderActivityCancelList o
let dec_nft_activity_elt n =
  { n with nft_activity_value = Z.to_string n.nft_activity_value }
let z_nft_activity_elt n =
  { n with nft_activity_value = Z.of_string n.nft_activity_value }
let dec_nft_activity_type = function
  | NftActivityMint n -> NftActivityMint (dec_nft_activity_elt n)
  | NftActivityBurn n -> NftActivityBurn (dec_nft_activity_elt n)
  | NftActivityTransfer {elt; from} -> NftActivityTransfer {elt=dec_nft_activity_elt elt; from}
let z_nft_activity_type = function
  | NftActivityMint n -> NftActivityMint (z_nft_activity_elt n)
  | NftActivityBurn n -> NftActivityBurn (z_nft_activity_elt n)
  | NftActivityTransfer {elt; from} -> NftActivityTransfer {elt=z_nft_activity_elt elt; from}
let dec_nft_activities n =
  { n with nft_activities_items = List.map dec_nft_activity_type n.nft_activities_items }
let z_nft_activities n =
  { n with nft_activities_items = List.map z_nft_activity_type n.nft_activities_items }
let dec_all_activity_type ?maked ?taked = function
  | OrderActivityType o -> OrderActivityType (dec_order_activity_type ?maked ?taked o)
  | NftActivityType o -> NftActivityType (dec_nft_activity_type o)
let z_all_activity_type ?maked ?taked = function
  | OrderActivityType o -> OrderActivityType (z_order_activity_type ?maked ?taked o)
  | NftActivityType o -> NftActivityType (z_nft_activity_type o)
let dec_activity_type ?maked ?taked a =
  { a with activity_type = dec_all_activity_type ?maked ?taked a.activity_type }
let z_activity_type ?maked ?taked a =
  { a with activity_type = z_all_activity_type ?maked ?taked a.activity_type }
let dec_order_activities ~d o =
  { o with order_activities_items =
             List.map2 (fun o (maked, taked) -> dec_order_activity_type ?maked ?taked o) o.order_activities_items d }
let z_order_activities ~d o =
  { o with order_activities_items =
             List.map2 (fun o (maked, taked) -> z_order_activity_type ?maked ?taked o) o.order_activities_items d }
let dec_order_bid_elt ?maked ?taked o =
  { o with order_bid_elt_make = dec_asset ?d:maked o.order_bid_elt_make;
           order_bid_elt_take = dec_asset ?d:taked o.order_bid_elt_take }
let z_order_bid_elt ?maked ?taked o =
  { o with order_bid_elt_make = z_asset ?d:maked o.order_bid_elt_make;
           order_bid_elt_take = z_asset ?d:taked o.order_bid_elt_take }
let dec_order_bid ?maked ?taked o =
  { o with order_bid_elt = dec_order_bid_elt ?maked ?taked o.order_bid_elt }
let z_order_bid ?maked ?taked o =
  { o with order_bid_elt = z_order_bid_elt ?maked ?taked o.order_bid_elt }
let dec_order_bids_pagination ~d o =
  { o with order_bids_pagination_items =
             List.map2 (fun o (maked, taked) -> dec_order_bid ?maked ?taked o)
               o.order_bids_pagination_items d }
let z_order_bids_pagination ~d o =
  { o with order_bids_pagination_items =
             List.map2 (fun o (maked, taked) -> z_order_bid ?maked ?taked o)
               o.order_bids_pagination_items d }
let dec_order_event ?maked ?taked o =
  { o with order_event_order = dec_order ?maked ?taked o.order_event_order }
let z_order_event ?maked ?taked o =
  { o with order_event_order = z_order ?maked ?taked o.order_event_order }
let dec_ft_balance ?d b = { b with ft_balance = Utils.decimal_balance ?decimals:d b.ft_balance }
let z_ft_balance ?d b = { b with ft_balance = Utils.absolute_balance ?decimals:d b.ft_balance }
