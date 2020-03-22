#!/bin/bash
export HOME=/home/user
HOME=/home/user

cd
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
SERVPORT=${SPORT:-0}
echo "using minecraft version $MINECRAFTVERSION"

cd
mkdir -p .config/rclone
cd .config/rclone

if [ -z "$DROPTOKEN" ]; then
    rcloud mineglory
    HCLOUDNAME="default mega"
else
    echo "using dropbox storage"
    rm rclone.conf
    touch rclone.conf
    pb rclone/dropbox
    addbox "$DROPTOKEN" "mineglory"
    HCLOUDNAME="dropbox"
fi

cd
cat .config/rclone/rclone.conf

rclogin mineglory "$USERNAME" "$PASSWORD"
cat ~/.config/rclone/rclone.conf

# handle tcp tunneling and the web server
mkdir ~/.ssh
ssh-keyscan -H -p 2222 paperbenni.mooo.com >>~/.ssh/known_hosts

while :; do
    mpm tunnel "$SERVPORT"
    sleep 2
done &

#download world data from dropbox
cd $HOME
rdl spigot
cd $HOME
mkdir -p spigot/plugins
rm -rf spigot/logs
cd spigot

# install plugin
rm plugins/*.mpm
rm plugins/*.jar
mpm install

[ -n "$MCPLUGINS" ] && mpm plugin "$MCPLUGINS"

cd ..

# start spigot
while :; do

    #default op user
    cd ~/spigot
    mpm op "${MCNAME:-Heinz007}"
    cat ops.json
    cd ~/spigot

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

    sleep ${BACKUPTIME:-30}m
    if pgrep rclone; then
        echo "rclone still running"
        continue
    fi

    echo "starting backup process"
    rm -rf ~/spigot/logs
    cd ~
    mkdir uploader
    cp -r spigot uploader/spigot
    cd uploader/spigot
    rm plugins/*.mpm
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
