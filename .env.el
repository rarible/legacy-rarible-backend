(message "loading environment for crawlori")
(setenv "PGDATABASE" "rarible")
(setenv "PGCUSTOM_CONVERTERS_CONFIG" (format "%s/backend/db/converters.sexp" (getenv "PWD")))
