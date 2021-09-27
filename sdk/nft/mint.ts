import { Provider, MichelsonData, send, send_batch, TransactionArg, get_address } from "../common/base"

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

function metadata_param(
  token_id: bigint,
  metadata : { [key: string] : string }) : MichelsonData {
  return { prim: 'Pair', args: [
    { int: token_id.toString() },
    Object.keys(metadata).map(function(k) { return {prim: 'Elt', args: [ {string : k}, {string: metadata[k] }] }})
  ] }
}

export async function get_next_token_id(
  provider: Provider,
  contract: string) : Promise<bigint> {
  const r = await fetch(provider.api + '/' + contract + '/next_token_id')
  const json = await r.json()
  return BigInt(JSON.stringify(json))
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
  metadata: { [key: string]: string },
  wait?: boolean) : Promise<string> {
  return send(provider, metadata_arg(contract, token_id, metadata), wait)
}

export async function mint_nft_arg(
  provider: Provider,
  contract: string,
  royalties: { [key: string]: bigint },
  token_id?: bigint,
  metadata?: { [key: string]: string }
) : Promise<[bigint, TransactionArg[]]> {
  const owner = await get_address(provider)
  const next_id = (token_id) ? token_id : await get_next_token_id(provider, contract)
  const parameter = mint_param(next_id, owner, royalties)
  const arg : TransactionArg[] = [ { destination: contract, entrypoint: 'mint', parameter } ]
  if (metadata) { return [ next_id, arg.concat([metadata_arg(contract, next_id, metadata)]) ] }
  else return [ next_id, arg ]
}

export async function mint_nft(
  provider: Provider,
  contract: string,
  royalties : { [key: string]: bigint },
  token_id?: bigint,
  metadata?: { [key: string]: string },
  wait?: boolean
) : Promise<bigint> {
  const [ next_id, args ] = await mint_nft_arg(provider, contract, royalties, token_id, metadata)
  if (args.length == 1) await send(provider, args[0])
  else await send_batch(provider, args, wait)
  return next_id
}

export async function mint_mt_arg(
  provider: Provider,
  contract: string,
  royalties : { [key: string]: bigint },
  supply: bigint,
  token_id?: bigint,
  metadata?: { [key: string]: string },
) : Promise<[bigint, TransactionArg[]]> {
  const owner = await get_address(provider)
  const next_id = (token_id) ? token_id : await get_next_token_id(provider, contract)
  const parameter = mint_param(next_id, owner, royalties, supply)
  const arg : TransactionArg[] = [ { destination: contract, entrypoint: 'mint', parameter } ]
  const arg_meta = (metadata)
    ? [ metadata_arg(contract, next_id, metadata) ]
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
  wait?: boolean
) : Promise<bigint> {
  const [ next_id, args ] = await mint_mt_arg(provider, contract, royalties, supply, token_id, metadata)
  if (args.length == 1) await send(provider, args[0])
  else await send_batch(provider, args, wait)
  return next_id
}

export async function mint_arg(
  provider: Provider,
  contract: string,
  royalties : { [key: string]: bigint },
  supply?: bigint,
  token_id?: bigint,
  metadata?: { [key: string]: string },
) : Promise<[bigint, TransactionArg[]]> {
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
  wait?: boolean
) : Promise<bigint> {
  if (supply) { return mint_mt(provider, contract, royalties, supply, token_id, metadata, wait) }
  else { return mint_nft(provider, contract, royalties, token_id, metadata, wait) }
}
