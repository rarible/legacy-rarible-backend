import { Provider, XTZAssetType, FTAssetType, mutez_to_tez } from "./base"

export async function get_balance(
  provider: Provider,
  owner: string,
  asset_type: XTZAssetType | FTAssetType) : Promise<string> {
  switch (asset_type.asset_class) {
    case "XTZ":
      const b_tz = await provider.tezos.balance()
      return mutez_to_tez(b_tz).toString()
    case "FT":
      const r = await fetch(provider.api + '/v0.1/balances/' + asset_type.contract + '/' + owner)
      if (r.ok) {
        const json = await r.json()
        return json.balance
      } else {
        throw new Error(r.statusText)
      }
  }
}
