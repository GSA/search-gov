REGISTER s3://piggybank/0.6.0/piggybank.jar
DEFINE LOWER org.apache.pig.piggybank.evaluation.string.LOWER();
DEFINE SUBSTRING org.apache.pig.piggybank.evaluation.string.SUBSTRING();

query_logs = LOAD 's3://datawrangling-datasets/AOL_search_logs/AOL-user-ct-collection/' as (
  AnonID:int,
  Query:chararray,
  QueryTime:chararray,
  ItemRank:int,
  ClickURL:chararray);

search_logs = FOREACH query_logs GENERATE AnonID, Query, QueryTime, ClickURL;

-- describe search_logs;
-- search_logs: {AnonID: int,Query: chararray,QueryTime: chararray,ClickURL: chararray}

STORE search_logs INTO 's3://datawrangling-datasets/AOL_search_logs/search_logs';
-- Records written : 36,389,577