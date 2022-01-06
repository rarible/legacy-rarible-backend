#!/bin/bash

contracts=("KT1LHHLso8zQWQWg1HUukajdxxbkGfNoHjh6"  "KT1MsdyBSAMQwzvDH4jt2mxUKJvBSWZuPoRJ"  "KT1VbHpQmtkA3D4uEbbju26zS8C42M5AGNjZ"  "KT1SyPgtiXTaEfBuMZKviWGNHqVrBBEjvtfQ"  "KT1HZVd9Cjc2CMe3sQvXgbxhpJkdena21pih"  "KT1TAS2v3DnjNMjaHHH2gHd9cUgQptpWE3qN"  "KT1CNHwTyjFrKnCstRoMftyFVwoNzF6Xxhpy"  "KT1S9VbCtVZUgAG4Q3VArvY5stu96q4CiPHZw"  "KT1EpGgjQs73QfFJs9z7m1Mxm5MTnpC2tqse")

for c in ${contracts[*]}; do
    echo "resetting royalties for " $c
    ./metadata_daemon --force --royalties --contract $c --split-load daemon_config_mainnet.json
    ./metadata_daemon --force --royalties --contract $c
    echo ""
done
