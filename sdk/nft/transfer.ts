import { Provider, MichelsonData, send, OperationArg } from "../utils"
import { check_asset_type, ExtendedAssetType } from "../check-asset-type"

function transfer_param(
  from: string,
  to: string,
  token_id: bigint[],
  token_amount?: bigint[] ) : MichelsonData {
  const amount : bigint[] = (token_amount) ? token_amount : token_id.map((_) => 1n)
  return [
    {
      prim: 'Pair',
      args: [
        { string: from },
        token_id.map(function(id, i) {
          return {
            prim: 'Pair',
            args: [ { string: to }, { int: id.toString() }, { int: amount[i].toString() } ] }
        })
      ]
    }
  ]
}

export function transfer_nft_arg(
  contract: string,
  from: string,
  to: string,
  token_id: bigint) : OperationArg {
  const parameter = transfer_param(from, to, [ token_id ])
  return { destination: contract, entrypoint: 'transfer', parameter }
}

export async function transfer_nft(
  provider: Provider,
  contract: string,
  from: string,
  to: string,
  token_id: bigint) : Promise<string> {
  const arg = transfer_nft_arg(contract, from, to, token_id)
  const op = await send(provider, arg)
  return op.hash
}

export function transfer_mt_arg(
  contract: string,
  from: string,
  to: string,
  token_id: bigint | bigint[],
  token_amount: bigint | bigint[]) : OperationArg {
  const ids = (Array.isArray(token_id)) ? token_id : [ token_id ]
  const amounts = (Array.isArray(token_amount)) ? token_amount : [ token_amount ]
  const parameter = transfer_param(from, to, ids, amounts)
  return { destination: contract , entrypoint: 'transfer', parameter }
}

export async function transfer_mt(
  provider: Provider,
  contract: string,
  from: string,
  to: string,
  token_id: bigint | bigint[],
  token_amount: bigint | bigint[]) : Promise<string> {
  const arg = transfer_mt_arg(contract, from, to, token_id, token_amount)
  const op = await send(provider, arg)
  return op.hash
}

export async function transfer_arg(
  provider: Provider,
  asset_type: ExtendedAssetType,
  to: string,
  amount?: bigint) : Promise<OperationArg> {
  const from = await provider.tezos.signer.publicKeyHash()
  const checked_asset = await check_asset_type(provider, asset_type)
  switch (checked_asset.asset_class) {
    case "FA_2" :
      if (amount) {
        return transfer_mt_arg(checked_asset.contract, from, to, checked_asset.token_id, amount) }
      else
        return transfer_nft_arg(checked_asset.contract, from, to, checked_asset.token_id)
    default:
      throw new Error("Cannot transfer non FA2 tokens")
  }
}

export async function transfer(
  provider: Provider,
  asset_type: ExtendedAssetType,
  to: string,
  amount?: bigint) : Promise<string> {
  const arg = await transfer_arg(provider, asset_type, to, amount)
  const op = await send(provider, arg)
  return op.hash
}
