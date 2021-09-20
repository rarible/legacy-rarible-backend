import { Provider, MichelsonV1Expression, send } from "../utils"

function transfer_param(
  from: string,
  to: string,
  token_id: bigint[],
  token_amount?: bigint[] ) : MichelsonV1Expression {
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

export async function transferErc721(
  provider: Provider,
  contract: string,
  from: string,
  to: string,
  token_id: bigint) : Promise<string> {
  const param = transfer_param(from, to, [ token_id ])
  const op = await send(provider, contract, "transfer", param)
  return op.hash
}

export async function transferErc1155(
  provider: Provider,
  contract: string,
  from: string,
  to: string,
  token_id: bigint | bigint[],
  token_amount: bigint | bigint[]) : Promise<string> {
  const ids = (Array.isArray(token_id)) ? token_id : [ token_id ]
  const amounts = (Array.isArray(token_amount)) ? token_amount : [ token_amount ]
  const param = transfer_param(from, to, ids, amounts)
  const op = await send(provider, contract, "transfer", param)
  return op.hash
}

export async function transfer(
  provider: Provider,
  contract: string,
  to: string,
  token_id: bigint | bigint[],
  token_amount?: bigint | bigint[]) : Promise<string> {
  const from = await provider.tezos.signer.publicKeyHash()
  if (token_amount) { return transferErc1155(provider, contract, from, to, token_id, token_amount) }
  else if (!Array.isArray(token_id)) { return transferErc721(provider, contract, from, to, token_id) }
  else { throw new Error("Cannot transfer array of ERC721 tokens") }
}
