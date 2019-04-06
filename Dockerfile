FROM paperbenni/alpine

RUN chmod 777 /etc/passwd

RUN apk update && apk upgrade && apk add curl grep bash jq git unzip man sed sqlite openjdk8 tree && \
rm -rf /var/cache/apk/*

COPY .netrc .netrc
COPY rclone.conf .config/rclone/rclone.conf
COPY start.sh start.sh
COPY quark quark
RUN  chmod -R 777 /home/user

CMD ./start.sh
