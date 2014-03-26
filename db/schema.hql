CREATE TABLE queries (
 host STRING,
 time STRING,
 request STRING,
 size INT,
 referer STRING,
 agent STRING,
 raw_query STRING,
 normalized_query STRING,
 affiliate STRING,
 locale STRING,
 is_bot TINYINT,
 is_contextual TINYINT)
PARTITIONED BY (ds STRING)
STORED AS TEXTFILE ;

CREATE TABLE daily_query_ip_stats (
 query STRING,
 host STRING,
 affiliate STRING,
 locale STRING,
 counter INT)
PARTITIONED BY (ds STRING)
STORED AS TEXTFILE ;

CREATE TABLE proportions (
 query STRING,
 total_queries INT,
 unique_ips INT,
 proportion FLOAT)
STORED AS TEXTFILE ;

CREATE TABLE usagov (
 host STRING,
 identity STRING,
 user STRING,
 time STRING,
 site STRING,
 request STRING,
 status STRING,
 size STRING,
 referer STRING,
 agent STRING,
 dash STRING)
PARTITIONED BY (ds STRING)
ROW FORMAT SERDE 'org.apache.hadoop.hive.contrib.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
 "input.regex" = "([^ ]*) ([^ ]*) ([^ ]*) (-|\\[[^\\]]*\\]) ([^ ]*) ([^ \"]*|\"[^\"]*\") (-|[0-9]*) (-|[0-9]*)(?: ([^ \"]*|\"[^\"]*\") ([^ \"]*|\"[^\"]*\") ([^ \"]*|\"[^\"]*\"))?",
 "output.format.string" = "%1$s %2$s %3$s %4$s %5$s %6$s %7$s %8$s %9$s %10$s %11$s"
)
STORED AS TEXTFILE;

CREATE TABLE bing_times (
 time_ms STRING)
PARTITIONED BY (ds STRING)
ROW FORMAT SERDE 'org.apache.hadoop.hive.contrib.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
"input.regex" = "[^0-9]*([0-9]*\.[0-9]).*","output.format.string" = "%1$s"
)
STORED AS TEXTFILE;

CREATE TABLE search_impressions (
 time STRING,
 query STRING,
 modules STRING)
PARTITIONED BY (ds STRING)
ROW FORMAT SERDE 'org.apache.hadoop.hive.contrib.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
"input.regex" = ".*([0-9][0-9]:[0-9][0-9]:[0-9][0-9]) , query: (.*), modules: \\[(.*)\\]", "output.format.string" = "%1$s %2$s %3$s")
STORED AS TEXTFILE;

CREATE TABLE elapsed_times (
 time_ms STRING,
 view_time_ms STRING,
 db_time_ms STRING,
 request_url STRING)
PARTITIONED BY (ds STRING)
ROW FORMAT SERDE 'org.apache.hadoop.hive.contrib.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
"input.regex" = "Completed in ([0-9]*)ms \\(View: ([0-9]*), DB: ([0-9]*)\\) \\| [0-9]* OK \\[(.*)\\]", "output.format.string" = "%1$s %2$s"
STORED AS TEXTFILE;

CREATE TABLE search_usa_gov_logs (
 host STRING,
 identity STRING,
 user STRING,
 time STRING,
 method STRING,
 request STRING,
 protocol STRING,
 status STRING,
 size STRING,
 referer STRING,
 agent STRING)
PARTITIONED BY (ds STRING)
ROW FORMAT SERDE 'org.apache.hadoop.hive.contrib.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
 "input.regex" = "([^ ]*) ([^ ]*) ([^ ]*) \\[.*{12}([0-9]{2}:[0-9]{2}:[0-9]{2}) \\+[0-9]{4}\\] \"([^ ]*) ([^ ]*) ([^\"]*)\" (-|[0-9]*) (-|[0-9]*) \"([^\"]*)\" \"([^\"]*)\"",
 "output.format.string" = "%1$s %2$s %3$s %4$s %5$s %6$s %7$s %8$s %9$s %10$s %11$s"
)
STORED AS TEXTFILE;

