import { Provider } from "../common/base"
import { OrderForm, order_to_json } from "./utils"
import { get_make_fee } from "./get-make-fee"
import { add_fee } from "./add-fee"
import { approve } from "./approve"
import { sign_order } from "./sign-order"
import fetch from "node-fetch"

export async function upsert_order(
  provider: Provider,
  order: OrderForm,
  infinite: boolean = false) {
  const make_fee = get_make_fee(provider.config.fees, order)
  const make = await add_fee(provider, order.make, make_fee)
  if (make.asset_type.asset_class != "XTZ" ) {
    await approve(provider, order.maker, order.make, infinite)
  }
  const signature = await sign_order(provider, order)
  const r = await fetch(provider.api + '/orders', {
    method: 'POST', headers: [[ 'content-type', 'application/json' ]],
    body: JSON.stringify(order_to_json({...order, signature}))
  })
  if (r.ok) { return r.json() }
  else throw new Error("/orders failed")
}
