<template>
  <div id="app">
      <b-navbar sticky toggleable="sm" type="dark" variant="dark">
        <b-navbar-brand @click="path='home'" class="px-2">
          <img src="/rarible-logo.png" alt="Rarible" width="30"/>
        </b-navbar-brand>
        <b-navbar-toggle target="nav-collapse"></b-navbar-toggle>
        <b-collapse id="nav-collapse" is-nav>
          <b-navbar-nav>
            <b-nav-item :active="path=='tokens'" @click="path='tokens'">Tokens</b-nav-item>
            <b-nav-item :active="path=='orders'" @click="path='orders'">Orders</b-nav-item>
            <b-nav-item :active="path=='api'" @click="path='api'">API</b-nav-item>
          </b-navbar-nav>
          <b-navbar-nav class="ms-auto">
            <b-input-group prepend="Node" class="mx-2">
              <b-form-input size="sm" v-model="node"></b-form-input>
            </b-input-group>
            <b-input-group prepend="API" class="mx-2">
              <b-form-input size="sm" v-model="api_url"></b-form-input>
            </b-input-group>
          </b-navbar-nav>
        </b-collapse>
      </b-navbar>

      <b-container v-if="path=='home'" class="mt-4">
        <h3 class="text-center mt-5 pt-5">
          Rarible SDK Example
        </h3>
      </b-container>

      <b-container v-if="path=='tokens'" class="mt-4">
        <b-tabs justified>

          <b-tab title="Deploy" class="mt-4">
            <div>
              <b-form-group label="Owner *" class="mb-2">
                <b-form-input v-model="deploy.fa2_owner"></b-form-input>
              </b-form-group>
              <b-form-group label="Royalties Contract *" class="mb-2">
                <b-form-select v-model="deploy.royalties_contract" :options="royalties_contracts_options"></b-form-select>
                <b-form-input v-if="deploy.royalties_contract=='custom'" v-model="deploy.royalties_contract_custom" class="mt-2"></b-form-input>
              </b-form-group>
              <div class="text-center" class="mb-2">
                <b-button class="m-2" @click="deploy_fa2()">
                  Deploy FA2
                </b-button>
              </div>
              <div :class="'text-center text-'+deploy.fa2_status">{{ deploy.fa2_result }}</div>
            </div>
            <div class="mt-4">
              <b-form-group label="Owner *" class="mb-2">
                <b-form-input v-model="deploy.royalties_owner"></b-form-input>
              </b-form-group>
              <div class="text-center" class="mb-2">
                <b-button class="m-2" @click="deploy_royalties()">
                  Deploy Royalties
                </b-button>
              </div>
              <div :class="'text-center text-'+deploy.royalties_status">{{ deploy.royalties_result }}</div>
            </div>
          </b-tab>

          <b-tab title="Mint" class="mt-4">
            <b-form-group label="Contract *" class="mb-2">
              <b-form-select v-model="mint.contract" :options="fa2_contracts_options"></b-form-select>
              <b-form-input v-if="mint.contract=='custom'" v-model="mint.contract_custom" class="mt-2"></b-form-input>
            </b-form-group>
            <b-form-group label="Token ID" class="mb-2">
              <b-form-input v-model="mint.token_id"></b-form-input>
            </b-form-group>
            <b-form-group label="Amount" class="mb-2">
              <b-form-input v-model="mint.amount" type="number"></b-form-input>
            </b-form-group>
            <b-form-group label="Royalties" description="{ &quot;tz1...&quot;: 42, ... }" class="mb-2">
              <b-form-input v-model="mint.royalties"></b-form-input>
            </b-form-group>
            <b-form-group label="Metadata" class="mb-2">
              <b-form-input v-model="mint.metadata"></b-form-input>
            </b-form-group>
            <div class="text-center" class="mb-2">
              <b-button class="m-2" @click="fmint()">
                Mint
              </b-button>
            </div>
            <div :class="'text-center text-'+mint.status">{{ mint.result }}</div>
          </b-tab>

          <b-tab title="Burn" class="mt-4">
            <b-form-group label="Contract *" class="mb-2">
              <b-form-select v-model="burn.contract" :options="fa2_contracts_options"></b-form-select>
              <b-form-input v-if="burn.contract=='custom'" v-model="burn.contract_custom" class="mt-2"></b-form-input>
            </b-form-group>
            <b-form-group label="Token ID *" class="mb-2">
              <b-form-input v-model="burn.token_id"></b-form-input>
            </b-form-group>
            <b-form-group label="Amount" class="mb-2">
              <b-form-input v-model="burn.amount" type="number"></b-form-input>
            </b-form-group>
            <div class="text-center" class="mb-2">
              <b-button class="m-2" @click="fburn()">
                Burn
              </b-button>
            </div>
            <div :class="'text-center text-'+burn.status">{{ burn.result }}</div>
          </b-tab>

          <b-tab title="Transfer" class="mt-4">
            <b-form-group label="Contract *" class="mb-2">
              <b-form-select v-model="transfer.contract" :options="fa2_contracts_options"></b-form-select>
              <b-form-input v-if="transfer.contract=='custom'" v-model="transfer.contract_custom" class="mt-2"></b-form-input>
            </b-form-group>
            <b-form-group label="Token ID *" class="mb-2">
              <b-form-input v-model="transfer.token_id"></b-form-input>
            </b-form-group>
            <b-form-group label="Destination *" class="mb-2">
              <b-form-input v-model="transfer.destination"></b-form-input>
            </b-form-group>
            <b-form-group label="Amount" class="mb-2">
              <b-form-input v-model="transfer.amount" type="number"></b-form-input>
            </b-form-group>
            <div class="text-center" class="mb-2">
              <b-button class="m-2" @click="ftransfer()">
                Transfer
              </b-button>
            </div>
            <div :class="'text-center text-'+transfer.status">{{ transfer.result }}</div>
          </b-tab>

          <b-tab title="Approve" class="mt-4">
            <b-form-group label="Class *" class="mb-2">
              <b-form-select v-model="approve.asset_type.asset_class" :options="['FA_1_2', 'FA_2']"></b-form-select>
            </b-form-group>
            <b-form-group label="Contract *" class="mb-2">
              <b-form-select v-model="approve.asset_type.contract" :options="fa2_contracts_options" :disabled="approve.asset_type.asset_class=='XTZ'"></b-form-select>
              <b-form-input v-if="approve.asset_type.contract=='custom'" v-model="approve.asset_type.contract_custom" class="mt-2"></b-form-input>
            </b-form-group>
            <b-form-group label="Token ID" class="mb-2">
              <b-form-input v-model="approve.asset_type.token_id" :disabled="approve.asset_type.asset_class!='FA_2'">
              </b-form-input>
            </b-form-group>
            <b-form-group label="Value" class="mb-2">
              <b-form-input v-model="approve.value"></b-form-input>
            </b-form-group>

            <div class="text-center" class="mb-2">
              <b-button class="m-2" @click="fapprove()">
                Approve
              </b-button>
            </div>
            <div :class="'text-center text-'+approve.status">{{ approve.result }}</div>
          </b-tab>

        </b-tabs>
      </b-container>

      <b-container v-if="path=='orders'" class="mt-4">

        <b-tabs justified>

          <b-tab title="Upsert" class="mt-4">
            <b-form-group label="Maker" class="mb-2">
              <b-form-input v-model="upsert.maker"></b-form-input>
            </b-form-group>
            <b-form-group label="Taker" class="mb-2">
              <b-form-input v-model="upsert.taker"></b-form-input>
            </b-form-group>
            <b-form-group label="Make Asset *" class="mb-2">
              <b-input-group>
                <b-input-group-text>Class</b-input-group-text>
                <b-form-select v-model="upsert.make.asset_type.asset_class" :options="['XTZ', 'FA_1_2', 'FA_2']"></b-form-select>
                <b-input-group-text>Contract</b-input-group-text>
                <b-form-select v-model="upsert.make.asset_type.contract" :options="fa2_contracts_options" :disabled="upsert.make.asset_type.asset_class=='XTZ'"></b-form-select>
                <b-form-input v-if="upsert.make.asset_type.contract=='custom'" v-model="upsert.make.asset_type.contract_custom" :disabled="upsert.make.asset_type.asset_class=='XTZ'"></b-form-input>
                <b-input-group-text>Token ID</b-input-group-text>
                <b-form-input v-model="upsert.make.asset_type.token_id" :disabled="upsert.make.asset_type.asset_class!='FA_2'" type="number"></b-form-input>
                <b-input-group-text>Value</b-input-group-text>
                <b-form-input v-model="upsert.make.value" type="number"></b-form-input>
              </b-input-group>
            </b-form-group>
            <b-form-group label="Take Asset *" class="mb-2">
              <b-input-group>
                <b-input-group-text>Class</b-input-group-text>
                <b-form-select v-model="upsert.take.asset_type.asset_class" :options="['XTZ', 'FA_1_2', 'FA_2']"></b-form-select>
                <b-input-group-text>Contract</b-input-group-text>
                <b-form-select v-model="upsert.take.asset_type.contract" :options="fa2_contracts_options" :disabled="upsert.take.asset_type.asset_class=='XTZ'"></b-form-select>
                <b-form-input v-if="upsert.take.asset_type.contract=='custom'" v-model="upsert.take.asset_type.contract_custom" :disabled="upsert.take.asset_type.asset_class=='XTZ'"></b-form-input>
                <b-input-group-text>Token ID</b-input-group-text>
                <b-form-input v-model="upsert.take.asset_type.token_id" :disabled="upsert.take.asset_type.asset_class!='FA_2'" type="number"></b-form-input>
                <b-input-group-text>Value</b-input-group-text>
                <b-form-input v-model="upsert.take.value" type="number"></b-form-input>
              </b-input-group>
            </b-form-group>
            <b-form-group label="Payouts" class="mb-2" description="{ &quot;tz1...&quot;: 42, ... }">
              <b-form-input v-model="upsert.payouts"></b-form-input>
            </b-form-group>
            <b-form-group label="Origin Fees" class="mb-2" description="{ &quot;tz1...&quot;: 42, ... }">
              <b-form-input v-model="upsert.origin_fees"></b-form-input>
            </b-form-group>

            <div class="text-center" class="mb-2">
              <b-button class="m-2" @click="fupsert_order()">
                Upsert
              </b-button>
            </div>
            <div v-if="upsert.result" :class="'text-center text-'+upsert.status">{{ upsert.result }}</div>
            <div id="upsert-result" :class="'text-'+upsert.status"></div>
          </b-tab>

          <b-tab title="Sell" class="mt-4">
            <b-form-group label="Maker" class="mb-2">
              <b-form-input v-model="sell.maker"></b-form-input>
            </b-form-group>
            <b-form-group label="Make Asset Type *" class="mb-2">
              <b-input-group>
                <b-input-group-text>Class</b-input-group-text>
                <b-form-select v-model="sell.make_asset_type.asset_class" :options="['XTZ', 'FA_1_2', 'FA_2', 'Unknown']"></b-form-select>
                <b-input-group-text>Contract</b-input-group-text>
                <b-form-select v-model="sell.make_asset_type.contract" :options="fa2_contracts_options" :disabled="sell.make_asset_type.asset_class=='XTZ'"></b-form-select>
                <b-form-input v-if="sell.make_asset_type.contract=='custom'" v-model="sell.make_asset_type.contract_custom" :disabled="sell.make_asset_type.asset_class=='XTZ'"></b-form-input>
                <b-input-group-text>Token ID</b-input-group-text>
                <b-form-input v-model="sell.make_asset_type.token_id" :disabled="sell.make_asset_type.asset_class in ['XTZ', 'FA_1_2']" type="number"></b-form-input>
              </b-input-group>
            </b-form-group>
            <b-form-group label="Take Asset Type *" class="mb-2">
              <b-input-group>
                <b-input-group-text>Class</b-input-group-text>
                <b-form-select v-model="sell.take_asset_type.asset_class" :options="['XTZ', 'FA_1_2']"></b-form-select>
                <b-input-group-text>Contract</b-input-group-text>
                <b-form-select v-model="sell.take_asset_type.contract" :options="fa2_contracts_options" :disabled="sell.take_asset_type.asset_class=='XTZ'"></b-form-select>
                <b-form-input v-if="sell.take_asset_type.contract=='custom'" v-model="sell.take_asset_type.contract_custom" :disabled="sell.take_asset_type.asset_class=='XTZ'"></b-form-input>
              </b-input-group>
            </b-form-group>
            <b-form-group label="Amount *" class="mb-2">
              <b-form-input v-model="sell.amount" type="number"></b-form-input>
            </b-form-group>
            <b-form-group label="Price *" class="mb-2">
              <b-form-input v-model="sell.price" type="number"></b-form-input>
            </b-form-group>
            <b-form-group label="Payouts" class="mb-2" description="{ &quot;tz1...&quot;: 42, ... }">
              <b-form-input v-model="sell.payouts"></b-form-input>
            </b-form-group>
            <b-form-group label="Origin Fees" class="mb-2" description="{ &quot;tz1...&quot;: 42, ... }">
              <b-form-input v-model="sell.origin_fees"></b-form-input>
            </b-form-group>

            <div class="text-center" class="mb-2">
              <b-button class="m-2" @click="sell_order()">
                Sell
              </b-button>
            </div>
            <div v-if="sell.result" :class="'text-center text-'+sell.status">{{ sell.result }}</div>
            <div id="sell-result" :class="'text-'+sell.status"></div>
          </b-tab>

          <b-tab title="Bid" class="mt-4">
            <b-form-group label="Maker" class="mb-2">
              <b-form-input v-model="bid.maker"></b-form-input>
            </b-form-group>
            <b-form-group label="Make Asset Type *" class="mb-2">
              <b-input-group>
                <b-input-group-text>Class</b-input-group-text>
                <b-form-select v-model="bid.make_asset_type.asset_class" :options="['XTZ', 'FA_1_2']"></b-form-select>
                <b-input-group-text>Contract</b-input-group-text>
                <b-form-select v-model="bid.make_asset_type.contract" :options="fa2_contracts_options" :disabled="bid.make_asset_type.asset_class=='XTZ'"></b-form-select>
                <b-form-input v-if="bid.make_asset_type.contract=='custom'" v-model="bid.make_asset_type.contract_custom" :disabled="bid.make_asset_type.asset_class=='XTZ'"></b-form-input>
              </b-input-group>
            </b-form-group>
            <b-form-group label="Take Asset Type *" class="mb-2">
              <b-input-group>
                <b-input-group-text>Class</b-input-group-text>
                <b-form-select v-model="bid.take_asset_type.asset_class" :options="['XTZ', 'FA_1_2', 'FA_2', 'Unknown']"></b-form-select>
                <b-input-group-text>Contract</b-input-group-text>
                <b-form-select v-model="bid.take_asset_type.contract" :options="fa2_contracts_options" :disabled="bid.take_asset_type.asset_class=='XTZ'"></b-form-select>
                <b-form-input v-if="bid.take_asset_type.contract=='custom'" v-model="bid.take_asset_type.contract_custom" :disabled="bid.take_asset_type.asset_class=='XTZ'"></b-form-input>
                <b-input-group-text>Token ID</b-input-group-text>
                <b-form-input v-model="bid.take_asset_type.token_id" :disabled="bid.take_asset_type.asset_class in ['XTZ', 'FA_1_2']" type="number"></b-form-input>
              </b-input-group>
            </b-form-group>
            <b-form-group label="Amount *" class="mb-2">
              <b-form-input v-model="bid.amount" type="number"></b-form-input>
            </b-form-group>
            <b-form-group label="Price *" class="mb-2">
              <b-form-input v-model="bid.price" type="number"></b-form-input>
            </b-form-group>
            <b-form-group label="Payouts" class="mb-2" description="{ &quot;tz1...&quot;: 42, ... }">
              <b-form-input v-model="bid.payouts"></b-form-input>
            </b-form-group>
            <b-form-group label="Origin Fees" class="mb-2" description="{ &quot;tz1...&quot;: 42, ... }">
              <b-form-input v-model="bid.origin_fees"></b-form-input>
            </b-form-group>
            <div class="text-center" class="mb-2">
              <b-button class="m-2" @click="bid_order()">
                Bid
              </b-button>
            </div>
            <div v-if="bid.result" :class="'text-center text-'+bid.status">{{ bid.result }}</div>
            <div id="bid-result" :class="'text-'+bid.status"></div>
          </b-tab>

          <b-tab title="Fill" @click="get_orders()">
            <b-table selectable :fields="fill.fields" :items="fill.orders" select-mode="single" class="mt-4" @row-selected="onselected" ref="orders_table">
              <template #cell(make_class)="data">
                {{ data.item.make.asset_type.asset_class }}
              </template>
              <template #cell(make_contract)="data">
                {{ data.item.make.asset_type.contract || '--'  }}
              </template>
              <template #cell(make_token_id)="data">
                {{ (data.item.make.asset_type.token_id==undefined) ? '--' : data.item.make.asset_type.token_id }}
              </template>
              <template #cell(make_value)="data">
                {{ (data.item.make.asset_type.asset_class=='FA_2') ? data.item.make.value : Number(data.item.make.value / 1000000n) + Number(data.item.make.value % 1000000n) / Number(1000000n) }}
              </template>
              <template #cell(take_class)="data">
                {{ data.item.take.asset_type.asset_class }}
              </template>
              <template #cell(take_contract)="data">
                {{ data.item.take.asset_type.contract || '--'  }}
              </template>
              <template #cell(take_token_id)="data">
                {{ (data.item.take.asset_type.token_id==undefined) ? '--' : data.item.take.asset_type.token_id }}
              </template>
              <template #cell(take_value)="data">
                {{ (data.item.take.asset_type.asset_class=='FA_2') ? data.item.take.value : Number(data.item.take.value / 1000000n) + Number(data.item.take.value % 1000000n) / Number(1000000n) }}
              </template>
            </b-table>
            <div v-if="fill.get_result!=''" class="text-center text-danger">{{ fill.get_result }}</div>
            <b-form-group label="Amount" class="mb-2">
              <b-form-input v-model="fill.amount" type="number"></b-form-input>
            </b-form-group>
            <b-form-group label="Payouts" class="mb-2" description="{ &quot;tz1...&quot;: 42, ... }">
              <b-form-input v-model="fill.payouts"></b-form-input>
            </b-form-group>
            <b-form-group label="Origin Fees" class="mb-2" description="{ &quot;tz1...&quot;: 42, ... }">
              <b-form-input v-model="fill.origin_fees"></b-form-input>
            </b-form-group>

            <div class="text-center" class="mb-2">
              <b-button class="m-2" @click="ffill_order()">
                Fill
              </b-button>
            </div>
            <div :class="'text-center text-'+fill.status">{{ fill.result }}</div>
          </b-tab>

        </b-tabs>
      </b-container>


      <b-container v-if="path=='api'" class="mt-4">
        <b-form-group label="Path *" class="mb-2">
          <b-form-input v-model="api.path"></b-form-input>
        </b-form-group>
        <b-form-group label="Data" class="mb-2">
          <b-form-textarea v-model="api.data"></b-form-textarea>
        </b-form-group>
        <div class="text-center" class="mb-2">
          <b-button class="m-2" @click="api_request()">
            Request
          </b-button>
        </div>
        <div v-if="api.result" :class="'text-center text-'+api.status">{{ api.result }}</div>
        <div id="api-request-result"></div>
      </b-container>

  </div>
