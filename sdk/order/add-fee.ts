import { Asset } from "../common/base"
import BigNumber from "@taquito/rpc/node_modules/bignumber.js"

export function add_fee(asset: Asset, fee: BigNumber) : Asset {
  const value = new BigNumber(asset.value)
    .multipliedBy(new BigNumber(10000).plus(fee))
    .div(10000)
  return { ...asset, value }
}
