FROM java:8-jre-alpine

RUN chmod 777 /etc/passwd

RUN apk update && apk upgrade && apk add curl grep bash jq git unzip man sed sqlite

RUN mkdir /home/mineuser

ENV HOME=/home/mineuser

WORKDIR /home/mineuser

COPY rclone.conf .config/rclone/rclone.conf
COPY rclone rclone
COPY start.sh start.sh
ENV PATH="/home/mineuser/rclone:${PATH}"
RUN  chmod -R 777 /home/mineuser

CMD ./start.sh
