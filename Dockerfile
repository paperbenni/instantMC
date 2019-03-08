FROM paperbenni/alpine

RUN chmod 777 /etc/passwd

RUN apk add --update curl grep bash jq unzip man sed openjdk8

RUN mkdir /home/mineuser
ENV HOME=/home/mineuser

WORKDIR /home/mineuser

COPY install.sh
RUN bash install.sh

COPY rclone.conf .config/rclone/rclone.conf

COPY start.sh start.sh

RUN  chmod -R 777 /home/mineuser

CMD ./start.sh
