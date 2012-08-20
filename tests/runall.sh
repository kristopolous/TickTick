#!/bin/bash
. common.sh

for i in *.test.sh; do
  test_init
  echo "$i {"
  ./$i | sed "s/^/   /g"
  test_done | sed "s/^/   /g"
  echo "}"
  echo 
done
