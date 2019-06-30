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
HSPIGOT=${MINECRAFTVERSION:=1.13}
MEGAMAIL=${MEGAMAIL:=mineglory@protonmail.com}
MEGAHASH=${MEGAHASH:=-AS_uLQGedO78_JXPwTtecPrxEpicGCRKfXw2w}

cd .config/rclone
if [ -z "$DROPTOKEN" ]; then
    echo "using mega storage"
    rpstring "spigotuser" "$MEGAMAIL" rclone.conf || exit 1
    rpstring "spigothash" "$MEGAHASH" rclone.conf
else
    echo "using dropbox storage"
    rm rclone.conf
    touch rclone.conf
    pb rclone/dropbox
    addbox "spigot" "$DROPTOKEN"
fi
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
    echo "checking serveo port $SERVEOPORT"
    while timeout 10 nc -vz serveo.net "$SERVEOPORT"; do
        echo "temporarily changing to other serveo port"
        SERVEOPORT=$(cat serveoid.txt)
        random 2800 2820 >serveoid.txt
        sleep 0.1
    done

    echo "serveo port is $SERVEOPORT"

    cd ~/
    while ! nc -vz serveo.net "$SERVEOPORT"; do
        echo "your ip is serveo.net:$SERVEOPORT"
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
rm -rf spigot/logs
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
    cd ~/spigot
    if ! [ -e server.properties ]; then
        curl https://raw.githubusercontent.com/paperbenni/openshiftspigot/master/server.properties >server.properties
    fi
    confset "server.properties" online-mode false
    tree ~/
    # execute spigot.jar
    sleep 1
    spigexe "$HSPIGOT"
    echo "spigot exited"
    # move cache to save cloud storage
done &

sleep 10

echo "backup loop starting"

while :; do
    sleep 30m
    # upload spigot folder
    echo "starting backup process"
    rm -rf ~/spigot/logs
    cd ~
    mkdir uploader
    cp -r spigot uploader/spigot
    cd uploader/spigot
    rm plugins/*.jar
    rm spigot.jar
    rm -rf cache
    cd ..
    rupl spigot
    rm -rf spigot
    cd ~/
    echo "restarting backup loop"
    sleep 2
done

echo 'quitting server :('
#end of script
