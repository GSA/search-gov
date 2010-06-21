REGISTER s3://piggybank/0.6.0/piggybank.jar
DEFINE LOWER org.apache.pig.piggybank.evaluation.string.LOWER();
DEFINE SUBSTRING org.apache.pig.piggybank.evaluation.string.SUBSTRING();

set job.name 'filtered_pairs'

rmf filtered_pairs
rmf s3://usasearch-logs/filtered_pairs

sessions = LOAD 's3://usasearch-logs/sessions' AS (
session_id:chararray, searches:chararray);

cp s3://usasearch-logs/query_pairs.py query_pairs.py    -- copy to HDFS first
copyToLocal query_pairs.py /home/hadoop/query_pairs.py   -- copy from HDFS into local amazon instance

cp s3://usasearch-logs/query_dictionary.pkl query_dictionary.pkl    -- copy to HDFS first
copyToLocal query_dictionary.pkl /home/hadoop/query_dictionary.pkl   -- copy from HDFS into local amazon instance

DEFINE query_pairs `query_pairs.py`
	SHIP ('/home/hadoop/query_pairs.py', '/home/hadoop/query_dictionary.pkl');
	
coo_queries = STREAM sessions THROUGH query_pairs
	AS (query:chararray, coquery:chararray);
	
grouped_coo = GROUP coo_queries BY (query, coquery) PARALLEL 50;
query_coo = FOREACH grouped_coo GENERATE $0.query as query, 
  $0.coquery as coquery, SIZE($1) as count;
filtered_pairs = FILTER query_coo BY count >= 5 PARALLEL 50;
STORE filtered_pairs INTO 'filtered_pairs';

filtered_pairs = LOAD 'filtered_pairs' AS (query:chararray, coquery:chararray, count:long);

STORE filtered_pairs INTO 's3://usasearch-logs/filtered_pairs';

--Records written : 21,376,075


