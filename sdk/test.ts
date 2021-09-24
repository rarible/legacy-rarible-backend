import { TezosToolkit, mint } from "./rarible"
import { InMemorySigner } from '@taquito/signer'

async function main() {

  const tezos = new TezosToolkit('https://granada.tz.functori.com');
  tezos.setProvider({
    signer: new InMemorySigner('edsk4RqeRTrhdKfJKBTndA9x1RLp4A3wtNL1iMFRXDvfs5ANeZAncZ'),
  });

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

  mint(provider, "KT1VYBd25dw5GjYqPM8T8My6b4g5c4cd4hwu", { tz1ibJRnL6hHjAfmEzM7QtGyTsS6ZtHdgE2S: 10000n }, 100n, 1n)

  // transfer(provider, { asset_class: "FA_2", contract: "KT1MWv7oH8JJhxJJs8co21XiByBEAYx2QDjY", token_id: 1n }, "tz1Mxsc66En4HsVHr6rppYZW82ZpLhpupToC", 1n).then(console.log).catch(console.log)

  // burn(provider, { asset_class: "FA_2", contract: "KT1MWv7oH8JJhxJJs8co21XiByBEAYx2QDjY", token_id: 1n }, 1n)

  // deploy(provider, "tz1ibJRnL6hHjAfmEzM7QtGyTsS6ZtHdgE2S", "KT1EZBkhGkRDxP6N1opkN8ULvnssG7f3PWoH").then(function(op) {
  //       console.log('test')
  //       op.confirmation().then(() => console.log(op.hash))
  //     })

 }


main()
