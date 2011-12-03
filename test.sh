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

for employee in ``people.Engineering``; do
  echo ${!employee}
done

m=``params.Extensions.js``

``params.Extensions.ruby="rb"``

echo $m ``params.Extensions.ruby``
