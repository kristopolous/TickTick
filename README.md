# Introduction

TickTick enables you to put JSON in your bash scripts.  Yes, just encapsulate them with two back-ticks.

# Example

<code>
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
  echo "  - ${!employee}"
done

echo
echo "Indexing an array, doing variable assignments"

person=``people.HR[0]``
echo $person ``people.HR[1]``
</code>
