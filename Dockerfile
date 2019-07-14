FROM paperbenni/alpine

RUN chmod 777 /etc/passwd

RUN apk update && apk upgrade && apk add curl grep bash jq git unzip man sed sqlite openjdk8 tree subversion && \
rm -rf /var/cache/apk/*
RUN curl https://rclone.org/install.sh | bash
COPY .netrc .netrc
COPY start.sh start.sh
RUN  chmod -R 777 /home/user

CMD ./start.sh
