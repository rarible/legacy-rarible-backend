(message "loading environment for crawlori")
(setenv "PGDATABASE" "rarible")
(setenv "PGCUSTOM_CONVERTERS_CONFIG" (format "%s/src/db/converters.sexp" (getenv "PWD")))
