DB=rarible
CONVERTERS=$(OPAM_SWITCH_PREFIX)/share/crawlori/converters

-include Makefile.config

all: copy

build:
	@CRAWLORI_NO_UPDATE=true PGDATABASE=$(DB) PGCUSTOM_CONVERTERS_CONFIG=$(CONVERTERS) dune build backend

copy: build openapi kafka_openapi
	@mkdir -p _bin
	@cp -f _build/default/backend/crawler/crawler.exe _bin/crawler
	@cp -f _build/default/backend/api/main_api.exe _bin/api
	@cp -f _build/default/backend/script/api_script.exe _bin/tester

clean:
	@dune clean
	@rm -rf _bin sdk/dist build/default/backend/db/.rarible_witness

dev:
	@CRAWLORI_NO_UPDATE=true PGDATABASE=$(DB) PGCUSTOM_CONVERTERS_CONFIG=$(CONVERTERS) dune build

drop:
	@dropdb $(DB)
	@rm -f _build/default/backend/db/.rarible_witness

opam-switch:
	@opam switch create . 4.12.0 --no-install

deps:
	@opam update
	PGDATABASE=$(DB) opam install --deps-only .

ts-global-deps:
	@sudo npm i -g typescript webpack webpack-cli

ts-deps:
	@npm --prefix sdk --no-audit --no-fund i

ts:
	@tsc -p sdk/tsconfig.json

web: ts
	@webpack --config sdk/webpack.config.js

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
	@cp -f _build/default/backend/api/openapi.yaml public/api

kafka_openapi:
	@cp -f _build/default/backend/api/kafka_openapi.yaml public/kafka

typedoc:
	@npx typedoc --tsconfig sdk/tsconfig.json --options sdk/typedoc.json
