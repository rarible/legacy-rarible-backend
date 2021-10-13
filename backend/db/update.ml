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
      ft_fa2 varchar[] not null default '{}',
      ft_fa1 varchar[] not null default '{}',
      protocol_fee bigint)|};

    {|create table contracts(
      kind varchar not null,
      address varchar primary key,
      owner varchar not null,
      block varchar not null,
      level int not null,
      tsp timestamp not null,
      main boolean not null default false,
      last_block varchar not null,
      last_level int not null,
      last timestamp not null,
      tokens_number bigint not null default 0,
      next_token_id bigint not null default 0,
      ledger_id bigint not null default 0,
      metadata jsonb not null default '{}',
      name varchar,
      symbol varchar)|};

    {|create table tokens(
      contract varchar not null,
      token_id bigint not null,
      block varchar not null,
      level int not null,
      tsp timestamp not null,
      transaction varchar not null,
      main boolean not null default false,
      last_block varchar not null,
      last_level int not null,
      last timestamp not null,
      owner varchar not null,
      amount bigint not null,
      supply bigint not null,
      operators varchar[] not null default '{}',
      metadata jsonb not null default '{}',
      royalties jsonb not null default '{}',
      name varchar,
      creators jsonb not null default '{}',
      description varchar,
      attributes jsonb,
      image varchar,
      animation varchar,
      primary key (contract, owner, token_id))|};

    {|create table accounts(
      address varchar primary key,
      main boolean not null default false,
      last_block varchar not null,
      last_level int not null,
      last timestamp not null,
      tokens jsonb[] not null default '{}')|};

    {|create table contract_updates(
      transaction varchar not null,
      index int not null,
      block varchar not null,
      level int not null,
      main boolean not null default false,
      tsp timestamp not null,
      contract varchar not null,
      mint jsonb,
      burn jsonb,
      uri varchar,
      primary key (block, index))|};

    {|create table token_updates(
      transaction varchar not null,
      index int not null,
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
      royalties jsonb,
      primary key (block, index))|};

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
      start_date timestamp,
      end_date timestamp,
      salt varchar not null,
      signature varchar not null,
      created_at timestamp not null,
      last_update_at timestamp not null,
      make_price_usd float not null,
      take_price_usd float not null,
      hash varchar primary key)|};

    {|create table origin_fees(
      account varchar not null,
      value int not null,
      hash varchar not null references orders(hash) on delete cascade,
      primary key (hash, account))|};

    {|create table payouts(
      account varchar not null,
      value int not null,
      hash varchar not null references orders(hash) on delete cascade)|};

    {|create table order_price_history(
      date timestamp not null,
      make_value bigint not null,
      take_value bigint not null,
      hash varchar not null references orders(hash) on delete cascade)|};

    {|create table nft_activities(
      activity_type varchar not null,
      transaction varchar,
      block varchar not null,
      level int not null,
      main boolean not null default false,
      date timestamp not null,
      contract varchar not null,
      token_id bigint not null,
      owner varchar not null,
      amount bigint not null,
      tr_from varchar,
      primary key (transaction, block))|};

    {|create table order_match(
      transaction varchar not null,
      index int not null,
      block varchar not null,
      level int not null,
      main boolean not null default false,
      tsp timestamp not null,
      source varchar not null,
      hash_left varchar not null,
      hash_right varchar not null,
      fill_make_value bigint not null,
      fill_take_value bigint not null,
      primary key (block, index))|};

    {|create table order_cancel(
      transaction varchar not null,
      index int not null,
      block varchar not null,
      level int not null,
      main boolean not null default false,
      tsp timestamp not null,
      source varchar not null,
      cancel varchar,
      primary key (block, index))|};

    {|create table order_activities(
      match_left varchar,
      match_right varchar,
      hash varchar,
      transaction varchar,
      block varchar,
      level int,
      main boolean not null default false,
      date timestamp not null,
      order_activity_type varchar not null)|};

    {|create table ft_tokens(
      contract varchar not null,
      account varchar not null,
      balance bigint not null,
      primary key (contract, account))|};

    {|create table ft_token_updates(
      transaction varchar not null,
      index int not null,
      block varchar not null,
      level int not null,
      main boolean not null default false,
      tsp timestamp not null,
      source varchar not null,
      destination varchar not null,
      contract varchar not null,
      amount bigint not null,
      primary key (block, index))|};

  ]

let upgrades =
  let last_version = fst List.(hd @@ rev !Versions.upgrades) in
  !Versions.upgrades @ [
    last_version + 1, upgrade_1_to_2;
  ]

let () =
  EzPGUpdater.main Cconfig.database ~upgrades
