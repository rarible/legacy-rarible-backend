import { Provider, send, OperationResult, to_hex } from "../common/base"

export async function set_metadata(
  provider: Provider,
  contract: string,
  key: string,
  value: string) : Promise<OperationResult> {
  return send(provider, {
    destination: contract,
    entrypoint: "setMetadata",
    parameter: [ { string: key }, { bytes: to_hex(value) } ] })
}
