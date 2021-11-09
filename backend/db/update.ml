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

    {|create table ft_contracts(
      address varchar primary key,
      kind varchar not null,
      ledger_id varchar not null,
      ledger_key jsonb,
      ledger_value jsonb,
      crawled boolean not null default false)|};

    {|create table contracts(
      kind varchar not null,
      address varchar primary key,
      owner varchar,
      block varchar not null,
      level int not null,
      tsp timestamp not null,
      main boolean not null default false,
      last_block varchar not null,
      last_level int not null,
      last timestamp not null,
      tokens_number bigint not null default 0,
      next_token_id varchar not null default 0,
      ledger_id varchar not null,
      ledger_key jsonb,
      ledger_value jsonb,
      metadata jsonb not null default '{}',
      name varchar,
      symbol varchar)|};

    {|create table tzip21_creators(
      contract varchar not null,
      token_id varchar not null,
      block varchar not null,
      level int not null,
      tsp timestamp not null,
      main boolean not null default false,
      account varchar not null,
      value int not null,
      primary key (contract, token_id))|};

    {|create table tzip21_formats(
      contract varchar not null,
      token_id varchar not null,
      block varchar not null,
      level int not null,
      tsp timestamp not null,
      main boolean not null default false,
      uri varchar not null,
      hash varchar,
      mime_type varchar,
      file_size int,
      file_name varchar,
      duration varchar ,
      dimensions_value varchar,
      dimensions_unit varchar,
      data_rate_value varchar,
      data_rate_unit varchar)|};

    {|create table tzip21_attributes(
      contract varchar not null,
      token_id varchar not null,
      block varchar not null,
      level int not null,
      tsp timestamp not null,
      main boolean not null default false,
      name varchar not null,
      value varchar not null,
      type varchar)|};

    {|create table tzip21_metadata(
      contract varchar not null,
      token_id varchar not null,
      block varchar not null,
      level int not null,
      tsp timestamp not null,
      main boolean not null default false,
      name varchar,
      symbol varchar,
      decimals int,
      artifact_uri varchar,
      display_uri varchar,
      thumbnail_uri varchar,
      description varchar,
      minter varchar,
      is_boolean_amount boolean,
      tags varchar[],
      contributors varchar[],
      publishers varchar[],
      date timestamp,
      block_level int,
      genres varchar[],
      language varchar,
      rights varchar,
      right_uri varchar,
      is_transferable boolean,
      should_prefer_symbol boolean,
      primary key (contract, token_id))|};

    {|create table royalties(
      contract varchar primary key,
      token_id varchar,
      block varchar not null,
      level int not null,
      tsp timestamp not null,
      main boolean not null default false,
      account varchar not null,
      value int not null)|};

    {|create table tokens(
      contract varchar not null,
      token_id varchar not null,
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
      balance bigint,
      operators varchar[] not null default '{}',
      metadata jsonb not null default '{}',
      royalties jsonb not null default '{}',
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
      transfer_index int not null default 0,
      source varchar not null,
      destination varchar,
      operator varchar,
      add boolean,
      contract varchar not null,
      token_id varchar,
      amount bigint,
      metadata jsonb,
      royalties jsonb,
      primary key (block, index, transfer_index))|};

    {|create table token_balance_updates(
      transaction varchar not null,
      index int not null,
      block varchar not null,
      level int not null,
      main boolean not null default false,
      tsp timestamp not null,
      kind varchar not null,
      contract varchar not null,
      token_id varchar not null,
      account varchar,
      balance bigint,
      unique (block, index, contract, token_id, account))|};

    {|create table orders(
      maker varchar not null,
      maker_edpk varchar not null,
      taker varchar,
      taker_edpk varchar,
      make_asset_type_class varchar not null,
      make_asset_type_contract varchar,
      make_asset_type_token_id varchar,
      make_asset_value varchar not null,
      take_asset_type_class varchar not null,
      take_asset_type_contract varchar,
      take_asset_type_token_id varchar,
      take_asset_value varchar not null,
      start_date timestamp,
      end_date timestamp,
      salt varchar not null,
      signature varchar not null,
      created_at timestamp not null,
      last_update_at timestamp not null,
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
      make_value varchar not null,
      take_value varchar not null,
      hash varchar not null references orders(hash) on delete cascade)|};

    {|create table nft_activities(
      activity_type varchar not null,
      transaction varchar,
      index int not null,
      block varchar not null,
      level int not null,
      main boolean not null default false,
      date timestamp not null,
      contract varchar not null,
      token_id varchar not null,
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
      transfer_index int not null default 0,
      source varchar,
      destination varchar,
      contract varchar not null,
      amount bigint not null,
      primary key (block, index, transfer_index))|};

  ]

let upgrades =
  let last_version = fst List.(hd @@ rev !Versions.upgrades) in
  !Versions.upgrades @ [
    last_version + 1, upgrade_1_to_2;
  ]

let () =
  EzPGUpdater.main Cconfig.database ~upgrades
