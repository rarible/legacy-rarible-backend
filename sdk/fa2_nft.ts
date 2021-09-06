import { TezosToolkit, BigMapAbstraction } from "@taquito/taquito"
import { MichelsonV1Expression } from "@taquito/rpc"

interface TransferDestination {
  to_ : string;
  token_id : number;
  amount : number;
}

interface Transfer {
  from_: string;
  txs: TransferDestination[];
}

interface TokenDef {
  from_: number;
  to_: number
}

interface TokenMetadata {
  token_id: number;
  token_info: [string, string][];
}

interface MintParam {
  token_def: TokenDef;
  metadata: TokenMetadata;
  owners: string[];
}

interface OperatorParam {
  owner: string;
  operator: string;
  token_id: number;
}

interface AddOperator {
  add_operator : OperatorParam
}

interface RemoveOperator {
  remove_operator : OperatorParam
}

type UpdateOperator = AddOperator | RemoveOperator

interface Storage {
  admin: string;
  company_wallet: string;
  pending_admin: string | undefined | null;
  pending_company_wallet: string | undefined | null;
  paused: boolean;
  ledger: BigMapAbstraction;
  operators: BigMapAbstraction;
  managed: BigMapAbstraction;
  token_defs: TokenDef[];
  next_token_id: number;
  token_metas: BigMapAbstraction;
  metadata: BigMapAbstraction;
}

async function set_admin(
  tk: TezosToolkit,
  kt1: string,
  param: string)
: Promise<string> {
  const contract = await tk.contract.at(kt1)
  const op = await contract.methods.set_admin(param).send()
  await op.confirmation()
  return op.hash
}

async function confirm_admin(
  tk: TezosToolkit,
  kt1: string)
: Promise<string> {
  const contract = await tk.contract.at(kt1)
  const op = await contract.methods.confirm_admin().send()
  await op.confirmation()
  return op.hash
}

async function pause(
  tk: TezosToolkit,
  kt1: string)
: Promise<string> {
  const contract = await tk.contract.at(kt1)
  const op = await contract.methods.pause(true).send()
  await op.confirmation()
  return op.hash
}

async function unpause(
  tk: TezosToolkit,
  kt1: string)
: Promise<string> {
  const contract = await tk.contract.at(kt1)
  const op = await contract.methods.pause(false).send()
  await op.confirmation()
  return op.hash
}

function encode_map(l : [string, string][]) : MichelsonV1Expression {
  return l.map(function([k, v]) {
    return {
      prim: 'Elt',
      args: [ {string: k}, {bytes: v} ]
    }
  })
}

async function mint(
  tk: TezosToolkit,
  kt1: string,
  param: MintParam)
: Promise<string> {
  let value = {
    prim: 'Pair',
    args: [
      {
        prim: 'Pair',
        args: [ { int: param.token_def.from_.toString() }, { int: param.token_def.to_.toString() } ] },
      {
          prim: 'Pair',
          args: [
            { int: param.metadata.token_id.toString() },
            encode_map(param.metadata.token_info)
          ]
        },
      param.owners.map(function(s) { return {string: s} })
    ]
  }
  const op = await tk.contract.transfer({
    amount: 0,
    to: kt1,
    parameter: { entrypoint: 'mint_tokens', value }
  })
  await op.confirmation()
  return op.hash
}

async function burn(
  tk: TezosToolkit,
  kt1: string,
  param: TokenDef)
: Promise<string> {
  let value = {
    prim: 'Pair',
    args: [ { int: param.from_.toString() }, { int: param.to_.toString() } ]
  }
  const op = await tk.contract.transfer({
    amount: 0,
    to: kt1,
    parameter: { entrypoint: 'burn_tokens', value }
  })
  await op.confirmation()
  return op.hash
}

async function transfer(
  tk: TezosToolkit,
  kt1: string,
  param: Transfer[] )
: Promise<string> {
  const contract = await tk.contract.at(kt1)
  const op = await contract.methods.transfer(param).send()
  await op.confirmation()
  return op.hash
}

async function update_operators(
  tk: TezosToolkit,
  kt1: string,
  param: UpdateOperator[] )
: Promise<string> {
  const contract = await tk.contract.at(kt1)
  const op = await contract.methods.update_operators(param).send()
  await op.confirmation()
  return op.hash
}

async function managed(
  tk: TezosToolkit,
  kt1: string,
  param: boolean )
: Promise<string> {
  const contract = await tk.contract.at(kt1)
  const op = await contract.methods.managed(param).send()
  await op.confirmation()
  return op.hash
}

async function storage(
  tk: TezosToolkit,
  kt1: string)
: Promise<Storage> {
  const contract = await tk.contract.at(kt1)
  let storage = await contract.storage() as Storage
  return storage
}

async function owner(
  tk: TezosToolkit,
  kt1: string,
  token_id: number,
  storage?: Storage
)
: Promise<string> {
  const contract = await tk.contract.at(kt1)
  let st = (storage == undefined) ? await contract.storage() as Storage : storage!
  let v = await st.ledger.get(token_id) as string
  return v
}

async function owners(
  tk: TezosToolkit,
  kt1: string,
  token_ids: number[],
  storage?: Storage
)
: Promise<any> {
  const contract = await tk.contract.at(kt1)
  let st = (storage == undefined) ? await contract.storage() as Storage : storage!
  let v = await st.ledger.getMultipleValues(token_ids)
  return v
}



export {
  set_admin,
  confirm_admin,
  pause,
  unpause,
  mint,
  burn,
  transfer,
  update_operators,
  managed,
  storage,
  owner,
  owners
}
