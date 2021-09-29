import { TezosToolkit, TransferParams, OriginateParams, OpKind } from "@taquito/taquito"
import { InMemorySigner } from '@taquito/signer'
import { TezosProvider } from "../../common/base"

export function in_memory_provider(edsk: string, endpoint: string) : TezosProvider {
  const tk = new TezosToolkit(endpoint)
  tk.setProvider({
    signer: new InMemorySigner(edsk),
  })

  const transfer = async(arg: TransferParams) => {
    const op = await tk.contract.transfer(arg)
    return { hash: op.hash, confirmation: async() => { await op.confirmation() } }
  }
  const originate = async(arg: OriginateParams) => {
    const op = await tk.contract.originate(arg)
    return { hash: op.hash, confirmation: async() => { await op.confirmation() } }
  }
  const batch = async(args: TransferParams[]) => {
    const args2 = args.map(function(a) {
      return {...a, kind: <OpKind.TRANSACTION>OpKind.TRANSACTION} })
    const op = await tk.contract.batch(args2).send()
    return { hash: op.hash, confirmation: async() => { await op.confirmation() } }
  }
  const sign = async(bytes: string) => {
    const sig = await tk.signer.sign(bytes)
    return sig.prefixSig
  }
  const address = async() => {
    return tk.signer.publicKeyHash()
  }
  const storage = async(contract: string) => {
    const c = await tk.contract.at(contract)
    return c.storage()
  }

  return {
    kind: "in_memory",
    transfer,
    originate,
    batch,
    sign,
    address,
    storage
  }
}
