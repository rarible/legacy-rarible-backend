import { Provider, XTZAssetType, FA12AssetType } from "../base"
import { Part, OrderForm, salt } from "./utils"
import { ExtendedAssetType, check_asset_type } from "../check-asset-type"
import { upsert_order } from "./upsert-order"

export type BidRequest = {
  maker: string
  makeAssetType: XTZAssetType | FA12AssetType
  amount: bigint
  takeAssetType: ExtendedAssetType
  price: bigint
  payouts: Array<Part>
  originFees: Array<Part>
}

export async function bid(
  provider: Provider,
  request: BidRequest
) {
  const order: OrderForm = {
    maker: request.maker,
    make: {
      asset_type: request.makeAssetType,
      value: request.price * request.amount,
    },
    take: {
      asset_type: await check_asset_type(provider, request.takeAssetType),
      value: request.amount,
    },
    type: "RARIBLE_V2",
    data: {
      data_type: "RARIBLE_V2_DATA_V1",
      payouts: request.payouts,
      origin_fees: request.originFees,
    },
    salt: salt()
  }
  return upsert_order(provider, order, false)
}
