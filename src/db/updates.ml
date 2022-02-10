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
    {|create index token_balance_updates_block_index on token_balance_updates(block)|};

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

let upgrade_3_to_4 dbh version =
  EzPG.upgrade ~dbh ~version
    ~downgrade:[ "alter table contracts drop column royalties_id" ]
    [ "alter table contracts add column royalties_id varchar" ]

let upgrade_4_to_5 dbh version =
  EzPG.upgrade ~dbh ~version
    ~downgrade:
      [ "alter table token_info drop constraint token_info_pkey";
        "alter table token_info drop column id";
        "alter table token_info add constraint token_info_pkey primary key (contract, token_id)";

        "alter table tokens drop column tid";
        "alter table tokens drop column oid";

        "drop index tokens_amount_index";
        "drop index token_info_amount_index";
        "drop index token_info_last_index";
        "drop index token_info_metadata_index";
        "drop index token_info_main_index";
        "drop index token_info_token_id_index";
        "drop index token_info_contract_index"]
    [ "alter table token_info add column id varchar collate \"C\" not null default ''";
      "update token_info set id = concat(contract, ':', token_id)";
      "alter table token_info drop constraint token_info_pkey";
      "alter table token_info add constraint token_info_pkey primary key (id)";
      "alter table token_info alter id set default null";

      "alter table tokens add column tid varchar collate \"C\" not null default ''";
      "update tokens set tid = concat(contract, ':', token_id)";
      "alter table tokens alter tid set default null";
      "alter table tokens add column oid varchar collate \"C\" not null default ''";
      "update tokens set oid = concat(contract, ':', token_id, ':', owner)";
      "alter table tokens alter oid set default null";

      "create index tokens_amount_index on tokens(amount)";
      "create index token_info_last_desc_index on token_info(last desc)";
      "create index token_info_last_index on token_info(last)";
      "create index token_info_metadata_index on token_info(metadata)";
      "create index token_info_main_index on token_info(main)";
      "create index token_info_token_id_index on token_info(token_id)";
      "create index token_info_contract_index on token_info(contract)"]

let upgrade_5_to_6 dbh version =
  EzPG.upgrade ~dbh ~version
    ~downgrade:[
      "alter table tzip21_metadata drop column royalties";
      "alter table token_info drop column royalties_metadata";
    ] [
    "alter table tzip21_metadata add column royalties jsonb";
    "alter table token_info add column royalties_metadata jsonb";
  ]

let upgrade_6_to_7 dbh version =
  EzPG.upgrade ~dbh ~version
    ~downgrade:
      [ "drop index order_date_desc_index";
        "drop index order_transaction_index";
        "drop index order_make_asset_type_class_index";
        "drop index order_take_asset_type_class_index";
        "drop index ft_contracts_token_id_index";
        "drop index order_cancel_cancel_index";
        "drop index order_match_left_index";
        "drop index order_match_right_index";
        "drop index contracts_ledger_key_index";
        "drop index contracts_ledger_value_index";
        "drop index contracts_owner_index";
        "drop index tokens_oid_index";
        "drop index tokens_tid_index";

        "alter table tzip21_attributes drop constraint tzip21_attributes_pkey";
        "alter table tzip21_formats drop constraint tip21_formats_pkey";
        "alter table tzip21_creators drop constraint tzip21_creators_pkey";
        "alter table tzip21_attributes add constraint tzip21_attributes_pkey \
         primary key (name, contract, token_id)";
        "alter table tzip21_formats add constraint tip21_formats_pkey \
         primary key (uri, contract, token_id)";
        "alter table tzip21_creators add constraint tzip21_creators_pkey \
         primary_key (account, contract, token_id)"]
    [ "alter table nft_activities alter transaction set data type varchar collate \"C\"";
      "alter table contracts alter address set data type varchar collate \"C\"";
      "alter table orders alter hash set data type varchar collate \"C\"";
      "alter table order_activities alter id set data type varchar collate \"C\"";

      "alter table tzip21_attributes drop constraint tzip21_attributes_pkey";
      "alter table tzip21_formats drop constraint tzip21_formats_pkey";
      "alter table tzip21_creators drop constraint tzip21_creators_pkey";
      "alter table tokens drop constraint tokens_pkey";
      "alter table tzip21_attributes add constraint tzip21_attributes_pkey \
       primary key (contract, token_id, name)";
      "alter table tzip21_formats add constraint tzip21_formats_pkey \
       primary key (contract, token_id, uri)";
      "alter table tzip21_creators add constraint tzip21_creators_pkey \
       primary key (contract, token_id, account)";
      "alter table tokens add constraint tokens_pkey primary key (contract ,token_id, owner)";

      "create index order_match_transaction_index on order_match(transaction)";
      "create index order_cancel_transaction_index on order_cancel(transaction)";
      "create index order_make_asset_type_class_index on orders(make_asset_type_class)";
      "create index order_take_asset_type_class_index on orders(take_asset_type_class)";
      "create index ft_contracts_token_id_index on ft_contracts(token_id)";
      "create index order_cancel_cancel_index on order_cancel(cancel)";
      "create index order_match_left_index on order_match(hash_left)";
      "create index order_match_right_index on order_match(hash_right)";
      "create index contracts_ledger_key_index on contracts(ledger_key)";
      "create index contracts_ledger_value_index on contracts(ledger_value)";
      "create index contracts_owner_index on contracts(owner)";
      "create index tokens_oid_index on tokens(oid)";
      "create index tokens_tid_index on tokens(tid)";
]

