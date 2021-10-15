import { Provider, transfer, mint, burn, deploy_fa2, deploy_royalties, upsert_order, bid, sell, Part, AssetType, OrderForm, SellRequest, BidRequest, ExtendedAssetType, XTZAssetType, FA12AssetType, TokenAssetType, approve, fill_order, get_public_key, order_of_json, salt, pk_to_pkh, get_address } from "../main"
import { beacon_provider } from '../providers/beacon/beacon_provider'
import JSONFormatter from "json-formatter-js"
import Vue from "vue"

function parse_parts(s : string) : Array<Part> {
  if (s == '') s = '{}'
  const json = JSON.parse(s) as { [key:string] : number }
  const parts : Array<Part> = []
  Object.keys(json).forEach(
    function(k : string) : void {
      parts.push({account: k, value: BigInt(json[k])})
    })
  return parts
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
  } else if (r.asset_class == 'FA_1_2' && (r.contract || (r.contract == 'custom' && r.contract_custom))) {
    return {
      asset_class: 'FA_1_2',
      contract: (r.contract=='custom') ? r.contract_custom : r.contract
    }
  } else if (r.asset_class == 'FA_2' && (r.contract || (r.contract == 'custom' && r.contract_custom))) {
    return {
      asset_class: 'FA_2',
      contract: (r.contract=='custom') ? r.contract_custom : r.contract,
      token_id: BigInt(r.token_id)
    }
  } else if (r.asset_class == 'Unknown' && (r.contract || (r.contract == 'custom' && r.contract_custom))) {
    return {
      contract: (r.contract=='custom') ? r.contract_custom : r.contract,
      token_id: BigInt(r.token_id)
    }
  } else return undefined
}

function parse_asset_value(r: RawAssetType, value: number) : bigint {
  if (r.asset_class == 'XTZ' || r.asset_class == 'FA_1_2') return BigInt(value * 1000000.)
  else return BigInt(value)
}

async function provider(node: string, api:string) : Promise<Provider> {
  const tezos = await beacon_provider({node})
  const config = {
    exchange: "KT1XgQ52NeNdjo3jLpbsPBRfg8YhWoQ5LB7g",
    fees: 300n
  }
  return { tezos, api, config }
}

