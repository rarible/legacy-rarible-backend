import { Provider, OriginationOperation } from "../utils"
import { code, make_storage } from "./fa2"
import { send, TransactionOperation } from "../utils"

export async function deploy(
  provider : Provider,
  owner: string,
  royalties_contract: string
) : Promise<OriginationOperation> {
  const init = make_storage(owner, royalties_contract)
  return provider.tezos.contract.originate({ init, code })
}

export async function set_metadata_uri(
  provider: Provider,
  contract: string,
  uri: string) : Promise<TransactionOperation> {
  const encoder = new TextEncoder();
  const a = encoder.encode(uri)
  return send(provider, {
    destination: contract,
    entrypoint: "setMetadataUri",
    parameter: { bytes: a.reduce((acc, x) => acc + x.toString(16).padStart(2, '0'), '') } })
}
