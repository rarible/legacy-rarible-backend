import { BeaconWallet } from '@taquito/beacon-wallet'
import { NetworkType, SigningType } from "@airgap/beacon-sdk"
import { TezosToolkit, TransferParams, OriginateParams, OpKind } from "@taquito/taquito"
import { TezosProvider } from "../../common/base"

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
  const sign = async(bytes: string) => {
    const { signature } = await wallet.client.requestSignPayload({
      signingType: SigningType.MICHELINE,
      payload: bytes
    })
    return signature
  }
  const address = async() => {
    return wallet.getPKH()
  }
  const public_key = async() => {
    const account = await wallet.client.getActiveAccount()
    if (account) return account.publicKey
    else return undefined
  }
  const storage = async(contract: string) => {
    const c = await tk.wallet.at(contract)
    return c.storage()
  }
  const balance = async() => {
    const a = await address()
    const b = await tk.tz.getBalance(a)
    return BigInt(b.toString())
  }

  return {
    kind: "beacon",
    transfer,
    originate,
    batch,
    sign,
    address,
    public_key,
    storage,
    balance
  }
}
