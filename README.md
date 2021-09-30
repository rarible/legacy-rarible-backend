# Rarible Integration by Functori

This project contains:

- A backend for Rarible to allow users of the platform to be able to
  create NFTs on the Tezos blockchain.
- An API server similar to the one already available for Ethereum at
  the following address: https://ethereum-api.rarible.org/v0.1/doc
- Development of the database and a crawler infrastructure
- An SDK for the Rarible protocol in the same model as the one for
  Ethereum at the following address:
  https://github.com/rarible/protocol-ethereum-sdk , which will allow
  to interact "programmatically" with the smart contract and the API
  server.

API and SDK documentation can be found [here](https://functori.gitlab.io/rarible/index.html)

## Repository Structure

This repository is organized as follows:
- `backend`: contains all the code of the database, the crawler and the API
- `scripts`: contains all the scipts useful for the project, especially a deployment script for the smart contract
- `contracts`: contrains smart contracts files
- `sdk`: typescript files for the rarible protocol

## Requirements / Setting Up Developement Environment

### Install Postgresql

Before installing the OCaml binding of postgresql, you need to install postgresql itself by following the online documentation.
To use postgresql with ocaml, you will to setup a user and configure it.

```bash
sudo -i -u postgres
psql
CREATE USER <user>;
ALTER ROLE <user> CREATEDB;
CTRL+D (to quit)
````

### Customizing database name

Create a `Makefile.config` file with something like:

    DB=my_db_name

to provide a personalized name for the database

### Npm dev env

Install node and npm on your machine (the process has been succesfully
tested with npm version 6.14.14 and node version 16.6.2). Then, run:

    $ make ts-deps
The command above will:
- install the typescript compiler (sudo privileges are needed for it)
- install the taquito library (needed by the interface code to the smart
contract), and the hacl-wasm library (used by the keys generation lib)

### OCaml Development Environment

Similarty to npm for nodeJS or Cargo for Haskell, OCaml has its own packages manager called opam. When installing OCaml dependencies, OPAM should be able to detect system dependencies that you should install as well.

- start by installing the latest version of OPAM by following the guide here: https://opam.ocaml.org/doc/Install.html


- then, run the following command to initialize opam


      $ opam init --reinit --bare

- once this is done, the following command should create an `_opam` directory at the root of this repository and install the OCaml compiler version 4.12.0:

      $ make opam-switch

- then, running the following target should install needed dependencies:

      $ make deps

### Tezos Client: Getting/Compiling Tezos

To interact and deploy the smart contract into the Tezos blockchain, you need to install tezos.

Follow the instructions on gitlab [Tezos documentation](https://tezos.gitlab.io/introduction/howtoget.html) and be sure tezos-client is installed.

If you want to test on the granadanet (current Tezos testnet), you need to get a faucet account on the Faucet website.

### Archetype Smart Contract Language

[todo]

## Building and Deploying

### Building javascript files from typescript

To generate javascript files from the typescript, just run:

```bash
make ts
```

The generated javascript files `fa2_nft.js` and `crypto.js` will be located in `sdk/dist`


### Interacting with the Smart contracts using provided OCaml Script

A OCaml script is provided to help compile and deploy the contract on the blockchain, as well as calling the contract entrypoints and getting the storage information.
```bash
./rarible.mlt --help
```
### Building/Deploying the smart contracts

If `tezos-client` is not installed and available in the `$PATH`
environment, you need to add the `--client` option with the right
path. Be sure that ligo is also installed.

Then you can deploy (which will compile again):

```bash

./rarible.mlt --client PATH_TO_TEZOS_CLIENT deploy
```

## Crawl the blockchain data of the smart contract

We use [Crawlori](https://gitlab.com/functori/crawlori) to crawl the Tezos blockchain.
[TODO]


## Deployment

The `deployment` directory allows to:
- start/stop the crawler with systemd
  (`deployment/systemd/rarible-crawler.service`) which will start the
  crawler using the script `deployment/scripts/rarible-crawler.sh)
- start/stop the API with systemd
  (`deployment/systemd/rarible-api.service`) which will start the API
  using the script `deployment/scripts/rarible-api.sh)
- update and compile the project with the latest version of master
  using `deployment/scripts/rarigle-git-update.sh`

First you need to edit the `deployment/scripts/rarigle-env.sh` to
setup the right pathes for different binaries and configuration files.

Then you can either edit and copy the systemd file or make a symbolic
link to these files. You can also use the bash scripts to start/stop
the crawler without systemd.

To configure nginx, you can use the draft in
`deployment/nginx/rarible-api.nginx`. We use certbot to enable https:

 ```bash
certbot --authenticator webroot --installer nginx
```
