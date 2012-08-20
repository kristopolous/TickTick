#!/bin/bash

test_assert() {
  (( test_count++ ))
  if [ "$1" != "$2" ]; then
    echo "Assert failure: $1 != $2"
    (( error_count++ ))
  fi
}

test_init() {
  error_count=0
  test_count=0
}

test_error() {
  (( error_count++ ))
  echo "$1"
}

test_done(){
  if (( error_count == 0 )); then
    echo "Success. "
  else
    echo "Failed. "
  fi
}

export -f test_assert
export error_count
export test_count