CREATE TABLE appsusagov (
host STRING,
identity STRING,
user STRING,
time STRING,
request STRING,
status STRING,
size STRING,
referer STRING,
agent STRING,
dash STRING)
PARTITIONED BY (ds STRING)
ROW FORMAT SERDE 'org.apache.hadoop.hive.contrib.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
"input.regex" = "([^ ]*) ([^ ]*) ([^ ]*) (-|\\[[^\\]]*\\]) ([^ \"]*|\"[^\"]*\") (-|[0-9]*) (-|[0-9]*)(?: ([^ \"]*|\"[^\"]*\") ([^ \"]*|\"[^\"]*\") ([^ \"]*|\"[^\"]*\"))?",
"output.format.string" = "%1$s %2$s %3$s %4$s %5$s %6$s %7$s %8$s %9$s %10$s %11$s"
)
STORED AS TEXTFILE;

CREATE TABLE m_gobiernousa (
host STRING,
identity STRING,
user STRING,
time STRING,
request STRING,
status STRING,
size STRING,
referer STRING,
agent STRING,
dash STRING)
PARTITIONED BY (ds STRING)
ROW FORMAT SERDE 'org.apache.hadoop.hive.contrib.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
"input.regex" = "([^ ]*) ([^ ]*) ([^ ]*) (-|\\[[^\\]]*\\]) ([^ \"]*|\"[^\"]*\") (-|[0-9]*) (-|[0-9]*)(?: ([^ \"]*|\"[^\"]*\") ([^ \"]*|\"[^\"]*\") ([^ \"]*|\"[^\"]*\"))?",
"output.format.string" = "%1$s %2$s %3$s %4$s %5$s %6$s %7$s %8$s %9$s %10$s %11$s"
)
STORED AS TEXTFILE;

CREATE TABLE usagov_dynamic (
host STRING,
identity STRING,
user STRING,
time STRING,
request STRING,
status STRING,
size STRING,
referer STRING,
agent STRING,
dash STRING)
PARTITIONED BY (ds STRING)
ROW FORMAT SERDE 'org.apache.hadoop.hive.contrib.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
"input.regex" = "([^ ]*) ([^ ]*) ([^ ]*) (-|\\[[^\\]]*\\]) ([^ \"]*|\"[^\"]*\") (-|[0-9]*) (-|[0-9]*)(?: ([^ \"]*|\"[^\"]*\") ([^ \"]*|\"[^\"]*\") ([^ \"]*|\"[^\"]*\"))?",
"output.format.string" = "%1$s %2$s %3$s %4$s %5$s %6$s %7$s %8$s %9$s %10$s %11$s"
)
STORED AS TEXTFILE;

CREATE TABLE usagov (
host STRING,
identity STRING,
user STRING,
time STRING,
site STRING,
request STRING,
status STRING,
size STRING,
referer STRING,
agent STRING,
dash STRING)
PARTITIONED BY (ds STRING)
ROW FORMAT SERDE 'org.apache.hadoop.hive.contrib.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
"input.regex" = "([^ ]*) ([^ ]*) ([^ ]*) (-|\\[[^\\]]*\\]) ([^ ]*) ([^ \"]*|\"[^\"]*\") (-|[0-9]*) (-|[0-9]*)(?: ([^ \"]*|\"[^\"]*\") ([^ \"]*|\"[^\"]*\") ([^ \"]*|\"[^\"]*\"))?",
"output.format.string" = "%1$s %2$s %3$s %4$s %5$s %6$s %7$s %8$s %9$s %10$s %11$s"
)
STORED AS TEXTFILE;

create view usagov_view
comment 'User-friendly version of usa.gov Apache logs'
AS
select ds as ds,
    regexp_extract(time, ':(.*) ', 1) hhmmss,
    regexp_extract(time, ':(.*):(.*):', 1) hour,
    host as host,
    regexp_extract(host, '(.*)\\.\\d{1,3}', 1) classc,
    regexp_extract(request, ' (.*) ', 1) request,
    status as status,
    size as size,
    regexp_replace(referer, "\"" , "") referer,
    regexp_replace(agent, "\"" , "") agent
from usagov;

