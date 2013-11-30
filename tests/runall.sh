#!/bin/bash
. common.sh

if [ $# -gt 0 ]; then
  toRun="*${1}*test.sh"
else
  toRun=*.test.sh
fi

output=temp-test-output

for i in $toRun; do
  test_init

  echo -n "$i "
  ./$i > $output

  expected=expected/$i

  if [ ! -e $expected ]; then
     echo "{"
    {
      echo "ERROR: Expected file $expected doesn't exist"
      cat $output
    } | sed 's/^/   /'
    echo "}"
  elif [ `diff $output $expected | wc -l` -gt 0 ] ; then
    echo "{"
    {
      echo "!!! FAILURE !!!"
      diff $output $expected
    } | sed 's/^/   /'
    echo "}"
  else
    echo "{ OK }"
  fi
done

[ -e $output ] && rm $output
