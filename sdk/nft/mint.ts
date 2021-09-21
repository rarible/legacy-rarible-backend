import { Provider, MichelsonData, send, batch, OperationArg } from "../utils"

function mint_param(
  token_id: bigint,
  owner: string,
  royalties: { [key: string]: bigint },
  supply?: bigint) : MichelsonData {
  if (supply) {
    return {
      prim: 'Pair',
      args: [
        { int : token_id.toString() },
        { string : owner },
        { int : supply.toString() },
        Object.keys(royalties).map(function(k) { return {prim: 'Pair', args: [ {string : k}, {int: royalties[k].toString() }] }})
      ]
    }
  } else {
    return {
      prim: 'Pair',
      args: [
        { int : token_id.toString() },
        { string : owner },
        Object.keys(royalties).map(function(k) { return {prim: 'Pair', args: [ {string : k}, {int: royalties[k].toString() }] }})
      ]
    }
  }
}

function metadata_param(metadata : { [key: string] : string }) : MichelsonData {
  return Object.keys(metadata).map(function(k) { return {prim: 'Elt', args: [ {string : k}, {string: metadata[k] }] }})
}

export async function get_next_token_id(
  provider: Provider,
  contract: string) : Promise<bigint> {
  const r = await fetch(provider.api + '/' + contract + '/next_token_id')
  const json = await r.json()
  return BigInt(JSON.stringify(json))
}

export async function mint_nft_arg(
  provider: Provider,
  contract: string,
  royalties: { [key: string]: bigint },
  token_id?: bigint,
  metadata?: { [key: string]: string }
) : Promise<[bigint, OperationArg[]]> {
  const owner = await provider.tezos.signer.publicKeyHash()
  const next_id = (token_id) ? token_id : await get_next_token_id(provider, contract)
  const parameter = mint_param(next_id, owner, royalties)
  const arg = [ { destination: contract, entrypoint: 'mint', parameter } ]
  const arg_meta = (metadata)
    ? [ { destination: contract, entrypoint: "setTokenMetadata", parameter: metadata_param(metadata) } ]
    : []
  return [ next_id, arg.concat(arg_meta) ]
}

export async function mint_nft(
  provider: Provider,
  contract: string,
  royalties : { [key: string]: bigint },
  token_id?: bigint,
  metadata?: { [key: string]: string }
) : Promise<bigint> {
  const [ next_id, args ] = await mint_nft_arg(provider, contract, royalties, token_id, metadata)
  if (args.length == 1) await send(provider, args[0])
  else await batch(provider, args)
  return next_id
}

export async function mint_mt_arg(
  provider: Provider,
  contract: string,
  royalties : { [key: string]: bigint },
  supply: bigint,
  token_id?: bigint,
  metadata?: { [key: string]: string },
) : Promise<[bigint, OperationArg[]]> {
  const owner = await provider.tezos.signer.publicKeyHash()
  const next_id = (token_id) ? token_id : await get_next_token_id(provider, contract)
  const parameter = mint_param(next_id, owner, royalties, supply)
  const arg = [ { destination: contract, entrypoint: 'mint', parameter } ]
  const arg_meta = (metadata)
    ? [ { destination: contract, entrypoint: "setTokenMetadata", parameter: metadata_param(metadata) } ]
    : []
  return [ next_id, arg.concat(arg_meta) ]
}

export async function mint_mt(
  provider: Provider,
  contract: string,
  royalties : { [key: string]: bigint },
  supply: bigint,
  token_id?: bigint,
  metadata?: { [key: string]: string },
) : Promise<bigint> {
  const [ next_id, args ] = await mint_mt_arg(provider, contract, royalties, supply, token_id, metadata)
  if (args.length == 1) await send(provider, args[0])
  else await batch(provider, args)
  return next_id
}

export async function mint_arg(
  provider: Provider,
  contract: string,
  royalties : { [key: string]: bigint },
  supply?: bigint,
  token_id?: bigint,
  metadata?: { [key: string]: string },
) : Promise<[bigint, OperationArg[]]> {
  if (supply) { return mint_mt_arg(provider, contract, royalties, supply, token_id, metadata) }
  else { return mint_nft_arg(provider, contract, royalties, token_id, metadata) }
}

export async function mint(
  provider: Provider,
  contract: string,
  royalties : { [key: string]: bigint },
  supply?: bigint,
  token_id?: bigint,
  metadata?: { [key: string]: string },
) : Promise<bigint> {
  if (supply) { return mint_mt(provider, contract, royalties, supply, token_id, metadata) }
  else { return mint_nft(provider, contract, royalties, token_id, metadata) }
}
