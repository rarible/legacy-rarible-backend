import { Asset } from "../common/base"

export function add_fee(asset: Asset, fee: bigint) : Asset {
  const value = (asset.value * (10000n + fee)) / BigInt(10000)
  return { ...asset, value }
}
