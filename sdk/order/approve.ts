import { TezosToolkit, TransactionOperation, storage, send } from "../utils"

export async function approveFa1(
  tk: TezosToolkit,
  contract: string,
  owner: string,
  operator: string,
): Promise<TransactionOperation | undefined> {
  const st = await storage(tk, contract)
  let r = await st.approved.get({ 0 : owner, 1 : operator })
  if (r===false) {
    return send(tk, contract, "approve", {prim: 'Pair', args: [ {string: operator}, { prim: 'True' } ] })
  }
  else {
    return undefined
  }
}
