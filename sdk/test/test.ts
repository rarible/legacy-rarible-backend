import { deploy_nft_public, mint, make_permit, add_permit, send } from "../main"
import { in_memory_provider } from '../providers/in_memory/in_memory_provider'
import BigNumber from "@taquito/rpc/node_modules/bignumber.js"

// edsk3UUamwmemNBJgDvS8jXCgKsvjL2NoTwYRFpGSRPut4Hmfs6dG8 Mxs
// edsk4RqeRTrhdKfJKBTndA9x1RLp4A3wtNL1iMFRXDvfs5ANeZAncZ ibJ
// edsk368NmXyps5vKts1TrFTTAgReC5VN9NtPmL9Er86XUdHm2yWiaU aMw
async function main() {

  try {
    const config = {
      exchange: "KT1KkUufmRPjK6SBNZVvAYniAY5F9czYmgwu",
      fees: new BigNumber(0),
      nft_public: "",
      mt_public: "",
    }

    const tezos_u6h = in_memory_provider(
      'edsk4CmgW9r4fwqtsT6x2bB7BdVcERxLPt6poFXGpk1gTKbqR43G5H',
      'https://hangzhou.tz.functori.com')
    const provider_u6h = {
      tezos: tezos_u6h,
      api: "https://rarible-api.functori.com/v0.1/",
      config
    }

  // await mint(provider, "KT1VYBd25dw5GjYqPM8T8My6b4g5c4cd4hwu", {tz1ibJRnL6hHjAfmEzM7QtGyTsS6ZtHdgE2S: 10000n}, 100n, 101n)

  // const st : StorageFA2 = await storage(provider, "KT1WUJBk5T53bfNLncG2csWo4y8pFSteBvQL")
  // const r = await st.operator_for_all.get({0: "KT1XgQ52NeNdjo3jLpbsPBRfg8YhWoQ5LB7g", 1: "tz1ibJRnL6hHjAfmEzM7QtGyTsS6ZtHdgE2S"})
  // console.log(r)

    // transfer(provider, { asset_class: "FA_2", contract: "KT1WUJBk5T53bfNLncG2csWo4y8pFSteBvQL", token_id: BigInt(1) }, "tz1iQ3DU476h5EUULD1e5yfuiYyk1JNR6HbY", BigInt(50)).then(console.log).catch(console.log)

    // burn(provider, { asset_class: "FA_2", contract: "KT1MWv7oH8JJhxJJs8co21XiByBEAYx2QDjY", token_id: 1n }, 1n)

  // get_balance(provider, await tezos.address(), { asset_class: 'XTZ' }).then(console.log)

    // check_asset_type(provider, {contract:"KT18ewjrhWB9ZZFYZkBACHxVEPuTtCg2eXPF", token_id: new BigNumber(6)}).then(console.log)

    // const op = await deploy_nft_public(provider_mxs, await provider_mxs.tezos.address())
    // const op = await mint(
    //   provider_mxs, "KT1GYa864wjMe61cdtW1UowweC7YHrH6rWb4", {}, undefined, new BigNumber(0))
    // const {transfer, permit} = await make_permit(
    //   provider_mxs, "KT1GYa864wjMe61cdtW1UowweC7YHrH6rWb4",
    //   [ { destination: "tz1ibJRnL6hHjAfmEzM7QtGyTsS6ZtHdgE2S", token_id: new BigNumber(0) } ])

    // const op = await add_permit(provider_amw, permit)

    const op = await send(provider_u6h, {
      destination: "KT1JPYtEMv8PHXfmLoMuWRLsVykoEou5AqKG",
      entrypoint: 'setRoyalties',
      parameter: [ {string: 'KT1Ex1FBFh8JeGwNU3uZNrV4afU7LoUgLWEK' }, {prim: "Some", args: [{int: '0'}]}, [] ]
    })
    console.log(op)
    await op.confirmation()

  } catch (e) {
    console.error(e)
  }

}

main()