let upgrade_7_to_8 dbh version =
  EzPG.upgrade ~dbh ~version
    ~downgrade:[ "drop table tezos_domains" ] [
    "create table tezos_domains(\
     key varchar not null, \
     owner varchar not null, \
     level int not null, \
     address varchar, \
     expiry_key varchar, \
     token_id varchar, \
     data jsonb not null, \
     internal_data jsonb not null, \
     block varchar not null, \
     blevel int not null, \
     index int not null, \
     tsp timestamp not null, \
     main boolean not null, \
     primary key (key, main))";
    "create index tezos_domains_block_index on tezos_domains(block)";
  ]

let upgrade_8_to_9 dbh version =
  EzPG.upgrade ~dbh ~version
    ~downgrade:[
      "alter table tzip21_metadata drop constraint tzip21_metadata_pkey";
      "alter table tzip21_metadata drop column id";
      "alter table tzip21_metadata add constraint tzip21_metadata_pkey primary key (contract, token_id)";
      "drop index tzip21_metadata_token_id_index";
      "drop index tzip21_metadata_contract_index"]
    [ "alter table tzip21_metadata add column id varchar not null default ''";
      "update tzip21_metadata set id = concat(contract, ':', token_id)";
      "alter table tzip21_metadata drop constraint tzip21_metadata_pkey";
      "alter table tzip21_metadata add constraint tzip21_metadata_pkey primary key (id)";
      "alter table tzip21_metadata alter id set default null";

      "create index tzip21_metadata_token_id_index on tzip21_metadata(token_id)";
      "create index tzip21_metadata_contract_index on tzip21_metadata(contract)"]

let upgrade_9_to_10 dbh version =
  EzPG.upgrade ~dbh ~version
    ~downgrade:[ "drop index token_info_block_index" ] [
    "create index token_info_block_index on token_info(block)" ]

let upgrade_10_to_11 dbh version =
  EzPG.upgrade ~dbh ~version
    ~downgrade:[
      "drop table tzip16_metadata";
      "alter table contracts add column name varchar";
      "alter table contracts add column symbol varchar"] [
    "create table tzip16_metadata(\
     contract varchar primary key, \
     block varchar not null, \
     level int not null, \
     tsp timestamp not null, \
     main boolean not null default false, \
     name varchar,description varchar,version varchar,license jsonb,\
     authors varchar[],homepage varchar,source jsonb,interfaces varchar[],\
     errors jsonb,views jsonb)";
    "alter table contracts drop column name";
    "alter table contracts drop column symbol";
 ]

let upgrade_11_to_12 dbh version =
  EzPG.upgrade ~dbh ~version
    ~downgrade:[
      "alter table origin_fees drop column id";
      "alter table payouts drop column id";
    ] [
    "alter table origin_fees add column id bigserial";
    "alter table payouts add column id bigserial" ]

let upgrade_12_to_13 dbh version =
  EzPG.upgrade ~dbh ~version
    ~downgrade:[
      "alter table state drop column level";
      "alter table state drop column chain_id";
      "alter table state drop column tsp";
    ] [
    "alter table state add column level int not null default 0";
    "alter table state add column chain_id varchar not null default ''";
    "alter table state add column tsp timestamp not null default now()" ]

let upgrade_13_to_14 dbh version =
  EzPG.upgrade ~dbh ~version
    ~downgrade:[
      "drop table creators"
    ] [
    "create table creators(\
     id varchar not null, \
     contract varchar not null, \
     token_id varchar not null, \
     account varchar not null, \
     value int not null, \
     unique (id, account))";
    "create index creators_id_index on creators(id)";
    "create index creators_account_index on creators(account)";
    "insert into creators(id, contract, token_id, account, value) \
     (select id, contract, token_id, c->>'account', (c->>'value')::int \
     from token_info, unnest(creators) c)" ]

let upgrade_14_to_15 dbh version =
  EzPG.upgrade ~dbh ~version
    ~downgrade:[ "alter table contracts drop column crawled" ] [
    "alter table contracts add column crawled boolean not null default true" ]

