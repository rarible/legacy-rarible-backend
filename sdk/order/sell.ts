import { Provider, XTZAssetType, FA12AssetType } from "../common/base"
import { ExtendedAssetType, check_asset_type } from "../common/check-asset-type"
import { Part, OrderForm, salt } from "./utils"
import { upsert_order } from "./upsert-order"

export interface SellRequest {
  maker: string
  make_asset_type: ExtendedAssetType
  amount: bigint
  take_asset_type: XTZAssetType | FA12AssetType
  price: bigint
  payouts: Array<Part>
  origin_fees: Array<Part>
}

export async function sell(
  provider: Provider,
  request: SellRequest
) {
  const order: OrderForm = {
    maker: request.maker,
    make: {
      asset_type: await check_asset_type(provider, request.make_asset_type),
      value: request.amount,
    },
    take: {
      asset_type: request.take_asset_type,
      value: request.price * request.amount,
    },
    type: "RARIBLE_V2",
    data: {
      data_type: "V1",
      payouts: request.payouts,
      origin_fees: request.origin_fees,
    },
    salt: salt()
  }
  return upsert_order(provider, order, false)
}
