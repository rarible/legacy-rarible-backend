import { TezosToolkit, storage } from "./rarible"

import { InMemorySigner } from '@taquito/signer';

async function main() {

  const tezos = new TezosToolkit('https://granada.tz.functori.com');
  tezos.setProvider({
    signer: new InMemorySigner('edsk4RqeRTrhdKfJKBTndA9x1RLp4A3wtNL1iMFRXDvfs5ANeZAncZ'),
  });

  const provider = { tezos, api: "https://api.todo-tezos.rarible.io" }

  // transfer(
  //   provider, 'KT1MWv7oH8JJhxJJs8co21XiByBEAYx2QDjY',
  //   'tz1ibJRnL6hHjAfmEzM7QtGyTsS6ZtHdgE2S', 'tz1Mxsc66En4HsVHr6rppYZW82ZpLhpupToC',
  //   0n, 3n)
  //   .then(hash =>
  //     console.log("done", hash))
  //   .catch(e => console.log("error", e))

  const st = await storage(provider, 'KT1MWv7oH8JJhxJJs8co21XiByBEAYx2QDjY')
  console.log(st.ledger.toJSON())
}

main()
