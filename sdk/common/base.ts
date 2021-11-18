import { BigMapAbstraction, TransferParams, OriginateParams } from "@taquito/taquito"
import { Config } from "../config/type"
import { MichelsonData } from "@taquito/michel-codec"
import BigNumber from "@taquito/rpc/node_modules/bignumber.js"
const bs58check = require("bs58check")

export interface StorageFA2 {
  owner: string;
  royaltiesContract: string;
  ledger: BigMapAbstraction;
  operator: BigMapAbstraction;
  operator_for_all: BigMapAbstraction;
}

export interface StorageFA1_2 {
  initialholder: string,
  totalsupply: BigNumber,
  ledger: BigMapAbstraction;
  allowance: BigMapAbstraction;
}

export interface XTZAssetType  {
  asset_class: "XTZ";
}

export interface FTAssetType {
  asset_class: "FT";
  contract: string;
}

export interface NFTAssetType {
  asset_class: "NFT";
  contract?: string;
  token_id: BigNumber;
}

export interface MultipleAssetType {
  asset_class: "MT";
  contract?: string;
  token_id: BigNumber;
}

export type TokenAssetType = FTAssetType | NFTAssetType | MultipleAssetType
export type AssetType = XTZAssetType | TokenAssetType

export interface Asset {
  asset_type: AssetType;
  value: BigNumber;
}

export interface OperationResult {
  hash: string;
  confirmation: () => Promise<void>;
  token_id?: BigNumber;
  contract?: string;
}

export interface TezosProvider {
  kind: 'in_memory' | "temple" | "beacon";
  transfer: (arg: TransferParams) => Promise<OperationResult>;
  originate: (arg: OriginateParams) => Promise<OperationResult>;
  batch: (args: TransferParams[]) => Promise<OperationResult>;
  sign: (bytes: string) => Promise<string>;
  address: () => Promise<string>;
  public_key: () => Promise<string | undefined>;
  storage: (contract: string) => Promise<any>;
  balance: () => Promise<BigNumber>;
  chain_id: () => Promise<string>;
}

export interface Provider {
  tezos: TezosProvider ;
  api: string;
  config: Config;
}

export interface TransactionArg {
  destination: string,
  amount?: BigNumber,
  entrypoint?: string,
  parameter?: MichelsonData
}

export function asset_type_to_json(a: AssetType) : any {
  switch (a.asset_class) {
    case "XTZ":
      return { assetClass: a.asset_class }
    case "FT":
      return { assetClass: a.asset_class, contract: a.contract }
    case "NFT":
    case "MT":
      return {
        assetClass: a.asset_class,
        contract: a.contract,
        tokenId: a.token_id.toString()
      }
  }
}

export function asset_type_of_json(a: any) : AssetType {
  switch (a.assetClass) {
    case "XTZ":
      return { asset_class: a.assetClass }
    case "FT":
      return { asset_class: a.assetClass, contract: a.contract }

    case "NFT":
    case "MT":
      return {
        asset_class: a.assetClass,
        contract: a.contract,
        token_id: new BigNumber(a.tokenId)
      }
    default: throw new Error("Unknown Asset Class")
  }
}

export function mutez_to_tez(mu: BigNumber) : number {
  const factor = new BigNumber(1000000)
  return Number(mu.div(factor).plus(mu.mod(factor).div(factor)))
}

export function asset_to_json(a: Asset) : any {
  // todo handle different decimal for FA_1_2
  switch (a.asset_type.asset_class) {
    case "XTZ":
      const value = mutez_to_tez(a.value)
      return {
        assetType : asset_type_to_json(a.asset_type),
        value: value.toString()
      }
    default:
      return {
        assetType : asset_type_to_json(a.asset_type),
        value: a.value.toString()
      }
  }
}

export function asset_of_json(a: any) : Asset {
  const factor = 1000000
    switch (a.assetType.assetClass) {
      case "XTZ":
        return {
          asset_type : asset_type_of_json(a.assetType),
          value: new BigNumber(a.value).multipliedBy(factor)
        }
      default:
        return {
          asset_type : asset_type_of_json(a.assetType),
          value: new BigNumber(a.value)
        }
    }
}

export function get_address(p: Provider) : Promise<string> {
  return p.tezos.address()
}

export function get_public_key(p: Provider) : Promise<string | undefined> {
  return p.tezos.public_key()
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
) : Promise<OperationResult> {
  if (arg.entrypoint && arg.parameter) {
    return provider.tezos.transfer({
      amount: (arg.amount!=undefined) ? mutez_to_tez(arg.amount) : 0,
      to: arg.destination,
      parameter: { entrypoint: arg.entrypoint, value: arg.parameter }
    })
  } else {
    return provider.tezos.transfer({
      amount: (arg.amount!=undefined) ? mutez_to_tez(arg.amount) : 0,
      to: arg.destination
    })
  }
}

export async function send_batch(
  provider: Provider,
  args: TransactionArg[],
) : Promise<OperationResult> {
  const params = args.map(function(p) {
    if (p.entrypoint && p.parameter) {
      return {
        amount: (p.amount!=undefined) ? mutez_to_tez(p.amount) : 0,
        to: p.destination,
        parameter: { entrypoint: p.entrypoint, value: p.parameter }
      }
    } else {
      return {
        amount: (p.amount!=undefined) ? mutez_to_tez(p.amount) : 0,
        to: p.destination,
      }
    }
  })
  return provider.tezos.batch(params)
}

export async function get_transaction(
  provider: Provider,
  op_hash: string) {
  const r = await fetch(provider.api + '/transaction/' + op_hash)
  if (r.ok) { return r.json() }
  else throw new Error("/transaction/" + op_hash + " failed")
}

export function uint8array_to_hex(a: Uint8Array) : string {
  return a.reduce((acc, x) => acc + x.toString(16).padStart(2, '0'), '')
}

export function hex_to_uint8array(s: string) : Uint8Array {
  const a = new Uint8Array(s.length / 2)
  for (let i = 0; i < s.length; i += 2) {
    a[i / 2] = parseInt(s.substring(i, i + 2), 16)
  }
  return a
}

export function to_hex(s: string) : string {
  const encoder = new TextEncoder();
  const a = encoder.encode(s)
  return uint8array_to_hex(a)
}
