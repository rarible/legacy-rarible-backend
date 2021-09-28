import { Provider, transfer } from "./rarible"
import { beacon_provider } from '../providers/beacon/beacon_provider'
import { NetworkType } from "@airgap/beacon-sdk";


async function provider() : Promise<Provider> {

  const tezos = await beacon_provider('https://granada.tz.functori.com', NetworkType.GRANADANET)
  const config = {
    exchange: "KT1C5kWbfzASApxCMHXFLbHuPtnRaJXE4WMu",
    proxies: { fa_1_2: "", nft: "" },
    fees: 0n
  }

  const provider = {
    tezos,
    api: "https://localhost:8080/v0.1",
    config
  }
  return provider
}

export async function test_transfer() {
  const p = await provider()
  const contract_elt = document.getElementById("transfer-contract") as HTMLInputElement
  const token_id_elt = document.getElementById("transfer-token-id") as HTMLInputElement
  const destination_elt = document.getElementById("transfer-destination") as HTMLInputElement
  const amount_elt = document.getElementById("transfer-amount") as HTMLInputElement
  transfer(
    p,
    { asset_class: "FA_2",
      contract: contract_elt.value,
      token_id: BigInt(token_id_elt.value) },
    destination_elt.value,
    BigInt(amount_elt.value)).then(console.log)
}
