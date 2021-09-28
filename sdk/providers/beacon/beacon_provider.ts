import { BeaconWallet } from '@taquito/beacon-wallet'
import { NetworkType } from "@airgap/beacon-sdk"
import { TezosToolkit, TransferParams, OriginateParams, OpKind } from "@taquito/taquito"
import { TezosProvider, b58enc } from "../../common/base"

export async function beacon_provider(endpoint: string, network: NetworkType, name = "rarible") : Promise<TezosProvider> {
  const wallet = new BeaconWallet({ name })
  await wallet.requestPermissions({ network: {type: network, rpcUrl: endpoint} })
  const tk = new TezosToolkit(endpoint)
  tk.setProvider({ wallet })

  const transfer = async(arg: TransferParams, wait?: boolean) => {
    const op = await tk.wallet.transfer(arg).send()
    if (wait) { await op.confirmation() }
    return op.opHash
  }
  const originate = async(arg: OriginateParams, wait?: boolean) => {
    const op = await tk.wallet.originate(arg).send()
    if (wait) { await op.confirmation() }
    return op.opHash
  }
  const batch = async(args: TransferParams[], wait?: boolean) => {
    const args2 = args.map(function(a) {
      return {...a, kind: <OpKind.TRANSACTION>OpKind.TRANSACTION} })
    const op = await tk.wallet.batch(args2).send()
    if (wait) { await op.confirmation() }
    return op.opHash
  }
  const sign = async(bytes: string) => {
    const { signature } = await wallet.client.requestSignPayload({payload: bytes})
    return b58enc(signature, new Uint8Array([9, 245, 205, 134, 18]))
  }
  const address = async() => {
    return wallet.getPKH()
  }
  const storage = async(contract: string) => {
    const c = await tk.wallet.at(contract)
    return c.storage()
  }
  return {
    kind: "beacon",
    transfer,
    originate,
    batch,
    sign,
    address,
    storage
  }
}
