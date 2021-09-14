import { Provider, MichelsonV1Expression, send } from "../utils"

// todo : choose type of burn parameter
function burn_param(
  token_id: bigint,
  owner: string,
  amount = 1n) : MichelsonV1Expression {
  return {
    prim: 'Pair',
    args: [ { int: token_id.toString() }, { string : owner }, { int : amount.toString() } ]
  }
}

export async function burn(
  provider: Provider,
  contract: string,
  token_id: bigint,
  amount? : bigint) : Promise<string> {
  const owner = await provider.tezos.signer.publicKeyHash()
  const param = burn_param(token_id, owner, amount)
  const op = await send(provider, contract, "burn", param)
  return op.hash
}
