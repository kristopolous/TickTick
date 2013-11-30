#!/bin/bash

test_assert() {
  (( test_count++ ))
  if [ "$1" != "$2" ]; then
    echo "Assert failure: $1 != $2"
    (( error_count++ ))
  fi
}

test_init() {
  export error_count=0
  export test_count=0
}

test_error() {
  (( error_count++ ))
  echo "$1"
}

export -f test_assert
export -f test_error
export error_count
export test_count
