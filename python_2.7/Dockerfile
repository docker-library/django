FROM python:2.7.9

RUN apt-get update && apt-get install -y mysql-client postgresql-client sqlite3 --no-install-recommends && rm -rf /var/lib/apt/lists/*

ENV DJANGO_VERSION 1.7.1

RUN pip install mysqlclient psycopg2 django=="$DJANGO_VERSION"
