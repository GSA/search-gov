pull-elastic:
	docker pull docker.elastic.co/elasticsearch/elasticsearch:5.6.16

run-elastic:
	docker run -p 9256\:9200 -p 9356\:9300 -e "discovery.type=single-node" docker.elastic.co/elasticsearch/elasticsearch:5.6.16

check-elastic:
	curl -u elastic\:changeme localhost:9256

