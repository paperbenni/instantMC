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

rclogin spigot "$USERNAME" "$PASSWORD"

rdl ixid.txt

rungrok tcp 25565 &

sleep 1
waitgrok

while :; do
    ixrun $(getgrok)
    echo "your id is $(cat ~/ixid.txt)"
    if ! rexists ixid.txt; then
        pushd ~/
        rupl ixid.txt
        popd
    fi
    sleep 2m
done &

rdl spigot

while :; do #start spigot
    cd ~/spigot
    spigexe
    mv cache ../
    mv spigot.jar ../
    cd ..
    rupl spigot
    echo "restarting loop"
    sleep 5

done

echo 'quitting server :('
#end of script
