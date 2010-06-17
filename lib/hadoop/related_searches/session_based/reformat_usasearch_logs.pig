-- query log rows have the following format
-- (query:chararray, user_hash:chararray, timestamp:chararray, affiliate:chararray, locale:chararray, agent:chararray, is_bot:chararray);
-- locale, agent, and is_bot are all NULL in the current extract and can be ignored for now.

-- click log rows have the following format:
--q1 = LOAD 's3://usasearch-logs/clicksSample' AS (query:chararray,
--user_hash:chararray, stimestamp:chararray, ctimestamp:chararray,
--url:chararray, position:long, affiliate:chararray, source:chararray );


REGISTER s3://piggybank/0.6.0/piggybank.jar

DEFINE LOWER org.apache.pig.piggybank.evaluation.string.LOWER();

set job.name 'reformat_usasearch_logs'

rmf s3://usasearch-logs/search_logs

query_logs = LOAD 's3://usasearch-logs/queries_extract_pii' AS (query:chararray, user_hash:chararray, timestamp:chararray, affiliate:chararray, locale:chararray, agent:chararray, is_bot:chararray);

search_logs = FOREACH query_logs GENERATE user_hash as AnonID, query as Query, timestamp as QueryTime, affiliate as ClickURL;

-- describe search_logs;
-- search_logs: {AnonID: chararray,Query: chararray,QueryTime: chararray,ClickURL: chararray}

STORE search_logs INTO 's3://usasearch-logs/search_logs';
-- Records written : 72,858,324
