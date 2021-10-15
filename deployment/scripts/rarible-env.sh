#!/bin/bash

# TO CONFIGURE / EDIT
NETWORK=mainnet
WORKING_DIRECTORY=$HOME/rarible
LOGDIR=$HOME/rarible-logs

TEZOS_SRC=$HOME/tezos
RPC_ADDR=127.0.0.1
ROTATE=$HOME/rotate/bin/rotate
CRAWLER_CONFIG_FILE=$WORKING_DIRECTORY/deployment/crawler_config.json
KAFKA_CONFIG_FILE=$WORKING_DIRECTORY/deployment/kafka_config.json

# Environment variable
NAME=rarible-$CMD-$NETWORK
LOGFILE=$LOGDIR/$NAME.log
PIDFILE=$LOGDIR/$NAME.pid

# Tezos related variables
TEZOS_BIN=$HOME/$NETWORK
TEZOS_DATA=$HOME/.tezos-$NETWORK
