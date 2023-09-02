# https://snyk.io/blog/10-best-practices-to-containerize-nodejs-web-applications-with-docker/
FROM node as build
RUN apt-get update && apt-get install -y --no-install-recommends dumb-init
ENV ALEXANDRITE_RUN_IN_NODE=true

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm ci
ENV NODE_ENV production
COPY . /usr/src/app
RUN npm run build

FROM debian:stable
COPY --from=build /usr/bin/dumb-init /usr/bin/dumb-init
WORKDIR /usr/src/app

COPY package*.json ./
RUN apt-get update
RUN apt-get install -y --no-install-recommends nodejs npm
RUN npm ci --only=production
USER node
COPY --chown=node:node --from=build /usr/src/app/build /usr/src/app/build
CMD ["dumb-init", "node", "build"]