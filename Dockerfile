FROM node:14-alpine3.14

WORKDIR /usr/src/app

COPY ./package*.json ./

RUN npm install

COPY . .

USER node

EXPOSE 5000

CMD ["npm", "start"]