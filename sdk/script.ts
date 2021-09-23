import { TezosToolkit, transfer, mint, burn, deploy } from "./rarible"
import { InMemorySigner } from '@taquito/signer'
import yargs from 'yargs'


async function main() {

  const argv = yargs(process.argv).argv
  console.log(argv)

  const edsk = (argv.edsk) ? argv.edsk as string : 'edsk4RqeRTrhdKfJKBTndA9x1RLp4A3wtNL1iMFRXDvfs5ANeZAncZ'
  const endpoint = (argv.endpoint) ? argv.endpoint as string : 'https://granada.tz.functori.com'
  const exchange = (argv.exchange) ? argv.exchange as string : "KT1C5kWbfzASApxCMHXFLbHuPtnRaJXE4WMu"
  const contract = (argv.contract) ? argv.contract as string : "KT1MWv7oH8JJhxJJs8co21XiByBEAYx2QDjY"
  const royalties_contract = (argv.royalties_contract) ? argv.royalties_contract as string : "KT1BkQiZcEL8kvx66WZCnFBCCjhJHsQsScw7"
  const token_id = (argv.token_id) ? argv.token_id as bigint : 0n

  const royalties = (argv.royalties) ? argv.royalties as any : {}

  const tezos = new TezosToolkit(endpoint);
  tezos.setProvider({
    signer: new InMemorySigner(edsk),
  });

  const config = {
    exchange: exchange,
    proxies: { fa_1_2: "", nft: "" },
    fees: 0n
  }

  const provider = {
    tezos,
    api: "https://localhost:8080/v0.1",
    config
  }
  const to = (argv.to) ? argv.to as string : await provider.tezos.signer.publicKeyHash()
  const owner = (argv.to) ? argv.to as string : await provider.tezos.signer.publicKeyHash()

  switch (argv._[0]) {
    case 'transfer' :
      transfer(provider, { asset_class: "FA_2", contract, token_id }, to, argv.amount as bigint).then(console.log)
    case 'mint':
      mint(provider, contract, royalties, argv.amount as bigint, argv.token_id as bigint).then(console.log)
    case 'burn':
      burn(provider, { asset_class: "FA_2", contract, token_id }, argv.amount as bigint).then(console.log)
    case 'deploy':
      deploy(provider, owner, royalties_contract).then(console.log)
  }
}


main()
