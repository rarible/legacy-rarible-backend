import { Asset } from "../common/base"

// export interface OrderCancel {
//   type: "CANCEL";
//   hash: string;
//   make?: Asset;
//   take?: Asset;
//   date: string;
//   maker?: string;
//   owner?: string;
// }

// export type OrderSide = "LEFT" | "RIGHT"

// export interface OrderSideMatch {
//   type: "ORDER_SIDE_MATCH";
//   hash: string;
//   make?: Asset;
//   take?: Asset;
//   date: string;
//   maker?: string;
//   side?: OrderSide;
//   fill: bigint;
//   taker?: string;
//   counterHash?: string;
//   makeUsd?: bigint;
//   takeUsd?: bigint;
//   makePriceUsd?: bigint;
//   takePriceUsd?: bigint;
// }

// export type OrderExchangeHistory = OrderCancel | OrderSideMatch

export interface Part {
  account: string;
  value: bigint;
}

export interface OrderRaribleV2DataV1 {
  data_type: "RARIBLE_V2_DATA_V1";
  payouts: Array<Part>;
  origin_fees: Array<Part>;
}

export declare type OrderForm = {
  type: "RARIBLE_V2";
  maker: string;
  taker?: string;
  make: Asset;
  take: Asset;
  salt: bigint;
  start?: number;
  end?: number;
  signature?: string;
  data: OrderRaribleV2DataV1;
}

// export type Order = OrderForm & {
//   fill: bigint;
//   makeStock: bigint;
//   cancelled: boolean;
//   createdAt: string;
//   lastUpdateAt: string;
//   pending?: Array<OrderExchangeHistory>;
//   hash: string;
//   makeBalance?: bigint;
//   makePriceUsd?: bigint;
//   takePriceUsd?: bigint;
// }

export function salt() : bigint {
  let a = new Uint8Array(32)
  a = crypto.getRandomValues(a)
  let h = a.reduce((acc, x) => acc + x.toString(16).padStart(2, '0'), '')
  return BigInt('0x'+h)
}
