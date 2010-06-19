REGISTER s3://piggybank/0.6.0/piggybank.jar
DEFINE LOG1P org.apache.pig.piggybank.evaluation.math.LOG1P();

set job.name 'topn_TFIDF'
rmf topn_tfidf

term_document = LOAD 's3://usasearch-logs/filtered_pairs' AS (document:chararray, term:chararray, count:long);

-- compute term frequency within each document
grouped_documents = group term_document BY document PARALLEL 100;
doc_counts = FOREACH grouped_documents GENERATE $0 as document,
 (float)SUM($1.count) as term_count;
 
-- compute total number of documents
grouped_doc_counts = GROUP doc_counts ALL PARALLEL 100;
D = FOREACH grouped_doc_counts GENERATE 1 as stub, COUNT_STAR(doc_counts) AS total;

joined_term_doc = JOIN term_document BY document, doc_counts BY document PARALLEL 100;
term_frequency = FOREACH joined_term_doc GENERATE term_document::document as document, 
 term_document::term as term, 
 term_document::count / ((float)doc_counts::term_count + 1.0) as frequency;

-- compute inverse document frequency (idf)
grouped_terms = group term_document BY term PARALLEL 100;
grouped_terms = FOREACH grouped_terms GENERATE 1 as stub, $0 as term, $1 as term_document;
joined_tot_grouped_terms = JOIN D by stub, grouped_terms BY stub PARALLEL 100;
idf = FOREACH joined_tot_grouped_terms GENERATE grouped_terms::term as term, 
 LOG1P(D::total/((float)SIZE(grouped_terms::term_document) + 1.0)) as idf;

joined_freq = JOIN term_frequency BY term, idf BY term PARALLEL 100;
tfidf = FOREACH joined_freq GENERATE term_frequency::document as document, 
  term_frequency::term as term, 
  term_frequency::frequency * idf::idf as tfidf_score;
 
grouped_tfidf = GROUP tfidf BY document PARALLEL 100;
top_n = FOREACH grouped_tfidf {
       sorted = ORDER tfidf BY $2 DESC;
       sorted = LIMIT sorted 100;
             GENERATE group, sorted;}
             
top_n = FOREACH top_n GENERATE flatten(sorted) AS (document:chararray, 
  term:chararray, tfidf_score:double);            

STORE top_n INTO 'topn_tfidf';

