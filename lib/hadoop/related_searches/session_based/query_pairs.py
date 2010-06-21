#!/usr/bin/env python
# encoding: utf-8
"""
query_pairs.py

Created by Peter Skomoroch on 2010-05-22.
"""

import sys
import os
import cPickle as pickle

pkl_file = open('query_dictionary.pkl', 'rb')
wikiphrases = pickle.load(pkl_file)

def clean(query):
  clean_query = query.replace('enter search term...', ' ')
  # remove multiple spaces
  clean_query = ' '.join(clean_query.split())
  # strip double quotes
  clean_query = clean_query.replace('"', '')
  # return None if query in blacklist, 1 char, or matches url regex    
  if len(clean_query.strip()) < 2:
    clean_query = None
    return clean_query
  # try mapping query to standard form using wikipedia pkl  
  try:
    std_query = wikiphrases[clean_query]
    clean_query = std_query
  except:
    pass  
  #TODO: spell correct query using common mispellings  
  return clean_query

for line in sys.stdin:
  try:
    #(12136478,2006-04-14)	{(federal irs),(federal income tax forms),(tax forms)}
    session, searches = line.strip().split('\t')
    searches = searches[1:-1].split(',')
    # scrub searches, removing leading, trailing spaces, standardizing spelling
    queries = [clean(x[1:-1]) for x in searches]
    # make the list of queries unique to avoid double counting pairs...
    queries = list(set(queries))
    try:
      # remove 'None' searches from queries
      queries.remove(None)
    except:
      pass      
    pairs = [(x,y) for x in queries for y in queries if x != y]
    for pair in pairs:
      sys.stdout.write('%s\t%s\n' % (pair[0], pair[1]))
      sys.stdout.write('%s\t%s\n' % (pair[1], pair[0]))
  except:
    pass  
