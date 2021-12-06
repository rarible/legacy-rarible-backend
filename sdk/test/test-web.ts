import { Provider, transfer, mint, burn, deploy_nft_private, deploy_mt_private, upsert_order, bid, sell, Part, AssetType, OrderForm, SellRequest, BidRequest, ExtendedAssetType, XTZAssetType, FTAssetType, TokenAssetType, approve_token, fill_order, get_public_key, order_of_json, salt, pk_to_pkh, get_address, OperationResult, sign } from "../main"
import { beacon_provider, BeaconWalletKind } from '../providers/beacon/beacon_provider'
import JSONFormatter from "json-formatter-js"
import Vue from "vue"
import BigNumber from "@taquito/rpc/node_modules/bignumber.js"
import { NetworkType } from "@airgap/beacon-sdk"
import { Networks } from "kukai-embed"
import { kukai_provider } from '../providers/kukai/kukai_provider'

function parse_parts(s : string) : Array<Part> {
  try {
    if (s == '') s = '{}'
    const json = JSON.parse(s) as { [key:string] : number }
    const parts : Array<Part> = []
    Object.keys(json).forEach(
      function(k : string) : void {
        parts.push({account: k, value: new BigNumber(json[k])})
      })
    return parts
  } catch (e) {
    console.error(e)
    throw e
  }

}

interface RawAssetType {
  asset_class: string;
  contract: string;
  contract_custom: string;
  token_id: number;
}

interface StorageContract {
  contract: string,
  owner: string,
}

function parse_asset_type(r : RawAssetType) : AssetType | ExtendedAssetType | undefined {
  if (r.asset_class == 'XTZ') {
    return { asset_class: 'XTZ' }
  } else if (r.asset_class == 'FT' && (r.contract || (r.contract == 'custom' && r.contract_custom))) {
    return {
      asset_class: 'FT',
      contract: (r.contract=='custom') ? r.contract_custom : r.contract
    }
  } else if ((r.asset_class == 'NFT' || r.asset_class == 'MT') && (r.contract || r.contract=='public' || (r.contract == 'custom' && r.contract_custom))) {
    return {
      asset_class: r.asset_class,
      contract: (r.contract=='public') ? undefined : (r.contract=='custom') ? r.contract_custom : r.contract,
      token_id: new BigNumber(r.token_id)
    }
  } else if (r.asset_class == 'Unknown' && (r.contract || (r.contract == 'custom' && r.contract_custom))) {
    return {
      contract: (r.contract=='custom') ? r.contract_custom : r.contract,
      token_id: new BigNumber(r.token_id)
    }
  } else return undefined
}

async function provider(node: string, api:string, wallet:BeaconWalletKind | string) : Promise<Provider> {
  let w = (wallet == '') ? undefined : wallet as BeaconWalletKind
  const tezos = await beacon_provider({node, network: NetworkType.HANGZHOUNET}, undefined, w)
  // const tezos = await kukai_provider({node, network: Networks.dev})
  const config = {
    exchange: "KT1AguExF32Z9UEKzD5nuixNmqrNs1jBKPT8",
    exchange_proxy: "KT1AguExF32Z9UEKzD5nuixNmqrNs1jBKPT8",
    fees: new BigNumber(300),
    nft_public: "",
    mt_public: "",
  }
  return { tezos, api, config }
}

