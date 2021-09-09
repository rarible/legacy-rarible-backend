import { TezosToolkit, MichelsonV1Expression, send } from "../utils"

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
  tk: TezosToolkit,
  contract: string,
  from: string,
  to: string,
  token_id: bigint) : Promise<string> {
  const param = transfer_param(from, to, [ token_id ])
  console.log(JSON.stringify(param))
  const op = await send(tk, contract, "transfer", param)
  return op.hash
}

export async function transferErc1155(
  tk: TezosToolkit,
  contract: string,
  from: string,
  to: string,
  token_id: bigint | bigint[],
  token_amount: bigint | bigint[]) : Promise<string> {
  const ids = (Array.isArray(token_id)) ? token_id : [ token_id ]
  const amounts = (Array.isArray(token_amount)) ? token_amount : [ token_amount ]
  const param = transfer_param(from, to, ids, amounts)
  const op = await send(tk, contract, "transfer", param)
  return op.hash
}

export async function transfer(
  tk: TezosToolkit,
  contract: string,
  from: string,
  to: string,
  token_id: bigint | bigint[],
  token_amount?: bigint | bigint[]) : Promise<string> {
  if (token_amount) { return transferErc1155(tk, contract, from, to, token_id, token_amount) }
  else if (!Array.isArray(token_id)) { return transferErc721(tk, contract, from, to, token_id) }
  else { throw new Error("Cannot transfer array of ERC721 tokens") }
}
