FROM java:8-jre-alpine

RUN chmod 777 /etc/passwd

RUN apk update && apk upgrade && apk add curl grep bash jq unzip man sed

RUN mkdir /home/mineuser
ENV HOME=/home/mineuser

WORKDIR /home/mineuser

COPY install.sh
RUN bash install.sh

COPY rclone.conf .config/rclone/rclone.conf

COPY start.sh start.sh

RUN  chmod -R 777 /home/mineuser

CMD ./start.sh
