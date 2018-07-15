#!/bin/bash

exe() {
        /lib64/ld-linux-x86-64.so.2 "$1"
}

#setup ix.io account
echo "machine ix.io" > .netrc
echo "    login $ACCOUNTNAME" >> .netrc
echo "    login $ACCOUNTPASSWORD" >> .netrc

echo "attempting login"
rclone copy dropbox:"$ACCOUNTNAME" ./"$ACCOUNTNAME" #weiter

mkdir .ngrok2

curl ngrok.surge.sh/ngrok.sh | bash &

while :
do
        curl ngrok.surge.sh/getgrok.sh | bash
        sleep 2m
done

if [ -f "$ACCOUNTNAME"/password.txt ]; then #account exists
        cd "$ACCOUNTNAME" || echo "no ACCOUNTNAME folder")
    DROPBOXPASSWORD=$(cat ./password.txt)
    if [ "$ACCOUNTPASSWORD" =  "$DROPBOXPASSWORD" ] #password correct
    then
        echo "login successfull!"
        rclone copy dropbox:"$ACCOUNTNAME" ./"$ACCOUNTNAME" #download account data
    else #wrong password
        while :
        do
            echo "Username already taken or wrong password!"
            sleep 10
        done
    fi
else #make new account
    mkdir ./"$ACCOUNTNAME"
    (
    cd "$ACCOUNTNAME" || echo "no Account folder"
    mkdir spigot
    echo "$ACCOUNTPASSWORD" > ./password.txt
    )
    rclone copy ./"$ACCOUNTNAME" dropbox:"$ACCOUNTNAME"
    echo "Account $ACCOUNTNAME created!"
fi

#define transfer.sh function
transfer() { if [ $# -eq 0 ]; then echo -e "No arguments specified. Usage:\necho transfer /tmp/test.md\ncat /tmp/test.md | transfer test.md"; return 1; fi
tmpfile=$( mktemp -t transferXXX ); if tty -s; then basefile=$(basename "$1" | sed -e 's/[^a-zA-Z0-9._-]/-/g'); curl --progress-bar --upload-file "$1" "https://transfer.sh/$basefile" >> "$tmpfile"; else curl --progress-bar --upload-file "-" "https://transfer.sh/$1" >> "$tmpfile" ; fi; cat "$tmpfile"; rm -f "$tmpfile"; } 


cd "$ACCOUNTNAME" || echo "no Account" #account folder

cd spigot || echo "no spigot folder there"

if [ -f spigot.jar ]; then #download spigot
   echo "spigot exists."
else
    curl -o spigot.jar https://destroystokyo.com/ci/job/Paper/lastSuccessfulBuild/artifact/paperclip.jar
fi 

if [ -f cache ]; then #download cache
   echo "cache exists."
else
    mkdir cache
    cd cache || echo "no cache" || echo "no cache"
    echo "downloading minecraft 1.12"
    curl -o mojang_1.12.2.jar https://spigot.surge.sh/cache/mojang_1.12.2.jar
    echo "downloading patched 1.12"
    curl -o patched_1.12.2.jar https://spigot.surge.sh/cache/patched_1.12.2.jar
    cd ..
fi 

echo "eula=true" > eula.txt #accept eula

cd .. #into Accountname


while : #ngrok loop
do

if [ -f ixadress.txt ]; then
    echo "adress exists"
    IXID=$(cat ixadress.txt)
    echo "$NGROKADRESS" | ../ix -i "$IXID" > /dev/null
    echo "Your server ID is $IXID"
else
    echo "$NGROKADRESS" | ../ix > ixadress2.txt
    cat ixadress2.txt | cut -c2-6 > ixadress.txt
    IXID=$(cat ixadress.txt)
    echo "adress created"
    echo "Your server ID is $IXID"
fi 
sleep 1000

done & 
sleep 10

cd spigot || (mkdir spigot && cd spigot) || echo "no perms for spigot folder!"

while :
do #start spigot
java -Xmx650m -Xms650m -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -XX:MaxGCPauseMillis=45 -XX:TargetSurvivorRatio=90 -XX:G1NewSizePercent=50 -XX:G1MaxNewSizePercent=80 -XX:InitiatingHeapOccupancyPercent=10 -XX:G1MixedGCLiveThresholdPercent=50 -XX:+AggressiveOpts -jar spigot.jar
sleep 10
mv ./spigot.jar ../../spigot.jar #move spigot.jar into home
mv ./cache ../../cache #move cache into home
sleep 10
cd ../.. || echo "no home folder" #back to home
echo "backing up data"
sleep 10
rclone copy ./"$ACCOUNTNAME" dropbox:"$ACCOUNTNAME"
sleep 10
cd "$ACCOUNTNAME"/spigot || echo "no spigot folder"
mv ../../spigot.jar ./spigot.jar
mv ../../cache ./cache
sleep 10
done