create view usagov_dynamic_view
comment 'User-friendly version of usa.gov dynamic Apache logs'
AS
select ds as ds,
    regexp_extract(time, ':(.*) ', 1) hhmmss,
    regexp_extract(time, ':(.*):(.*):', 1) hour,
    host as host,
    regexp_extract(host, '(.*)\\.\\d{1,3}', 1) classc,
    regexp_extract(request, ' (.*) ', 1) request,
    status as status,
    size as size,
    regexp_replace(referer, "\"" , "") referer,
    regexp_replace(agent, "\"" , "") agent
from usagov_dynamic;

create view m_gobiernousa_view
comment 'User-friendly version of usa.gov dynamic Apache logs'
AS
select ds as ds,
    regexp_extract(time, ':(.*) ', 1) hhmmss,
    regexp_extract(time, ':(.*):(.*):', 1) hour,
    host as host,
    regexp_extract(host, '(.*)\\.\\d{1,3}', 1) classc,
    regexp_extract(request, ' (.*) ', 1) request,
    status as status,
    size as size,
    regexp_replace(referer, "\"" , "") referer,
    regexp_replace(agent, "\"" , "") agent
from m_gobiernousa;

create view appsusagov_view
comment 'User-friendly version of usa.gov dynamic Apache logs'
AS
select ds as ds,
    regexp_extract(time, ':(.*) ', 1) hhmmss,
    regexp_extract(time, ':(.*):(.*):', 1) hour,
    host as host,
    regexp_extract(host, '(.*)\\.\\d{1,3}', 1) classc,
    regexp_extract(request, ' (.*) ', 1) request,
    status as status,
    size as size,
    regexp_replace(referer, "\"" , "") referer,
    regexp_replace(agent, "\"" , "") agent
from appsusagov;

create view search_usa_gov_logs_view
AS
select ds as ds,
    regexp_extract(time, ':(.*) ', 1) hhmmss,
    regexp_extract(time, ':(.*):(.*):', 1) hour,
    host as host,
    regexp_extract(host, '(.*)\\.\\d{1,3}', 1) classc,
    regexp_extract(request, ' (.*) ', 1) request,
    status as status,
    size as size,
    regexp_replace(referer, "\"" , "") referer,
    regexp_replace(agent, "\"" , "") agent
from search_usa_gov_logs;

CREATE TABLE usagov_pageviews (
hhmmss STRING,
hour INT,
host STRING,
classc STRING,
request STRING,
status INT,
size INT,
referer STRING,
agent STRING)
PARTITIONED BY (ds STRING)
CLUSTERED BY(hhmmss) INTO 12 BUCKETS
ROW FORMAT SERDE "org.apache.hadoop.hive.serde2.columnar.ColumnarSerDe"
STORED AS RCFile;

CREATE TABLE query_impressions (
json STRING)
PARTITIONED BY (ds STRING)
ROW FORMAT SERDE 'org.apache.hadoop.hive.contrib.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
"input.regex" = "^[^\\]]*\\] (.*)","output.format.string" = "%1$s")
STORED AS TEXTFILE;

create view query_impressions_view
AS
select ds,
regexp_extract(get_json_object(a.json, '$.time'), ' (.*)', 1) hhmmss,
regexp_extract(get_json_object(a.json, '$.time'), ' (\\d{2})', 1) hour,
get_json_object(a.json,'$.query') query,
get_json_object(a.json,'$.affiliate') affiliate,
get_json_object(a.json,'$.locale') locale,
get_json_object(a.json,'$.vertical') vertical,
module from query_impressions a
lateral view explode(split(get_json_object(a.json,'$.modules'),'\\|')) foo as module;

CREATE TABLE clicks (
json STRING)
PARTITIONED BY (ds STRING)
ROW FORMAT SERDE 'org.apache.hadoop.hive.contrib.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
"input.regex" = "^[^\\]]*\\] (.*)","output.format.string" = "%1$s")
STORED AS TEXTFILE;

