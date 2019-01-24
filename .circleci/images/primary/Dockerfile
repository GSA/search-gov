# using legacy image for phantomjs
FROM circleci/ruby:2.3.8-browsers-legacy

USER root

RUN apt-get update && apt-get install -y \
  mysql-client \
  libprotobuf-dev \
  protobuf-compiler

USER circleci
