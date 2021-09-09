import { TezosToolkit, MichelsonV1Expression, send, storage } from "../utils"

function mint_param(
  token_id: bigint,
  owner: string,
  metadata: { [key: string]: string },
  supply?: bigint) : MichelsonV1Expression {
  if (supply) {
    return {
      prim: 'Pair',
      args: [
        { int : token_id.toString() },
        { string : owner },
        Object.keys(metadata).map(function(k) { return {prim: 'Elt', args: [ {string : k}, {bytes: metadata[k] }] }}),
        { int : supply.toString() }
      ]
    }
  } else {
    return {
      prim: 'Pair',
      args: [
        { int : token_id.toString() },
        { string : owner },
        Object.keys(metadata).map(function(k) { return {prim: 'Elt', args: [ {string : k}, {bytes: metadata[k] }] }})
      ]
    }
  }
}

export async function mintErc721Legacy(
  tk: TezosToolkit,
  contract: string,
  metadata: { [key: string]: string }
) : Promise<bigint> {
  const owner = await tk.signer.publicKeyHash()
  const st = await storage(tk, contract)
  const next_id = st.next_token_id
  const param = mint_param(next_id, owner, metadata)
  await send(tk, contract, "mint", param)
  return next_id
}

export async function mintErc1155Legacy(
  tk: TezosToolkit,
  contract: string,
  metadata: { [key: string]: string },
  supply: bigint
) : Promise<bigint> {
  const owner = await tk.signer.publicKeyHash()
  const st = await storage(tk, contract)
  const next_id = st.next_token_id
  const param = mint_param(next_id, owner, metadata, supply)
  await send(tk, contract, "mint", param)
  return next_id
}

export async function mint(
  tk: TezosToolkit,
  contract: string,
  metadata: { [key: string]: string },
  supply?: bigint
) : Promise<bigint> {
  if (supply) { return mintErc1155Legacy(tk, contract, metadata, supply) }
  else { return mintErc721Legacy(tk, contract, metadata) }
}
