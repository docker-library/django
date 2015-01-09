FROM python:3.4.2

RUN apt-get update && apt-get install -y mysql-client postgresql-client sqlite3 --no-install-recommends && rm -rf /var/lib/apt/lists/*

ENV DJANGO_VERSION 1.7.2

RUN pip install mysqlclient psycopg2 django=="$DJANGO_VERSION"
