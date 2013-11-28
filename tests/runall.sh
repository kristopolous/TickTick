#!/bin/bash
. common.sh

if [ $# -gt 0 ]; then
  toRun="*${1}*test.sh"
else
  toRun=*.test.sh
fi

for i in $toRun; do
  test_init
  echo "$i {"
  ./$i | sed "s/^/   /g"
  test_done | sed "s/^/   /g"
  echo "}"
  echo 
done
