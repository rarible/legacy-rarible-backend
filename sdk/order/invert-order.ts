import { OrderForm, pk_to_pkh } from "./utils"
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
  maker_edpk: string,
  salt: bigint = BigInt(0)
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
    maker: pk_to_pkh(maker_edpk),
    maker_edpk,
    taker: order.maker,
    taker_edpk: order.maker_edpk,
    salt,
    signature: undefined,
  }
}
