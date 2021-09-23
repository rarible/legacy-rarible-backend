import { Provider, OriginationOperation } from "../utils"
import { code, make_storage } from "./fa2"

export async function deploy(
  provider : Provider,
  owner: string,
  royalties_contract: string
) : Promise<OriginationOperation> {
  const storage = make_storage(owner, royalties_contract)
  return provider.tezos.contract.originate({ storage, code })
}
