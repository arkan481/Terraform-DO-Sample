FROM node

WORKDIR /usr/src/app

COPY ./package*.json ./

COPY ./scripts/post-install.js ./scripts/post-install.js

RUN npm install

COPY . .

USER node

EXPOSE 5000

CMD ["npm", "start"]