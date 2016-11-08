FROM alpine:3.4

ENV DJANGO_VERSION 1.10.3

RUN apk add --update-cache \
            bash python3 \
            mariadb-libs libpq sqlite && \
    apk add --virtual=build-deps \
            gcc musl-dev python3-dev \
            wget ca-certificates \
            mariadb-dev postgresql-dev && \
    wget https://bootstrap.pypa.io/get-pip.py --no-verbose --output-document - | \
         python3 && \
    pip install mysqlclient \
                psycopg2 \
                django=="$DJANGO_VERSION" && \
    apk del build-deps && rm -rf /var/cache/apk/*

RUN cd /usr/bin && ln -sf python3 python
