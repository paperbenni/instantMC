#!/bin/bash
###########################################################################
## install script to run instantMC on a container that's already running ##
###########################################################################

echo "installing instantMC"

RAW="https://raw.githubusercontent.com/paperbenni/instantMC/master/"

if ! grep -qi 'alpine' /etc/os-release; then
    echo "this is currently only supported on alpine"
fi

apk update
apk add bash git curl wget vim subversion busybox-extras autossh screen

mkdir -p /home/user

curl -s "$RAW/Dockerfile" | grep -E '(^RUN|^[^A-Z])' | sed 's/RUN//g' | bash
curl -s "$RAW/start.sh" >/usr/bin/instantmc
curl -s "$RAW/local/startmc" >/usr/bin/spigot
curl -s "$RAW/local/attachmc" >/usr/bin/attachspigot

chmod 755 /usr/bin/instantmc
chmod 755 /usr/bin/spigot
chmod 755 /usr/bin/attachspigot
