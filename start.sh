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
ixlogin "${USERNAME}spigotdocker" "${PASSWORD}spigotdocker"

if ! rlogin "$USERNAME" "$PASSWORD"; then
    echo "mega login failed"
    exit 1
fi

rungrok tcp 25565 &

while :; do
    sleep 20
    getgrok
    rdl ixid.txt
    ixrun $(cat ngrokadress.txt)
    echo "Your Server ID is $(cat ixid.txt)"
    echo "Your Server link is http://ix.io/$(cat ixid.txt)"
    echo "Your Server IP is $(cat ngrokadress.txt)"

    rupl ixid.txt
    sleep 5m
done &

#weiter
rdl spigot
cd spigot
while :; do #start spigot
    if [ -e ../spigot.jar ]; then
        mv ../spigot.jar ./
    fi
    echo "eula=true" >eula.txt
    spigexe
    mv spigot.jar ../
    mv -r cache/ ../
    cd ..
    rupl spigot
    sleep 1
    mv spigot.jar spigot/
    mv -r cache spigot/
    echo "restarting server"
    sleep 2
done

echo 'quitting server :('
#end of script
