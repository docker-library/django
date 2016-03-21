FROM alpine:3.3

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ONBUILD COPY requirements.txt /usr/src/app/
ONBUILD RUN apk add --virtual=build-deps --update-cache \
                    gcc musl-dev python-dev \
                    mariadb-dev postgresql-dev && \
            pip install --no-cache-dir -r requirements.txt && \
            apk del build-deps && rm -rf /var/cache/apk/*

ONBUILD COPY . /usr/src/app

RUN apk add --update-cache \
            bash py-pip \
            mariadb-libs libpq sqlite && rm -rf /var/cache/apk/*

EXPOSE 8000
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
