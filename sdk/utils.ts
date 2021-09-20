import { TezosToolkit, TransactionOperation, BigMapAbstraction } from "@taquito/taquito"
import { MichelsonV1Expression } from "@taquito/rpc"
import { Config } from "./config/type"
import { MichelsonData, MichelsonType, packDataBytes } from "@taquito/michel-codec"

export { TezosToolkit, TransactionOperation, BigMapAbstraction } from "@taquito/taquito"
export { MichelsonV1Expression } from "@taquito/rpc"
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

export async function send(
  provider : Provider,
  contract: string,
  entrypoint?: string,
  value?: MichelsonV1Expression,
  amount: bigint = 0n) : Promise<TransactionOperation> {
  if (entrypoint && value) {
    return provider.tezos.contract.transfer({
      amount: Number(amount),
      to: contract,
      parameter: { entrypoint, value }
    })
  } else {
    return provider.tezos.contract.transfer({
      amount: Number(amount),
      to: contract
    })
  }
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
  op: TransactionOperation,
  confirmations?: number) : Promise<TransactionOperation> {
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
