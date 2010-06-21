REGISTER s3://piggybank/0.6.0/piggybank.jar
DEFINE LOWER org.apache.pig.piggybank.evaluation.string.LOWER();
DEFINE SUBSTRING org.apache.pig.piggybank.evaluation.string.SUBSTRING();
DEFINE RegexMatch org.apache.pig.piggybank.evaluation.string.RegexMatch();
DEFINE RegexExtract org.apache.pig.piggybank.evaluation.string.RegexExtract();

set job.name 'top_queries'

rmf s3://usasearch-logs/top_queries

search_logs = LOAD 's3://usasearch-logs/search_logs' AS (
AnonID:int, Query:chararray, QueryTime:chararray, ClickURL:chararray);
-- lower case and strip site:foo.gov from queries
queries = FOREACH search_logs GENERATE LOWER(Query) as Query, RegexExtract(LOWER(Query), '^(site:\\S+\\s+)(.*)',2) as CleanQuery, AnonID;
queries = FOREACH queries GENERATE ((CleanQuery is null) ? Query : CleanQuery) as Query, AnonID;

grouped_queries = GROUP queries by Query;
query_counts = FOREACH grouped_queries GENERATE $0, SIZE($1) as count;
top_queries = FILTER query_counts BY count >= 250; 
sorted_queries = ORDER top_queries BY count DESC;
STORE sorted_queries INTO 's3://usasearch-logs/top_queries';

-- Records written : 15,158,388 (>=2)
-- Records written : 21,233 (>=250)




--String RegexExtract(String expression, String regex, int match_index).
--Input:
--expression-source string.
--regex-regular expression.
--match_index-index of the group to extract.
--Output:
--extracted group, if fail, return null.
