import { AssetType } from "../utils"

export function is_nft(a: AssetType) {
  return (a.asset_class === "FA_2")
}
