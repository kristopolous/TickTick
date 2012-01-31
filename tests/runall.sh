#!/bin/bash

for i in *.test.sh; do
  echo "$i {"
  ./$i | sed "s/^/   /g"
  echo "}"
  echo 
done
