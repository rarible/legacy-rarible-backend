import { MichelsonData } from "@taquito/michel-codec"
import { Provider, send, TransactionArg, get_address, OperationResult } from "../common/base"

function mint_param(
  token_id: bigint,
  owner: string,
  metadata: { [key: string]: string },
  royalties: { [key: string]: bigint },
  amount?: bigint) : MichelsonData {
  const meta : MichelsonData = Object.keys(metadata).map(function(k) { return {prim: 'Elt', args: [ {string : k}, {bytes: metadata[k] } ] } })
  const roya = Object.keys(royalties).map(function(k) { return [ {string : k}, {int: royalties[k].toString() }] })
  if (amount==undefined) return [ { int : token_id.toString() }, { string : owner }, meta, roya ]
  else return [ { int : token_id.toString() }, { string : owner }, { int: amount.toString() }, meta, roya ]
}

function metadata_param(
  token_id: bigint,
  metadata : { [key: string] : string }) : MichelsonData {
  return [
    { int: token_id.toString() },
    Object.keys(metadata).sort().map(function(k) { return {prim: 'Elt', args: [ {string : k}, {string: metadata[k] }] }})
  ]
}

export async function get_next_token_id(
  provider: Provider,
  contract: string) : Promise<bigint> {
  const r = await fetch(provider.api + '/v0.1/collections/' + contract + '/generate_token_id')
  const json = await r.json()
  return BigInt(JSON.stringify(json.tokenId))
}

export function metadata_arg(
  contract: string,
  token_id: bigint,
  metadata: { [key: string]: string }
) : TransactionArg {
  return {
    destination: contract,
    entrypoint: "setTokenMetadata",
    parameter: metadata_param(token_id, metadata)
  }
}

export async function set_token_metadata(
  provider: Provider,
  contract: string,
  token_id: bigint,
  metadata: { [key: string]: string }) : Promise<OperationResult> {
  return send(provider, metadata_arg(contract, token_id, metadata))
}

export async function mint_nft_arg(
  provider: Provider,
  contract: string,
  royalties: { [key: string]: bigint },
  token_id?: bigint,
  metadata?: { [key: string]: string },
  owner?: string,
) : Promise<[bigint, TransactionArg]> {
  const owner2 = (owner) ? owner : await get_address(provider)
  const meta = (metadata==undefined) ? {} : metadata
  const next_id = (token_id!=undefined) ? token_id : await get_next_token_id(provider, contract)
  const parameter = mint_param(next_id, owner2, meta, royalties)
  return [ next_id, { destination: contract, entrypoint: 'mint', parameter } ]
}

export async function mint_nft(
  provider: Provider,
  contract: string,
  royalties : { [key: string]: bigint },
  token_id?: bigint,
  metadata?: { [key: string]: string },
  owner?: string,
) : Promise<OperationResult> {
  const [ next_id, arg ] = await mint_nft_arg(provider, contract, royalties, token_id, metadata, owner)
  let op = await send(provider, arg)
  op.token_id = next_id
  return op
}

export async function mint_mt_arg(
  provider: Provider,
  contract: string,
  royalties : { [key: string]: bigint },
  supply: bigint,
  token_id?: bigint,
  metadata?: { [key: string]: string },
  owner?: string,
) : Promise<[bigint, TransactionArg]> {
  const owner2 = (owner) ? owner : await get_address(provider)
  const meta = (metadata==undefined) ? {} : metadata
  const next_id = (token_id!=undefined) ? token_id : await get_next_token_id(provider, contract)
  const parameter = mint_param(next_id, owner2, meta, royalties, supply)
  return [ next_id, { destination: contract, entrypoint: 'mint', parameter } ]
}

export async function mint_mt(
  provider: Provider,
  contract: string,
  royalties : { [key: string]: bigint },
  supply: bigint,
  token_id?: bigint,
  metadata?: { [key: string]: string },
  owner?: string,
) : Promise<OperationResult> {
  const [ next_id, arg ] = await mint_mt_arg(provider, contract, royalties, supply, token_id, metadata, owner)
  let op = await send(provider, arg)
  op.token_id = next_id
  return op
}

export async function mint_arg(
  provider: Provider,
  contract: string,
  royalties : { [key: string]: bigint },
  supply?: bigint,
  token_id?: bigint,
  metadata?: { [key: string]: string },
  owner?: string,
) : Promise<[bigint, TransactionArg]> {
    if (supply!=undefined) { return mint_mt_arg(provider, contract, royalties, supply, token_id, metadata, owner) }
  else { return mint_nft_arg(provider, contract, royalties, token_id, metadata, owner) }
}

export async function mint(
  provider: Provider,
  contract: string,
  royalties : { [key: string]: bigint },
  supply?: bigint,
  token_id?: bigint,
  metadata?: { [key: string]: string },
  owner?: string,
) : Promise<OperationResult> {
  if (supply!=undefined) { return mint_mt(provider, contract, royalties, supply, token_id, metadata, owner) }
  else { return mint_nft(provider, contract, royalties, token_id, metadata, owner) }
}
