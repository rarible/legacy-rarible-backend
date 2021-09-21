import { Provider, MichelsonData, OperationArg, send } from "../utils"
import { check_asset_type, ExtendedAssetType } from "../check-asset-type"

// todo : choose type of burn parameter
function burn_param(
  token_id: bigint,
  owner: string,
  amount = 1n) : MichelsonData {
  return {
    prim: 'Pair',
    args: [ { int: token_id.toString() }, { string : owner }, { int : amount.toString() } ]
  }
}

export async function burn_arg(
  provider: Provider,
  asset_type: ExtendedAssetType,
  amount?: bigint,
  owner?: string) : Promise<OperationArg> {
  owner = (owner) ? owner : await provider.tezos.signer.publicKeyHash()
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
  owner?: string) : Promise<string> {
  const arg = await burn_arg(provider, asset_type, amount, owner)
  const op = await send(provider, arg)
  return op.hash
}
