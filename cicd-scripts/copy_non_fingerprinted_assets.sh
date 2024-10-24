#!/bin/bash

cd /home/search/searchgov/current

# Copy non-fingerprinted JS and CSS assets
for file in $(find public/packs -name "*-*.js" -or -name "*-*.css"); do
  cp "$file" "${file%%-*}.${file##*.}"
done

echo "Non-fingerprinted assets copied successfully."
