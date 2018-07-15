#!/bin/bash

exe() {
        /lib64/ld-linux-x86-64.so.2 "$1"
}

savet() {
        echo "$1" > "$2".txt
}

gitexe() {
        curl https://raw.githubusercontent.com/paperbenni/"$1"/master/"$2".sh | bash
}

gitget() {
        curl https://raw.githubusercontent.com/paperbenni/"$1"/master/"$2".sh
}

#setup ix.io account
echo "machine ix.io" > .netrc
echo "    login $ACCOUNTNAME" >> .netrc
echo "    login $ACCOUNTPASSWORD" >> .netrc

echo "attempting login"

rclone copy dropbox:"$ACCOUNTNAME" ./"$ACCOUNTNAME" #weiter

mkdir .ngrok2

gitexe ngrok.sh ngrok &

while :
do
        gitexe ngrok.sh getgrok &
        mv ngrokadress.txt ix.txt
        gitexe ix.io ix
        sleep 2m
done


if [ -e "$ACCOUNTNAME"/password.txt ]; then #account exists
        cd "$ACCOUNTNAME" || echo "no ACCOUNTNAME folder"
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


cd "$ACCOUNTNAME"/spigot || ( mkdir -p "$ACCOUNTNAME"/spigot && cd "$ACCOUNTNAME"/spigot || echo "bruh" )

gitexe spigot.sh spigot

cd .. #into Accountname

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

echo 'quitting server :('
#end of script

