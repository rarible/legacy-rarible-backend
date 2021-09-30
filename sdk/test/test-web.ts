import { Provider, transfer, mint, burn, deploy_fa2, deploy_royalties } from "../main"
import { beacon_provider } from '../providers/beacon/beacon_provider'
import Vue from "vue"


async function provider(node: string, api:string) : Promise<Provider> {
  const tezos = await beacon_provider({node})
  const config = {
    exchange: "KT1C5kWbfzASApxCMHXFLbHuPtnRaJXE4WMu",
    proxies: { fa_1_2: "", nft: "" },
    fees: 0n
  }
  return { tezos, api, config }
}

export default new Vue({
  el: "#app",
  data: {
    api_url: "https://localhost:8080/v0.1/",
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
      royalties: '',
      amount: 1,
      token_id: '' as string | undefined,
      result: '',
      status: 'info'
    },
    burn: {
      contract: '',
      amount: 1,
      token_id: '',
      result: '',
      status: 'info'
    },
    deploy: {
      fa2_owner: '',
      royalties_contract: '',
      fa2_result: '',
      fa2_status: 'info',
      royalties_owner: '',
      royalties_result: '',
      royalties_status: 'info'
    },
    api: {
      path: '',
      data: '',
      result: '',
      status: undefined as string | undefined
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
        Object.keys(royalties0).forEach(
          function(k : string) : void {
            royalties[k] = BigInt(royalties0[k])
          })
        const token_id = (this.mint.token_id!=undefined) ? BigInt(this.mint.token_id) : undefined
        const op = await mint(
          p, this.mint.contract, royalties, BigInt(this.mint.amount), token_id)
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
        const p = (this.provider) ? this.provider : await provider(this.node, this.api_url)
        this.provider = p
        const op = await burn(
          p, { asset_class: "FA_2",
               contract: this.burn.contract,
               token_id: BigInt(this.burn.token_id) }, BigInt(this.transfer.amount))
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
        const op = await deploy_fa2(
          p, this.deploy.fa2_owner, this.deploy.royalties_contract)
        this.deploy.fa2_result = `operation ${op.hash} injected`
        await op.confirmation()
        this.deploy.fa2_status = 'success'
        this.deploy.fa2_result = `operation ${op.hash} confirmed`
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
        this.deploy.royalties_result = `operation ${op.hash} confirmed`
      }
    },

    async api_request() {
      this.api.status = undefined
      this.api.result = ''
      const options = (this.api.data)
        ? { method: "POST", headers : { "Content-Type": "application/json" }, body: JSON.stringify(this.api.data) }
        : undefined
      const r = await fetch(this.api_url + this.api.path, options)
      if (r.ok) this.api.result = await r.text()
      else {
        this.api.status = 'danger'
        this.api.result = r.statusText
      }
    }
  }
})
