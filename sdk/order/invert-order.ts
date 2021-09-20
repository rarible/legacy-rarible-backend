import { OrderForm } from "./utils"
import { is_nft } from "./is-nft"

function calculate_amounts(
  make: bigint,
  take: bigint,
  amount: bigint,
  bid: boolean
): [bigint, bigint] {
  if (bid) return [amount, (amount * make) /take ]
  else return [(amount * take) / make, amount]
}

export function invert_order(
  order: OrderForm,
  amount: bigint,
  maker: string,
  salt: bigint = 0n
): OrderForm {
  const [makeValue, takeValue] = calculate_amounts(
    order.make.value,
    order.take.value,
    amount,
    is_nft(order.take.asset_type)
  )
  return {
    ...order,
    make: {
      ...order.take,
      value: makeValue,
    },
    take: {
      ...order.make,
      value: takeValue,
    },
    maker,
    taker: order.maker,
    salt,
    signature: undefined,
  }
}
