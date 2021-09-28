#!/bin/bash

LOG_PREFIX="Rarible Git Updater Script"
GIT=git
MAKE=make
CMD=updater
source $HOME/rarible-env.sh

rarible_update () {
    $ROTATE $LOGFILE
    cd $WORKING_DIRECTORY
    $GIT fetch --all &> $LOGFILE
    $GIT pull origin master &> $LOGFILE
    echo $! > $PIDFILE
}

rarible_compile () {
    source rarible-env.sh
    $ROTATE $LOGFILE
    cd $WORKING_DIRECTORY
    $MAKE clean
    $MAKE deps
    opam upgrade ez_pgocaml ez_api digestif hacl ppx_deriving_encoding ppx_deriving_jsoo tzfunc crawlori
    $MAKE &> $LOGFILE
    echo $! > $PIDFILE
}

case "$1" in
    update)
        echo "$LOG_PREFIX - Updating git repository"
        rarible_update
        echo tail -f $LOGFILE
        ;;

    compile)
        echo "$LOG_PREFIX - compiling git repository"
        rarible_compile
        echo tail -f $LOGFILE
        ;;

    all)
        echo "$LOG_PREFIX - updating and compiling git repository"
        rarible_update
        rarible_compile
        echo tail -f $LOGFILE
        ;;

    *)

        echo "Usage: ./rarible-git-update.sh {update}"
        exit 1
        ;;
esac

exit 0
