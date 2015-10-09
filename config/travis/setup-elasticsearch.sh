#!/bin/bash -x
rm -fr $HOME/elasticsearch
mkdir -p $HOME/elasticsearch
mkdir -p $HOME/elasticsearch/data
mkdir -p $HOME/elasticsearch/logs
cp -p config/travis/elasticsearch-client.yml config/elasticsearch.yml
cat config/elasticsearch.yml
sed "s#__HOME__#$HOME#g;" config/travis/elasticsearch-server.yml > $HOME/elasticsearch/elasticsearch.yml
cat $HOME/elasticsearch/elasticsearch.yml
sed "s#__HOME__#$HOME#g;" config/travis/elasticsearch.sh > $HOME/elasticsearch/elasticsearch.sh
cat $HOME/elasticsearch/elasticsearch.sh
bash -x $HOME/elasticsearch/elasticsearch.sh
