import { Provider, TokenAssetType } from "./utils"

export interface UnknownTokenAssetType {
  contract: string;
  token_id: bigint
}

export type ExtendedAssetType = TokenAssetType | UnknownTokenAssetType

export async function get_asset_type(
  provider: Provider,
  contract: string) : Promise<TokenAssetType> {
  const r = await fetch(provider.api + '/' + contract + '/asset_type')
  if (r.ok) { return r.json() }
  else throw new Error("Cannot get asset type of contract " + contract)
}

export async function check_asset_type(
  provider: Provider,
  asset: ExtendedAssetType,
): Promise<TokenAssetType> {
  if ("assetClass" in asset) return asset
  else return get_asset_type(provider, asset.contract)
}
