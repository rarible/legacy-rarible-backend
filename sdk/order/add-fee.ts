import { Asset } from "../common/base"

export function add_fee(asset: Asset, fee: bigint) : Asset {
  const value = (asset.value * (10000n + fee)) / 10000n
  return { ...asset, value }
}
