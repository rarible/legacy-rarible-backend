import { AssetType, FA2AssetType } from "../base"

export function is_nft(a: AssetType) : a is FA2AssetType {
  return (a.asset_class === "FA_2")
}
