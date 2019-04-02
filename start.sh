#!/bin/bash
cd
#import functions
source <(curl -s https://raw.githubusercontent.com/paperbenni/bash/master/import.sh)

pb bash/bash.sh
pb ix/ix.sh
pb ngrok/ngrok.sh
pb rclone/login.sh
pb rclone/rclone.sh
pb spigot/spigot.sh
USERNAME=${USERNAME:=paperbennitester}
PASSWORD=${PASSWORD:=paperbennitester}
rclogin spigot "$USERNAME" "$PASSWORD"

rdl ixid.txt

rungrok tcp -region=eu 25565 &

sleep 1
waitgrok

while :; do
    ixrun $(getgrok)
    echo "your id is $(cat ~/ixid.txt)"
    if ! rexists ixid.txt && ! pgrep rclone; then
        pushd ~/
        rupl ixid.txt
        popd
    fi
    sleep 2m
    if ! [ -z "$HEROKU_APP_NAME" ]; then
        echo "heroku name is $HEROKU_APP_NAME"
        curl "$HEROKU_APP_NAME.herokuapp.com"
    fi
done &

rdl spigot
mkdir -p spigot/plugins

cd spigot
spigoautostop 7300
cd ..

while :; do #start spigot
    cd ~/spigot
    spigexe
    mv cache ~/
    mv spigot.jar ~/
    cd ~
    rupl spigot
    mv spigot.jar ./spigot/
    mv cache ./spigot/
    echo "restarting loop"
    sleep 5

done

echo 'quitting server :('
#end of script
