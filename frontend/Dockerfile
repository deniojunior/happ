FROM node:12.18

ADD ./ /app
WORKDIR /app

RUN npm i
RUN npm run build
RUN npm install -g serve

EXPOSE 5000

CMD serve -s build
