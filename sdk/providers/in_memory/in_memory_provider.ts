import { TezosToolkit } from "@taquito/taquito"
import { InMemorySigner } from '@taquito/signer'
import { TezosProvider } from "../../common/base"

export function in_memory_provider(edsk: string, endpoint: string) : TezosProvider {
  const tk = new TezosToolkit(endpoint)
  tk.setProvider({
    signer: new InMemorySigner(edsk),
  })
  return { kind: "in_memory", tk }
}