create view clicks_view
AS
select ds,
regexp_extract(get_json_object(a.json, '$.clicked_at'), ' (.*)', 1) clicked_hhmmss,
regexp_extract(get_json_object(a.json, '$.queried_at'), ' (.*)', 1) queried_hhmmss,
regexp_extract(get_json_object(a.json, '$.clicked_at'), ' (\\d{2})', 1) clicked_hour,
get_json_object(a.json,'$.query') query,
get_json_object(a.json,'$.results_source') module,
get_json_object(a.json,'$.click_ip') click_ip,
regexp_extract(get_json_object(a.json,'$.click_ip'), '(.*)\\.\\d{1,3}', 1) click_ip_classc,
if(parse_url(get_json_object(a.json,'$.url'),'PATH') == '', concat(get_json_object(a.json,'$.url'),'/') ,get_json_object(a.json,'$.url')) url,
get_json_object(a.json,'$.position') serp_position,
get_json_object(a.json,'$.vertical') vertical,
get_json_object(a.json,'$.affiliate_name') affiliate,
get_json_object(a.json,'$.locale') locale,
get_json_object(a.json,'$.user_agent') user_agent
from clicks a;

CREATE TABLE app_metrics (
json STRING)
PARTITIONED BY (ds STRING)
ROW FORMAT SERDE 'org.apache.hadoop.hive.contrib.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
"input.regex" = "(.*)","output.format.string" = "%1$s")
STORED AS TEXTFILE;

create view app_metrics_view
AS
select ds,
get_json_object(a.json,'$.total_time') total_time,
get_json_object(a.json,'$.db_time') db_time,
get_json_object(a.json,'$.view_time') view_time,
get_json_object(a.json,'$.request_url') request_url
from app_metrics a;

CREATE TABLE search_api_queries (
 host STRING,
 time STRING,
 request STRING,
 raw_query STRING,
 normalized_query STRING,
 affiliate STRING,
 locale STRING)
PARTITIONED BY (ds STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE ;

CREATE TABLE search_usa_gov_logs_rc (
host STRING,
time STRING,
request STRING,
status INT,
size INT,
referer STRING,
agent STRING)
PARTITIONED BY (ds STRING)
STORED AS RCFile;

CREATE TABLE datagov (
date_yymmdd STRING,
time STRING,
host STRING,
method STRING,
request STRING,
status STRING,
size STRING,
time_taken STRING,
referer STRING,
agent STRING,
cookie STRING,
site STRING)
PARTITIONED BY (ds STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;

CREATE TABLE itdashboard (
date_yymmdd STRING,
time STRING,
host STRING,
method STRING,
request STRING,
status STRING,
size STRING,
time_taken STRING,
referer STRING,
agent STRING,
cookie STRING,
site STRING)
PARTITIONED BY (ds STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;
load data local inpath '/home/jwynne/downloads/itdashboard.log.gz' overwrite into table itdashboard partition (ds='2011-08-19');

CREATE TABLE raw_pageloads (
host STRING,
time STRING,
request STRING,
status STRING,
referer STRING,
agent STRING,
cookie STRING)
PARTITIONED BY (ds STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;

CREATE VIEW raw_pageloads_view
AS
select host, time, request,referer,agent,cookie,
  parse_url(concat('http://www.foo.gov',request), 'QUERY','a') affiliate,
  reflect("java.net.URLDecoder", "decode", parse_url(concat('http://www.foo.gov',request), 'QUERY','u')) url,
  ds,
  hour(time) hr
from raw_pageloads;

CREATE TABLE pageloads (
affiliate STRING,
affiliate_id STRING,
url STRING,
host STRING,
time STRING,
request STRING,
referer STRING,
agent STRING,
cookie STRING)
PARTITIONED BY (ds STRING, hr STRING)
STORED AS RCFile;

create view left_nav_view AS
select q.ds ds, q.affiliate affiliate,q.host host, b.* from queries q
lateral view parse_url_tuple(concat("http://search.gov",request), 'PATH', 'QUERY:dc', 'QUERY:channel', 'QUERY:tbs') b as path, dc,channel,tbs ;

CREATE VIEW normalized_pageloads
AS SELECT affiliate_id, concat(lower(parse_url(url, 'PROTOCOL')),'://',lower(parse_url(url, 'HOST')),regexp_replace(parse_url(url, 'PATH'),'\;.*','')) normal_url, url, ds
FROM pageloads
WHERE url like 'http://%';
