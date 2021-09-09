import { TezosToolkit, MichelsonV1Expression, send } from "../utils"

// todo : choose type of burn parameter
function burn_param(
  token_id: bigint,
  owner: string,
  amount?: number) : MichelsonV1Expression {
  if (amount) {
    return {
      prim: 'Pair',
      args: [ { int: token_id.toString() }, { string : owner }, { int : amount.toString() } ]
    }
  } else {
    return { int : token_id.toString() }
  }
}

export async function burn(
  tk: TezosToolkit,
  contract: string,
  token_id: bigint,
  amount? : number) : Promise<string> {
  const owner = await tk.signer.publicKeyHash()
  const param = burn_param(token_id, owner, amount)
  const op = await send(tk, contract, "burn", param)
  return op.hash
}
