import { TezosToolkit, BigMapAbstraction } from "@taquito/taquito"

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
  token_info: Map<string, string>;
  token_burnable: boolean;
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

async function mint(
  tk: TezosToolkit,
  kt1: string,
  param: MintParam)
: Promise<string> {
  const contract = await tk.contract.at(kt1)
  const op = await contract.methods.mint_tokens(param).send()
  await op.confirmation()
  return op.hash
}

async function burn(
  tk: TezosToolkit,
  kt1: string,
  param: TokenDef)
: Promise<string> {
  const contract = await tk.contract.at(kt1)
  const op = await contract.methods.burn_tokens(param).send()
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
