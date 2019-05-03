#!/bin/bash
cd
#import functions
source <(curl -s https://raw.githubusercontent.com/paperbenni/bash/master/import.sh)

pb bash
pb config
pb replace

pb rclone
pb rclone/login

pb spigot
pb spigot/op
pb spigot/mpm

pb ix
pb ngrok

pb titlesite

#set up rclone storage

USERNAME=${USERNAME:=Heinz007}
PASSWORD=${PASSWORD:=paperbennitester}

MEGAMAIL=${MEGAMAIL:=mineglory@protonmail.com}
MEGAHASH=${MEGAHASH:=-AS_uLQGedO78_JXPwTtecPrxEpicGCRKfXw2w}

cd .config/rclone
rpstring "spigotuser" "$MEGAMAIL" rclone.conf || exit 1
rpstring "spigothash" "$MEGAHASH" rclone.conf
cd ~/

rclogin spigot "$USERNAME" "$PASSWORD"

# handle tcp tunneling and the web server

# app is running on heroku?
if [ -z "$HEROKU_APP_NAME" ]; then
    echo "other host detected"
    # not heroku
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
    done &
else
    # heroku
    echo "Heroku detected"
    rdl serveoid.txt

    if test -z $(cat serveoid.txt); then
        random 2800 2820 >serveoid.txt
        SERVEOPORT=$(cat serveoid.txt)
        while nc -vz serveo.net "$SERVEOPORT"; do
            SERVEOPORT=$(cat serveoid.txt)
            random 2800 2820 >serveoid.txt
            sleep 0.1
        done
        rupl serveoid.txt
    fi

    SERVEOPORT=$(cat serveoid.txt)
    echo "checking serveo port"
    while nc -vz serveo.net "$SERVEOPORT"; do
        echo "temporarily changing to other serveo port"
        SERVEOPORT=$(cat serveoid.txt)
        random 2800 2820 >serveoid.txt
        sleep 0.1
    done

    echo "serveo port is $SERVEOPORT"

    cd ~/
    while ! nc -vz serveo.net "$SERVEOPORT"; do
        echo "your ip is serveo.net:$(cat serveoid.txt)"
        loop nohup autossh -oStrictHostKeyChecking=no -M 0 -R $SERVEOPORT:localhost:25565 serveo.net
    done &

    titlesite glitch quark "join my minecraft server at" "serveo.net:$SERVEOPORT"

    while :; do
        echo "checking web server"

        if ! pgrep httpd; then
            echo "web server not found, starting httpd"
            httpd -p 0.0.0.0:"$PORT" -h quark
            sleep 2
        else
            echo "web server found"
            sleep 5m
        fi
        curl "$HEROKU_APP_NAME.herokuapp.com"
    done &
fi

rdl spigot
mkdir -p spigot/plugins

cd spigot
spigotdl 1.13
test -e spigot.jar || exit 1
rm plugins/*.mpm
cat mpmfile && mpm -f
cd ..

# start spigot
while :; do

    #op and AutoRestart
    cd ~/spigot
    mcop "$USERNAME"
    cat ops.json
    mpm autorestart
    cd ~/spigot
    if ! [ -e server.properties ]; then
        curl https://raw.githubusercontent.com/paperbenni/openshiftspigot/master/server.properties >server.properties
    fi
    confset "server.properties" online-mode false
    tree ~/

    # execute spigot.jar
    sleep 1
    spigexe

    # move cache to save cloud storage
    mv cache ~/
    mv spigot.jar ~/
    mkdir ~/plugins

    mv plugins/*.jar ~/plugins/

    cd ~
    # upload spigot folder
    rupl spigot

    #move cache back in
    mv spigot.jar ./spigot/
    mv cache ./spigot/
    mv ~/plugins/*.jar ./spigot/plugins/
    echo "restarting loop"
    sleep 2

done

echo 'quitting server :('
#end of script
