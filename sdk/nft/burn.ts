import { Provider, MichelsonData, TransactionArg, send, get_address } from "../common/base"
import { check_asset_type, ExtendedAssetType } from "../common/check-asset-type"

// todo : choose type of burn parameter
function burn_param(
  token_id: bigint,
  owner: string,
  amount = 1n) : MichelsonData {
  return {
    prim: 'Pair',
    args: [
      { int: token_id.toString() },
      { prim : 'Pair', args: [
        { string : owner },
        { int : amount.toString() } ] } ] }
}

export async function burn_arg(
  provider: Provider,
  asset_type: ExtendedAssetType,
  amount?: bigint,
  owner?: string) : Promise<TransactionArg> {
  owner = (owner) ? owner : await get_address(provider)
  const checked_asset = await check_asset_type(provider, asset_type)
  switch (checked_asset.asset_class) {
    case "FA_2":
      const parameter = burn_param(checked_asset.token_id, owner, amount)
      return { destination: checked_asset.contract, entrypoint: "burn", parameter }
    default: throw new Error("Cannot burn non FA2 tokens")
  }
}

export async function burn(
  provider: Provider,
  asset_type: ExtendedAssetType,
  amount?: bigint,
  owner?: string,
  wait?: boolean) : Promise<string> {
  const arg = await burn_arg(provider, asset_type, amount, owner)
  return send(provider, arg, wait)
}
