import { OrderForm } from "./utils"

export function get_make_fee(fees: bigint, order: OrderForm) {
  const origin_fees = order.data.origin_fees.map(f => f.value).reduce((v, acc) => v + acc)
  return fees + origin_fees
}
