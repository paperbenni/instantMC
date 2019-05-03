#!/usr/bin/env bash
if [ -z "$1" ]; then
    echo "usage: ./newheroku.sh appname"
    return 1
fi
heroku labs:enable runtime-dyno-metadata -a "$1"
