FROM python:3.7-alpine3.10

RUN apk add --update alpine-sdk
RUN apk add --update openssl-dev
RUN apk add --update libffi-dev

ADD ./ /app
WORKDIR /app

RUN pip install -q pip
RUN pip install -q pipenv
RUN pipenv install

EXPOSE 8080

CMD pipenv run gunicorn -w 2 --timeout 3600 -b 0.0.0.0:8080 "app.server:create_app(config='config.yaml')"