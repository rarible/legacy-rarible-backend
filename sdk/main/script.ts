import { transfer, mint, burn, deploy_fa2, deploy_royalties, set_token_metadata, set_metadata_uri } from "."
import { in_memory_provider } from '../providers/in_memory/in_memory_provider'
import yargs from 'yargs'


async function main() {
  const argv = yargs(process.argv.slice(2)).options({
    edsk: {type: 'string', default: 'edsk4RqeRTrhdKfJKBTndA9x1RLp4A3wtNL1iMFRXDvfs5ANeZAncZ'},
    endpoint: {type: 'string', default: 'https://granada.tz.functori.com'},
    exchange: {type: 'string', default: 'KT1C5kWbfzASApxCMHXFLbHuPtnRaJXE4WMu'},
    contract: {type: 'string', default: 'KT1MWv7oH8JJhxJJs8co21XiByBEAYx2QDjY'},
    royalties_contract: {type: 'string', default: 'KT1BkQiZcEL8kvx66WZCnFBCCjhJHsQsScw7'},
    token_id: {type : 'number'},
    royalties: {type: 'string', default: '{}'},
    amount: {type: 'number'},
    metadata: {type: 'string', default: '{}'},
    metadata_uri: {type: 'string', default: ''},
    to: {type: 'string'},
    owner: {type: 'string'}
  }).argv

  const token_id_opt = (argv.token_id) ? BigInt(argv.token_id) : undefined
  const token_id = (argv.token_id) ? BigInt(argv.token_id) : 0n

  const royalties0 = JSON.parse(argv.royalties) as { [key: string] : number }
  const royalties : { [key: string] : bigint } = {};
  if (royalties0) {
    Object.keys(royalties0).forEach(
      function(k : string) : void {
        royalties[k] = BigInt(royalties0[k])
      })
  }

  const amount = (argv.amount) ? BigInt(argv.amount as number) : undefined
  const metadata = JSON.parse(argv.metadata) as { [_: string] : string }

  const tezos = in_memory_provider(argv.edsk, argv.endpoint)

  const config = {
    exchange: argv.exchange,
    proxies: { fa_1_2: "", nft: "" },
    fees: 0n
  }

  const provider = {
    tezos,
    api: "https://localhost:8080/v0.1",
    config
  }
  const to = (argv.to) ? argv.to : await provider.tezos.address()
  const owner = (argv.owner) ? argv.owner : await provider.tezos.address()

  switch(argv._[0]) {
    case 'transfer' :
      console.log("transfer")
      const op_transfer = await transfer(provider, { asset_class: "FA_2", contract: argv.contract, token_id }, to, amount)
      await op_transfer.confirmation()
      console.log(op_transfer.hash)
      break

    case 'mint':
      console.log("mint")
      const op_mint = await mint(provider, argv.contract, royalties, amount, token_id_opt)
      await op_mint.confirmation()
      console.log(op_mint.hash)
      break

    case 'burn':
      console.log("burn")
      const op_burn = await burn(provider, { asset_class: "FA_2", contract: argv.contract, token_id }, amount)
      await op_burn.confirmation()
      console.log(op_burn.hash)
      break

    case 'deploy_fa2':
      console.log("deploy fa2")
      const op_deploy_fa2 = await deploy_fa2(provider, owner, argv.royalties_contract)
      await op_deploy_fa2.confirmation()
      console.log(op_deploy_fa2.hash)
      break

    case 'deploy_royalties':
      console.log("deploy royalties")
      const op_deploy_royalties = await deploy_royalties(provider, owner)
      await op_deploy_royalties.confirmation()
      console.log(op_deploy_royalties.hash)
      break

    case 'set_token_metadata':
      console.log("set_token_metadata")
      const op_token_metadata = await set_token_metadata(provider, argv.contract, token_id, metadata)
      await op_token_metadata.confirmation()
      console.log(op_token_metadata.hash)
      break

    case 'set_metadata_uri':
      console.log("set_metadata_uri")
      const op_metadata_uri = await set_metadata_uri(provider, argv.contract, argv.metadata_uri)
      await op_metadata_uri.confirmation()
      console.log(op_metadata_uri.hash)
      break


  }
}


main()
