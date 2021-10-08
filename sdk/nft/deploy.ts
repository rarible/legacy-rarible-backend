import { Provider, send, OperationResult } from "../common/base"
import { fa2_code, fa2_storage } from "./fa2"

export async function deploy_fa2(
  provider : Provider,
  owner: string,
  royalties_contract: string
) : Promise<OperationResult> {
  const init = fa2_storage(owner, royalties_contract)
  return provider.tezos.originate({init, code: fa2_code})
}

export async function set_metadata_uri(
  provider: Provider,
  contract: string,
  uri: string) : Promise<OperationResult> {
  const encoder = new TextEncoder();
  const a = encoder.encode(uri)
  return send(provider, {
    destination: contract,
    entrypoint: "setMetadataUri",
    parameter: { bytes: a.reduce((acc, x) => acc + x.toString(16).padStart(2, '0'), '') } })
}
