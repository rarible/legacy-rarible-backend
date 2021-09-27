import { TransactionOperation, BigMapAbstraction, OpKind, BatchOperation, TezosToolkit, Wallet, TransferParams, TransactionWalletOperation, OriginateParams, OriginationWalletOperation, OriginationOperation } from "@taquito/taquito"
import { Config } from "./config/type"
import { MichelsonData, MichelsonType, packDataBytes } from "@taquito/michel-codec"
import { TempleWallet } from "@temple-wallet/dapp"
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

// Provider

export interface TempleProvider {
  kind: "temple";
  tk: TempleWallet;
}

export interface InMemoryProvider {
  kind: "in_memory";
  tk: TezosToolkit;
}

export type TezosProvider = TempleProvider | InMemoryProvider

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

export async function wtransfer(p: Provider, arg: TransferParams, wait = false)
: Promise<string> {
  switch (p.tezos.kind) {
    case "in_memory":
      const op1 = await p.tezos.tk.contract.transfer(arg)
      if (wait) { await op1.confirmation() }
      return op1.hash
    case "temple":
      const op2 = await p.tezos.tk.toTezos().wallet.transfer(arg).send()
      if (wait) { await op2.confirmation() }
      return op2.opHash
  }
}

export async function originate(p: Provider, arg: OriginateParams, wait = false)
: Promise<string> {
  switch (p.tezos.kind) {
    case "in_memory":
      const op1 = await p.tezos.tk.contract.originate(arg)
      if (wait) { await op1.confirmation() }
      return op1.hash
    case "temple":
      const op2 = await p.tezos.tk.toTezos().wallet.originate(arg).send()
      if (wait) { await op2.confirmation() }
      return op2.opHash
  }
}

export async function batch(p: Provider, args: TransferParams[], wait = false)
: Promise<string> {
  const args2 = args.map(function(a) {
    return {...a, kind: <OpKind.TRANSACTION>OpKind.TRANSACTION} })
  switch (p.tezos.kind) {
    case "in_memory":
      const op1 = await p.tezos.tk.contract.batch(args2).send()
      if (wait) { await op1.confirmation() }
      return op1.hash
    case "temple":
      const op2 = await p.tezos.tk.toTezos().wallet.batch(args2).send()
      if (wait) { await op2.confirmation() }
      return op2.opHash
  }
}

export function get_address(p: Provider) : Promise<string> {
  switch (p.tezos.kind) {
    case "in_memory":
      return p.tezos.tk.signer.publicKeyHash()
    case "temple":
      return p.tezos.tk.getPKH()
  }
}

export async function storage<T>(p : Provider, contract: string) : Promise<T> {
  switch (p.tezos.kind) {
    case "in_memory":
      const c1 = await p.tezos.tk.contract.at(contract)
      return c1.storage()
    case "temple":
      const c2 = await p.tezos.tk.toTezos().wallet.at(contract)
      return c2.storage()
  }
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
  switch (p.tezos.kind) {
    case "in_memory":
      const s1 = await p.tezos.tk.signer.sign(bytes)
      return s1.prefixSig
    case "temple":
      const s2 = await p.tezos.tk.sign(bytes)
      return b58enc(s2, new Uint8Array([9, 245, 205, 134, 18]))
  }
}

export async function send(
  provider : Provider,
  arg: TransactionArg,
  wait?: boolean
) : Promise<string> {
  if (arg.entrypoint && arg.parameter) {
    return wtransfer(provider, {
      amount: (arg.amount) ? Number(arg.amount) : 0,
      to: arg.destination,
      parameter: { entrypoint: arg.entrypoint, value: arg.parameter }
    }, wait)
  } else {
    return wtransfer(provider, {
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
  return batch(provider, params, wait)
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


export { TezosToolkit, TransactionOperation, BatchOperation, OriginationOperation, BigMapAbstraction } from "@taquito/taquito"
export { MichelsonData, MichelsonType } from "@taquito/michel-codec"
