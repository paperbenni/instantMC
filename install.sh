#!/usr/bin/env bash

cd $HOME
mkdir ngrok
cd ngrok
wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
unzip *.zip
rm *.zip
chmod +x ngrok
cd ..


mkdir test
cd test
wget https://downloads.rclone.org/v1.46/rclone-v1.46-linux-amd64.zip
unzip *.zip
chmod +x */rclone
mv */rclone /bin/
cd ..
rm -rf test
