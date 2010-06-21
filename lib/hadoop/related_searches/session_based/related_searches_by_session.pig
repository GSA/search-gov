REGISTER s3://piggybank/0.6.0/piggybank.jar
DEFINE LOWER org.apache.pig.piggybank.evaluation.string.LOWER();
DEFINE SUBSTRING org.apache.pig.piggybank.evaluation.string.SUBSTRING();

set job.name 'related_searches_by_session'

rmf s3://usasearch-logs/related_searches_by_session
rmf s3://usasearch-logs-west/related_searches_by_session


topn_tfidf = LOAD 'topn_tfidf' AS (query:chararray, terms:chararray, tfidf_scores:chararray, counts:chararray);

cp s3://usasearch-logs/convert_tfidf_to_json.py convert_tfidf_to_json.py    -- copy to HDFS first
copyToLocal convert_tfidf_to_json.py /home/hadoop/convert_tfidf_to_json.py   -- copy from HDFS into local amazon instance

DEFINE convert_tfidf_to_json `convert_tfidf_to_json.py`
	SHIP ('/home/hadoop/convert_tfidf_to_json.py');

related_searches_std = STREAM topn_tfidf THROUGH convert_tfidf_to_json
	AS (query:chararray, related_searches_json:chararray);

related_searches_std = LOAD 'related_searches_std' AS (query:chararray, related_searches_json:chararray);

-- Map normalized query keys to orginal query variants
query_dictionary = LOAD 's3://usasearch-logs/query_dictionary.txt' AS (query:chararray, std_query:chararray, count:long);

top_queries = LOAD 's3://usasearch-logs/top_queries' AS (query:chararray, count:long);

-- find which queries in top 20k have been standardized
joined_top_dict = JOIN top_queries BY query, query_dictionary BY query;

normed_top_queries = FOREACH joined_top_dict GENERATE top_queries::query as query, 
  query_dictionary::std_query as std_query;
  
normed_top_queries = DISTINCT normed_top_queries;  

--   store normed_top_queries INTO 'normed_top_queries';


-- for those queries, join on std_query to related searches
joined_related_normed = JOIN normed_top_queries BY std_query, related_searches_std BY query;

normed_related_searches = FOREACH joined_related_normed GENERATE normed_top_queries::query as query,
  related_searches_std::related_searches_json as related_searches_json;

joined_top_related = JOIN top_queries BY query, related_searches_std BY query;

top_related = FOREACH joined_top_related GENERATE related_searches_std::query as query, related_searches_std::related_searches_json as related_searches_json;

all_related_queries = UNION top_related, normed_related_searches;

STORE all_related_queries INTO 's3://usasearch-logs/related_searches_by_session';

all_related_queries = LOAD 's3://usasearch-logs/related_searches_by_session' AS (query:chararray, related_searches_json:chararray);
STORE all_related_queries INTO 's3://usasearch-logs-west/related_searches_by_session';