let upgrade_15_to_16 dbh version =
  EzPG.upgrade ~dbh ~version
    ~downgrade:[ "alter table creators drop column main" ] [
    "alter table creators add column main boolean not null default true";
    "alter table creators add column block varchar not null default ''";
    "alter table creators alter column main set default false";
    "alter table creators alter column block drop default"
  ]

let upgrade_16_to_17 dbh version =
  EzPG.upgrade ~dbh ~version
    ~downgrade:[
      "alter table tzip21_creators drop column id";
      "alter table tzip21_creators drop index tzip21_creators_id_index";
      "alter table tzip21_formats drop column id";
      "alter table tzip21_formats drop index tzip21_formats_id_index";
      "alter table tzip21_attributes drop column id";
      "alter table tzip21_attributes drop index tzip21_attributes_id_index";
    ] [
    "alter table tzip21_creators add column id varchar not null default ''";
    "update tzip21_creators set id = concat(contract, ':', token_id)";
    "alter table tzip21_creators alter column id drop default";
    "create index tzip21_creators_id_index on tzip21_creators(id)";
    "alter table tzip21_creators drop constraint tzip21_creators_pkey";
    "alter table tzip21_creators add constraint tzip21_creators_unique unique (id, account)";

    "alter table tzip21_formats add column id varchar not null default ''";
    "update tzip21_formats set id = concat(contract, ':', token_id)";
    "alter table tzip21_formats alter column id drop default";
    "create index tzip21_formats_id_index on tzip21_formats(id)";
    "alter table tzip21_formats drop constraint tzip21_formats_pkey";
    "alter table tzip21_formats add constraint tzip21_formats_unique unique (id, uri)";

    "alter table tzip21_attributes add column id varchar not null default ''";
    "update tzip21_attributes set id = concat(contract, ':', token_id)";
    "alter table tzip21_attributes alter column id drop default";
    "create index tzip21_attributes_id_index on tzip21_attributes(id)";
    "alter table tzip21_attributes drop constraint tzip21_attributes_pkey";
    "alter table tzip21_attributes add constraint tzip21_attributes_unique unique (id, name)";

    "drop index tokens_oid_index";
    "create unique index tokens_oid_index on tokens(oid)";
  ]

let upgrade_17_to_18 dbh version =
  EzPG.upgrade ~dbh ~version
    ~downgrade:[
      "alter table order_price_history drop index order_price_histoy_hash_index";
      "alter table origin_fees drop index origin_fees_hash_index";
      "alter table origin_fees drop index origin_fees_id_index ";
      "alter table payouts drop index payouts_hash_index";
      "alter table payouts drop index payouts_id_index ";
      "alter table order_cancel drop index order_cancel_cancel_index ";
      "alter table order_cancel drop index order_cancel_tsp_index";
      "alter table order_match drop index order_match_hash_left_index";
      "alter table order_match drop index order_match_hash_right_index ";
      "alter table order_match drop index order_match_tsp_index ";
    ] [
    "create index order_price_histoy_hash_index on order_price_history(hash)";
    "create index origin_fees_hash_index on origin_fees(hash)";
    "create index origin_fees_id_index on origin_fees(id)";
    "create index payouts_hash_index on payouts(hash)";
    "create index payouts_id_index on payouts(id)";
    "create index if not exists order_cancel_cancel_index on order_cancel(cancel)";
    "create index order_cancel_tsp_index on order_cancel(tsp)";
    "create index order_match_hash_left_index on order_match(hash_left)";
    "create index order_match_hash_right_index on order_match(hash_right)";
    "create index order_match_tsp_index on order_match(tsp)";
  ]

let upgrade_18_to_19 dbh version =
  EzPG.upgrade ~dbh ~version [
    "update tzip21_metadata set main = true where not main";
    "update tzip21_attributes set main = true where not main";
    "update tzip21_formats set main = true where not main";
    "update tzip21_creators set main = true where not main"
  ]

let upgrades =
  let last_version = fst List.(hd @@ rev !Versions.upgrades) in
  !Versions.upgrades @ List.map (fun (i, f) -> last_version + i, f) [
    1, upgrade_1_to_2;
    2, upgrade_2_to_3;
    3, upgrade_3_to_4;
    4, upgrade_4_to_5;
    5, upgrade_5_to_6;
    6, upgrade_6_to_7;
    7, upgrade_7_to_8;
    8, upgrade_8_to_9;
    9, upgrade_9_to_10;
    10, upgrade_10_to_11;
    11, upgrade_11_to_12;
    12, upgrade_12_to_13;
    13, upgrade_13_to_14;
    14, upgrade_14_to_15;
    15, upgrade_15_to_16;
    16, upgrade_16_to_17;
    17, upgrade_17_to_18;
    18, upgrade_18_to_19;
  ]
