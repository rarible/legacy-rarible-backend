import { Asset, asset_to_json } from "../common/base"

export interface Part {
  account: string;
  value: bigint;
}

export interface OrderRaribleV2DataV1 {
  data_type: "V1";
  payouts: Array<Part>;
  origin_fees: Array<Part>;
}

export declare type OrderForm = {
  type: "RARIBLE_V2";
  maker: string;
  taker?: string;
  make: Asset;
  take: Asset;
  salt: bigint;
  start?: number;
  end?: number;
  signature?: string;
  data: OrderRaribleV2DataV1;
}

function part_to_json(p: Part) {
  return { account: p.account, value: p.value.toString() }
}

function data_to_json(d: OrderRaribleV2DataV1) {
  let payouts = []
  let originFees = []
  for (let p of d.payouts) { payouts.push(part_to_json(p)) }
  for (let o of d.origin_fees) { originFees.push(part_to_json(o)) }
  return {
    dataType: d.data_type,
    payouts, originFees
  }
}


export function order_to_json(order : OrderForm) : any {
  const { salt, make, take, data, ...rest } = order
  return {
    salt: salt.toString(),
    make: asset_to_json(order.make),
    take: asset_to_json(order.take),
    data: data_to_json(data),
    ...rest }
}

export function salt() : bigint {
  let a = new Uint8Array(32)
  a = crypto.getRandomValues(a)
  let h = a.reduce((acc, x) => acc + x.toString(16).padStart(2, '0'), '')
  return BigInt('0x'+h)
}
