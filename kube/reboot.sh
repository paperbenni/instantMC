#!/bin/bash
apk add curl bash git screen
if ! command -v instantmc; then
    curl -s 'https://raw.githubusercontent.com/paperbenni/instantMC/master/local/install.sh' | sh
    export TERM=xterm
    screen -d -m "instantmc"
    sleep 10
    if ! pgrep instantmc; then
        screen -d -m "instantmc"
    fi
fi
