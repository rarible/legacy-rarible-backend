#!/bin/bash

LOG_PREFIX="Rarible API Script"
CMD=api
source $HOME/rarible-env.sh

API=$WORKING_DIRECTORY/_bin/$CMD
ARG="--kafka-config $KAFKA_CONFIG_FILE"

rarible_api_start () {
    $ROTATE $LOGFILE
    cd $WORKING_DIRECTORY
    $API $ARG &> $LOGFILE &
    PID=$!
    echo $PID > $PIDFILE
}

rarible_api_stop () {
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
        echo "$LOG_PREFIX - Starting API"
        rarible_api_start
        echo tail -f $LOGFILE
        ;;

    stop)
        echo "$LOG_PREFIX - Stopping API"
        rarible_api_stop
        echo tail -f $LOGFILE
        ;;

    restart)
        echo "$LOG_PREFIX - Restarting API"
        rarible_api_stop
        rarible_api_start
        echo tail -f $LOGFILE
        ;;

    *)

        echo "Usage: ./rarible-git-update.sh {start|stop|restart}"
        exit 1
        ;;
esac

exit 0
