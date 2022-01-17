type account = {
  alias: string;
  edsk: string;
  edpk: string;
  tz1: string;
}

type collection = {
  col_kt1: string;
  col_alias: string;
  col_kind: [ `nft | `mt ];
  col_privacy: [ `pub | `priv ];
  col_admin: account;
  col_source: account;
  col_royalties_contract: string;
  col_metadata: string;
}

type item = {
  it_collection: string;
  it_owner: account;
  it_kind: [`nft | `mt of Z.t ];
  it_token_id: Z.t;
  it_royalties: (string * int64) list;
  it_metadata: (string * string) list;
}
