import { Provider, TransactionOperation, send, MichelsonData } from "../utils"
import { Part, OrderForm } from "./utils"
import { invert_order } from "./invert-order"
import { get_make_fee } from "./get-make-fee"
import { add_fee } from "./add-fee"
import { approve } from "./approve"
import { order_to_struct, some_struct, none_struct } from "./sign-order"

export interface FillOrderRequest {
  amount: bigint;
  payouts?: Array<Part>;
  origin_fees?: Array<Part>;
  infinite?: boolean;
}

const zero_address = "tz1Ke2h7sDdakHJQh8WX4Z372du1KChsksyU"

function get_make_asset(
  provider: Provider,
  order: OrderForm,
  amount: bigint) {
  const inverted = invert_order(order, amount, zero_address)
  const make_fee = get_make_fee(provider.config.fees, inverted)
  return add_fee(inverted.make, make_fee)
}

function get_real_value(provider: Provider, order: OrderForm) : bigint {
  const fee = get_make_fee(provider.config.fees, order)
  const make = add_fee(order.make, fee)
  return make.value
}

export function match_order_to_struct(
  left : OrderForm,
  right: OrderForm) : MichelsonData {
  return {
    prim: "Pair", args:[
      order_to_struct(left),
      { prim: "Pair", args:[
        (left.signature) ? some_struct({string : left.signature}) : none_struct(),
        { prim: "Pair", args:[
          order_to_struct(right),
          (right.signature) ? some_struct({string : right.signature}) : none_struct() ] } ] }] }
}

export async function fill_order(
  provider: Provider,
  left: OrderForm,
  request: FillOrderRequest
): Promise<TransactionOperation> {
  const make = get_make_asset(provider, left, request.amount)
  if (make.asset_type.asset_class != "XTZ" ) {
    await approve(provider, left.maker, left.make, request.infinite)
  }
  const address = await provider.tezos.signer.publicKeyHash()
  const right = {
    ...invert_order(left, request.amount, address),
    data: {
      ...left.data,
      payouts: request.payouts || [],
      originFees: request.origin_fees || [],
    },
  }
  const amount =
    (left.make.asset_type.asset_class === "XTZ" && left.salt === 0n)
    ? get_real_value(provider, left)
    : (right.make.asset_type.asset_class === "XTZ" && right.salt === 0n)
    ? get_real_value(provider, right)
    : undefined
  return send(
    provider,
    provider.config.exchange,
    "matchOrders",
    match_order_to_struct(left, right),
    amount)
}
