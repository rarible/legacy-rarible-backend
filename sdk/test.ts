import { TezosToolkit, transferErc721 } from "./rarible"

import { InMemorySigner } from '@taquito/signer';

async function main() {

  const tk = new TezosToolkit('https://granada.tz.functori.com');
  tk.setProvider({
    signer: new InMemorySigner('edsk4RqeRTrhdKfJKBTndA9x1RLp4A3wtNL1iMFRXDvfs5ANeZAncZ'),
  });


  transferErc721(
    tk, 'KT1SGf3Z1TLm7SWqQrNbA7qFqhkGNxjymRB3', 'tz1ibJRnL6hHjAfmEzM7QtGyTsS6ZtHdgE2S',
    'tz1Mxsc66En4HsVHr6rppYZW82ZpLhpupToC', 42n)
    .then(hash =>
      console.log("done", hash))
    .catch(e => console.log("error", e))
}

main()
