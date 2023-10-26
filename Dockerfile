FROM node:19-alpine AS build

RUN addgroup -S app && adduser -S app -G app \
	&& mkdir /app && chown app:app /app \
	&& apk add --update --no-cache python3 py3-pip make g++ git

USER app

WORKDIR /app

COPY ./app/package.json ./
COPY ./app/tsconfig.json ./
COPY ./app/craco.config.js ./craco.config.js
COPY ./app/public ./public
COPY ./app/src ./src

RUN npm install --legacy-peer-deps
RUN npm run build

FROM node:19-alpine AS release

RUN addgroup -S app && adduser -S app -G app \
	&& mkdir /app && chown app:app /app
	# && apk add --update --no-cache python3 py3-pip make g++ git

COPY --from=build /app/build /app

RUN chown -R app:app /app
RUN npm install -g serve

USER app

WORKDIR /app

CMD ["/usr/local/bin/serve"]
ARG ["-s" "build"]
