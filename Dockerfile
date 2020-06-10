FROM ruby:2.5

RUN apt-get update -y && apt-get install -y --no-install-recommends \
  default-jre \
  default-mysql-client \
  libprotobuf-dev \
  protobuf-compiler

# Workaround for PhantomJS: https://github.com/DMOJ/online-judge/pull/1270
ENV OPENSSL_CONF /etc/ssl/

# Install PhantomJS for cucumber features
RUN wget -q https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 && \
  tar xvjf phantomjs-2.1.1-linux-x86_64.tar.bz2 -C /usr/local/share/ && \
  rm phantomjs-2.1.1-linux-x86_64.tar.bz2 && \
  ln -s /usr/local/share/phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin/phantomjs \
  && echo "PhantomJS version $(phantomjs --version) installed"

COPY Gemfile* /usr/src/app/
WORKDIR /usr/src/app

ENV BUNDLE_PATH /gems

RUN bundle install

COPY . /usr/src/app/


ENTRYPOINT ["./docker-entrypoint.sh"]
