import { Provider } from "../common/base"
import { OrderForm } from "./utils"
import { get_make_fee } from "./get-make-fee"
import { add_fee } from "./add-fee"
import { approve } from "./approve"
import { sign_order } from "./sign-order"

export async function upsert_order(
  provider: Provider,
  order: OrderForm,
  infinite: boolean = false) {
  const make_fee = get_make_fee(provider.config.fees, order)
  const make = add_fee(order.make, make_fee)
  if (make.asset_type.asset_class != "XTZ" ) {
    await approve(provider, order.maker, order.make, infinite)
  }
  const signature = sign_order(provider, order)
  const r = await fetch(provider.api + '/upsert_order', {
    method: 'POST', headers: [[ 'content-type', 'application/json' ]],
    body: JSON.stringify({...order, signature})
  })
  if (r.ok) { return r.json() }
  else throw new Error("/upsert_order failed")
}
