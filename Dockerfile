FROM paperbenni/alpine

RUN apk add --update curl grep bash jq unzip man sed openjdk8 unzip screen

RUN mkdir /home/mineuser
ENV HOME=/home/mineuser

WORKDIR /home/mineuser

COPY install.sh install.sh
RUN bash install.sh && chmod -R 777 /home/mineuser

COPY rclone.conf .config/rclone/rclone.conf

COPY start.sh start.sh

CMD ./start.sh
