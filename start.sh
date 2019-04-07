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

USERNAME=${USERNAME:=Heinz007}
PASSWORD=${PASSWORD:=paperbennitester}
rclogin spigot "$USERNAME" "$PASSWORD"

if [ -z "$HEROKU_APP_NAME" ]; then
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

    if ! nc -vz serveo.net "$SERVEOPORT"; then
        cd quark
        rpstring "replaceme" "serveo.net:$SERVEOPORT" index.html
        cd ../
        echo "your ip is serveo.net:$(cat serveoid.txt)"
        httpd -p 0.0.0.0:"$PORT" -h quark
        loop nohup autossh -oStrictHostKeyChecking=no -M 0 -R $SERVEOPORT:localhost:25565 serveo.net &
    fi
fi

rdl spigot
mkdir -p spigot/plugins

while :; do #start spigot
    cd ~/spigot
    mcop "$USERNAME"
    cat ops.json
    spigoautostop 22000
    cd ~/spigot
    if ! [ -e server.properties ]; then
        curl https://raw.githubusercontent.com/paperbenni/openshiftspigot/master/server.properties >server.properties
    fi
    confset "server.properties" online-mode false
    tree ~/
    sleep 1
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
