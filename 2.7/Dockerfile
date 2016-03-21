FROM alpine:3.3

RUN apk add \
               gcc musl-dev python-dev py-pip \
               mariadb-dev \
               postgresql-dev \
               sqlite \
        --update-cache && rm -rf /var/cache/apk/*

ENV DJANGO_VERSION 1.9.4

RUN pip install mysqlclient psycopg2 django=="$DJANGO_VERSION"
