import { Provider, XTZAssetType, FTAssetType } from "./base"
import fetch from 'node-fetch'

export async function get_balance(
  provider: Provider,
  owner: string,
  asset_type: XTZAssetType | FTAssetType) : Promise<string> {
  switch (asset_type.asset_class) {
    case "XTZ":
      const b_tz = await provider.tezos.balance()
      return b_tz.toString()
    case "FT":
      const r = await fetch(provider.config.api + '/v0.1/balances/' + asset_type.contract + '/' + owner)
      if (r.ok) {
        const json = await r.json()
        return json.balance
      } else {
        throw new Error(r.statusText)
      }
  }
}
