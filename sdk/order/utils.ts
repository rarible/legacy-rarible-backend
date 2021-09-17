export interface XTZAssetType {
  asset_class: "XTZ";
}

export interface FA12AssetType {
  asset_class: "FA_1_2";
  contract: string;
}

export interface FA2AssetType {
  asset_class: "FA_2";
  contract: string;
  token_id: bigint;
}

export type AssetType = XTZAssetType | FA12AssetType | FA2AssetType

export interface Asset {
  asset_type: AssetType;
  value: bigint;
}

export interface OrderCancel {
  type: "CANCEL";
  hash: string;
  make?: Asset;
  take?: Asset;
  date: string;
  maker?: string;
  owner?: string;
}

export type OrderSide = "LEFT" | "RIGHT"

export interface OrderSideMatch {
  type: "ORDER_SIDE_MATCH";
  hash: string;
  make?: Asset;
  take?: Asset;
  date: string;
  maker?: string;
  side?: OrderSide;
  fill: bigint;
  taker?: string;
  counterHash?: string;
  makeUsd?: bigint;
  takeUsd?: bigint;
  makePriceUsd?: bigint;
  takePriceUsd?: bigint;
}

export type OrderExchangeHistory = OrderCancel | OrderSideMatch

export interface Part {
    account: string;
    value: bigint;
}

export interface OrderRaribleV2DataV1 {
  data_type: "RARIBLE_V2_DATA_V1";
  payouts: Array<Part>;
  originFees: Array<Part>;
}

export interface Order {
  type: "RARIBLE_V2";
  maker: string;
  taker?: string;
  make: Asset;
  take: Asset;
  fill: bigint;
  start?: number;
  end?: number;
  makeStock: bigint;
  cancelled: boolean;
  salt: string;
  signature?: string;
  createdAt: string;
  lastUpdateAt: string;
  pending?: Array<OrderExchangeHistory>;
  hash: string;
  makeBalance?: bigint;
  makePriceUsd?: bigint;
  takePriceUsd?: bigint;
  data: OrderRaribleV2DataV1;
}

export function mk_asset_type(a: AssetType)
  return {
    prim: 'Pair',
    args: [
      assetclass,
      { bytes: data }
    ]
  }
}
