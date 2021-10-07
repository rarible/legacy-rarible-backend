import { Provider, XTZAssetType, FA12AssetType } from "../common/base"
import { ExtendedAssetType, check_asset_type } from "../common/check-asset-type"
import { Part, OrderForm, salt } from "./utils"
import { upsert_order } from "./upsert-order"

export type BidRequest = {
  maker: string
  make_asset_type: XTZAssetType | FA12AssetType
  amount: bigint
  take_asset_type: ExtendedAssetType
  price: bigint
  payouts: Array<Part>
  origin_fees: Array<Part>
}

export async function bid(
  provider: Provider,
  request: BidRequest
) {
  const order: OrderForm = {
    maker: request.maker,
    make: {
      asset_type: request.make_asset_type,
      value: request.price * request.amount,
    },
    take: {
      asset_type: await check_asset_type(provider, request.take_asset_type),
      value: request.amount,
    },
    type: "RARIBLE_V2",
    data: {
      data_type: "V1",
      payouts: request.payouts,
      origin_fees: request.origin_fees,
    },
    salt: 0n
  }
  return upsert_order(provider, order, false)
}
