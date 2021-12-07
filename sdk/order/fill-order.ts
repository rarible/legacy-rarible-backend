import { MichelsonData } from "@taquito/michel-codec"
import { Provider, send, send_batch, TransactionArg, get_public_key, OperationResult } from "../common/base"
import { Part, OrderForm } from "./utils"
import { invert_order } from "./invert-order"
import { get_make_fee } from "./get-make-fee"
import { add_fee } from "./add-fee"
import { approve_arg } from "./approve"
import { order_to_struct, some_struct, none_struct } from "./sign-order"
import BigNumber from "bignumber.js"

export interface FillOrderRequest {
  amount: BigNumber;
  payouts?: Array<Part>;
  origin_fees?: Array<Part>;
  infinite?: boolean;
  edpk?: string
}

function get_make_asset(
  provider: Provider,
  order: OrderForm,
  amount: BigNumber,
  edpk: string
  ) {
  const inverted = invert_order(order, amount, edpk)
  const make_fee = get_make_fee(provider.config.fees, inverted)
  return add_fee(inverted.make, make_fee)
}

function get_real_value(provider: Provider, order: OrderForm) : BigNumber {
  const fee = get_make_fee(provider.config.fees, order)
  const make = add_fee(order.make, fee)
  return make.value
}

export async function match_order_to_struct(
  p: Provider,
  left : OrderForm,
  right: OrderForm) : Promise<MichelsonData> {
  return {
    prim: "Pair", args:[
      await order_to_struct(p, left),
      { prim: "Pair", args:[
        (left.signature) ? some_struct({string : left.signature}) : none_struct(),
        { prim: "Pair", args:[
          await order_to_struct(p, right),
          (right.signature) ? some_struct({string : right.signature}) : none_struct() ] } ] }] }
}

export async function fill_order_arg(
  provider: Provider,
  left: OrderForm,
  request: FillOrderRequest
): Promise<TransactionArg[]> {
  const pk = (request.edpk) ? request.edpk : await get_public_key(provider)
  if (!pk) throw new Error("cannot get public key")

  const make = get_make_asset(provider, left, request.amount, pk)
  const arg_approve =
    (make.asset_type.asset_class != "XTZ" )
    ? await approve_arg(provider, left.maker, left.make, request.infinite)
    : undefined
  const args = (arg_approve) ? [ arg_approve ] : []

  const right = {
    ...invert_order(left, request.amount, pk),
    data: {
      ...left.data,
      payouts: request.payouts || [],
      originFees: request.origin_fees || [],
    },
  }
  const amount =
    (left.make.asset_type.asset_class === "XTZ" && left.salt == '0')
    ? get_real_value(provider, left)
    : (right.make.asset_type.asset_class === "XTZ" && right.salt == '0')
    ? get_real_value(provider, right)
    : undefined
  const parameter = await match_order_to_struct(provider, left, right)
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
