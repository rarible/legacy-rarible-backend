import { Provider, TransactionOperation, storage, send } from "../utils"

export async function approve(
  provider: Provider,
  contract: string,
  owner: string,
  operator: string,
): Promise<TransactionOperation | undefined> {
  const st = await storage(provider, contract)
  let r = await st.operator_for_all.get({ 0 : operator, 1 : owner })
  if (r===false) {
    let update_p = [ { prim: 'Left', args : [ { string: operator } ] } ]
    return send(provider, contract, "update_operator_for_all", update_p)
  }
  else {
    return undefined
  }
}

export async function approve_token(
  provider: Provider,
  contract: string,
  owner: string,
  operator: string,
  token_id: bigint
): Promise<TransactionOperation | undefined> {
  const st = await storage(provider, contract)
  let r = await st.operator.get({ 0 : operator, 1 : token_id, 2: owner })
  if (r===false) {
    let update_p = [ { prim: 'Left', args: [ { prim: "Pair", args: [
      { string: owner }, { string : operator }, { int : token_id.toString() }
    ] } ] } ]
    return send(provider, contract, "update_operator", update_p)
  }
  else {
    return undefined
  }
}
