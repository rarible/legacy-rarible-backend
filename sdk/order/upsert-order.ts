import { Provider } from "../common/base"
import { OrderForm, order_to_json } from "./utils"
import { get_make_fee } from "./get-make-fee"
import { add_fee } from "./add-fee"
import { approve } from "./approve"
import { sign_order } from "./sign-order"
const bs58check = require('bs58check')
const blake = require('blakejs');

const tz1_prefix =  new Uint8Array([6, 161, 159])
const edpk_prefix =  new Uint8Array([13, 15, 37, 217])

function b58enc(payload: Uint8Array, prefix: Uint8Array) {
  const n = new Uint8Array(prefix.length + payload.length);
  n.set(prefix);
  n.set(payload, prefix.length);
  return bs58check.encode(Buffer.from(n.buffer));
}

function b58dec(enc : string, prefix : Uint8Array) : Uint8Array {
  return bs58check.decode(enc).slice(prefix.length)
}

export function pk_to_pkh(edpk: string) : string {
  const pk_bytes = b58dec(edpk, edpk_prefix)
  const hash = blake.blake2b(pk_bytes, null, 20)
  return b58enc(hash, tz1_prefix)
}

export async function upsert_order(
  provider: Provider,
  order: OrderForm,
  infinite: boolean = false) {
  const make_fee = get_make_fee(provider.config.fees, order)
  const make = add_fee(order.make, make_fee)
  if (make.asset_type.asset_class != "XTZ" ) {
    await approve(provider, pk_to_pkh(order.maker), order.make, infinite)
  }
  const signature = await sign_order(provider, order)
  const r = await fetch(provider.api + '/orders', {
    method: 'POST', headers: [[ 'content-type', 'application/json' ]],
    body: JSON.stringify(order_to_json({...order, signature}))
  })
  if (r.ok) { return r.json() }
  else throw new Error("/orders failed")
}
