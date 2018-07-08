#!/bin/bash

rclone copy dropbox:"$ACCOUNTNAME"/password.txt ./password.txt

DROPBOXPASSWORD=$(cat ./password.txt)

if [ "$ACCOUNTPASSWORD" =  "$DROPBOXPASSWORD" ]
then #weiter
echo "Account verified"
else

while :
do
echo "Username already taken or wrong password!"
sleep 10
done

fi



rclone copy dropbox:"$ACCOUNTNAME"/spigot ./spigot

updateix(){
    if [ -n "$IXID" ]
    then
    echo $NEWNGROKADRESS | ./ix -i $IXID
    else
    echo $NEWNGROKADRESS | ./ix > spigot/ixadress.txt
    fi
}

if [ -f spigot/spigot.jar ]; then
   echo "spigot exists."
else
   curl -o spigot/spigot.jar https://ci.destroystokyo.com/job/PaperSpigot/lastSuccessfulBuild/artifact/paperclip.jar
fi 

echo "eula=true" > spigot/eula.txt

while :
do

curl "https://gist.githubusercontent.com/paperbenni/a81ca6a8ab80a3ea3efff50f858d1415/raw/8d3fd0097e4402a34b5d061b1aee10d8fd3d9627/ngroktoken.sh" | bash
./ngrok authtoken $(cat token.txt)

./ngrok tcp 25565 > /dev/null & 
sleep 5

NEWNGROKADRESS=$(echo $(curl -s localhost:4040/inspect/http | grep -oP 'window.common[^;]+' | sed 's/^[^\(]*("//' | sed 's/")\s*$//' | sed 's/\\"/"/g') | jq -r ".Session.Tunnels | values | map(.URL) | .[]" | grep "^tcp://" | sed 's/tcp\?:\/\///')

if [ -f spigot/ixadress.txt ]; then
    echo "adress exists"
    IXID=$(cat spigot/ixadress)
else
    echo "$NEWNGROKADRESS" | grep -oP "^$http://ix.io/\K.*" > spigot/ixadress.txt
    echo "adress created"
    IXID=$(cat spigot/ixadress)

fi 


if [ ! $NGROKADRESS == $NEWNGROKADRESS ]
then
updateix
NGROKADRESS=$NEWNGROKADRESS
fi

sleep 5

if [ ! -f ./adress.txt ]
then
updateix
echo true > adress.txt
else 
rm adress.txt
fi

sleep 10000

done & 

cd spigot
while :
do
java -Xmx650m -Xms650m -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -XX:MaxGCPauseMillis=45 -XX:TargetSurvivorRatio=90 -XX:G1NewSizePercent=50 -XX:G1MaxNewSizePercent=80 -XX:InitiatingHeapOccupancyPercent=10 -XX:G1MixedGCLiveThresholdPercent=50 -XX:+AggressiveOpts -jar spigot.jar
done

rm ./spigot.jar
rclone copy ../spigot dropbox:"$ACCOUNTNAME"spigot