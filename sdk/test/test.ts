import { storage, StorageFA2 } from "../main"
import { in_memory_provider } from '../providers/in_memory/in_memory_provider'

async function main() {

  const tezos = in_memory_provider(
    'edsk3UUamwmemNBJgDvS8jXCgKsvjL2NoTwYRFpGSRPut4Hmfs6dG8',
    'https://granada.tz.functori.com')

  const config = {
    exchange: "KT1C5kWbfzASApxCMHXFLbHuPtnRaJXE4WMu",
    fees: 0n
  }

  const provider = {
    tezos,
    api: "https://localhost:8080/v0.1",
    config
  }

  // mint(provider, "KT1VYBd25dw5GjYqPM8T8My6b4g5c4cd4hwu", { tz1ibJRnL6hHjAfmEzM7QtGyTsS6ZtHdgE2S: 10000n }, 100n, 1n)

  const st : StorageFA2 = await storage(provider, "KT1WUJBk5T53bfNLncG2csWo4y8pFSteBvQL")
  const r = await st.operator_for_all.get({0: "KT1XgQ52NeNdjo3jLpbsPBRfg8YhWoQ5LB7g", 1: "tz1ibJRnL6hHjAfmEzM7QtGyTsS6ZtHdgE2S"})
  console.log(r)

  // transfer(provider, { asset_class: "FA_2", contract: "KT1WUJBk5T53bfNLncG2csWo4y8pFSteBvQL", token_id: 1n }, "tz1iQ3DU476h5EUULD1e5yfuiYyk1JNR6HbY", 50n).then(console.log).catch(console.log)

  // burn(provider, { asset_class: "FA_2", contract: "KT1MWv7oH8JJhxJJs8co21XiByBEAYx2QDjY", token_id: 1n }, 1n)

  // deploy(provider, "tz1ibJRnL6hHjAfmEzM7QtGyTsS6ZtHdgE2S", "KT1EZBkhGkRDxP6N1opkN8ULvnssG7f3PWoH").then(function(op) {
  //       console.log('test')
  //       op.confirmation().then(() => console.log(op.hash))
  //     })

 }


main()
