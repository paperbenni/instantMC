#!/bin/bash
export HOME=/home/user
HOME=/home/user

if curl serveo.net | grep 'expose'; then
    echo "serveo is up"
    SERVEOUP="yes"
fi

cd
echo "home dir: $HOME"
echo "current dir: $(pwd)"
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
    rcloud mineglory
else
    echo "using dropbox storage"
    rm rclone.conf
    touch rclone.conf
    pb rclone/dropbox
    addbox "spigot" "$DROPTOKEN"
fi
cd ~/

rclogin mineglory "$USERNAME" "$PASSWORD"

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

    #check if serveo is offline, ngrok for backup
    if [ -n SERVEOUP ]; then
        rdl serveoid.txt
        # generate serveo port
        if test -z $(cat serveoid.txt); then
            random 2800 2820 >serveoid.txt
            SERVEOPORT=$(cat serveoid.txt)
            #check if someone is using that port
            while nc -vz serveo.net "$SERVEOPORT"; do
                SERVEOPORT=$(cat serveoid.txt)
                random 2800 2820 >serveoid.txt
                sleep 0.1
            done
            rupl serveoid.txt
        fi

        SERVEOPORT=$(cat serveoid.txt)
        echo "checking serveo port $SERVEOPORT"
        #check serveo port availability
        while timeout 10 nc -vz serveo.net "$SERVEOPORT"; do
            echo "temporarily changing to other serveo port"
            SERVEOPORT=$(cat serveoid.txt)
            random 2800 2820 >serveoid.txt
            sleep 0.1
        done
        echo "serveo port is $SERVEOPORT"
        cd ~/

        #check if tunnel is still going
        while ! nc -vz serveo.net "$SERVEOPORT"; do
            echo "your ip is serveo.net:$SERVEOPORT"
            loop nohup autossh -oStrictHostKeyChecking=no -M 0 -R $SERVEOPORT:localhost:25565 serveo.net
        done &
        titlesite glitch quark "join my minecraft server at" "serveo.net:$SERVEOPORT"
        #start web server for status and heroku kill
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
            curl -s "$HEROKU_APP_NAME.herokuapp.com" | grep 'minecraft'
        done &
    else
        echo "serveo is currently down, switching to ngrok"
        rungrok tcp -region=eu 25565 &
        sleep 1
    fi

fi

#download world data from dropbox
rdl spigot
mkdir -p spigot/plugins
rm -rf spigot/logs
cd spigot
spigotdl 1.13
test -e spigot.jar || exit 1

# install plugin
rm plugins/*.mpm
cat mpmfile && mpm -f
if [ -n "$MCPLUGINS" ]; then
    echo "installing mpm plugins from list"
    IFS2="$IFS"
    export IFS=","
    for word in $MCPLUGINS; do
        mpm "$word"
    done
    export IFS="$IFS2"
fi

cd ..

# start spigot
while :; do

    #default op user
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

# upload spigot folder every 30 min
while :; do
    sleep 30m
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

echo 'how did you reach the end of the script?'
#end of script
