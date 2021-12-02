import { BeaconWallet } from '@taquito/beacon-wallet'
import { NetworkType, SigningType } from "@airgap/beacon-sdk"
import { TezosToolkit, TransferParams, OriginateParams, OpKind } from "@taquito/taquito"
import { TezosProvider, b58enc, hex_to_uint8array, edpk_prefix, tezos_signed_message } from "../../common/base"

export interface BeaconNetwork {
  node: string;
  network?: NetworkType;
}

export type BeaconWalletKind = "temple" | "kukai" | "spire" | "airgap" | "galleon" | "umami"

export async function beacon_provider(network: BeaconNetwork, name = "rarible", preferred_wallet ?: BeaconWalletKind) : Promise<TezosProvider> {
  const type = (!network.network) ? NetworkType.CUSTOM : network.network
  const wallet = new BeaconWallet({ name, preferredNetwork: type })
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
  const sign = async(bytes: string, type?: "message" | "operation") => {
    let signingType = SigningType.MICHELINE
    let payload = bytes
    if (type=='message') {
      switch (preferred_wallet) {
        case 'spire':
        case 'airgap':
        case 'galleon':
        case 'umami':
          signingType = SigningType.RAW
        case 'temple':
        case 'kukai':
          signingType = SigningType.MICHELINE
          payload = tezos_signed_message(bytes)
      }
    }
    const { signature } = await wallet.client.requestSignPayload({ signingType, payload })
    return { signature, message: payload }
  }
  const address = async() => {
    return wallet.getPKH()
  }
  const public_key = async() => {
    const account = await wallet.client.getActiveAccount()
    if (account) {
      if (['edpk', 'sppk', 'p2pk'].includes(account.publicKey.substring(0, 4))) return account.publicKey
      else return b58enc(hex_to_uint8array(account.publicKey), edpk_prefix)
    }
    else return undefined
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
    kind: "beacon",
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
