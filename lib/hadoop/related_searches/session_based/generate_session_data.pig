REGISTER s3://piggybank/0.6.0/piggybank.jar
DEFINE LOWER org.apache.pig.piggybank.evaluation.string.LOWER();
DEFINE SUBSTRING org.apache.pig.piggybank.evaluation.string.SUBSTRING();
DEFINE RegexMatch org.apache.pig.piggybank.evaluation.string.RegexMatch();
DEFINE RegexExtract org.apache.pig.piggybank.evaluation.string.RegexExtract();

set job.name 'generate_session_data'
rmf s3://usasearch-logs/sessions

search_logs = LOAD 's3://usasearch-logs/search_logs' AS (
AnonID:chararray, Query:chararray, QueryTime:chararray, ClickURL:chararray);
queries = FOREACH search_logs GENERATE AnonID, SUBSTRING(QueryTime, 0, 10) as QueryDate, Query; 

-- lower case and strip site:foo.gov from queries
queries = FOREACH queries GENERATE AnonID, QueryDate, LOWER(Query) as Query, 
  RegexExtract(LOWER(Query), '^(site:\\S+\\s+)(.*)',2) as CleanQuery;

queries = FOREACH queries GENERATE AnonID, QueryDate, 
  ((CleanQuery is null) ? Query : CleanQuery) as Query;

queries = DISTINCT queries;
sessions = GROUP queries BY (AnonID, QueryDate);
sessions = FOREACH sessions GENERATE $0 as session_id, $1.Query as searches, SIZE($1) as count;
sessions = FILTER sessions BY (count >1) AND (count <=500);
sessions = FOREACH sessions GENERATE session_id, searches;
STORE sessions INTO 's3://usasearch-logs/sessions';

--Records written : 7,168,620
