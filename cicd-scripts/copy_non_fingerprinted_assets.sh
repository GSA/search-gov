#!/bin/bash

cd /home/search/searchgov/current

# Copy non-fingerprinted JS and CSS assets in public/packs
for file in $(find public/packs -name "*-*.js" -or -name "*-*.css"); do
  cp "$file" "${file%%-*}.${file##*.}"
done

# Copy non-fingerprinted assets in public/assets directory
for file in $(find public/assets -name "*-*.js" -or -name "*-*.css" -or -name "*-*.js.gz" -or -name "*-*.css.gz"); do
  cp "$file" "${file%%-*}.${file##*.}"
done

echo "Non-fingerprinted assets copied successfully in both packs and assets directories."
