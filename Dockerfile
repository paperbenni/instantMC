FROM paperbenni/alpine

RUN apk update && apk upgrade && apk add curl grep bash jq git unzip man sed sqlite openjdk8 tree rm -rf /var/cache/apk/*
RUN curl https://rclone.org/install.sh | bash
RUN curl https://raw.githubusercontent.com/paperbenni/mpm/master/mpm.sh > /usr/bin/mpm && chmod 755 /usr/bin/mpm
COPY start.sh start.sh
RUN  chmod -R 777 /home/user

CMD ./start.sh
