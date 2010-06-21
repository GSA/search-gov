#!/bin/sh

# Quick driver script to compute baseline related searches using Pig/EC2
# 

# reformat_usasearch_logs.pig  {AnonID,Query,QueryTime,ClickURL}
# top_queries.pig {query, count}
# generate_session_data.pig {session_id, searches;}  (session_id is (AnonId,date)
# filter_pairs.pig & query_pairs.py -> {query, coquery, count}
# TFIDF.pig {query, related_searches_bag {(coquery, score, count)...} }
# TODO: python streaming script to convert related searches to json
# TODO: related_searches_by_session.pig , (1) explode out related_searches keys by using query_dictionary.txt
#  to regenerate full original related queries keys. 
# JOIN against join against top_queries to return related searches for only the top 20K queries
#  FILTER to only return subset of top 50K queries.


