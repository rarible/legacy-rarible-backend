import { Provider, NftAssetType } from "../utils"

export interface UnknownNftAssetType {
  contract: string;
  token_id: bigint
}

export type ExtendedAssetType = NftAssetType | UnknownNftAssetType

export async function get_asset_type(
  provider: Provider,
  contract: string) : Promise<NftAssetType> {
  const r = await fetch(provider.api + '/' + contract + '/asset_type')
  if (r.ok) { return r.json() }
  else throw new Error("Cannot get asset type of contract " + contract)
}

export async function check_asset_type(
  provider: Provider,
  asset: ExtendedAssetType,
): Promise<NftAssetType> {
  if ("assetClass" in asset) return asset
  else return get_asset_type(provider, asset.contract)
}
