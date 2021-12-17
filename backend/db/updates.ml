let upgrade_1_to_2 dbh version =
  EzPG.upgrade ~dbh ~version
    ~downgrade:[
      "drop table orders";
      "drop table match_orders";
      "drop table token_updates";
      "drop table contract_updates";
      "drop table contracts";
      "drop table tokens";
      "drop table state";
    ] [
    {|create table state(
      royalties varchar not null default '',
      exchange varchar not null default '',
      transfer_manager varchar not null default '')|};

    {|create table ft_contracts(
      address varchar primary key,
      kind varchar not null,
      ledger_id varchar not null,
      ledger_key jsonb,
      ledger_value jsonb,
      crawled boolean not null default false,
      decimals int not null default 0,
      token_id varchar)|};

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
      last_token_id zarith not null default '0',
      ledger_id varchar not null,
      ledger_key jsonb,
      ledger_value jsonb,
      metadata jsonb not null default '{}',
      name varchar,
      symbol varchar,
      minters varchar[],
      uri_pattern varchar,
      counter zarith not null default 0,
      metadata_id varchar)|};

    {|create table tzip21_creators(
      contract varchar not null,
      token_id varchar not null,
      block varchar not null,
      level int not null,
      tsp timestamp not null,
      main boolean not null default false,
      account varchar not null,
      value int not null,
      primary key (account, contract, token_id))|};

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
      data_rate_unit varchar,
      primary key (uri, contract, token_id))|};

    {|create table tzip21_attributes(
      contract varchar not null,
      token_id varchar not null,
      block varchar not null,
      level int not null,
      tsp timestamp not null,
      main boolean not null default false,
      name varchar not null,
      value jsonb not null,
      type varchar,
      primary key(name, contract, token_id))|};

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
      owner varchar not null,
      amount zarith not null,
      balance zarith,
      primary key (contract, owner, token_id))|};

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
      metadata_key varchar,
      metadata_value varchar,
      minter jsonb,
      uri_pattern varchar,
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
      amount zarith,
      royalties jsonb,
      metadata jsonb,
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
      balance zarith,
      unique (block, index, contract, token_id, account))|};

    {|create table orders(
      maker varchar not null,
      maker_edpk varchar not null,
      taker varchar,
      taker_edpk varchar,
      make_asset_type_class varchar not null,
      make_asset_type_contract varchar,
      make_asset_type_token_id varchar,
      make_asset_value zarith not null,
      make_asset_decimals int,
      take_asset_type_class varchar not null,
      take_asset_type_contract varchar,
      take_asset_type_token_id varchar,
      take_asset_value zarith not null,
      take_asset_decimals int,
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
      make_value zarith not null,
      take_value zarith not null,
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
      amount zarith not null,
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
      fill_make_value zarith not null,
      fill_take_value zarith not null,
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
      id varchar not null,
      match_left varchar,
      match_right varchar,
      hash varchar,
      transaction varchar,
      block varchar,
      level int,
      main boolean not null default false,
      date timestamp not null,
      order_activity_type varchar not null)|};

    {|create table token_info(
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
      supply zarith not null default 0,
      metadata jsonb not null default '{}',
      metadata_uri varchar,
      royalties jsonb not null default '{}',
      creators jsonb[] not null default '{}',
      primary key (contract, token_id))|};

  ]

let upgrade_2_to_3 dbh version =
  EzPG.upgrade ~dbh ~version
    ~downgrade:[
      "alter table contracts drop column metadata_id";
      "alter table contracts rename column token_metadata_id to metadata_id";
    ] [
    "alter table contracts rename column metadata_id to token_metadata_id";
    "alter table contracts add column metadata_id varchar";
  ]

let upgrades =
  let last_version = fst List.(hd @@ rev !Versions.upgrades) in
  !Versions.upgrades @ [
    last_version + 1, upgrade_1_to_2;
    last_version + 2, upgrade_2_to_3;
  ]
