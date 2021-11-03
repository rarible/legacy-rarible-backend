import { transfer, mint, burn, deploy_nft_public, deploy_royalties, set_token_metadata, set_metadata, deploy_exchangeV2, deploy_validator, send, TransactionArg} from "."
import { in_memory_provider } from '../providers/in_memory/in_memory_provider'
import yargs from 'yargs'

async function main() {
  const argv = yargs(process.argv.slice(2)).options({
    edsk: {type: 'string', default: 'edsk4RqeRTrhdKfJKBTndA9x1RLp4A3wtNL1iMFRXDvfs5ANeZAncZ'},
    endpoint: {type: 'string', default: 'https://granada.tz.functori.com'},
    exchange: {type: 'string', default: 'KT1XgQ52NeNdjo3jLpbsPBRfg8YhWoQ5LB7g'},
    contract: {type: 'string', default: 'KT1MWv7oH8JJhxJJs8co21XiByBEAYx2QDjY'},
    royalties_contract: {type: 'string', default: 'KT1KrzCSQs6XMMRsQ7dqCVcYQeGs7d512zzb'},
    token_id: {type : 'number'},
    royalties: {type: 'string', default: '{}'},
    amount: {type: 'number'},
    metadata: {type: 'string', default: '{}'},
    metadata_key: {type: 'string', default: ''},
    metadata_value: {type: 'string', default: ''},
    to: {type: 'string'},
    owner: {type: 'string'},
    receiver: {type: 'string'},
    fee: {type: 'number', default: 0},
    validator: {type: 'string', default: 'KT1RtsevY6b6izV12QMxvVZviSTy4Mcu2apg'},
    operator: {type: 'string', default: 'KT1XgQ52NeNdjo3jLpbsPBRfg8YhWoQ5LB7g'},

  }).argv

  const token_id_opt = (argv.token_id!=undefined) ? BigInt(argv.token_id) : undefined
  const token_id = (argv.token_id!=undefined) ? BigInt(argv.token_id) : 0n

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
    fees: 0n,
    nft_public: "",
    mt_public: "",
  }

  const provider = {
    tezos,
    api: "https://localhost:8080/v0.1",
    config
  }
  const to = (argv.to) ? argv.to : await provider.tezos.address()
  const owner = (argv.owner) ? argv.owner : await provider.tezos.address()
  const receiver = (argv.receiver) ? argv.receiver : await provider.tezos.address()
  const asset_class = (amount==undefined) ? "NFT" : "MT"

  switch(argv._[0]) {
    case 'transfer' :
      console.log("transfer")
      const op_transfer = await transfer(provider, { asset_class, contract: argv.contract, token_id }, to, amount)
      await op_transfer.confirmation()
      console.log(op_transfer.hash)
      break

    case 'mint':
      console.log("mint")
      const op_mint = await mint(provider, argv.contract, royalties, amount, token_id_opt, undefined, argv.owner)
      await op_mint.confirmation()
      console.log(op_mint.hash)
      break

    case 'burn':
      console.log("burn")
      const op_burn = await burn(provider, { asset_class, contract: argv.contract, token_id }, amount)
      await op_burn.confirmation()
      console.log(op_burn.hash)
      break

    case 'deploy_nft':
      console.log("deploy nft")
      const op_deploy_fa2 = await deploy_nft_public(provider, owner)
      await op_deploy_fa2.confirmation()
      console.log(op_deploy_fa2.contract)
      break

    case 'deploy_royalties':
      console.log("deploy royalties")
      const op_deploy_royalties = await deploy_royalties(provider, owner)
      await op_deploy_royalties.confirmation()
      console.log(op_deploy_royalties.contract)
      break

    case 'set_token_metadata':
      console.log("set token metadata")
      const op_token_metadata = await set_token_metadata(provider, argv.contract, token_id, metadata)
      await op_token_metadata.confirmation()
      console.log(op_token_metadata.hash)
      break

    case 'set_metadata':
      console.log("set metadata uri")
      const op_metadata_uri = await set_metadata(provider, argv.contract, argv.metadata_key, argv.metadata_value)
      await op_metadata_uri.confirmation()
      console.log(op_metadata_uri.hash)
      break

    case 'deploy_validator':
      console.log("deploy validator")
      const op_deploy_validator = await deploy_validator(provider, argv.exchange, argv.royalties_contract)
      await op_deploy_validator.confirmation()
      console.log(op_deploy_validator.contract)
      break

    case 'deploy_exchange':
      console.log("deploy exchange")
      const op_deploy_exchange = await deploy_exchangeV2(provider, owner, receiver, BigInt(argv.fee))
      await op_deploy_exchange.confirmation()
      console.log(op_deploy_exchange.contract)
      break

    case 'set_validator':
      console.log("set validator")
      const arg : TransactionArg = {
        destination: argv.contract,
        entrypoint: "setValidator",
        parameter: { string: argv.validator }
      }
      const op_set_validator = await send(provider, arg)
      await op_set_validator.confirmation()
      console.log(op_set_validator.hash)
      break

    case 'update_operators_for_all':
      console.log('update operators for all')
      const arg_update : TransactionArg = {
        destination: argv.contract,
        entrypoint: "update_operators_for_all",
        parameter: [ { prim: 'Left', args : [ { string: argv.operator } ] } ]
      }
      const op_update = await send(provider, arg_update)
      await op_update.confirmation()
      console.log(op_update.hash)
      break

  }
}


main()
