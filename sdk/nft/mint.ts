import { Provider, MichelsonV1Expression, send } from "../utils"

function mint_param(
  token_id: bigint,
  owner: string,
  royalties: { [key: string]: bigint },
  supply?: bigint) : MichelsonV1Expression {
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

function metadata_param(metadata : { [key: string] : string }) : MichelsonV1Expression {
  return Object.keys(metadata).map(function(k) { return {prim: 'Elt', args: [ {string : k}, {string: metadata[k] }] }})
}

export async function get_next_token_id(
  provider: Provider,
  contract: string) : Promise<bigint> {
  const r = await window.fetch(provider.api + '/' + contract + '/next_token_id')
  const json = await r.json()
  return BigInt(JSON.stringify(json))
}

export async function mintErc721Legacy(
  provider: Provider,
  contract: string,
  royalties : { [key: string]: bigint },
  metadata?: { [key: string]: string }
) : Promise<bigint> {
  const owner = await provider.tezos.signer.publicKeyHash()
  const next_id = await get_next_token_id(provider, contract)
  const mint_p = mint_param(next_id, owner, royalties)
  await send(provider, contract, "mint", mint_p)
  if (metadata) {
    const meta_p = metadata_param(metadata)
    await send(provider, contract, "setTokenMetadata", meta_p)
  }
  return next_id
}

export async function mintErc1155Legacy(
  provider: Provider,
  contract: string,
  royalties : { [key: string]: bigint },
  supply: bigint,
  metadata?: { [key: string]: string },
) : Promise<bigint> {
  const owner = await provider.tezos.signer.publicKeyHash()
  const next_id = await get_next_token_id(provider, contract)
  const mint_p = mint_param(next_id, owner, royalties, supply)
  await send(provider, contract, "mint", mint_p)
  if (metadata) {
    const meta_p = metadata_param(metadata)
    await send(provider, contract, "setTokenMetadata", meta_p)
  }
  return next_id
}

export async function mint(
  provider: Provider,
  contract: string,
  royalties : { [key: string]: bigint },
  supply?: bigint,
  metadata?: { [key: string]: string },
) : Promise<bigint> {
  if (supply) { return mintErc1155Legacy(provider, contract, royalties, supply, metadata) }
  else { return mintErc721Legacy(provider, contract, royalties, metadata) }
}
