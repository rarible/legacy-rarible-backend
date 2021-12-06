import { deploy_fa1, mint, make_permit, add_permit, send, sign, StorageFA1_2, of_hex } from "../main"
import { in_memory_provider } from '../providers/in_memory/in_memory_provider'
import BigNumber from "@taquito/rpc/node_modules/bignumber.js"

// edsk3UUamwmemNBJgDvS8jXCgKsvjL2NoTwYRFpGSRPut4Hmfs6dG8 Mxs
// edsk4RqeRTrhdKfJKBTndA9x1RLp4A3wtNL1iMFRXDvfs5ANeZAncZ ibJ
// edsk368NmXyps5vKts1TrFTTAgReC5VN9NtPmL9Er86XUdHm2yWiaU aMw
// edskRsg6YnXooVuL1mdBfiJYkH2sAbeVTLUxBGNiqhbAc76QwStLg61QDHoxV6F2ckfmWv7uBFSmQgRhoDVfhmGZ4CRnvKLG7W iA1
async function main() {

  try {
    const config = {
      exchange: "KT1KkUufmRPjK6SBNZVvAYniAY5F9czYmgwu",
      exchange_proxy: "KT1KkUufmRPjK6SBNZVvAYniAY5F9czYmgwu",
      fees: new BigNumber(0),
      nft_public: "",
      mt_public: "",
    }

    const tezos = in_memory_provider(
      'edskRsg6YnXooVuL1mdBfiJYkH2sAbeVTLUxBGNiqhbAc76QwStLg61QDHoxV6F2ckfmWv7uBFSmQgRhoDVfhmGZ4CRnvKLG7W',
      'https://hangzhou.tz.functori.com')
    const provider = {
      tezos: tezos,
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

    // const op = await send(provider_u6h, {
    //   destination: "KT1JPYtEMv8PHXfmLoMuWRLsVykoEou5AqKG",
    //   entrypoint: 'setRoyalties',
    //   parameter: [ {string: 'KT1Ex1FBFh8JeGwNU3uZNrV4afU7LoUgLWEK' }, {prim: "Some", args: [{int: '0'}]}, [] ]
    // })

    // const s = await sign(provider, "I would like to save like for itemId: 0xf5de760f2e916647fd766b4ad9e85ff943ce3a2b:16440")
    // console.log(s)
    // const op = await deploy_fa1(provider, await provider.tezos.address(), new BigNumber(1000), 2)

    // const op = await send(provider, {
    //   destination: "KT1XZCojvmT858LXRmgAa7NFqAFkS35hs4fH",
    //   entrypoint: 'approve',
    //   parameter: [ {string: 'tz1iA1KggftRjKtAxQs9QbGra2YdsB5MZmgX' }, {int: "42"} ] })

    // console.log(op)
    // await op.confirmation()

    const st : StorageFA1_2 = await provider.tezos.storage('KT1L5WyeKsBMTvseptzcX9Vtbn7Qw4naW98X')
    const v : any = await st.token_metadata.get('0')
    console.log(v)
    console.log(v[Object.keys(v)[1]].get('decimals'))
    console.log(of_hex(v[Object.keys(v)[1]].get('decimals')))

  } catch (e) {
    console.error(e)
  }

}

main()
