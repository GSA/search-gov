#!/usr/bin/env python
# encoding: utf-8
"""
query_pairs.py

Created by Peter Skomoroch on 2010-05-22.
"""

import sys
import os

for line in sys.stdin:
  try:
    #(12136478,2006-04-14)	{(federal irs),(federal income tax forms),(tax forms)}
    session, searches = line.strip().split('\t')
    searches = searches[1:-1].split(',')
    queries = [x[1:-1] for x in searches]
    pairs = [(x,y) for x in queries for y in queries if x != y]
    for pair in pairs:
      sys.stdout.write('%s\t%s\n' % (pair[0], pair[1]))
  except:
    pass  
