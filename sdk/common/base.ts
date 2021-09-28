import { BigMapAbstraction, TransferParams, OriginateParams } from "@taquito/taquito"
import { Config } from "../config/type"
import { MichelsonData, MichelsonType, packDataBytes } from "@taquito/michel-codec"
const bs58check = require("bs58check")

// Storages

export interface StorageFA2 {
  owner: string;
  royaltiesContract: string;
  ledger: BigMapAbstraction;
  operator: BigMapAbstraction;
  operator_for_all: BigMapAbstraction;
}

export interface StorageFA1_2 {
  initialholder: string,
  totalsupply: bigint,
  ledger: BigMapAbstraction;
  allowance: BigMapAbstraction;
}

export type Storage = StorageFA2 | StorageFA1_2

// Assets

export interface XTZAssetType {
  asset_class: "XTZ";
}

export interface FA12AssetType {
  asset_class: "FA_1_2";
  contract: string;
}

export interface FA2AssetType {
  asset_class: "FA_2";
  contract: string;
  token_id: bigint;
}

export type TokenAssetType = FA12AssetType | FA2AssetType
export type AssetType = XTZAssetType | TokenAssetType

export interface Asset {
  asset_type: AssetType;
  value: bigint;
}

export interface TezosProvider {
  kind: 'in_memory' | "temple" | "beacon";
  transfer: (arg: TransferParams, wait?: boolean) => Promise<string>;
  originate: (arg: OriginateParams, wait?: boolean) => Promise<string>;
  batch: (args: TransferParams[], wait?: boolean) => Promise<string>;
  sign: (bytes: string) => Promise<string>;
  address: () => Promise<string>;
  storage: (contract: string) => Promise<any>;
}

export interface Provider {
  tezos: TezosProvider ;
  api: string;
  config: Config;
}

// Operation Argument

export interface TransactionArg {
  destination: string,
  amount?: bigint,
  entrypoint?: string,
  parameter?: MichelsonData
}

export function get_address(p: Provider) : Promise<string> {
  return p.tezos.address()
}

export async function storage<T>(p : Provider, contract: string) : Promise<T> {
  return p.tezos.storage(contract)
}

export function b58enc(payload: string, prefix: Uint8Array) {
  const p = payload.match(/.{1,2}/g)
  if (p) {
    const a = new Uint8Array(p.map(b => parseInt(b, 16)))
    const n = new Uint8Array(prefix.length + a.length);
    n.set(prefix);
    n.set(a, prefix.length);
    return bs58check.encode(Buffer.from(n.buffer));
  }
}

export async function sign(p : Provider, bytes: string) : Promise<string> {
  return p.tezos.sign(bytes)
}

export async function send(
  provider : Provider,
  arg: TransactionArg,
  wait?: boolean
) : Promise<string> {
  if (arg.entrypoint && arg.parameter) {
    return provider.tezos.transfer({
      amount: (arg.amount) ? Number(arg.amount) : 0,
      to: arg.destination,
      parameter: { entrypoint: arg.entrypoint, value: arg.parameter }
    }, wait)
  } else {
    return provider.tezos.transfer({
      amount: (arg.amount) ? Number(arg.amount) : 0,
      to: arg.destination
    }, wait)
  }
}

export async function send_batch(
  provider: Provider,
  args: TransactionArg[],
  wait?: boolean
) : Promise<string> {
  const params = args.map(function(p) {
    if (p.entrypoint && p.parameter) {
      return {
        amount: (p.amount) ? Number(p.amount) : 0,
        to: p.destination,
        parameter: { entrypoint: p.entrypoint, value: p.parameter }
      }
    } else {
      return {
        amount: (p.amount) ? Number(p.amount) : 0,
        to: p.destination,
      }
    }
  })
  return provider.tezos.batch(params, wait)
}

export function pack(
  data: MichelsonData,
  type: MichelsonType) : string {
  return packDataBytes(data, type).bytes
}

export async function get_transaction(
  provider: Provider,
  op_hash: string) {
  const r = await fetch(provider.api + '/transaction/' + op_hash)
  if (r.ok) { return r.json() }
  else throw new Error("/transaction/" + op_hash + " failed")
}

export { MichelsonData, MichelsonType } from "@taquito/michel-codec"
