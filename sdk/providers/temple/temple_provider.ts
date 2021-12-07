import { TempleWallet } from '@temple-wallet/dapp'
import { TezosToolkit, TransferParams, OriginateParams, OpKind } from "@taquito/taquito"
import { TezosProvider, tezos_signed_message_prefix, pack_string } from "../../common/base"

export async function temple_provider(wallet: TempleWallet, tk: TezosToolkit) : Promise<TezosProvider> {
  tk.setWalletProvider(wallet)
  const transfer = async(arg: TransferParams) => {
    const op = await tk.wallet.transfer(arg).send()
    return { hash: op.opHash, confirmation: async() => { await op.confirmation() } }
  }
  const originate = async(arg: OriginateParams) => {
    const op = await tk.wallet.originate(arg).send()
    return {
      hash: op.opHash,
      confirmation: async function() {
        await op.confirmation()
        const op2 = await op.originationOperation()
        const contract = (op2!.metadata.operation_result.originated_contracts || [])[0]
        this.contract = contract
      },
      contract: undefined as string | undefined
    }
  }
  const batch = async(args: TransferParams[]) => {
    const args2 = args.map(function(a) {
      return {...a, kind: <OpKind.TRANSACTION>OpKind.TRANSACTION} })
    const op = await tk.wallet.batch(args2).send()
    return { hash: op.opHash, confirmation: async() => { await op.confirmation() } }
  }
  const sign = async(bytes: string, type?: "operation" | "message") => {
    let prefix = (type=="message") ? tezos_signed_message_prefix() : ''
    let message = prefix + bytes
    let payload = pack_string(message)
    const signature = await wallet.sign(payload)
    return {signature, prefix}
  }
  const address = async() => {
    return wallet.getPKH()
  }
  const public_key = async() => {
    const perm = await TempleWallet.getCurrentPermission()
    if (perm) return perm.publicKey
    else undefined
  }
  const storage = async(contract: string) => {
    const c = await tk.wallet.at(contract)
    return c.storage()
  }
  const balance = async() => {
    const a = await address()
    return tk.tz.getBalance(a)
  }
  const chain_id = async () => tk.rpc.getChainId()
  return {
    kind: "temple",
    transfer,
    originate,
    batch,
    sign,
    address,
    public_key,
    storage,
    balance,
    chain_id,
  }
}
