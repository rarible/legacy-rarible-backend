import { AssetType, FA2AssetType } from "../utils"

export function is_nft(a: AssetType) : a is FA2AssetType {
  return (a.asset_class === "FA_2")
}
