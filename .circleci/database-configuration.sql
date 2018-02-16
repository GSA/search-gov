SET GLOBAL innodb_strict_mode = ON;
SET GLOBAL innodb_file_format = Barracuda;
SET GLOBAL innodb_large_prefix = 1;
SHOW GLOBAL VARIABLES LIKE 'innodb_%';
SHOW DATABASES;
ALTER DATABASE usasearch_test CHARSET utf8mb4;
USE usasearch_test;
CREATE TABLE large_index_test(a varchar(255), INDEX (a)) ROW_FORMAT=DYNAMIC;
SHOW CREATE TABLE large_index_test\G;
DROP TABLE large_index_test;
exit
