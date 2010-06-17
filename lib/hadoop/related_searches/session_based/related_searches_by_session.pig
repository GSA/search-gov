REGISTER s3://piggybank/0.6.0/piggybank.jar
DEFINE LOWER org.apache.pig.piggybank.evaluation.string.LOWER();
DEFINE SUBSTRING org.apache.pig.piggybank.evaluation.string.SUBSTRING();

set job.name 'related_searches_by_session'

rmf s3://usasearch-logs/related_searches_by_session

filtered_pairs = LOAD 's3://usasearch-logs/filtered_pairs' AS (
query:chararray, coquery:chararray, count:int);

-- compute tfidf of first element of query pairs vs co-query
-- rank by tfidf and return top N TFIDF pairs as related searches, de-weighting common co-queries
