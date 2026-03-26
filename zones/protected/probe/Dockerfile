FROM node:20-alpine

RUN apk add --no-cache curl

WORKDIR /app

COPY package*.json tsconfig.json ./
RUN npm install

COPY src ./src

EXPOSE 3000

CMD ["npm", "start"]
