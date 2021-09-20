import { Provider, TransactionOperation, storage, send, StorageFA1_2, StorageFA2 } from "../utils"
import { Asset } from "./utils"

export async function approve_fa1_2(
  provider: Provider,
  owner: string,
  contract: string,
  value: bigint,
  infinite: boolean = true
) : Promise<TransactionOperation | undefined> {
  const spender = provider.config.proxies.fa_1_2
  const st : StorageFA1_2 = await storage(provider, contract)
  let r = await st.allowance.get({ 0 : owner, 1 : spender })
  if (r===false) {
    let v = (infinite) ? st.totalsupply.toString() : value.toString()
    const approve_p = [ { prim: 'Pair', args : [ { string: spender }, { int: v } ] } ]
    return send(provider, contract, "approve", approve_p)
  }
  else return undefined
}

export async function approve_fa2(
  provider: Provider,
  owner: string,
  contract: string,
  token_id?: bigint) : Promise<TransactionOperation | undefined> {
  const operator = provider.config.proxies.fa_1_2
  const st : StorageFA2 = await storage(provider, contract)
  if (token_id) {
    let r = await st.operator.get({ 0 : operator, 1 : token_id, 2: owner })
    if (r===false) {
      let update_p = [ { prim: 'Left', args: [ { prim: "Pair", args: [
        { string: owner }, { string : operator }, { int : token_id.toString() }
      ] } ] } ]
      return send(provider, contract, "update_operator", update_p)
    }
    else {
      return undefined
    }
  } else {
    let r = await st.operator_for_all.get({ 0 : operator, 1 : owner })
    if (r===false) {
      let update_p = [ { prim: 'Left', args : [ { string: operator } ] } ]
      return send(provider, contract, "update_operator_for_all", update_p)
    }
    else {
      return undefined
    }
  }
}


export async function approve(
  provider: Provider,
  owner: string,
  asset: Asset,
  infinite?: boolean
): Promise<TransactionOperation | undefined> {

  if (asset.asset_type.asset_class == "FA_1_2") {
    return approve_fa1_2(provider, owner, asset.asset_type.contract, asset.value, infinite)
  } else if (asset.asset_type.asset_class == "FA_2") {
    return approve_fa2(provider, owner, asset.asset_type.contract)
  } else
    throw new Error("Asset class " + asset.asset_type.asset_class + " not handled for approve")
}

export async function approve_token(
  provider: Provider,
  owner: string,
  asset: Asset,
  infinite?: boolean
): Promise<TransactionOperation | undefined> {

  if (asset.asset_type.asset_class == "FA_1_2") {
    return approve_fa1_2(provider, owner, asset.asset_type.contract, asset.value, infinite)
  } else if (asset.asset_type.asset_class == "FA_2") {
    return approve_fa2(provider, owner, asset.asset_type.contract, asset.asset_type.token_id)
  } else
    throw new Error("Asset class " + asset.asset_type.asset_class + " not handled for approve")
}
