(lang dune 2.9)

(name rarible)
(source (uri git://gitlab.com/functori/rarible))
(license MIT)
(authors "functori")
(maintainers "contact@functori.com")
(homepage "https://gitlab.com/functori/rarible")
(bug_reports "https://gitlab.com/functori/rarible/-/issues")

(package
 (name rarible)
 (synopsis "Crawler, server and sdk for Tezos rarible")
 (depends crawlori pgocaml_ppx ez_pgocaml ocurl kafka_lwt secp256k1-internal))