export default new Vue({
  el: "#app",
  data: {
    api_url: "http://localhost:8080/v0.1/",
    node: 'https://hangzhou.tz.functori.com',
    wallet: '' as BeaconWalletKind | string,
    provider: undefined as Provider | undefined,
    path: "home",
    transfer : {
      asset_type: {
        asset_class: 'NFT',
        contract: '',
        contract_custom: '',
        token_id: 0,
      },
      destination: '',
      amount: '',
      result: '',
      status: 'info'
    },
    mint: {
      asset_class: 'NFT',
      contract: '',
      contract_custom: '',
      token_id: '' as undefined | string ,
      royalties: '',
      amount: '',
      metadata: '',
      result: '',
      status: 'info'
    },
    burn: {
      asset_type: {
        asset_class: 'NFT',
        contract: '',
        contract_custom: '',
        token_id: 0,
      },
      amount: '',
      result: '',
      status: 'info'
    },
    deploy: {
      owner: '',
      kind: 'NFT',
      result: '',
      status: 'info',
    },
    approve: {
      asset_type: {
        asset_class: 'NFT',
        contract: '',
        contract_custom: '',
        token_id: 0,
      },
      value: 1,
      status: 'info',
      result: ''
    },
    api: {
      path: '',
      data: '',
      result: '',
      status: undefined as string | undefined
    },
    upsert: {
      maker: '',
      taker: '',
      make: {
        asset_type: {
          asset_class: 'NFT',
          contract: '',
          contract_custom: '',
          token_id: 0,
        },
        value: 1
      },
      take: {
        asset_type: {
          asset_class: 'NFT',
          contract: '',
          contract_custom: '',
          token_id: 0,
        },
        value: 1
      },
      payouts: '',
      origin_fees: '',
      status: 'info',
      result: ''
    },
    sell: {
      maker: '',
      make_asset_type: {
        asset_class: 'NFT',
        contract: '',
        contract_custom: '',
        token_id: 0,
      },
      take_asset_type: {
        asset_class: 'XTZ',
        contract: '',
        contract_custom: '',
        token_id: 0,
      },
      payouts: '',
      origin_fees: '',
      amount: 1,
      price: 1,
      status: 'info',
      result: ''
    },
    bid: {
      maker: '',
      make_asset_type: {
        asset_class: 'XTZ',
        contract: '',
        contract_custom: '',
        token_id: 0,
      },
      take_asset_type: {
        asset_class: 'NFT',
        contract: '',
        contract_custom: '',
        token_id: 0,
      },
      payouts: '',
      origin_fees: '',
      amount: 1,
      price: 1,
      status: 'info',
      result: ''
    },
    fill : {
      continuation: undefined,
      orders: [],
      selected: undefined as any | undefined,
      amount: 1,
      status: 'info',
      result: '',
      get_result: '',
      fields: [ 'make_class', 'make_contract', 'make_token_id', 'make_value', 'take_class', 'take_contract', 'take_token_id', 'take_value' ],
      payouts: '',
      origin_fees: ''
    },
    sign : {
      message: ''
    },
    nft_contracts: new Set<StorageContract>()
  },

  async created() {
    const r = await fetch("/config.json")
    if (r.ok) {
      const r2 = await r.json()
      if (r2.nft_contracts) r2.nft_contracts.forEach((c : StorageContract) => this.nft_contracts.add(c))
      if (r2.api_url) { this.api_url = r2.api_url }
      if (r2.node) { this.node = r2.node }
      if (r2.wallet) { this.wallet = r2.wallet }
    }
    let nft_contracts_s = JSON.parse(localStorage.getItem('nft_contracts') || '[]')
    nft_contracts_s.forEach((c : StorageContract) => this.nft_contracts.add(c))
    localStorage.setItem('nft_contracts', JSON.stringify(Array.from(this.nft_contracts)))
  },

  computed: {
    nft_contracts_options() {
      let options = []
      for (let c of this.nft_contracts) {
        options.push({ text: c.contract.substring(0,10) + ' - ' + c.owner.substring(0,10), value: c.contract })
      }
      options.push({text:'Custom', value:'custom'})
      options.push({text:'Public', value:'public'})
      return options
    }
  },

  methods: {
    async ftransfer() {
      this.transfer.status = 'info'
      this.transfer.result = ''
      const asset_type = parse_asset_type(this.transfer.asset_type) as TokenAssetType
      const p = (this.provider) ? this.provider : await provider(this.node, this.api_url, this.wallet)
      this.provider = p
      const transfer_amount = (this.transfer.amount) ? new BigNumber(this.transfer.amount) : undefined
      const op = await transfer(p, asset_type, this.transfer.destination, transfer_amount)
      this.transfer.result = `operation ${op.hash} injected`
      await op.confirmation()
      this.transfer.status = 'success'
      this.transfer.result = `operation ${op.hash} confirmed`
    },

    async fmint() {
      this.mint.status = 'info'
      this.mint.result = ''
      if (!this.mint.contract) {
        this.mint.status = 'danger'
        this.mint.result = "no contract given"
      } else {
        if (!this.mint.royalties) this.mint.royalties = '{}'
        if (this.mint.token_id=='') this.mint.token_id = undefined
        const p = (this.provider) ? this.provider : await provider(this.node, this.api_url, this.wallet)
        this.provider = p
        const royalties0 = JSON.parse(this.mint.royalties) as { [key:string] : number }
        const royalties : { [key:string] : BigNumber } = {}
        const contract = (this.mint.contract=="custom") ? this.mint.contract_custom : this.mint.contract
        const mint_amount = (this.mint.asset_class=='NFT') ? undefined : new BigNumber(this.mint.amount)
        Object.keys(royalties0).forEach(
          function(k : string) : void {
            royalties[k] = new BigNumber(royalties0[k])
          })
        const metadata = (this.mint.metadata) ? JSON.parse(this.mint.metadata) : undefined
        const token_id = (this.mint.token_id!=undefined) ? new BigNumber(this.mint.token_id) : undefined
        const op = await mint(p, contract, royalties, mint_amount, token_id, metadata)
        this.mint.result = `operation ${op.hash} injected`
        await op.confirmation()
        this.mint.status = 'success'
        this.mint.result = `operation ${op.hash} confirmed`
      }
    },

    async fburn() {
      this.burn.status = 'info'
      this.burn.result = ''
      const asset_type = parse_asset_type(this.burn.asset_type) as TokenAssetType
      const p = (this.provider) ? this.provider : await provider(this.node, this.api_url, this.wallet)
      this.provider = p
      const op = await burn(p, asset_type, (this.burn.amount) ? new BigNumber(this.burn.amount) : undefined)
      this.burn.result = `operation ${op.hash} injected`
      await op.confirmation()
      this.burn.status = 'success'
      this.burn.result = `operation ${op.hash} confirmed`
    },

    async deploy_fa2() {
      this.deploy.status = 'info'
      this.deploy.result = ''
      if (!this.deploy.owner) {
        this.deploy.status = 'danger'
        this.deploy.result = "no owner given"
      } else {
        const p = (this.provider) ? this.provider : await provider(this.node, this.api_url, this.wallet)
        this.provider = p
        let op : OperationResult | undefined ;
        if (this.deploy.kind == 'NFT') op = await deploy_nft_private(p, this.deploy.owner)
        else if (this.deploy.kind == 'MT') op = await deploy_mt_private(p, this.deploy.owner)
        if (!op) {
          this.deploy.status = 'danger'
          this.deploy.result = "kind not understood"
        } else {
          this.deploy.result = `operation ${op.hash} injected`
          await op.confirmation()
          this.deploy.status = 'success'
          if (op.contract) {
            this.deploy.result = `operation ${op.hash} confirmed -> new contract: ${op.contract}`
            this.nft_contracts.add({contract: op.contract, owner: this.deploy.owner })
            localStorage.setItem('nft_contracts', JSON.stringify(Array.from(this.nft_contracts)))
          } else {
            this.deploy.result = `operation ${op.hash} confirmed`
          }
        }
      }
    },

    async fapprove() {
      this.approve.status = 'info'
      this.approve.result = ''
      const asset_type = parse_asset_type(this.approve.asset_type) as TokenAssetType
      if (!asset_type) {
        this.approve.status = 'danger'
        this.approve.result = "invalid asset type"
      } else {
        const p = (this.provider) ? this.provider : await provider(this.node, this.api_url, this.wallet)
        this.provider = p
        const owner = await p.tezos.address()
        const op = await approve_token(p, owner, { asset_type, value: new BigNumber(this.approve.value) })
        if (!op) {
          this.approve.status = 'warning'
          this.approve.result = "asset already approved"
        } else {
          this.approve.result = `operation ${op.hash} injected`
          await op.confirmation()
          this.approve.status = 'success'
          this.approve.result = `operation ${op.hash} confirmed`
        }
      }
    },

    async api_request() {
      this.api.status = undefined
      const elt = document.getElementById("api-request-result")
      if (!elt) throw new Error('element "api-request-result" not found')
      elt.innerHTML = ''
      const options = (this.api.data)
        ? { method: "POST", headers : { "Content-Type": "application/json" }, body: JSON.stringify(this.api.data) }
        : undefined
      try {
        const r = await fetch(this.api_url + this.api.path, options)
        if (r.ok) {
          const formatter = new JSONFormatter(await r.json(), 3)
          elt.appendChild(formatter.render())
        }
        else {
          this.api.status = 'danger'
          this.api.result = r.statusText
        }
      } catch(e: any) {
        this.api.status = 'danger'
        this.api.result = e.toString()
      }
    },

    async fupsert_order() {
      this.upsert.status = 'info'
      this.upsert.result = ''
      const elt = document.getElementById("upsert-result")
      if (!elt) throw new Error('element "upsert-result" not found')
      elt.innerHTML = ''
      const p = (this.provider) ? this.provider : await provider(this.node, this.api_url, this.wallet)
      this.provider = p
      const maker_edpk = this.upsert.maker || await get_public_key(p)
      if (!maker_edpk) {
        this.upsert.status = 'danger'
        this.upsert.result = "no maker given"
      } else {
        const make_asset_type = parse_asset_type(this.upsert.make.asset_type) as AssetType
        const take_asset_type = parse_asset_type(this.upsert.take.asset_type) as AssetType
        const make_value = new BigNumber(this.upsert.make.value)
        const take_value = new BigNumber(this.upsert.take.value)
        let payouts = parse_parts(this.upsert.payouts)
        if (payouts.length == 0) payouts = [ { account: pk_to_pkh(maker_edpk), value: new BigNumber(10000)} ]
        const origin_fees = parse_parts(this.upsert.origin_fees)
        if (!make_asset_type) {
          this.upsert.status = 'danger'
          this.upsert.result = "invalid make asset"
        } else if (!take_asset_type) {
          this.upsert.status = 'danger'
          this.upsert.result = "invalid take asset"
        } else {
          const order : OrderForm = {
            type: "RARIBLE_V2",
            maker: pk_to_pkh(maker_edpk),
            maker_edpk,
            taker_edpk: (this.upsert.taker) ? this.upsert.taker : undefined,
            taker: (this.upsert.taker) ? pk_to_pkh(this.upsert.taker) : undefined,
            make: { asset_type: make_asset_type, value: make_value },
            take: { asset_type: take_asset_type, value: take_value },
            salt: salt(),
            start: undefined,
            end: undefined,
            signature: undefined,
            data: { data_type: "V1", payouts, origin_fees } }
          try {
            const r = await upsert_order(p, order)
            this.upsert.status = 'success'
            const formatter = new JSONFormatter(r, 3)
            elt.appendChild(formatter.render())
          } catch(e : any) {
            this.upsert.status = 'danger'
            this.upsert.result = e.toString()
          }
        }
      }
    },

    async sell_order() {
      this.sell.status = 'info'
      this.sell.result = ''
      const elt = document.getElementById("sell-result")
      if (!elt) throw new Error('element "sell-result" not found')
      elt.innerHTML = ''
      const p = (this.provider) ? this.provider : await provider(this.node, this.api_url, this.wallet)
      this.provider = p
      const maker_edpk = this.upsert.maker || await get_public_key(p)
      if (!maker_edpk) {
        this.sell.status = 'danger'
        this.sell.result = "no maker given"
      } else {
        const maker = pk_to_pkh(maker_edpk)
        const make_asset_type = parse_asset_type(this.sell.make_asset_type) as ExtendedAssetType
        const take_asset_type = parse_asset_type(this.sell.take_asset_type) as XTZAssetType | FTAssetType
        const amount = new BigNumber(this.sell.amount)
        const price = new BigNumber(this.sell.price)
        let payouts = parse_parts(this.sell.payouts)
        if (payouts.length == 0) payouts = [ { account: maker, value: new BigNumber(10000)} ]
        const origin_fees = parse_parts(this.sell.origin_fees)
        if (!make_asset_type) {
          this.sell.status = 'danger'
          this.sell.result = "invalid make asset"
        } else if (!take_asset_type) {
          this.sell.status = 'danger'
          this.sell.result = "invalid take asset"
        } else {
          const request : SellRequest = {
            maker,
            maker_edpk,
            make_asset_type,
            take_asset_type,
            amount,
            price,
            payouts,
            origin_fees }
          try {
            const r = await sell(p, request)
            this.sell.status = 'success'
            const formatter = new JSONFormatter(r, 3)
            elt.appendChild(formatter.render())
          } catch(e : any) {
            this.sell.status = 'danger'
            this.sell.result = e.toString()
          }
        }
      }
    },

    async bid_order() {
      this.bid.status = 'info'
      this.bid.result = ''
      const elt = document.getElementById("bid-result")
      if (!elt) throw new Error('element "bid-result" not found')
      elt.innerHTML = ''
      const p = (this.provider) ? this.provider : await provider(this.node, this.api_url, this.wallet)
      this.provider = p
      const maker_edpk = this.bid.maker || await get_public_key(p)
      if (!maker_edpk) {
        this.bid.status = 'danger'
        this.bid.result = "no maker given"
      } else {
        const maker = pk_to_pkh(maker_edpk)
        const make_asset_type = parse_asset_type(this.bid.make_asset_type) as XTZAssetType | FTAssetType
        const take_asset_type = parse_asset_type(this.bid.take_asset_type) as ExtendedAssetType
        const amount = new BigNumber(this.bid.amount)
        const price = new BigNumber(this.bid.price)
        let payouts = parse_parts(this.bid.payouts)
        if (payouts.length == 0) payouts = [ { account: pk_to_pkh(maker), value: new BigNumber(10000)} ]
        const origin_fees = parse_parts(this.bid.origin_fees)
        if (!make_asset_type) {
          this.bid.status = 'danger'
          this.bid.result = "invalid make asset"
        } else if (!take_asset_type) {
          this.bid.status = 'danger'
          this.bid.result = "invalid take asset"
        } else {
          const request : BidRequest = {
            maker,
            maker_edpk,
            make_asset_type,
            take_asset_type,
            amount,
            price,
            payouts,
            origin_fees }
          try {
            const r = await bid(p, request)
            this.bid.status = 'success'
            const formatter = new JSONFormatter(r, 3)
            elt.appendChild(formatter.render())
          } catch(e : any) {
            this.bid.status = 'danger'
            this.bid.result = e.toString()
          }
        }
      }
    },

    async get_orders() {
      const continuation = (this.fill.continuation) ? '?' + this.fill.continuation : ''
      try {
        const r = await fetch(this.api_url + "/orders/all" + continuation)
        if (!r.ok) {
          this.fill.status = 'danger'
          this.fill.get_result = r.statusText
        } else {
          const res = await r.json()
          this.fill.orders = res.orders.map(order_of_json)
          this.fill.continuation = res.continuation
        }
      } catch(error : any) {
        this.fill.status = 'danger'
        this.fill.get_result = error.toString()
      }
    },

    onselected(items : any) {
      this.fill.selected = items[0]
    },

    async ffill_order() {
      this.fill.status = 'info'
      this.fill.result = ''
      if (!this.fill.selected) {
        this.fill.status = 'danger'
        this.fill.result = 'no order selected'
      } else {
        const p = (this.provider) ? this.provider : await provider(this.node, this.api_url, this.wallet)
        this.provider = p
        let payouts = parse_parts(this.upsert.payouts)
        const origin_fees = parse_parts(this.upsert.origin_fees)
        let account = await get_address(p)
        if (payouts.length == 0) payouts = [ { account, value: new BigNumber(10000)} ]
        const op = await fill_order(p, this.fill.selected, {
          amount: new BigNumber(this.fill.amount),
          payouts, origin_fees
        })
        this.fill.result = `operation ${op.hash} injected`
        await op.confirmation()
        this.fill.status = 'success'
        this.fill.result = `operation ${op.hash} confirmed`
      }
    },

    async sign_message() {
      const p = (this.provider) ? this.provider : await provider(this.node, this.api_url, this.wallet)
      this.provider = p
      const elt = document.getElementById("sign-result")
      if (!elt) throw new Error('element "sign-result" not found')
      elt.innerHTML = ''
      let r = await sign(p, this.sign.message, "message")
      const formatter = new JSONFormatter(r, 3)
      elt.appendChild(formatter.render())
    },

    async test() {
    }
  }
})
