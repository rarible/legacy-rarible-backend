import { BeaconWallet } from '@taquito/beacon-wallet'
import { NetworkType } from "@airgap/beacon-sdk"
import { TezosToolkit, TransferParams, OriginateParams, OpKind } from "@taquito/taquito"
import { TezosProvider, b58enc } from "../../common/base"

interface Network {
  node: string;
  network?: NetworkType;
}

export async function beacon_provider(network: Network, name = "rarible") : Promise<TezosProvider> {
  const wallet = new BeaconWallet({ name })
  const type = (!network.network) ? NetworkType.CUSTOM : network.network
  await wallet.requestPermissions({ network: {type, rpcUrl: network.node} })
  const tk = new TezosToolkit(network.node)
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
