import { TezosToolkit, TransferParams, OriginateParams, OpKind } from "@taquito/taquito"
import { InMemorySigner } from '@taquito/signer'
import { TezosProvider } from "../../common/base"

export function in_memory_provider(edsk: string, endpoint: string) : TezosProvider {
  const tk = new TezosToolkit(endpoint)
  tk.setProvider({
    signer: new InMemorySigner(edsk),
  })

  const transfer = async(arg: TransferParams, wait?: boolean) => {
    const op = await tk.contract.transfer(arg)
    if (wait) { await op.confirmation() }
    return op.hash
  }
  const originate = async(arg: OriginateParams, wait?: boolean) => {
    const op = await tk.contract.originate(arg)
    if (wait) { await op.confirmation() }
    return op.hash
  }
  const batch = async(args: TransferParams[], wait?: boolean) => {
    const args2 = args.map(function(a) {
      return {...a, kind: <OpKind.TRANSACTION>OpKind.TRANSACTION} })
    const op = await tk.contract.batch(args2).send()
    if (wait) { await op.confirmation() }
    return op.hash
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
