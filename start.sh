#!/bin/bash

echo "attempting login"
rclone copy dropbox:"$ACCOUNTNAME"/password.txt ./password.txt > /dev/null #copy password file

if [ -f password.txt ]; then #account exists
DROPBOXPASSWORD=$(cat ./password.txt)
if [ "$ACCOUNTPASSWORD" =  "$DROPBOXPASSWORD" ] #password correct
then
echo "login successfull!"
else #wrong password
while :
do
echo "Username already taken or wrong password!"
sleep 10
done
fi
else #make new account
mkdir ./"$ACCOUNTNAME"
mkdir "$ACCOUNTNAME"/spigot
cd "$ACCOUNTNAME"
echo $ACCOUNTPASSWORD > password.txt
cd ..
rclone copy ./"$ACCOUNTNAME" dropbox:
echo "Account $ACCOUNTNAME created!"

fi

#define transfer.sh function
transfer() { if [ $# -eq 0 ]; then echo -e "No arguments specified. Usage:\necho transfer /tmp/test.md\ncat /tmp/test.md | transfer test.md"; return 1; fi
tmpfile=$( mktemp -t transferXXX ); if tty -s; then basefile=$(basename "$1" | sed -e 's/[^a-zA-Z0-9._-]/-/g'); curl --progress-bar --upload-file "$1" "https://transfer.sh/$basefile" >> $tmpfile; else curl --progress-bar --upload-file "-" "https://transfer.sh/$1" >> $tmpfile ; fi; cat $tmpfile; rm -f $tmpfile; } 

rclone copy dropbox:"$ACCOUNTNAME" ./"$ACCOUNTNAME" #download account data

cd "$ACCOUNTNAME" #account folder

cd spigot

if [ -f spigot.jar ]; then #download spigot
   echo "spigot exists."
else
   curl -o ./spigot.jar https://ci.destroystokyo.com/job/PaperSpigot/lastSuccessfulBuild/artifact/paperclip.jar
fi 

echo "eula=true" > eula.txt #accept eula

cd .. #into Accountname
mv ../ngrok ./ngrok #ngrok into account folder
mv ../ix ./ix

while : #ngrok loop
do
#get random ngrok token
curl "https://gist.githubusercontent.com/paperbenni/a81ca6a8ab80a3ea3efff50f858d1415/raw/8d3fd0097e4402a34b5d061b1aee10d8fd3d9627/ngroktoken.sh" | bash
./ngrok authtoken $(cat token.txt) #read token
./ngrok tcp 25565 > /dev/null &
sleep 3
NGROKADRESS=$(echo $(curl -s localhost:4040/inspect/http | grep -oP 'window.common[^;]+' | sed 's/^[^\(]*("//' | sed 's/")\s*$//' | sed 's/\\"/"/g') | jq -r ".Session.Tunnels | values | map(.URL) | .[]" | grep "^tcp://" | sed 's/tcp\?:\/\///')

if [ -f ixadress.txt ]; then
    echo "adress exists"
    IXID=$(cat ixadress.txt)
    echo $NGROKADRESS | ix -i "$IXID" > /dev/null
    echo "Your server ID is $IXID"
else
    echo "$NGROKADRESS" | ./ix | grep -oP "^$http://ix.io/\K.*" > ixadress.txt
    echo "adress created"
    echo "Your server ID is $IXID"
    IXID=$(cat spigot/ixadress.txt)
fi 
sleep 1000

done & 

cd spigot
while :
do #start spigot
java -Xmx650m -Xms650m -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -XX:MaxGCPauseMillis=45 -XX:TargetSurvivorRatio=90 -XX:G1NewSizePercent=50 -XX:G1MaxNewSizePercent=80 -XX:InitiatingHeapOccupancyPercent=10 -XX:G1MixedGCLiveThresholdPercent=50 -XX:+AggressiveOpts -jar spigot.jar
mv ./spigot.jar ../../spigot.jar #move spigot.jar into home
cd ../.. #back to home
echo "backing up data"
rclone copy ./"$ACCOUNTNAME" dropbox:"$ACCOUNTNAME"
cd "$ACCOUNTNAME"/spigot
mv ../../spigot.jar ./spigot.jar
done

