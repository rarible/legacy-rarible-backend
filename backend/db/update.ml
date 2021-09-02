let upgrade_1_to_2 dbh version =
  EzPG.upgrade ~dbh ~version
    ~downgrade:[
      "drop table state";
      "drop contracts";
      "drop tokens";
      "drop accounts";
      "drop contract_updates";
      "drop token_updates";
    ] [
    {|create table state(
      admin_wallet varchar not null default '',
      last_updated timestamp not null default now(),
      last_block varchar not null default '',
      tokens_number bigint not null default 0)|};
    {|create table contracts(
      address varchar primary key,
      block varchar not null,
      main boolean not null default false,
      tokens_number bigint not null default 0,
      supply bigint,
      metadata jsonb not null default '{}')|};
    {|create table tokens(
      kind varchar not null,
      contract varchar not null,
      token_id bigint not null,
      block varchar not null,
      main boolean not null default false,
      last timestamp not null,
      owner varchar not null,
      amount bigint,
      metadata jsonb not null default '{}',
      primary key (contract, owner, token_id))|};
    {|create table accounts(
      address varchar primary key,
      block varchar not null,
      main boolean not null default false,
      last timestamp not null,
      tokens bigint[] not null default '{}')|};
    {|create table contract_updates(
      transaction varchar not null,
      counter zarith,
      nonce int,
      block varchar not null,
      main boolean not null default false,
      tsp timestamp not null,
      contract varchar not null,
      mints bigint[] not null,
      burns bigint[] not null,
      primary key (transaction, counter, nonce))|};
    {|create table token_updates(
      transaction varchar not null,
      counter zarith,
      nonce int,
      block varchar not null,
      main boolean not null default false,
      tsp timestamp not null,
      old_owner varchar not null,
      new_owner varchar not null,
      contract varchar not null,
      token_id varchar not null,
      amount bigint,
      primary key (transaction, counter, nonce))|};
  ]

let upgrades =
  let last_version = fst List.(hd @@ rev !Versions.upgrades) in
  !Versions.upgrades @ [
    last_version + 1, upgrade_1_to_2;
  ]

let () =
  EzPGUpdater.main Cconfig.database ~upgrades
