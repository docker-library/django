FROM python:3.4.2-slim

RUN apt-get update && apt-get install -y \
		mysql-client libmysqlclient-dev \
		postgresql-client libpq-dev \
		sqlite3 \
		gcc \
	--no-install-recommends && rm -rf /var/lib/apt/lists/*

ENV DJANGO_VERSION 1.7.5

RUN pip install mysqlclient psycopg2 django=="$DJANGO_VERSION"
