import BigNumber from "@taquito/rpc/node_modules/bignumber.js"

export interface Config {
  exchange: string;
  fees: BigNumber;
  nft_public: string;
  mt_public: string;
}
