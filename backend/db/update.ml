let upgrade_1_to_2 dbh version =
  EzPG.upgrade ~dbh ~version
    ~downgrade:[
      "drop table orders";
      "drop table match_orders";
      "drop table token_updates";
      "drop table contract_updates";
      "drop table accounts";
      "drop table contracts";
      "drop table tokens";
      "drop table state";
    ] [
    {|create table state(
      admin_wallet varchar not null default '',
      last_updated timestamp not null default now(),
      last_block varchar not null default '',
      royalties_contract varchar not null default '',
      exchange_v2_contract varchar not null default '',
      validator_contract varchar not null default '',
      fees_receiver jsonb[] not null default '{}',
      protocol_fee bigint)|};

    {|create table contracts(
      kind varchar not null,
      address varchar primary key,
      owner varchar not null,
      block varchar not null,
      level int not null,
      main boolean not null default false,
      last timestamp not null,
      tokens_number bigint not null default 0,
      ledger_id bigint not null default 0,
      metadata jsonb not null default '{}')|};

    {|create table tokens(
      contract varchar not null,
      token_id bigint not null,
      block varchar not null,
      level int not null,
      main boolean not null default false,
      last timestamp not null,
      transaction varchar not null,
      owner varchar not null,
      amount bigint not null,
      supply bigint not null,
      operators varchar[] not null default '{}',
      metadata jsonb not null default '{}',
      royalties jsonb[] not null default '{}',
      primary key (contract, owner, token_id))|};

    {|create table accounts(
      address varchar primary key,
      block varchar not null,
      level int not null,
      main boolean not null default false,
      last timestamp not null,
      tokens jsonb[] not null default '{}')|};

    {|create table contract_updates(
      transaction varchar not null,
      id varchar not null,
      block varchar not null,
      level int not null,
      main boolean not null default false,
      tsp timestamp not null,
      contract varchar not null,
      mint jsonb,
      burn jsonb,
      uri varchar,
      primary key (transaction, id))|};

    {|create table token_updates(
      transaction varchar not null,
      id varchar not null,
      block varchar not null,
      level int not null,
      main boolean not null default false,
      tsp timestamp not null,
      source varchar not null,
      destination varchar,
      operator varchar,
      add boolean,
      contract varchar not null,
      token_id bigint,
      amount bigint,
      metadata jsonb,
      primary key (transaction, id))|};

    {|create table orders(
      maker varchar not null,
      taker varchar,
      make_asset_type_class varchar not null,
      make_asset_type_contract varchar,
      make_asset_type_token_id varchar,
      make_asset_value bigint not null,
      take_asset_type_class varchar not null,
      take_asset_type_contract varchar,
      take_asset_type_token_id varchar,
      take_asset_value bigint not null,
      fill bigint not null,
      start_date timestamp,
      end_date timestamp,
      make_stock bigint not null,
      cancelled boolean not null,
      salt varchar not null,
      signature varchar not null,
      created_at timestamp not null,
      last_update_at timestamp not null,
      hash varchar primary key,
      make_balance bigint,
      make_price_usd float,
      take_price_usd float)|};

    {|create table origin_fees(
      account varchar not null,
      value int not null,
      hash varchar not null references orders(hash) on delete cascade,
      primary key (hash, account))|};

    {|create table payouts(
      account varchar not null,
      value int not null,
      hash varchar not null references orders(hash) on delete cascade)|};

    {|create table order_pending(
      type varchar not null,
      make_asset_type_class varchar,
      make_asset_type_contract varchar,
      make_asset_type_token_id varchar,
      make_asset_value bigint,
      take_asset_type_class varchar,
      take_asset_type_contract varchar,
      take_asset_type_token_id varchar,
      take_asset_value bigint,
      date timestamp not null,
      maker varchar,
      side varchar,
      fill bigint,
      taker varchar,
      counter_hash varchar,
      make_usd float,
      take_usd float,
      make_price_usd float,
      take_price_usd float,
      hash varchar not null references orders(hash) on delete cascade)|};

    {|create table order_price_history(
      date timestamp not null,
      make_value bigint not null,
      take_value bigint not null,
      hash varchar not null references orders(hash) on delete cascade)|};

    {|create table match_orders(
      hash1 varchar not null references orders(hash),
      hash2 varchar not null references orders(hash),
      primary key (hash1, hash2))|};
  ]

let upgrades =
  let last_version = fst List.(hd @@ rev !Versions.upgrades) in
  !Versions.upgrades @ [
    last_version + 1, upgrade_1_to_2;
  ]

let () =
  EzPGUpdater.main Cconfig.database ~upgrades
