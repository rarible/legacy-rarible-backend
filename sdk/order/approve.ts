import { MichelsonData } from "@taquito/michel-codec"
import { Provider, send, StorageFA1_2, StorageFA2, Asset, TransactionArg, OperationResult } from "../common/base"

export async function approve_fa1_2_arg(
  provider: Provider,
  owner: string,
  contract: string,
  value: bigint,
  infinite: boolean = true
) : Promise<TransactionArg | undefined > {
  const spender = provider.config.proxies.fa_1_2
  const st : StorageFA1_2 = await provider.tezos.storage(contract)
  let r = await st.allowance.get({ 0 : owner, 1 : spender })
  if (r===false) {
    let v = (infinite) ? st.totalsupply.toString() : value.toString()
    const parameter : MichelsonData = [ { prim: 'Pair', args : [ { string: spender }, { int: v } ] } ]
    return { destination: contract, entrypoint: "approve", parameter }
  }
  else return undefined
}

export async function approve_fa1_2(
  provider: Provider,
  owner: string,
  contract: string,
  value: bigint,
  infinite: boolean = true,
) : Promise<OperationResult | undefined> {
  const arg = await approve_fa1_2_arg(provider, owner, contract, value, infinite)
  if (arg) return send(provider, arg)
  else return undefined
}

export async function approve_fa2_arg(
  provider: Provider,
  owner: string,
  contract: string,
  token_id?: bigint) : Promise<TransactionArg | undefined> {
  const operator = provider.config.proxies.fa_1_2
  const st : StorageFA2 = await provider.tezos.storage(contract)
  if (token_id) {
    let r = await st.operator.get({ 0 : operator, 1 : token_id, 2: owner })
    if (r===false) {
      let parameter : MichelsonData = [
        { prim: 'Left', args: [
          { prim: "Pair", args: [
            { string: owner },
            { prim: 'Pair', args: [
              { string : operator },
              { int : token_id.toString() } ] } ] } ] } ]
      return { destination: contract, entrypoint: "update_operator", parameter }
    }
    else {
      return undefined
    }
  } else {
    let r = await st.operator_for_all.get({ 0 : operator, 1 : owner })
    if (r===false) {
      let parameter : MichelsonData = [ { prim: 'Left', args : [ { string: operator } ] } ]
      return { destination: contract, entrypoint: "update_operator_for_all", parameter }
    }
    else {
      return undefined
    }
  }
}

export async function approve_fa2(
  provider: Provider,
  owner: string,
  contract: string,
  token_id?: bigint) : Promise<OperationResult | undefined> {
  const arg = await approve_fa2_arg(provider, owner, contract, token_id)
  if (arg) return send(provider, arg)
  else return undefined
}

export async function approve_arg(
  provider: Provider,
  owner: string,
  asset: Asset,
  infinite?: boolean
): Promise<TransactionArg | undefined> {
  if (asset.asset_type.asset_class == "FA_1_2") {
    return approve_fa1_2_arg(provider, owner, asset.asset_type.contract, asset.value, infinite)
  } else if (asset.asset_type.asset_class == "FA_2") {
    return approve_fa2_arg(provider, owner, asset.asset_type.contract)
  } else
    throw new Error("Asset class " + asset.asset_type.asset_class + " not handled for approve")
}

export async function approve(
  provider: Provider,
  owner: string,
  asset: Asset,
  infinite?: boolean,
): Promise<OperationResult | undefined> {
  if (asset.asset_type.asset_class == "FA_1_2") {
    return approve_fa1_2(provider, owner, asset.asset_type.contract, asset.value, infinite)
  } else if (asset.asset_type.asset_class == "FA_2") {
    return approve_fa2(provider, owner, asset.asset_type.contract, undefined)
  } else
    throw new Error("Asset class " + asset.asset_type.asset_class + " not handled for approve")
}

export async function approve_token_arg(
  provider: Provider,
  owner: string,
  asset: Asset,
  infinite?: boolean
): Promise<TransactionArg | undefined> {
  if (asset.asset_type.asset_class == "FA_1_2") {
    return approve_fa1_2_arg(provider, owner, asset.asset_type.contract, asset.value, infinite)
  } else if (asset.asset_type.asset_class == "FA_2") {
    return approve_fa2_arg(provider, owner, asset.asset_type.contract, asset.asset_type.token_id)
  } else
    throw new Error("Asset class " + asset.asset_type.asset_class + " not handled for approve")
}

export async function approve_token(
  provider: Provider,
  owner: string,
  asset: Asset,
  infinite?: boolean,
): Promise<OperationResult | undefined> {
  if (asset.asset_type.asset_class == "FA_1_2") {
    return approve_fa1_2(provider, owner, asset.asset_type.contract, asset.value, infinite)
  } else if (asset.asset_type.asset_class == "FA_2") {
    return approve_fa2(provider, owner, asset.asset_type.contract, asset.asset_type.token_id)
  } else
    throw new Error("Asset class " + asset.asset_type.asset_class + " not handled for approve")
}
