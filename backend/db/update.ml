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
      block varchar not null,
      level int not null,
      main boolean not null default false,
      last timestamp not null,
      tokens_number bigint not null default 0,
      ledger_id bigint not null,
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
      id bigserial primary key)|};

    {|create table match_orders(
      id1 bigint not null references orders(id),
      id2 bigint not null references orders(id),
      cancel boolean not null default false,
      primary key (id1, id2))|};
  ]

let upgrades =
  let last_version = fst List.(hd @@ rev !Versions.upgrades) in
  !Versions.upgrades @ [
    last_version + 1, upgrade_1_to_2;
  ]

let () =
  EzPGUpdater.main Cconfig.database ~upgrades
