export interface TransferProxies {
  nft: string;
  fa_1_2: string;
}

export interface Config {
  exchange: string;
  proxies: TransferProxies;
  fees: bigint;
}
