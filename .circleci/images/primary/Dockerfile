# using legacy image for phantomjs
FROM circleci/ruby:2.3.8-browsers-legacy

USER root

RUN apt-get update && apt-get install -y \
  mysql-client \
  libprotobuf-dev \
  protobuf-compiler

# Install Dockerize to ensure services are started before test runs
# https://support.circleci.com/hc/en-us/articles/360006773953-Race-Conditions-Wait-For-Database
ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
  && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
  && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

USER circleci
