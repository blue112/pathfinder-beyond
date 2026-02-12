FROM haxe:4.3.7 AS build

RUN mkdir /build
COPY backend/ /build/backend
COPY frontend/ /build/frontend
WORKDIR /build/backend
RUN haxe make.hxml

FROM node:22
WORKDIR /app
COPY --from=0 /build/backend/package.json /app
COPY --from=0 /build/backend/package-lock.json /app
RUN npm ci
COPY --from=0 /build/backend/templates /app/templates
COPY --from=0 /build/backend/static /app/static
COPY --from=0 /build/backend/bin/ /app

CMD ["node", "server.js"]
