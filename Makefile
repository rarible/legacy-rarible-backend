DB=rarible
CONVERTERS=$(OPAM_SWITCH_PREFIX)/share/crawlori/converters

-include Makefile.config

all: copy

build:
	@CRAWLORI_NO_UPDATE=true PGDATABASE=$(DB) PGCUSTOM_CONVERTERS_CONFIG=$(CONVERTERS) dune build backend

copy: build
	@mkdir -p _bin
	@cp -f _build/default/backend/crawler/crawler.exe _bin/crawler
	@cp -f _build/default/backend/api/api.exe _bin/api

clean:
	@dune clean
	@rm -rf _bin sdk/dist build/default/backend/db/.rarible_witness

dev:
	@CRAWLORI_NO_UPDATE=true PGDATABASE=$(DB) PGCUSTOM_CONVERTERS_CONFIG=$(CONVERTERS) dune build

drop:
	@dropdb $(DB)
	@rm -f _build/default/backend/db/.rarible_witness

deps:
	@opam pin add -n -y ez_pgocaml.dev git+https://github.com/ocamlpro/ez_pgocaml.git
	@opam pin add -n -y ez_api.dev git+https://github.com/ocamlpro/ez_api.git
	@opam pin add -n -y hacl.dev git+https://gitlab.com/maxtori/ocaml-hacl.git
	@opam pin add -n -y ppx_deriving_encoding.dev git+https://gitlab.com/o-labs/ppx_deriving_encoding.git
	@opam pin add -n -y --ignore-pin-depends tzfunc.~dev git+https://gitlab.com/functori/tzfunc.git
	@opam pin add -n -y --ignore-pin-depends crawlori.~dev git+https://gitlab.com/functori/crawlori.git
	@opam install --deps-only --ignore-pin-depends .

ts-deps:
	@sudo npm i -g typescript
	@npm --prefix sdk --no-audit --no-fund i @taquito/signer hacl-wasm

ts:
	@tsc -p sdk/tsconfig.json