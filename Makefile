DB=rarible
CONVERTERS=$(shell pwd)/src/db/converters.sexp
IMAGE=rarible:latest
POSTGRES_USER ?= postgres

-include Makefile.config

all: copy

build:
	@CRAWLORI_NO_UPDATE=true PGDATABASE=$(DB) PGCUSTOM_CONVERTERS_CONFIG=$(CONVERTERS) dune build src

copy: build openapi
	@mkdir -p _bin
	@cp -f _build/default/src/crawler/crawler.exe _bin/crawler
	@cp -f _build/default/src/api/main_api.exe _bin/api
	@cp -f _build/default/src/script/api_script.exe _bin/tester
	@cp -f _build/default/src/crawler/recrawl_ft.exe _bin/recrawl_ft
	@cp -f _build/default/src/crawler/recrawl_nft.exe _bin/recrawl_nft
	@cp -f _build/default/src/db/update.exe _bin/update_db
	@cp -f _build/default/src/db/extract_bigmap_id.exe _bin/extract_bigmap_id
	@cp -f _build/default/src/crawler/metadata_daemon.exe _bin/metadata_daemon
	@cp -f _build/default/src/crawler/collection_daemon.exe _bin/collection_daemon
	@cp -f _build/default/src/crawler/direct_crawl.exe _bin/direct_crawl
	@cp -f _build/default/src/db/check_ledger.exe _bin/check_ledger
	@cp -f _build/default/src/db/prefix_hash.exe _bin/prefix_hash
	@cp -f _build/default/src/db/update_supply.exe _bin/update_supply
	@cp -f _build/default/src/permit/permit.exe _bin/permit_api
	@cp -f _build/default/src/crawler/recrawl_hen_royalties.exe _bin/recrawl_hen_royalties
	@cp -f _build/default/src/crawler/recrawl_objkt.exe _bin/recrawl_objkt
	@cp -f _build/default/src/db/clean_balance_updates.exe _bin/clean_balance_updates
	@cp -f _build/default/src/db/fetch_off_royalties.exe _bin/fetch_off_royalties

clean:
	@dune clean
	@rm -rf _bin sdk/dist

dev:
	@CRAWLORI_NO_UPDATE=true PGDATABASE=$(DB) PGCUSTOM_CONVERTERS_CONFIG=$(CONVERTERS) dune build

drop:
	@dropdb $(DB)
	@dune clean

opam-switch:
	@opam switch create . 4.13.1 --no-install

deps:
	@opam update
	PGDATABASE=$(DB) opam install --deps-only .

mligo-pin:
	@opam pin add -n -y mligo.~dev git+https://gitlab.com/functori/mligo.git

mligo:
	@dune build contracts/mligo

arl-deps:
	sudo npm i @completium/completium-cli -g
	completium-cli init

arl:
	@dune build contracts/arl

openapi:
	@cp -f _build/default/src/api/openapi.yaml public/api

build-docker:
	docker build -t $(IMAGE) -f docker/Dockerfile .