export default new Vue({
  el: "#app",
  data: {
    api_url: "http://localhost:8080/v0.1/",
    node: 'https://granada.tz.functori.com',
    provider: undefined as Provider | undefined,
    path: "home",
    transfer : {
      contract: '',
      token_id: '',
      destination: '',
      amount: 1,
      result: '',
      status: 'info'
    },
    mint: {
      contract: '',
      contract_custom: '',
      royalties: '',
      amount: 1,
      token_id: '' as string | undefined,
      metadata: '',
      result: '',
      status: 'info'
    },
    burn: {
      contract: '',
      contract_custom: '',
      amount: 1,
      token_id: '',
      result: '',
      status: 'info'
    },
    deploy: {
      fa2_owner: '',
      royalties_contract: '',
      royalties_contract_custom: '',
      fa2_result: '',
      fa2_status: 'info',
      royalties_owner: '',
      royalties_result: '',
      royalties_status: 'info'
    },
    approve: {
      asset_type: {
        asset_class: 'FA_2',
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
          asset_class: 'FA_2',
          contract: '',
          contract_custom: '',
          token_id: 0,
        },
        value: 1
      },
      take: {
        asset_type: {
          asset_class: 'FA_2',
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
        asset_class: 'FA_2',
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
        asset_class: 'FA_2',
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
    royalties_contracts: new Set<string>(),
    fa2_contracts: new Set<StorageContract>()
  },

  async created() {
    const r = await fetch("/config.json")
    if (r.ok) {
      const r2 = await r.json()
      if (r2.royalties_contracts) r2.royalties_contracts.forEach((c : string) => this.royalties_contracts.add(c))
      if (r2.fa2_contracts) r2.fa2_contracts.forEach((c : StorageContract) => this.fa2_contracts.add(c))
      if (r2.api_url) { this.api_url = r2.api_url }
      if (r2.node) { this.node = r2.node }
    }
    const royalties_contracts_s = localStorage.getItem('royalties_contracts')
    if (royalties_contracts_s && Array.isArray(royalties_contracts_s))
      JSON.parse(royalties_contracts_s).forEach((c : string) => this.royalties_contracts.add(c))
    const fa2_contracts_s = localStorage.getItem('fa2_contracts')
    if (fa2_contracts_s && Array.isArray(fa2_contracts_s))
      JSON.parse(fa2_contracts_s).forEach((c : StorageContract) => this.fa2_contracts.add(c))
    localStorage.setItem('royalties_contracts', JSON.stringify(Array.from(this.royalties_contracts)))
    localStorage.setItem('fa2_contracts', JSON.stringify(Array.from(this.fa2_contracts)))

  },

  computed: {
    royalties_contracts_options() {
      let options = []
      for (let c of this.royalties_contracts) {
        options.push({ text: c.substr(0,10), value: c })
      }
      options.push({text:'Custom', value:'custom'})
      return options
    },
    fa2_contracts_options() {
      let options = []
      for (let c of this.fa2_contracts) {
        options.push({ text: c.contract.substr(0,10) + ' - ' + c.owner.substr(0,10), value: c.contract })
      }
      options.push({text:'Custom', value:'custom'})
      return options
    }
  },

  methods: {
    async ftransfer() {
      this.transfer.status = 'info'
      this.transfer.result = ''
      if (!this.transfer.contract) {
        this.transfer.status = 'danger'
        this.transfer.result = "no contract given"
      } else if (!this.transfer.token_id) {
        this.transfer.status = 'danger'
        this.transfer.result = "no token id given"
      } else {
        if (!this.transfer.amount) this.transfer.amount = 1
        const p = (this.provider) ? this.provider : await provider(this.node, this.api_url)
        this.provider = p
        const op = await transfer(
          p,
          { asset_class: "FA_2",
            contract: this.transfer.contract,
            token_id: BigInt(this.transfer.token_id) },
          this.transfer.destination,
          BigInt(this.transfer.amount))
        this.transfer.result = `operation ${op.hash} injected`
        await op.confirmation()
        this.transfer.status = 'success'
        this.transfer.result = `operation ${op.hash} confirmed`
      }
    },

    async fmint() {
      this.mint.status = 'info'
      this.mint.result = ''
      if (!this.mint.contract) {
        this.mint.status = 'danger'
        this.mint.result = "no contract given"
      } else {
        if (!this.mint.royalties) this.mint.royalties = '{}'
        if (!this.mint.amount) this.mint.amount = 1
        if (this.mint.token_id=='') this.mint.token_id = undefined
        const p = (this.provider) ? this.provider : await provider(this.node, this.api_url)
        this.provider = p
        const royalties0 = JSON.parse(this.mint.royalties) as { [key:string] : number }
        const royalties : { [key:string] : bigint } = {}
        const contract = (this.mint.contract=="custom") ? this.mint.contract_custom : this.mint.contract
        Object.keys(royalties0).forEach(
          function(k : string) : void {
            royalties[k] = BigInt(royalties0[k])
          })
        const metadata = (this.mint.metadata) ? JSON.parse(this.mint.metadata) : undefined
        const token_id = (this.mint.token_id!=undefined) ? BigInt(this.mint.token_id) : undefined
        const op = await mint(p, contract, royalties, BigInt(this.mint.amount), token_id, metadata)
        this.mint.result = `operation ${op.hash} injected`
        await op.confirmation()
        this.mint.status = 'success'
        this.mint.result = `operation ${op.hash} confirmed`
      }
    },

    async fburn() {
      this.burn.status = 'info'
      this.burn.result = ''
      if (!this.burn.contract) {
        this.burn.status = 'danger'
        this.burn.result = "no contract given"
      } else if (!this.burn.token_id) {
        this.burn.status = 'danger'
        this.burn.result = "no token id given"
      } else {
        if (!this.burn.amount) this.burn.amount = 1
        const contract = (this.burn.contract=="custom") ? this.burn.contract_custom : this.burn.contract
        const p = (this.provider) ? this.provider : await provider(this.node, this.api_url)
        this.provider = p
        const op = await burn(
          p, { asset_class: "FA_2",
               contract: contract,
               token_id: BigInt(this.burn.token_id) }, BigInt(this.burn.amount))
        this.burn.result = `operation ${op.hash} injected`
        await op.confirmation()
        this.burn.status = 'success'
        this.burn.result = `operation ${op.hash} confirmed`
      }
    },

    async deploy_fa2() {
      this.deploy.fa2_status = 'info'
      this.deploy.fa2_result = ''
      if (!this.deploy.fa2_owner) {
        this.deploy.fa2_status = 'danger'
        this.deploy.fa2_result = "no owner given"
      } else if (!this.deploy.royalties_contract) {
        this.deploy.fa2_status = 'danger'
        this.deploy.fa2_result = "no royalties contract given"
      } else {
        const p = (this.provider) ? this.provider : await provider(this.node, this.api_url)
        this.provider = p
        const contract = (this.deploy.royalties_contract=='custom') ? this.deploy.royalties_contract_custom : this.deploy.royalties_contract
        const op = await deploy_fa2(
          p, this.deploy.fa2_owner, contract)
        this.deploy.fa2_result = `operation ${op.hash} injected`
        await op.confirmation()
        this.deploy.fa2_status = 'success'
        if (op.contract) {
          this.deploy.fa2_result = `operation ${op.hash} confirmed -> new contract: ${op.contract}`
          this.fa2_contracts.add({contract: op.contract, owner: this.deploy.fa2_owner })
          localStorage.setItem('fa2_contracts', JSON.stringify(this.fa2_contracts))
        } else {
          this.deploy.fa2_result = `operation ${op.hash} confirmed`
        }
      }
    },

    async deploy_royalties() {
      this.deploy.royalties_status = 'info'
      this.deploy.royalties_result = ''
      if (!this.deploy.royalties_owner) {
        this.deploy.royalties_status = 'danger'
        this.deploy.royalties_result = "no owner given"
      } else {
        const p = (this.provider) ? this.provider : await provider(this.node, this.api_url)
        this.provider = p
        const op = await deploy_royalties(
          p, this.deploy.royalties_owner)
        this.deploy.royalties_result = `operation ${op.hash} injected`
        await op.confirmation()
        this.deploy.royalties_status = 'success'
        if (op.contract) {
          this.deploy.royalties_result = `operation ${op.hash} confirmed -> new contract: ${op.contract}`
          this.royalties_contracts.add(op.contract)
          localStorage.setItem('royalties_contracts', JSON.stringify(this.royalties_contracts))
        } else {
          this.deploy.royalties_result = `operation ${op.hash} confirmed`
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
        const p = (this.provider) ? this.provider : await provider(this.node, this.api_url)
        this.provider = p
        const owner = await p.tezos.address()
        const op = await approve(p, owner, { asset_type, value: BigInt(this.approve.value) })
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
      const p = (this.provider) ? this.provider : await provider(this.node, this.api_url)
      this.provider = p
      const maker = this.upsert.maker || await get_public_key(p)
      if (!maker) {
        this.upsert.status = 'danger'
        this.upsert.result = "no maker given"
      } else {
        const make_asset_type = parse_asset_type(this.upsert.make.asset_type) as AssetType
        const take_asset_type = parse_asset_type(this.upsert.take.asset_type) as AssetType
        const make_value = parse_asset_value(this.upsert.make.asset_type, this.upsert.make.value)
        const take_value = parse_asset_value(this.upsert.take.asset_type, this.upsert.take.value)
        let payouts = parse_parts(this.upsert.payouts)
        if (payouts.length == 0) payouts = [ { account: pk_to_pkh(maker), value: 10000n} ]
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
            maker,
            taker: (this.upsert.maker) ? this.upsert.maker : undefined,
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
      const p = (this.provider) ? this.provider : await provider(this.node, this.api_url)
      this.provider = p
      const maker = this.upsert.maker || await get_public_key(p)
      if (!maker) {
        this.sell.status = 'danger'
        this.sell.result = "no maker given"
      } else {
        const make_asset_type = parse_asset_type(this.sell.make_asset_type) as ExtendedAssetType
        const take_asset_type = parse_asset_type(this.sell.take_asset_type) as XTZAssetType | FA12AssetType
        const amount = BigInt(this.sell.amount)
        const price = BigInt(this.sell.price * 1000000.)
        let payouts = parse_parts(this.sell.payouts)
        if (payouts.length == 0) payouts = [ { account: pk_to_pkh(maker), value: 10000n} ]
        const origin_fees = parse_parts(this.sell.origin_fees)
        if (!make_asset_type) {
          this.sell.status = 'danger'
          this.sell.result = "invalid make asset"
        } else if (!take_asset_type) {
          this.sell.status = 'danger'
          this.sell.result = "invalid take asset"
        } else {
          const p = (this.provider) ? this.provider : await provider(this.node, this.api_url)
          this.provider = p
          const request : SellRequest = {
            maker,
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
      const p = (this.provider) ? this.provider : await provider(this.node, this.api_url)
      this.provider = p
      const maker = this.bid.maker || await get_public_key(p)
      if (!maker) {
        this.bid.status = 'danger'
        this.bid.result = "no maker given"
      } else {
        const make_asset_type = parse_asset_type(this.bid.make_asset_type) as XTZAssetType | FA12AssetType
        const take_asset_type = parse_asset_type(this.bid.take_asset_type) as ExtendedAssetType
        const amount = BigInt(this.bid.amount)
        const price = BigInt(this.bid.price * 1000000.)
        let payouts = parse_parts(this.bid.payouts)
        if (payouts.length == 0) payouts = [ { account: pk_to_pkh(maker), value: 10000n} ]
        const origin_fees = parse_parts(this.bid.origin_fees)
        if (!make_asset_type) {
          this.bid.status = 'danger'
          this.bid.result = "invalid make asset"
        } else if (!take_asset_type) {
          this.bid.status = 'danger'
          this.bid.result = "invalid take asset"
        } else {
          const p = (this.provider) ? this.provider : await provider(this.node, this.api_url)
          this.provider = p
          const request : BidRequest = {
            maker,
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
        const p = (this.provider) ? this.provider : await provider(this.node, this.api_url)
        this.provider = p
        let payouts = parse_parts(this.upsert.payouts)
        const origin_fees = parse_parts(this.upsert.origin_fees)
        let account = await get_address(p)
        if (payouts.length == 0) payouts = [ { account, value: 10000n} ]
        const op = await fill_order(p, this.fill.selected, {
          amount: BigInt(this.fill.amount),
          payouts, origin_fees
        })
        this.fill.result = `operation ${op.hash} injected`
        await op.confirmation()
        this.fill.status = 'success'
        this.fill.result = `operation ${op.hash} confirmed`
      }
    }
  }
})
