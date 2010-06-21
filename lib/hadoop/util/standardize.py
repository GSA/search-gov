#!/usr/bin/env python
# encoding: utf-8
"""
standardize.py

generate 

Created by Peter Skomoroch on 2010-06-19.
Copyright (c) 2010 Data Wrangling LLC. All rights reserved.
"""

import sys
import os
import cPickle as pickle

pkl_file = open('wikiphrases.pkl', 'rb')
wikiphrases = pickle.load(pkl_file)
queries = open('top_queries.txt', 'r').readlines()
outfile = open('std_queries.txt','w')
diff_file = open('query_dictionary.txt','w')

query_dictionary = {}

for line in queries:
  try:
    query, count = line.strip().split('\t')
    try:
      query = ' '.join(query.replace('"', '').split())
      stdquery = wikiphrases[query]
    except:
      stdquery = query
    print >> outfile, '\t'.join([query,stdquery,count])
    if query != stdquery:
      #if (stdquery.find('.') > 0) or (len(query) <= 6):
      #print query, stdquery, count
      query_dictionary[query]=stdquery
      print >> diff_file, '\t'.join([query,stdquery,count])
  except:
    pass  
    
print "Done, saving pickle"
output = open('query_dictionary.pkl','wb')
pickle.dump(wikiphrases, output, -1)
output.close()    

