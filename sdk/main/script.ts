import { transfer, mint, burn, deploy_nft_public, deploy_royalties, set_token_metadata, set_metadata, deploy_exchangeV2, deploy_validator, deploy_fill, send, TransactionArg} from "."
import { in_memory_provider } from '../providers/in_memory/in_memory_provider'
import yargs from 'yargs'
import BigNumber from "@taquito/rpc/node_modules/bignumber.js"

async function main() {
  const argv = await yargs(process.argv.slice(2)).options({
    edsk: {type: 'string', default: 'edsk4CmgW9r4fwqtsT6x2bB7BdVcERxLPt6poFXGpk1gTKbqR43G5H'},
    endpoint: {type: 'string', default: 'https://hangzhou.tz.functori.com'},
    exchange: {type: 'string', default: 'KT1AguExF32Z9UEKzD5nuixNmqrNs1jBKPT8'},
    contract: {type: 'string', default: ''},
    royalties_contract: {type: 'string', default: 'KT1Ebv7msgzT9tRGjcWHMnnb6Rm8mAy6b9dq'},
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
    validator: {type: 'string', default: 'KT1U8NoG9oiBYWtszvQ6WiSJyvmeDxo8ZcoT'},
    operator: {type: 'string', default: ''},
    fill: {type: 'string', default: 'KT1GwQQ2HL8JW931AMod49fmNmS2kfjqAtS7'},
  }).argv

  const token_id_opt = (argv.token_id!=undefined) ? new BigNumber(argv.token_id) : undefined
  const token_id = (argv.token_id!=undefined) ? new BigNumber(argv.token_id) : new BigNumber(0)

  const royalties0 = JSON.parse(argv.royalties) as { [key: string] : number }
  const royalties : { [key: string] : BigNumber } = {};
  if (royalties0) {
    Object.keys(royalties0).forEach(
      function(k : string) : void {
        royalties[k] = new BigNumber(royalties0[k])
      })
  }

  const amount = (argv.amount) ? new BigNumber(argv.amount as number) : undefined
  const metadata = JSON.parse(argv.metadata) as { [_: string] : string }

  const tezos = in_memory_provider(argv.edsk, argv.endpoint)

  const config = {
    exchange: argv.exchange,
    fees: new BigNumber(0),
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
      const op_mint = await mint(provider, argv.contract, royalties, amount, token_id_opt, metadata, argv.owner)
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
      const op_deploy_validator = await deploy_validator(provider, owner, argv.exchange, argv.royalties_contract, argv.fill)
      await op_deploy_validator.confirmation()
      console.log(op_deploy_validator.contract)
      break

    case 'deploy_fill':
      console.log("deploy fill")
      const op_deploy_fill = await deploy_fill(provider, owner)
      await op_deploy_fill.confirmation()
      console.log(op_deploy_fill.contract)
      break

    case 'deploy_exchange':
      console.log("deploy exchange")
      const op_deploy_exchange = await deploy_exchangeV2(provider, owner, receiver, new BigNumber(argv.fee))
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
