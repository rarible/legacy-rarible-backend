import { transfer, mint, burn, deploy, set_token_metadata, set_metadata_uri, get_address } from "./rarible"
import { in_memory_provider } from '../providers/in_memory/in_memory_provider'
import yargs from 'yargs'


async function main() {

  const argv = yargs(process.argv).argv
  const edsk = (argv.edsk) ? argv.edsk as string : 'edsk4RqeRTrhdKfJKBTndA9x1RLp4A3wtNL1iMFRXDvfs5ANeZAncZ'
  const endpoint = (argv.endpoint) ? argv.endpoint as string : 'https://granada.tz.functori.com'
  const exchange = (argv.exchange) ? argv.exchange as string : "KT1C5kWbfzASApxCMHXFLbHuPtnRaJXE4WMu"
  const contract = (argv.contract) ? argv.contract as string : "KT1MWv7oH8JJhxJJs8co21XiByBEAYx2QDjY"
  const royalties_contract = (argv.royalties_contract) ? argv.royalties_contract as string : "KT1BkQiZcEL8kvx66WZCnFBCCjhJHsQsScw7"
  const token_id_opt = (argv.token_id) ? BigInt(argv.token_id as number) : undefined
  const token_id = (argv.token_id) ? BigInt(argv.token_id as number) : 0n

  const royalties0 = argv.royalties as ({ [key: string] : number } | undefined) ;
  const royalties : { [key: string] : bigint } = {};
  if (royalties0) {
    Object.keys(royalties0).forEach(
      function(k : string) : void {
        royalties[k] = BigInt(royalties0[k])
      })
  }

  const amount = (argv.amount) ? BigInt(argv.amount as number) : undefined
  const metadata = (argv.metadata) ? argv.metadata as { [_: string] : string } : {}
  const metadata_uri = (argv.metadata_uri) ? argv.metadata_uri as string : ""

  const tezos = in_memory_provider(edsk, endpoint)

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
  const to = (argv.to) ? argv.to as string : await get_address(provider)
  const owner = (argv.owner) ? argv.owner as string : await get_address(provider)

  switch(argv._[0]) {
    case 'transfer' :
      console.log("transfer")
      transfer(provider, { asset_class: "FA_2", contract, token_id }, to, amount).then()
      break

    case 'mint':
      console.log("mint")
      mint(provider, contract, royalties, amount, token_id_opt).then(console.log)
      break

    case 'burn':
      console.log("burn")
      burn(provider, { asset_class: "FA_2", contract, token_id }, amount).then(console.log)
      break

    case 'deploy':
      console.log("deploy")
      deploy(provider, owner, royalties_contract).then(console.log)
      break

    case 'set_token_metadata':
      console.log("set_token_metadata")
      set_token_metadata(provider, contract, token_id, metadata).then(console.log)
      break

    case 'set_metadata_uri':
      console.log("set_metadata_uri")
      set_metadata_uri(provider, contract, metadata_uri).then(console.log)
      break


  }
}


main()
