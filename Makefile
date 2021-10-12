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
	@opam pin add -n -y ez_pgocaml.dev git+https://github.com/ocamlpro/ez_pgocaml.git
	@opam pin add -n -y ez_api.dev git+https://github.com/maxtori/ez_api.git#allow-static-dynamic
	@opam pin add -n -y digestif.dev git+https://github.com/maxtori/digestif.git#keccak-256
	@opam pin add -n -y hacl.dev git+https://gitlab.com/maxtori/ocaml-hacl.git
	@opam pin add -n -y json-data-encoding.dev git+https://gitlab.com/maxtori/json-data-encoding.git
	@opam pin add -n -y ppx_deriving_encoding.dev git+https://gitlab.com/o-labs/ppx_deriving_encoding.git
	@opam pin add -n -y ppx_deriving_jsoo.dev git+https://gitlab.com/o-labs/ppx_deriving_jsoo.git
	@opam pin add -n -y --ignore-pin-depends tzfunc.~dev git+https://gitlab.com/functori/tzfunc.git
	@opam pin add -n -y --ignore-pin-depends crawlori.~dev git+https://gitlab.com/functori/crawlori.git
	@CRAWLORI_NO_UPDATE=true PGDATABASE=$(DB) opam install --deps-only --ignore-pin-depends .

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
	@cp -f _build/default/backend/api/openapi.json public/api

kafka_openapi:
	@cp -f _build/default/backend/api/kafka_openapi.json public/api

typedoc:
	@npx typedoc --tsconfig sdk/tsconfig.json --options sdk/typedoc.json
