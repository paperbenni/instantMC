#!/bin/bash
cd $HOME

pb bash/bash.sh
pb ngrok/ngrok.sh
pb ix/ix.sh
pb rclone/login.sh
pb spigot/spigot.sh

# set up mega account
if [ -z "$MEGANAME" ] &&
    [ -z "$MEGAPASS" ]; then
    rmega "$MEGANAME" "$MEGAPASS"
fi

#ix.io account
ixlogin "$ACCOUNTNAME" "$ACCOUNTPASSWORD"

if ! rlogin "$ACCOUNTNAME" "$ACCOUNTPASSWORD"; then
    echo "mega login failed"
    exit 1
fi

rungrok tcp 25565 &

while :; do
    sleep 20
    getgrok
    ixrun $(cat ngrokadress.txt)
    echo "Your Server ID is $(cat ixid.txt)"
    sleep 5m
done &

#weiter
rdl spigot
cd spigot
while :; do #start spigot
    if [ -e ../spigot.jar ]; then
        mv ../spigot.jar ./
    else
        wget -O spigot.jar https://papermc.io/api/v1/paper/1.13.2/561/download
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
