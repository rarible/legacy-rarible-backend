import { MichelsonData, MichelsonType, packDataBytes } from "@taquito/michel-codec"
import { Provider, sign, AssetType, Asset } from "../common/base"
import { OrderForm, OrderRaribleV2DataV1 } from "./utils"
const keccak_base = require("keccak")

export function keccak(s : string) : string {
  return keccak_base('keccak256').update(s, 'hex').digest('hex')
}

function pack(
  data: MichelsonData,
  type: MichelsonType) : string {
  return packDataBytes(data, type).bytes
}

export const XTZ : MichelsonData = { prim: 'Left', args: [ { prim: 'Unit' } ] }

export const FA_1_2 : MichelsonData = {
  prim: 'Right', args: [ { prim: 'Left', args: [ { prim: 'Unit' } ] } ] }

export const FA_2 : MichelsonData = {
  prim: 'Right', args: [
    { prim: 'Right', args: [ { prim: 'Left', args: [ { prim: 'Unit' } ] } ] } ] }

export const FEE_SIDE_NONE = 0
export const FEE_SIDE_MAKE = 1
export const FEE_SIDE_TAKE = 2

export function some_struct(v : MichelsonData ) : MichelsonData {
  return {
    prim: 'Some',
    args: [ v ]
  }
}

export function none_struct() : MichelsonData { return { prim: 'None' } }

export const fa_1_2_type : MichelsonType = {prim:'address'}
export const fa_2_type : MichelsonType =
  {prim:'pair',args:[{prim:'address'},{prim:'nat'}]}
export const asset_class_type : MichelsonType =
  {prim:'or', args:[{prim:'unit'},{prim:'or',args:[{prim:'unit'}, {prim:'or',args:[
    {prim:'unit'}, {prim:'or',args:[{prim:'unit'}, {prim:'bytes'}]}]}]}]}
export const asset_type_type : MichelsonType =
  {prim:'pair',args:[ asset_class_type, {prim: 'bytes'}]}
export const asset_type : MichelsonType =
  {prim:'pair',args:[asset_type_type, {prim:'nat'}]}
export const part_type : MichelsonType =
  {prim:'pair',args:[{prim:'address'},{prim:'nat'}]}
export const order_data_type : MichelsonType =
  {prim:'pair',args:[{prim:'list',args:[part_type]},{prim:'list',args:[part_type]}]}
export const order_type : MichelsonType = {
  prim: 'pair', args:[
    { prim: 'option', args:[ {prim: 'key'} ] },
    { prim: 'pair', args:[
      asset_type,
      {prim: 'pair', args:[
        {prim: 'option', args:[ {prim: 'key'} ]},
        {prim: 'pair', args:[
          asset_type,
          {prim: 'pair', args:[
            {prim: 'nat'},
            {prim: 'pair', args:[
              {prim: 'option', args:[ {prim: 'timestamp'} ]},
              {prim: 'pair', args:[
                {prim: 'option', args:[ {prim: 'timestamp'} ]},
                {prim: 'pair', args:[
                  {prim: 'bytes'}, {prim: 'bytes'} ]}]}]}]}]}]}]}]}

export function asset_type_to_struct(a : AssetType) : MichelsonData {
  switch (a.asset_class) {
    case "XTZ":
      return { prim: 'Pair', args: [ XTZ,  { bytes: "00" } ] }
    case "FA_1_2":
      return { prim: 'Pair', args: [ FA_1_2,  {
        bytes: pack({ string: a.contract }, fa_1_2_type) } ] }
    case "FA_2":
      return { prim: 'Pair', args: [ FA_1_2,  {
        bytes: pack({ prim: "Pair", args: [
          { string: a.contract }, { int: a.token_id.toString() } ] }, fa_2_type) } ] }
  }
}

export function asset_to_struct(a: Asset) : MichelsonData {
  return { prim: "Pair", args: [ asset_type_to_struct(a.asset_type), { int: a.value.toString() } ] }
}

export function data_to_struct(data: OrderRaribleV2DataV1) : MichelsonData {
  return { prim : "Pair", args: [
    data.payouts.map((p) => {
      return { prim : "Pair", args: [ {string: p.account}, {int: p.value.toString()} ] } }),
    data.origin_fees.map((p) => {
      return { prim : "Pair", args: [ {string: p.account}, {int: p.value.toString()} ] } })
  ] }
}

export function order_to_struct(order: OrderForm) : MichelsonData {
  let data_type = keccak(
    pack({ string: order.data.data_type }, { prim: 'string'} ))
  let data = pack(data_to_struct(order.data), order_data_type)
  return {
    prim: "Pair", args: [
      some_struct({string: order.maker}),
      { prim: "Pair", args: [
        asset_to_struct(order.make),
        { prim: "Pair", args: [
          (order.taker) ? some_struct({string: order.taker}) : none_struct(),
          { prim: "Pair", args: [
            asset_to_struct(order.take),
            { prim: "Pair", args: [
              { int: order.salt.toString() },
              { prim: "Pair", args: [
                (order.start) ? some_struct({int: order.start.toString()}) : none_struct(),
                { prim: "Pair", args: [
                  (order.end) ? some_struct({int: order.end.toString()}) : none_struct(),
                  { prim: "Pair", args: [
                    { bytes: data_type },
                    { bytes: data } ] } ] } ] } ] } ] } ] } ] } ] }
}

export async function sign_order(
  provider: Provider,
  order: OrderForm) : Promise<string> {
  let h = pack(order_to_struct(order), order_type)
  return sign(provider, h)
}

export async function order_key(
  order: OrderForm) : Promise<string> {
  const maker = pack({string: order.maker}, { prim: "key" })
  const make_asset = keccak(pack(asset_type_to_struct(order.make.asset_type), asset_type_type))
  const take_asset = keccak(pack(asset_type_to_struct(order.take.asset_type), asset_type_type))
  const salt = pack({int: order.salt.toString()}, {prim:"nat"})
  return keccak(maker + make_asset + take_asset + salt)
}
