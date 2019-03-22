#!/usr/bin/env bash

cd $HOME
source <(curl -s https://raw.githubusercontent.com/paperbenni/bash/master/import.sh)

pb bash/bash.sh
pb ngrok/ngrok.sh
pb ix/ix.sh
pb rclone/login.sh
pb rclone/rclone.sh
pb spigot/spigot.sh

# set up optional rclone mega account
if [ -n "$MEGANAME" ] &&
    [ -n "$MEGAPASS" ]; then
    rmega "$MEGANAME" "$MEGAPASS"
fi

if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
    USERNAME="paperbennitestspigot"
    PASSWORD="paperbennitestspigot"
fi

#ix.io account
ixlogin

if ! rclogin "$USERNAME" "$PASSWORD"; then
    echo "mega login failed"
    exit 1
fi
echo "starting ngrok"
rungrok tcp 25565 &>/dev/null &
sleep 5
while :; do
    sleep 20
    rdl ixid.txt
    NGROKADRESS=$(getgrok)
    ixrun "$NGROKADRESS"
    echo "Your Server ID is $(cat ixid.txt)"
    echo "Your Server link is http://ix.io/$(cat ixid.txt)"
    echo "Your Server IP is $(getgrok)"
    rupl ixid.txt
    sleep 5m
done &

#weiter
rdl spigot
mkdir spigot

while :; do #start spigot
    cd spigot
    if [ -e ../spigot.jar ]; then
        mv ../spigot.jar ./
    fi
    echo "eula=true" >eula.txt
    spigexe
    echo "spigot exited"
    echo "moving spigot"
    mv spigot.jar ../
    echo "moving cache"
    mv cache/ ../
    cd ..
    rupl spigot
    sleep 1
    echo "moving stuff back in"
    mv spigot.jar spigot/
    mv cache spigot/
    echo "restarting server"
    sleep 2
done

echo 'quitting server :('
#end of script
