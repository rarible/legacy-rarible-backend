DB=rarible
CONVERTERS=$(OPAM_SWITCH_PREFIX)/share/crawlori/converters.sexp
IMAGE=rarible:latest
POSTGRES_USER ?= postgres

-include Makefile.config

all: copy

pgmp-extension:
	@if [ -z "$$(psql -lqt | cut -d \| -f 1 | grep -w $(DB))" ]; then\
		createdb $(DB) && sudo -i -u $(POSTGRES_USER) -- psql ${DB} -c 'create extension if not exists pgmp';\
	fi

build: pgmp-extension
	@CRAWLORI_NO_UPDATE=true PGDATABASE=$(DB) PGCUSTOM_CONVERTERS_CONFIG=$(CONVERTERS) dune build backend

copy: build openapi
	@mkdir -p _bin
	@cp -f _build/default/backend/crawler/crawler.exe _bin/crawler
	@cp -f _build/default/backend/api/main_api.exe _bin/api
	@cp -f _build/default/backend/script/api_script.exe _bin/tester
	@cp -f _build/default/backend/crawler/recrawl_single.exe _bin/recrawl
	@cp -f _build/default/backend/db/update.exe _bin/update_db

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

ts-deps:
	@npm --prefix sdk --no-audit --no-fund --force i

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

typedoc-deps:
	@sudo npm install -g typedoc

typedoc:
	@npx typedoc --tsconfig sdk/tsconfig.json --options sdk/typedoc.json

build-docker:
	docker build -t $(IMAGE) -f docker/Dockerfile .
