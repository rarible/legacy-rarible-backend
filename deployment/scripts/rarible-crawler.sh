#!/bin/bash

LOG_PREFIX="Rarible Crawler Script"
CMD=crawler
source $HOME/rarible-env.sh

CRAWLER=$WORKING_DIRECTORY/_bin/$CMD
ARG=

rarible_crawler_start () {
    $ROTATE $LOGFILE
    cd $WORKING_DIRECTORY
    $CRAWLER $ARG $CRAWLER_CONFIG_FILE &> $LOGFILE &
    PID=$!
    echo $PID > $PIDFILE
}

rarible_crawler_stop () {
    if test -f $PIDFILE; then
        PID=$(cat $PIDFILE)
        kill -9 $PID
        rm -f $PIDFILE
    else
        echo No PID file
    fi
}

case "$1" in
    start)
        echo "$LOG_PREFIX - Starting crawler"
        rarible_crawler_start
        echo tail -f $LOGFILE
        ;;

    stop)
        echo "$LOG_PREFIX - Stopping crawler"
        rarible_crawler_stop
        echo tail -f $LOGFILE
        ;;

    restart)
        echo "$LOG_PREFIX - Restarting crawler"
        rarible_crawler_stop
        rarible_crawler_start
        echo tail -f $LOGFILE
        ;;

    *)

        echo "Usage: ./rarible-git-update.sh {start|stop|restart}"
        exit 1
        ;;
esac

exit 0
