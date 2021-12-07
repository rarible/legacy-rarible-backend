import { Asset, asset_to_json, asset_of_json } from "../common/base"
import BigNumber from "bignumber.js"
const getRandomValues = require('get-random-values')

export interface Part {
  account: string;
  value: BigNumber;
}

export interface OrderRaribleV2DataV1 {
  data_type: "V1";
  payouts: Array<Part>;
  origin_fees: Array<Part>;
}

export declare type OrderForm = {
  type: "RARIBLE_V2";
  maker: string;
  maker_edpk: string;
  taker?: string;
  taker_edpk?: string;
  make: Asset;
  take: Asset;
  salt: string;
  start?: number;
  end?: number;
  signature?: string;
  data: OrderRaribleV2DataV1;
}

function part_to_json(p: Part) {
  return { account: p.account, value: Number(p.value) }
}

function part_of_json(p: any) : Part {
  return { account: p.account, value: new BigNumber(p.value) }
}

function data_to_json(d: OrderRaribleV2DataV1) {
  let payouts = []
  let originFees = []
  for (let p of d.payouts) { payouts.push(part_to_json(p)) }
  for (let o of d.origin_fees) { originFees.push(part_to_json(o)) }
  return {
    dataType: "V1",
    payouts: d.payouts.map(part_to_json),
    originFees: d.origin_fees.map(part_to_json)
  }
}

function data_of_json(d: any) : OrderRaribleV2DataV1 {
  return {
    data_type: "V1",
    payouts: d.payouts.map(part_of_json),
    origin_fees: d.originFees.map(part_of_json)
  }
}

export function order_to_json(order: OrderForm) : any {
  const { make, take, data, maker_edpk, taker_edpk, ...rest } = order
  return {
    make: asset_to_json(order.make),
    take: asset_to_json(order.take),
    data: data_to_json(data),
    makerEdpk: maker_edpk,
    takerEdpk: taker_edpk,
    ...rest }
}

export function order_of_json(order: any ) : OrderForm {
  const { make, take, data, makerEdpk, takerEdpk, ...rest } = order
  return {
    make: asset_of_json(order.make),
    take: asset_of_json(order.take),
    data: data_of_json(data),
    maker_edpk: makerEdpk,
    taker_edpk: takerEdpk,
    ...rest }
}

export function salt() : string {
  let a = new Uint8Array(32)
  a = getRandomValues(a)
  return a.reduce((acc, x) => acc + x.toString(10).padStart(2, '0'), '')
}
