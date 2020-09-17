#!/bin/bash
if command -v apk && [ -z "$HOME" ]; then
    export HOME=/home/user
    HOME=/home/user
fi

cd || exit 1
echo "home dir: $HOME"
echo "current dir: $(pwd)"
#import functions
source <(curl -Ls https://git.io/JerLG)

pb config
pb replace

pb rclone
pb rclone/login

pb ix
pb ngrok

#set up rclone storage
if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
    echo "please set the environment variables"
    echo "USERNAME and PASSWORD"
    exit
fi

MEGAMAIL=${MEGAMAIL:=mineglory@protonmail.com}
MEGAHASH=${MEGAHASH:=-AS_uLQGedO78_JXPwTtecPrxEpicGCRKfXw2w}

# randomize port if sport is not set
if [ -n "$SPORT" ]; then
    if [ "$SPORT" -eq "$SPORT" ]; then
        SERVPORT="$SPORT"
    else
        echo "no valid serveo port found"
    fi
else
    SERVPORT="$(random 2802 25566)"
    echo "the port is $SERVPORT"
fi

echo "using minecraft version $MINECRAFTVERSION"

cd || exit 1
mkdir -p .config/rclone
cd .config/rclone || exit 1

if [ -z "$DROPTOKEN" ]; then
    rcloud mineglory
    HCLOUDNAME="default mega"
else
    echo "using dropbox storage"
    rm rclone.conf
    touch rclone.conf
    pb rclone/dropbox
    addbox "$DROPTOKEN" "mineglory"
    export HCLOUDNAME="dropbox"
fi

cd || exit 1
cat .config/rclone/rclone.conf

rclogin mineglory "$USERNAME" "$PASSWORD"
cat ~/.config/rclone/rclone.conf

# handle tcp tunneling and the web server
mkdir ~/.ssh
ssh-keyscan -H -p 2222 mc.paperbenni.xyz >>~/.ssh/known_hosts

if [ -n "$SERVPORT" ]
then
while :; do
    mpm tunnel "$SERVPORT"
    sleep 2
done &
else
    echo "skipping serveo"
fi

#download world data from dropbox
cd "$HOME" || exit 1
rdl spigot
cd "$HOME" || exit 1
mkdir -p spigot/plugins
rm -rf spigot/logs
cd spigot || exit 1

# install plugin
rm plugins/*.mpm
rm plugins/*.jar
mpm install

[ -n "$MCPLUGINS" ] && mpm plugin "$MCPLUGINS"

cd ..

# start spigot
while :; do

    #default op user
    cd ~/spigot || exit 1
    mpm op "${MCNAME:-Heinz007}"
    cat ops.json
    cd ~/spigot || exit 1

    # execute spigot.jar
    sleep 1
    mpm spigot "$MCVERSION"

    # custom motd
    if [ -e server.properties ] && [ -n "$MCMOTD" ]; then
        sed -i 's/motd=.*/motd='"$MCMOTD"'/g' server.properties
    fi

    mpm start "$MCMEMORY"
    echo "spigot exited"
    # move cache to save cloud storage
done &

sleep 10

echo "backup loop starting"

# upload spigot folder every 30 min
# copy it so it doesnt upload the copy that gets written to
while :; do

    sleep "${BACKUPTIME:-30}"m
    if pgrep rclone; then
        echo "rclone still running"
        continue
    fi

    echo "starting backup process"
    rm -rf ~/spigot/logs
    cd ~ || exit 1
    mkdir uploader
    cp -r spigot uploader/spigot
    cd uploader/spigot || exit 1
    rm plugins/*.mpm
    rm plugins/*.jar
    rm spigot.jar
    rm -rf cache
    cd ..
    rupl spigot
    rm -rf spigot
    cd ~/ || exit 1
    echo "restarting backup loop"
    sleep 2
done

echo 'how did you reach the end of the script?'
#end of script
