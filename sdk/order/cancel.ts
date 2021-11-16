import { Provider, send, TransactionArg, OperationResult } from "../common/base"
import { OrderForm } from "./utils"
import { order_to_struct } from "./sign-order"
import BigNumber from "@taquito/rpc/node_modules/bignumber.js"

export function cancel_arg(
  provider: Provider,
  order: OrderForm
): TransactionArg {
  const parameter = order_to_struct(provider, order)
  return {
    destination: provider.config.exchange,
    entrypoint: "cancel", parameter, amount: new BigNumber(0)
  }
}

export async function cancel(
  provider: Provider,
  order: OrderForm
): Promise<OperationResult> {
  const arg = cancel_arg(provider, order)
  return send(provider, arg)
}
