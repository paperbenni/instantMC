#!/bin/bash
cd
#import functions
source <(curl -s https://raw.githubusercontent.com/paperbenni/bash/master/import.sh)

pb clear
pb nocache
pb bash/bash.sh
pb ix/ix.sh
pb ngrok/ngrok.sh
pb rclone/login.sh
pb rclone/rclone.sh
pb spigot/spigot.sh
pb spigot/op.sh
pb config/config.sh
pb replace/replace.sh

#set up rclone storage

USERNAME=${USERNAME:=Heinz007}
PASSWORD=${PASSWORD:=paperbennitester}

MEGAMAIL=${MEGAMAIL:=mineglory@protonmail.com}
MEGAHASH=${MEGAHASH:=hXrGi5EjPZeu7c8YZB0gOyAYf97yVTC5TsI-HQ}

cd .config/rclone
rpstring "spigotuser" "$MEGAMAIL" rclone.conf
rpstring "spigothash" "$MEGAHASH" rclone.conf
cd ~/

rclogin spigot "$USERNAME" "$PASSWORD"

# handle tcp tunneling and the web server

# app is running on heroku?
if [ -z "$HEROKU_APP_NAME" ]; then
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

    cd quark
    rpstring "replaceme" "serveo.net:$SERVEOPORT" index.html
    cd ~/
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
    done &
fi

rdl spigot
mkdir -p spigot/plugins

# start spigot
while :; do

    #op and AutoRestart
    cd ~/spigot
    mcop "$USERNAME"
    cat ops.json
    spigotautorestart 1.5
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

    cd ~
    # upload spigot folder
    rupl spigot

    #move cache back in
    mv spigot.jar ./spigot/
    mv cache ./spigot/
    echo "restarting loop"
    sleep 2

done

echo 'quitting server :('
#end of script
