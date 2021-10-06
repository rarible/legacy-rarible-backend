import { TempleWallet, TempleDAppNetwork } from '@temple-wallet/dapp'
import { TezosToolkit, TransferParams, OriginateParams, OpKind } from "@taquito/taquito"
import { TezosProvider, b58enc } from "../../common/base"

export async function temple_provider(endpoint: string, network: TempleDAppNetwork, name = "rarible") : Promise<TezosProvider> {
  const wallet = new TempleWallet(name)
  await wallet.connect(network)
  const tk = new TezosToolkit(endpoint)
  tk.setProvider({ wallet })

  const transfer = async(arg: TransferParams) => {
    const op = await tk.wallet.transfer(arg).send()
    return { hash: op.opHash, confirmation: async() => { await op.confirmation() } }
  }
  const originate = async(arg: OriginateParams) => {
    const op = await tk.wallet.originate(arg).send()
    return { hash: op.opHash, confirmation: async() => { await op.confirmation() } }
  }
  const batch = async(args: TransferParams[]) => {
    const args2 = args.map(function(a) {
      return {...a, kind: <OpKind.TRANSACTION>OpKind.TRANSACTION} })
    const op = await tk.wallet.batch(args2).send()
    return { hash: op.opHash, confirmation: async() => { await op.confirmation() } }
  }
  const sign = async(bytes: string) => {
    const sig = await wallet.sign(bytes)
    return b58enc(sig, new Uint8Array([9, 245, 205, 134, 18]))
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
  return {
    kind: "temple",
    transfer,
    originate,
    batch,
    sign,
    address,
    public_key,
    storage
  }
}
