#!/bin/bash

. ticktick.sh

``
  people = {
    "HR" : [
      "Alice",
      "Bob",
      "Carol"
    ],
    "Sales": {
      "Gale": { "profits" : 1000 },
      "Harry": { "profits" : 500 }
    }
  }
``

`` people.Engineering = [ "Darren", "Edith", "Frank" ] ``

echo "Iteration"

for employee in ``people.Engineering``; do
  printf "\t%s\n" ${!employee}
done

echo
echo "Indexing an array, doing variable assignments"

person0=``people.HR[0]``
echo $person0 ``people.HR[1]``
