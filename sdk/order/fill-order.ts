import { MichelsonData } from "@taquito/michel-codec"
import { Provider, send, send_batch, TransactionArg, get_public_key, OperationResult } from "../common/base"
import { Part, OrderForm } from "./utils"
import { invert_order } from "./invert-order"
import { get_make_fee } from "./get-make-fee"
import { add_fee } from "./add-fee"
import { approve_arg } from "./approve"
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

export async function fill_order_arg(
  provider: Provider,
  left: OrderForm,
  request: FillOrderRequest
): Promise<TransactionArg[]> {
  const make = get_make_asset(provider, left, request.amount)
  const arg_approve =
    (make.asset_type.asset_class != "XTZ" )
    ? await approve_arg(provider, left.maker, left.make, request.infinite)
    : undefined
  const args = (arg_approve) ? [ arg_approve ] : []
  const pk = await get_public_key(provider)
  if (!pk) throw new Error("cannot get public key")
  const right = {
    ...invert_order(left, request.amount, pk),
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
  const parameter = match_order_to_struct(left, right)
  return args.concat([{
    destination: provider.config.exchange, entrypoint: "matchOrders", parameter, amount }])
}

export async function fill_order(
  provider: Provider,
  left: OrderForm,
  request: FillOrderRequest
): Promise<OperationResult> {
  const args = await fill_order_arg(provider, left, request)
  if (args.length == 1) return send(provider, args[0])
  else return send_batch(provider, args)
}