</template>

<script lang="ts">


import { Provider, transfer, mint, burn, deploy_fa2, deploy_royalties, upsert_order, bid, sell, Part, AssetType, OrderForm, SellRequest, BidRequest, ExtendedAssetType, XTZAssetType, FA12AssetType, TokenAssetType, approve, fill_order, get_public_key, order_of_json, salt, pk_to_pkh, get_address } from "../../sdk/main"
import { beacon_provider } from '../../sdk/providers/beacon/beacon_provider'
import JSONFormatter from "json-formatter-js"
import Vue from "vue"

function parse_parts(s : string) : Array<Part> {
  try {
    if (s == '') s = '{}'
    const json = JSON.parse(s) as { [key:string] : number }
    const parts : Array<Part> = []
    Object.keys(json).forEach(
        function(k : string) : void {
          parts.push({account: k, value: BigInt(json[k])})
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
declare module "*.vue" {
  import Vue from "vue";
  export default Vue;
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
    fees: BigInt(300)
  }
  return { tezos, api, config }
}

export default {
  name: "App",

  data: function(): any {
    return {
      api_url: "http://localhost:8080/v0.1/",
      node: 'https://granada.tz.functori.com',
      provider: undefined as any,
      path: "home",
      transfer : {
        contract: '',
        contract_custom: '',
        token_id: '',
        destination: '',
        amount: 1,
        result: '',
        status: 'info'
      } as any,
      mint: {
        contract: '',
        contract_custom: '',
        royalties: '',
        amount: 1,
        token_id: '' as string | undefined,
        metadata: '',
        result: '',
        status: 'info'
      } as any,
      burn: {
        contract: '',
        contract_custom: '',
        amount: 1,
        token_id: '',
        result: '',
        status: 'info'
      } as any,
      deploy: {
        fa2_owner: '',
        royalties_contract: '',
        royalties_contract_custom: '',
        fa2_result: '',
        fa2_status: 'info',
        royalties_owner: '',
        royalties_result: '',
        royalties_status: 'info'
      } as any,
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
      } as any,
      api: {
        path: '',
        data: '',
        result: '',
        status: undefined as string | undefined
      } as any,
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
      } as any,
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
      } as any,
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
      } as any,
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
      } as any,
      royalties_contracts: new Set<string>(),
      fa2_contracts: new Set<StorageContract>()
    }
  },

  async created() {
    const r = await fetch("/config.json")
    const royalties_contracts: any = this.royalties_contracts
    if (r.ok) {
      const r2 = await r.json()
      if (r2.royalties_contracts) r2.royalties_contracts.forEach((c : string) => royalties_contracts.add(c))
      if (r2.fa2_contracts) r2.fa2_contracts.forEach((c : StorageContract) => this.fa2_contracts.add(c))
      if (r2.api_url) { this.api_url = r2.api_url }
      if (r2.node) { this.node = r2.node }
    }
    const royalties_contracts_s = localStorage.getItem('royalties_contracts')
    if (royalties_contracts_s && Array.isArray(royalties_contracts_s))
      JSON.parse(royalties_contracts_s).forEach((c : string) => royalties_contracts.add(c))
    const fa2_contracts_s = localStorage.getItem('fa2_contracts')
    if (fa2_contracts_s && Array.isArray(fa2_contracts_s))
      JSON.parse(fa2_contracts_s).forEach((c : StorageContract) => this.fa2_contracts.add(c))
    localStorage.setItem('royalties_contracts', JSON.stringify(Array.from(royalties_contracts)))
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
      const transfer: any = this.transfer
      transfer.status = 'info'
      transfer.result = ''
      if (!transfer.contract) {
        transfer.status = 'danger'
        transfer.result = "no contract given"
      } else if (!transfer.token_id) {
        transfer.status = 'danger'
        transfer.result = "no token id given"
      } else {
        if (!transfer.amount) transfer.amount = 1
        const p = (this.provider) ? this.provider : await provider(this.node, this.api_url)
        this.provider = p
        const contract = (transfer.contract=="custom") ? transfer.contract_custom : transfer.contract
        const op = await transfer(
            p,
            { asset_class: "FA_2",
              contract: contract,
              token_id: BigInt(transfer.token_id) },
            transfer.destination,
            BigInt(transfer.amount))
        transfer.result = `operation ${op.hash} injected`
        await op.confirmation()
        transfer.status = 'success'
        transfer.result = `operation ${op.hash} confirmed`
      }
    },

    async fmint() {
      const mint: any = this.mint
      mint.status = 'info'
      mint.result = ''
      if (!mint.contract) {
        mint.status = 'danger'
        mint.result = "no contract given"
      } else {
        if (!mint.royalties) mint.royalties = '{}'
        if (!mint.amount) mint.amount = 1
        if (mint.token_id=='') mint.token_id = undefined
        const p = (this.provider) ? this.provider : await provider(this.node, this.api_url)
        this.provider = p
        const royalties0 = JSON.parse(mint.royalties) as { [key:string] : number }
        const royalties : { [key:string] : bigint } = {}
        const contract = (mint.contract=="custom") ? mint.contract_custom : mint.contract
        Object.keys(royalties0).forEach(
            function(k : string) : void {
              royalties[k] = BigInt(royalties0[k])
            })
        const metadata = (mint.metadata) ? JSON.parse(mint.metadata) : undefined
        const token_id = (mint.token_id!=undefined) ? BigInt(mint.token_id) : undefined
        const op = await mint(p, contract, royalties, BigInt(mint.amount), token_id, metadata)
        mint.result = `operation ${op.hash} injected`
        await op.confirmation()
        mint.status = 'success'
        mint.result = `operation ${op.hash} confirmed`
      }
    },

    async fburn() {
      const burn: any = this.burn
      burn.status = 'info'
      burn.result = ''
      if (!burn.contract) {
        burn.status = 'danger'
        burn.result = "no contract given"
      } else if (!burn.token_id) {
        burn.status = 'danger'
        burn.result = "no token id given"
      } else {
        if (!burn.amount) burn.amount = 1
        const contract = (burn.contract=="custom") ? burn.contract_custom : burn.contract
        const p = (this.provider) ? this.provider : await provider(this.node, this.api_url)
        this.provider = p
        const op = await burn(
            p, { asset_class: "FA_2",
              contract: contract,
              token_id: BigInt(burn.token_id) }, BigInt(burn.amount))
        burn.result = `operation ${op.hash} injected`
        await op.confirmation()
        burn.status = 'success'
        burn.result = `operation ${op.hash} confirmed`
      }
    },

    async deploy_fa2() {
      const deploy: any = this.deploy
      deploy.fa2_status = 'info'
      deploy.fa2_result = ''
      if (!deploy.fa2_owner) {
        deploy.fa2_status = 'danger'
        deploy.fa2_result = "no owner given"
      } else if (!deploy.royalties_contract) {
        deploy.fa2_status = 'danger'
        deploy.fa2_result = "no royalties contract given"
      } else {
        const p = (this.provider) ? this.provider : await provider(this.node, this.api_url)
        this.provider = p
        const contract = (deploy.royalties_contract=='custom') ? deploy.royalties_contract_custom : deploy.royalties_contract
        const op = await deploy_fa2(
            p, deploy.fa2_owner, contract)
        deploy.fa2_result = `operation ${op.hash} injected`
        await op.confirmation()
        deploy.fa2_status = 'success'
        if (op.contract) {
          deploy.fa2_result = `operation ${op.hash} confirmed -> new contract: ${op.contract}`
          this.fa2_contracts.add({contract: op.contract, owner: deploy.fa2_owner })
          localStorage.setItem('fa2_contracts', JSON.stringify(this.fa2_contracts))
        } else {
          deploy.fa2_result = `operation ${op.hash} confirmed`
        }
      }
    },

    async deploy_royalties() {
      const deploy: any = this.deploy

      deploy.royalties_status = 'info'
      deploy.royalties_result = ''
      if (!deploy.royalties_owner) {
        deploy.royalties_status = 'danger'
        deploy.royalties_result = "no owner given"
      } else {
        const p = (this.provider) ? this.provider : await provider(this.node, this.api_url)
        this.provider = p
        const op = await deploy_royalties(
            p, deploy.royalties_owner)
        deploy.royalties_result = `operation ${op.hash} injected`
        await op.confirmation()
        deploy.royalties_status = 'success'
        if (op.contract) {
          deploy.royalties_result = `operation ${op.hash} confirmed -> new contract: ${op.contract}`
          this.royalties_contracts.add(op.contract)
          localStorage.setItem('royalties_contracts', JSON.stringify(this.royalties_contracts))
        } else {
          deploy.royalties_result = `operation ${op.hash} confirmed`
        }
      }
    },

    async fapprove() {
      const approve: any = this.approve

      approve.status = 'info'
      approve.result = ''
      const asset_type = parse_asset_type(approve.asset_type) as TokenAssetType
      if (!asset_type) {
        approve.status = 'danger'
        approve.result = "invalid asset type"
      } else {
        const p = (this.provider) ? this.provider : await provider(this.node, this.api_url)
        this.provider = p
        const owner = await p.tezos.address()
        const op = await approve(p, owner, { asset_type, value: BigInt(approve.value) })
        if (!op) {
          approve.status = 'warning'
          approve.result = "asset already approved"
        } else {
          approve.result = `operation ${op.hash} injected`
          await op.confirmation()
          approve.status = 'success'
          approve.result = `operation ${op.hash} confirmed`
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
      const maker_edpk = this.upsert.maker || await get_public_key(p)
      if (!maker_edpk) {
        this.upsert.status = 'danger'
        this.upsert.result = "no maker given"
      } else {
        const make_asset_type = parse_asset_type(this.upsert.make.asset_type) as AssetType
        const take_asset_type = parse_asset_type(this.upsert.take.asset_type) as AssetType
        const make_value = parse_asset_value(this.upsert.make.asset_type, this.upsert.make.value)
        const take_value = parse_asset_value(this.upsert.take.asset_type, this.upsert.take.value)
        let payouts = parse_parts(this.upsert.payouts)
        if (payouts.length == 0) payouts = [ { account: pk_to_pkh(maker_edpk), value: BigInt(10000)} ]
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
      const p = (this.provider) ? this.provider : await provider(this.node, this.api_url)
      this.provider = p
      const maker_edpk = this.upsert.maker || await get_public_key(p)
      if (!maker_edpk) {
        this.sell.status = 'danger'
        this.sell.result = "no maker given"
      } else {
        const maker = pk_to_pkh(maker_edpk)
        const make_asset_type = parse_asset_type(this.sell.make_asset_type) as ExtendedAssetType
        const take_asset_type = parse_asset_type(this.sell.take_asset_type) as XTZAssetType | FA12AssetType
        const amount = BigInt(this.sell.amount)
        const price = BigInt(this.sell.price * 1000000.)
        let payouts = parse_parts(this.sell.payouts)
        if (payouts.length == 0) payouts = [ { account: maker, value: BigInt(10000)} ]
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
      const p = (this.provider) ? this.provider : await provider(this.node, this.api_url)
      this.provider = p
      const maker_edpk = this.bid.maker || await get_public_key(p)
      if (!maker_edpk) {
        this.bid.status = 'danger'
        this.bid.result = "no maker given"
      } else {
        const maker = pk_to_pkh(maker_edpk)
        const make_asset_type = parse_asset_type(this.bid.make_asset_type) as XTZAssetType | FA12AssetType
        const take_asset_type = parse_asset_type(this.bid.take_asset_type) as ExtendedAssetType
        const amount = BigInt(this.bid.amount)
        const price = BigInt(this.bid.price * 1000000.)
        let payouts = parse_parts(this.bid.payouts)
        if (payouts.length == 0) payouts = [ { account: pk_to_pkh(maker), value: BigInt(10000)} ]
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
      const fill: any = this.fill
      const continuation = (fill.continuation) ? '?' + fill.continuation : ''
      try {
        const r = await fetch(this.api_url + "/orders/all" + continuation)
        if (!r.ok) {
          fill.status = 'danger'
          fill.get_result = r.statusText
        } else {
          const res = await r.json()
          fill.orders = res.orders.map(order_of_json)
          fill.continuation = res.continuation
        }
      } catch(error : any) {
        fill.status = 'danger'
        fill.get_result = error.toString()
      }
    },

    onselected(items : any) {
      const fill: any = this.fill

      fill.selected = items[0]
    },

    async ffill_order() {
      this as any
      const fill: any = this.fill
      const upsert: any = this.upsert

      fill.status = 'info'
      fill.result = ''
      if (!fill.selected) {
        fill.status = 'danger'
        fill.result = 'no order selected'
      } else {
        const p = (this.provider) ? this.provider : await provider(this.node, this.api_url)
        this.provider = p
        let payouts = parse_parts(this.upsert.payouts)
        const origin_fees = parse_parts(this.upsert.origin_fees)
        let account = await get_address(p)
        if (payouts.length == 0) payouts = [ { account, value: BigInt(10000)} ]
        const op = await fill_order(p, fill.selected, {
          amount: BigInt(fill.amount),
          payouts, origin_fees
        })
        fill.result = `operation ${op.hash} injected`
        await op.confirmation()
        fill.status = 'success'
        fill.result = `operation ${op.hash} confirmed`
      }
    }
  }
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
