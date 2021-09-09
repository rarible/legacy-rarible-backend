import { Asset } from "../utils"

export function addFee(asset: Asset, fee: number) : Asset {
  const value : bigint = BigInt((Number(asset.value) * (10000 + fee)) / 10000)
  return { ...asset, value }
}
