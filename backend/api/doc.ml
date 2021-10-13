let docs = List.map (fun (n, t, d) -> (n, (t, d, None, None))) @@ [
    (* NFT activity controller *)
    "search_activities", "getNftActivities", "Search activities with some filter" ;

    (* NFT ownership controller *)
    "ownerships", "getNftOwnershipById", "Get NFT ownerships by id" ;
    "ownerships_by_item", "getNftOwnershipByItem", "Get NFT ownerships by item" ;
    "ownerships_all", "getNftAllOwnerships", "Get NFT all ownerships" ;

    (* NFT item controller *)
    "items_meta", "getNftItemMetaById", "Get NFT item by meta id" ;
    "items_by_id", "getNftItemById", "Get NFT item by id" ;
    "items_by_owner", "getNftItemsByOwner", "Get NFT items by owner" ;
    "items_by_creator", "getNftItemsByCreator", "Get NFT items by creator" ;
    "items_by_collection", "getNftItemsByCollection", "items_by_collection" ;

    (* NFT collection controller *)
    "collections_generate_id", "generateNftTokenId", "collections_generate_id" ;
    "collections_by_id", "getNftCollectionById", "collections_by_id" ;
    "collections_by_owner", "searchNftCollectionsByOwner", "collections_by_owner" ;
    "collections_all", "searchNftAllCollections", "collections_all" ;

    (* Order controller *)
    "orders_upsert", "upsertOrder", "Create or update an order" ;
    "orders_all", "getOrdersAll", "Get all orders" ;
    "orders_by_hash", "getOrderByHash", "Get order by hash" ;
    "orders_by_maker", "getSellOrdersByMaker", "Get sell order by maker" ;
    "orders_sell_by_item", "getSellOrderByItem", "Get sell order by item" ;
    "orders_sell_by_collection", "getSellOrdersByCollection", "Get sell orders by collection" ;
    "orders_sell", "getSellOrders", "Get sell orders" ;
    "orders_bids_by_maker", "getOrderBidsByMaker", "Get order bids by maker" ;
    "orders_bids_by_item", "getOrderBidsByItem", "Get order bids by item" ;

    (* Order Activity controller *)
    "get_order_activities", "getOrderActivities", "get Order activities with some filter" ;

    (* Order Aggregation controller *)
    "aggregate_nft_sell_by_maker", "aggregate_nft_sell_by_maker",
    "Aggregate Nft Sell orders by maker" ;
    "aggregate_nft_purchase_by_taker", "aggregate_nft_purchase_by_taker",
    "Aggregate Nft Sell orders by taker" ;
    "aggregate_nft_purchase_buy_collection", "aggregate_nft_purchase_buy_collection",
    "Aggregate Nft Sell orders by collection" ;

    (* Order Bid controller *)
    "get_bids_by_item", "getBidsByItem", "get Bid by item" ;

    (* Order Signature controller *)
    "validate", "validate", "Validate a message" ;


  ]
