import { Provider, MichelsonData, OperationArg, send } from "../utils"

// todo : choose type of burn parameter
function burn_param(
  token_id: bigint,
  owner: string,
  amount = 1n) : MichelsonData {
  return {
    prim: 'Pair',
    args: [ { int: token_id.toString() }, { string : owner }, { int : amount.toString() } ]
  }
}

export async function burn_arg(
  provider: Provider,
  contract: string,
  token_id: bigint,
  amount? : bigint) : Promise<OperationArg> {
  const owner = await provider.tezos.signer.publicKeyHash()
  const parameter = burn_param(token_id, owner, amount)
  return { destination: contract, entrypoint: "burn", parameter }
}

export async function burn(
  provider: Provider,
  contract: string,
  token_id: bigint,
  amount? : bigint) : Promise<string> {
  const arg = await burn_arg(provider, contract, token_id, amount)
  const op = await send(provider, arg)
  return op.hash
}
