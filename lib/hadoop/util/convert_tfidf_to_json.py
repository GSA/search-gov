#!/usr/bin/env python
# encoding: utf-8
"""
convert_tfidf_to_json.py

converts tab delimited Pig bags into json:

Input Format:
barack obama	{(president,michelle obama,joe biden)} {(0.579811054540683,0.39416984199894883,0.3899443008016943)} {(320,223,154)}

into tab delimited JSON:

Output format:

obama {"barack obama": [["president", "1.93"], ["white house", "1.5"], ["george bush", "1.2"], ["michelle obama", "1.1"], ["global warming", ".4"], ["education", ".3"], ["inauguration", ".2"]]}
...

Created by Peter Skomoroch on 2010-01-25.
"""

import sys, os, re
import simplejson as json

 
for line in sys.stdin:
  try:
    if len(line.split('\t')) == 4:
      (query_key, search_bag, score_bag, count_bag) = line.strip().split('\t')

      search_tuples = search_bag[2:-2].split('),(')
      score_tuples = score_bag[2:-2].split('),(')
      count_tuples = score_bag[2:-2].split('),(')
      score_tuples = [str(round(float(x),5)) for x in score_tuples]
      zipped = zip(search_tuples, score_tuples)
      related_searches = json.dumps({query_key:list(zipped)})
      sys.stdout.write('\t'.join([query_key, related_searches]) + '\n')
  except:
    pass
