# Multi-Stage Dockerfile

FROM node:14.17.3-buster as build

WORKDIR /app

# COPY ["package*.json", "/app/"]
COPY ./package-lock.json ./package-lock.json

#RUN npm i

COPY . .

RUN npm ci --production

COPY . .

RUN npm run build

# NGNIX Web Server
FROM nginx:stable-alpine as prod

COPY --from=build /app/build /usr/share/nginx/html/counter-app

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]


# FROM node:latest AS node_base
# WORKDIR /app
# COPY ["LoneWolf.Web/package*.json", "/app/"]
# COPY ["./package*.json", "/app/"]
# COPY ./ ./
# RUN npm install -g npm@8.1.4
# CMD ["npm", "run", "start"]

# Stage 1 - Building image
#FROM node:8.7.0-alpine as node
# Old Code Starts Here
# FROM node:latest as node

# WORKDIR /app

# COPY package*.json ./

# # RUN npm i react-scripts
# RUN npm install -g npm@8.1.4 react-scripts 
# Old Code Ends Here


# FROM node:lts-buster
# WORKDIR /app
# COPY ./package.json ./
# COPY ./package-lock.json ./
# COPY ./ ./
# RUN npm i
# CMD ["npm", "run", "start"]


# FROM alpine:3.12

# WORKDIR /app

# COPY package*.json ./
# ENV NODE_VERSION 12.22.7

# RUN addgroup -g 1000 node \
#     && adduser -u 1000 -G node -s /bin/sh -D node \
#     && apk add --no-cache \
#         libstdc++ \
#     && apk add --no-cache --virtual .build-deps \
#         curl \
#     && ARCH= && alpineArch="$(apk --print-arch)" \
#       && case "${alpineArch##*-}" in \
#         x86_64) \
#           ARCH='x64' \
#           CHECKSUM="c8672a664087e96b4e2804caf77a0aaa8c1375ae6b378edb220a678155383a81" \
#           ;; \
#         *) ;; \
#       esac \
#   && if [ -n "${CHECKSUM}" ]; then \
#     set -eu; \
#     curl -fsSLO --compressed "https://unofficial-builds.nodejs.org/download/release/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz"; \
#     echo "$CHECKSUM  node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz" | sha256sum -c - \
#       && tar -xJf "node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
#       && ln -s /usr/local/bin/node /usr/local/bin/nodejs; \
#   else \
#     echo "Building from source" \
#     # backup build
#     && apk add --no-cache --virtual .build-deps-full \
#         binutils-gold \
#         g++ \
#         gcc \
#         gnupg \
#         libgcc \
#         linux-headers \
#         make \
#         python2 \
#     # gpg keys listed at https://github.com/nodejs/node#release-keys
#     && for key in \
#       4ED778F539E3634C779C87C6D7062848A1AB005C \
#       94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
#       74F12602B6F1C4E913FAA37AD3A89613643B6201 \
#       71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
#       8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
#       C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
#       C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
#       DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
#       A48C2BEE680E841632CD4E44F07496B3EB3C1762 \
#       108F52B48DB57BB0CC439B2997B01419BD92F80A \
#       B9E2F5981AA6E0CD28160D9FF13993A75599653C \
#     ; do \
#       gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$key" || \
#       gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" ; \
#     done \
#     && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.xz" \
#     && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
#     && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
#     && grep " node-v$NODE_VERSION.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
#     && tar -xf "node-v$NODE_VERSION.tar.xz" \
#     && cd "node-v$NODE_VERSION" \
#     && ./configure \
#     && make -j$(getconf _NPROCESSORS_ONLN) V= \
#     && make install \
#     && apk del .build-deps-full \
#     && cd .. \
#     && rm -Rf "node-v$NODE_VERSION" \
#     && rm "node-v$NODE_VERSION.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt; \
#   fi \
#   && rm -f "node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz" \
#   && apk del .build-deps \
#   # smoke tests
#   && node --version \
#   && npm --version

# ENV YARN_VERSION 1.22.15

# RUN apk add --no-cache --virtual .build-deps-yarn curl gnupg tar \
#   && for key in \
#     6A010C5166006599AA17F08146C2130DFD2497F5 \
#   ; do \
#     gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$key" || \
#     gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" ; \
#   done \
#   && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
#   && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz.asc" \
#   && gpg --batch --verify yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
#   && mkdir -p /opt \
#   && tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/ \
#   && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
#   && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg \
#   && rm yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
#   && apk del .build-deps-yarn \
#   # smoke test
#   && yarn --version

# COPY docker-entrypoint.sh /usr/local/bin/
# ENTRYPOINT ["docker-entrypoint.sh"]

# CMD [ "node" ]
# # Old Starts here above is new code
# RUN npm config set package-lock true
# # RUN npm install -g npm@8.1.4 react-scripts
# RUN npm i react-scripts
# # RUN npm i -g npm@8.1.4 react-helix
# # RUN npm i -g npm@8.1.4  @helix-design-system/helix-react
# # RUN npm install lwt
# # RUN npm install @lwt-helix/page
# RUN npm i react-redux 
# RUN npm i typescript
# COPY . .

# RUN npm run build

# Stage 2 - Running image
# FROM bitnami/nginx:1.14.2

# COPY --from=node /app/build /var/www/LoneWolf
# COPY ./nginx.conf /opt/bitnami/nginx/conf/nginx.conf

