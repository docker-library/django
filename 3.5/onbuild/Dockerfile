FROM alpine:3.3

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ONBUILD COPY requirements.txt /usr/src/app/
ONBUILD RUN apk add --virtual=build-deps --update-cache \
                    gcc musl-dev python3-dev \
                    mariadb-dev postgresql-dev && \
            pip install --no-cache-dir -r requirements.txt && \
            apk del build-deps && rm -rf /var/cache/apk/*

ONBUILD COPY . /usr/src/app

# A bug in Alpine ca-certificates package requires installing openssl-dev as well
RUN apk add --update-cache \
            bash python3 \
            mariadb-libs libpq sqlite && \
    apk add --virtual=pip-deps \
            wget ca-certificates openssl-dev && \
    wget https://bootstrap.pypa.io/get-pip.py --no-verbose --output-document - | \
         python3 && \
    apk del pip-deps && rm -rf /var/cache/apk/*

RUN cd /usr/bin && ln -sf python3 python

EXPOSE 8000
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
