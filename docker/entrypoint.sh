#!/bin/sh

$(pg_config --bindir)/pg_ctl start -D data && "$@"
