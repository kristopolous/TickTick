#!/bin/bash

error_count=0
test_error() {
  (( error_count++ ))
  echo "$1"
}

test_done(){
  if (( error_count == 0 )); then
    echo "Success"
  else
    echo "Failed " $error_count " tests"
  fi
}
