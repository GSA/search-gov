#!/bin/bash -x

ES_HOME=/usr/share/elasticsearch
ES_CLASSPATH=$ES_CLASSPATH:$ES_HOME/lib/*:$ES_HOME/lib/sigar/*
ES_HEAP_SIZE=1024m

nohup java \
  -server \
  -Djava.net.preferIPv4Stack=true \
  -Des.config=__HOME__/elasticsearch/elasticsearch.yml \
  -Xms$ES_HEAP_SIZE \
  -Xmx$ES_HEAP_SIZE \
  -Xss256k \
  -XX:+UseParNewGC \
  -XX:+UseConcMarkSweepGC \
  -XX:CMSInitiatingOccupancyFraction=75 \
  -XX:+UseCMSInitiatingOccupancyOnly \
  -XX:+HeapDumpOnOutOfMemoryError \
  -Delasticsearch \
  -Des.pidfile=__HOME__/elasticsearch.pid \
  -Des.path.home=$ES_HOME \
  -cp $ES_CLASSPATH \
  org.elasticsearch.bootstrap.Elasticsearch &

count=0
up="no"
while [[ ($up == "no") && ($count -lt 30) ]]; do
  let count=$count+1
  curl -s localhost:9200/ 2>&1 > /dev/null
  if [ $? -eq 0 ]; then
    up="yes"
  else
    sleep 1
  fi
done

if [ $up == "no" ]; then
  echo "Elasticsearch server did not start, log files say:"
  cat __HOME__/elasticsearch/logs/*
  exit 1
else
  exit 0
fi
