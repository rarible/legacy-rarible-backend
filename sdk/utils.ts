import { TezosToolkit, TransactionOperation, BigMapAbstraction, OpKind, BatchOperation } from "@taquito/taquito"
import { Config } from "./config/type"
import { MichelsonData, MichelsonType, packDataBytes } from "@taquito/michel-codec"

export { TezosToolkit, TransactionOperation, BatchOperation, BigMapAbstraction } from "@taquito/taquito"
export { MichelsonData, MichelsonType } from "@taquito/michel-codec"

export interface Provider {
  tezos: TezosToolkit;
  api: string;
  config: Config;
}

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

export interface OperationArg {
  destination: string,
  amount?: bigint,
  entrypoint?: string,
  parameter?: MichelsonData
}

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

export type NftAssetType = FA12AssetType | FA2AssetType
export type AssetType = XTZAssetType | NftAssetType

export interface Asset {
  asset_type: AssetType;
  value: bigint;
}

export async function send(
  provider : Provider,
  arg: OperationArg) : Promise<TransactionOperation> {
  if (arg.entrypoint && arg.parameter) {
    return provider.tezos.contract.transfer({
      amount: (arg.amount) ? Number(arg.amount) : 0,
      to: arg.destination,
      parameter: { entrypoint: arg.entrypoint, value: arg.parameter }
    })
  } else {
    return provider.tezos.contract.transfer({
      amount: (arg.amount) ? Number(arg.amount) : 0,
      to: arg.destination
    })
  }
}

export async function batch(
  provider: Provider,
  args: OperationArg[])
: Promise<BatchOperation> {
  const params = args.map(function(p) {
    if (p.entrypoint && p.parameter) {
      return {
        kind: <OpKind.TRANSACTION>OpKind.TRANSACTION,
        amount: (p.amount) ? Number(p.amount) : 0,
        to: p.destination,
        parameter: { entrypoint: p.entrypoint, value: p.parameter }
      }
    } else {
      return {
        kind: <OpKind.TRANSACTION>OpKind.TRANSACTION,
        amount: (p.amount) ? Number(p.amount) : 0,
        to: p.destination,
      }
    }
  })
  const batch_op = provider.tezos.contract.batch(params)
  return batch_op.send()
}

export async function storage<T>(
  provider: Provider,
  contract: string)
: Promise<T> {
  const c = await provider.tezos.contract.at(contract)
  let storage : T = await c.storage()
  return storage
}

export async function wait_for_confirmation(
  op: TransactionOperation | BatchOperation,
  confirmations?: number) : Promise<TransactionOperation | BatchOperation> {
  await op.confirmation(confirmations)
  return op
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
