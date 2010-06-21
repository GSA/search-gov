#!/usr/bin/env python
# encoding: utf-8
"""
construct_wikiphrases.py

This script constructs a Python pickle file used to standardize queries

page_lookup_redirects.txt.gz is constructed from the redirect table in the Wikipedia databse dump

Barak_Obama	Barack Obama	534366	276223690
Barack_H._Obama	Barack Obama	534366	276223690
Barack	Barack Obama	534366	276223690
Barack_Obama.	Barack Obama	534366	276223690
Barack_H_Obama	Barack Obama	534366	276223690
44th_President_of_the_United_States	Barack Obama	534366	276223690
Barach_Obama	Barack Obama	534366	276223690
Senator_Barack_Obama	Barack Obama	534366	276223690


$ s3cmd get s3://trendingtopics/wikidump/page_lookup_redirects.txt.gz page_lookup_redirects.txt.gz
$ gunzip page_lookup_redirects.txt.gz


Created by Peter Skomoroch on 2010-03-11.
Copyright (c) 2010 Data Wrangling LLC. All rights reserved.
"""

import sys
import os
import csv
import cPickle as pickle
import difflib

def main():
  wikiphrases = {}
  reader = csv.reader(open('page_lookup_redirects.txt', "rb"), delimiter='\t', quoting=csv.QUOTE_NONE)
  
  #phrase std_phrase  page_from page_to
  #Barack_Obama_"Progress"_poster  Barack Obama "Hope" poster      21129442        276142252
  for i, row in enumerate(reader):
    phrase, std_phrase = row[0], row[1]
    clean_phrase = phrase.lower().replace('_',' ').strip()
    clean_std_phrase = std_phrase.lower().split('(')[0].strip()
    # we just want to normalize close string variants "obama, barack obama etc."
    if difflib.SequenceMatcher(None, clean_phrase,clean_std_phrase).ratio() >= 0.5:
      if clean_phrase != clean_std_phrase:
        wikiphrases[clean_phrase] = clean_std_phrase
      if i % 50000 == 0:
        print i, phrase, "|CLEANED =>", clean_phrase, "STD=>", clean_std_phrase
  
  # read in blacklist phrases
  blacklist = open('blacklist_query_mappings.txt', 'r').readlines()
  for line in blacklist:
    try:
      query, std_query, count = line.strip().split('\t')
      del wikiphrases[query]
      print "removed", query
    except:
      print "Error"
  
  
  print "Done, saving pickle"
  output = open('wikiphrases.pkl','wb')
  pickle.dump(wikiphrases, output, -1)
  output.close()

  print "test loading pickle"
  pkl_file = open('wikiphrases.pkl', 'rb')
  wikiphrases = pickle.load(pkl_file)
  
  print wikiphrases['obama']
  print wikiphrases['search']

if __name__ == '__main__':
  main()
