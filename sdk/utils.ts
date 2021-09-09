import { TezosToolkit, TransactionOperation, BigMapAbstraction } from "@taquito/taquito"
import { MichelsonV1Expression } from "@taquito/rpc"

export { TezosToolkit, TransactionOperation, BigMapAbstraction } from "@taquito/taquito"
export { MichelsonV1Expression } from "@taquito/rpc"

export interface Storage {
  admin: string;
  pending_admin: string | undefined | null;
  paused: boolean;
  ledger: BigMapAbstraction;
  operators: BigMapAbstraction;
  approved: BigMapAbstraction;
  next_token_id: bigint;
  metadata: BigMapAbstraction;
}

export interface Asset {
  kind: "ERC721" | "ERC1155";
  contract: string;
  token_id: bigint;
  value: bigint;
}

export async function send(
  tk : TezosToolkit,
  contract: string,
  entrypoint: string,
  value: MichelsonV1Expression) : Promise<TransactionOperation> {
  return tk.contract.transfer({
    amount: 0,
    to: contract,
    parameter: { entrypoint, value }
  })
}

export async function storage(
  tk: TezosToolkit,
  contract: string)
: Promise<Storage> {
  const c = await tk.contract.at(contract)
  let storage = await c.storage() as Storage
  return storage
}

export async function wait_for_confirmation(
  op: TransactionOperation,
  confirmations?: number) : Promise<TransactionOperation> {
  await op.confirmation(confirmations)
  return op
}