import { Provider, XTZAssetType, FA12AssetType } from "../common/base"
import { ExtendedAssetType, check_asset_type } from "../common/check-asset-type"
import { Part, OrderForm, salt } from "./utils"
import { upsert_order } from "./upsert-order"

export interface SellRequest {
  maker: string
  makeAssetType: ExtendedAssetType
  amount: bigint
  takeAssetType: XTZAssetType | FA12AssetType
  price: bigint
  payouts: Array<Part>
  originFees: Array<Part>
}

export async function sell(
  provider: Provider,
  request: SellRequest
) {
  const order: OrderForm = {
    maker: request.maker,
    make: {
      asset_type: await check_asset_type(provider, request.makeAssetType),
      value: request.amount,
    },
    take: {
      asset_type: request.takeAssetType,
      value: request.price * request.amount,
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