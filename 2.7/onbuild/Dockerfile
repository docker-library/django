FROM alpine:3.3

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ONBUILD COPY requirements.txt /usr/src/app/
ONBUILD RUN pip install --no-cache-dir -r requirements.txt

ONBUILD COPY . /usr/src/app

RUN apk add --update \
               gcc musl-dev python-dev py-pip \
               mariadb-dev \
               postgresql-dev \
               sqlite && \
        rm -rf /var/cache/apk/*

EXPOSE 8000
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
