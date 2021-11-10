import { MichelsonData } from "@taquito/michel-codec"
import { Provider, send, StorageFA1_2, StorageFA2,
         Asset, TransactionArg, OperationResult } from "../common/base"
import BigNumber from "@taquito/rpc/node_modules/bignumber.js"

export async function approve_fa1_2_arg(
  provider: Provider,
  owner: string,
  contract: string,
  value: BigNumber,
  infinite: boolean = true
) : Promise<TransactionArg | undefined > {
  const spender = provider.config.exchange
  const st : StorageFA1_2 = await provider.tezos.storage(contract)
  let key_exists = false
  try {
    let r = await st.allowance.get({ 0 : owner, 1 : spender })
    key_exists = (r!=undefined && r!=0)
  } catch {
    key_exists = false
  }
  if (!key_exists) {
    let v = (infinite) ? st.totalsupply.toString() : value.toString()
    const parameter : MichelsonData = [ { prim: 'Pair', args : [ { string: spender }, { int: v } ] } ]
    return { destination: contract, entrypoint: "approve", parameter }
  }
}

export async function approve_fa1_2(
  provider: Provider,
  owner: string,
  contract: string,
  value: BigNumber,
  infinite: boolean = true,
) : Promise<OperationResult | undefined> {
  const arg = await approve_fa1_2_arg(provider, owner, contract, value, infinite)
  if (arg) {
    try { return send(provider, arg) } catch(e) { return undefined }
  }
  else return undefined
}

export async function approve_fa2_arg(
  provider: Provider,
  owner: string,
  contract: string,
  token_id?: BigNumber) : Promise<TransactionArg | undefined> {
  const operator = provider.config.exchange
  const st : StorageFA2 = await provider.tezos.storage(contract)
  let key_exists = false
  if (token_id!=undefined) {
    try {
      let r = await st.operator.get({ 0 : operator, 1 : token_id, 2: owner })
      key_exists = (r!=undefined)
    } catch {
      key_exists = false
    }
    if (!key_exists) {
      let parameter : MichelsonData = [
        { prim: 'Left', args: [
          { prim: "Pair", args: [
            { string: owner },
            { prim: 'Pair', args: [
              { string : operator },
              { int : token_id.toString() } ] } ] } ] } ]
      return { destination: contract, entrypoint: "update_operators", parameter }
    }
  } else {
    try {
      let r = await st.operator_for_all.get({ 0 : operator, 1 : owner })
      key_exists = (r!=undefined)
    } catch {
      key_exists = false
    }
    if (!key_exists) {
      let parameter : MichelsonData = [ { prim: 'Left', args : [ { string: operator } ] } ]
      return { destination: contract, entrypoint: "update_operators_for_all", parameter }
    }
  }
}

export async function approve_fa2(
  provider: Provider,
  owner: string,
  contract: string,
  token_id?: BigNumber) : Promise<OperationResult | undefined> {
  const arg = await approve_fa2_arg(provider, owner, contract, token_id)
  if (arg) {
    return send(provider, arg)
  }
}

export async function approve_arg(
  provider: Provider,
  owner: string,
  asset: Asset,
  infinite?: boolean
): Promise<TransactionArg | undefined> {
  if (asset.asset_type.asset_class == "FT") {
    return approve_fa1_2_arg(provider, owner, asset.asset_type.contract, asset.value, infinite)
  } else if (asset.asset_type.asset_class == "NFT") {
    return approve_fa2_arg(provider, owner, asset.asset_type.contract || provider.config.nft_public)
  } else if (asset.asset_type.asset_class == "MT") {
    return approve_fa2_arg(provider, owner, asset.asset_type.contract || provider.config.mt_public)
  }else
    throw new Error("Asset class " + asset.asset_type.asset_class + " not handled for approve")
}

export async function approve(
  provider: Provider,
  owner: string,
  asset: Asset,
  infinite?: boolean,
): Promise<OperationResult | undefined> {
  if (asset.asset_type.asset_class == "FT") {
    return approve_fa1_2(provider, owner, asset.asset_type.contract, asset.value, infinite)
  } else if (asset.asset_type.asset_class == "NFT") {
    return approve_fa2(provider, owner, asset.asset_type.contract || provider.config.nft_public)
  } else if (asset.asset_type.asset_class == "MT") {
    return approve_fa2(provider, owner, asset.asset_type.contract || provider.config.mt_public)
  } else
    throw new Error("Asset class " + asset.asset_type.asset_class + " not handled for approve")
}

export async function approve_token_arg(
  provider: Provider,
  owner: string,
  asset: Asset,
  infinite?: boolean
): Promise<TransactionArg | undefined> {
  if (asset.asset_type.asset_class == "FT") {
    return approve_fa1_2_arg(provider, owner, asset.asset_type.contract, asset.value, infinite)
  } else if (asset.asset_type.asset_class == "NFT") {
    return approve_fa2_arg(provider, owner, asset.asset_type.contract || provider.config.nft_public, asset.asset_type.token_id)
  } else if (asset.asset_type.asset_class == "MT") {
    return approve_fa2_arg(provider, owner, asset.asset_type.contract || provider.config.mt_public, asset.asset_type.token_id)
  }else
    throw new Error("Asset class " + asset.asset_type.asset_class + " not handled for approve")
}

export async function approve_token(
  provider: Provider,
  owner: string,
  asset: Asset,
  infinite?: boolean,
): Promise<OperationResult | undefined> {
  if (asset.asset_type.asset_class == "FT") {
    return approve_fa1_2(provider, owner, asset.asset_type.contract, asset.value, infinite)
  } else if (asset.asset_type.asset_class == "NFT") {
    return approve_fa2(provider, owner, asset.asset_type.contract || provider.config.nft_public, asset.asset_type.token_id)
  } else if (asset.asset_type.asset_class == "MT") {
    return approve_fa2(provider, owner, asset.asset_type.contract || provider.config.mt_public, asset.asset_type.token_id)
  } else
    throw new Error("Asset class " + asset.asset_type.asset_class + " not handled for approve")
}
