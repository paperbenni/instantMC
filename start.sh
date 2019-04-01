#!/bin/bash

#import functions
source <(curl -s https://raw.githubusercontent.com/paperbenni/bash/master/import.sh)
pb bash/bash.sh
pb ix/ix.io
spigot/spigot.sh

rclogin spigot "$USERNAME" "$PASSWORD"

rdl ixid.txt

while :; do
    exegrok 25565 &
    ixrun $(getgrok)
    sleep 2m
done &

rdl spigot

while :; do #start spigot
    ~/spigot
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
