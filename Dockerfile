FROM --platform=linux/amd64 ruby:3.0.6
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
WORKDIR /usr/src/app
EXPOSE 3000

RUN apt-get update -y && apt-get install -y --no-install-recommends \
  default-jre \
  default-mysql-client \
  imagemagick \
  libprotobuf-dev \
  protobuf-compiler 

# Workaround for PhantomJS: https://github.com/DMOJ/online-judge/pull/1270
ENV OPENSSL_CONF /etc/ssl/

ENV NODE_VERSION 16.18.1
ENV NVM_DIR=/root/.nvm

COPY package.json yarn.lock ./

RUN apt install -y curl \
  && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash \
  && . "$NVM_DIR/nvm.sh" \
  && nvm install $NODE_VERSION \
  && nvm alias default $NODE_VERSION \
  && nvm use default \
  && npm install -g yarn \
  && yarn install

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

RUN gem install bundler:2.4.7 \
  && gem install therubyracer -v '0.12.3' --source 'https://rubygems.org/' -- --with-system-v8

COPY Gemfile* /usr/src/app/
ENV BUNDLE_PATH /gems
RUN bundle install

COPY . /usr/src/app/
# ENTRYPOINT ["./docker-entrypoint.sh"]
