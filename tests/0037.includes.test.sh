#!/bin/bash
. ../ticktick.sh
. 0037a.includes.sh  

``
  people = {
    "HR" : [
      "Alice",
      "Bob",
      "Carol"
    ]
  }
``

firstPerson

echo "Second Person"
echo `` people.HR[1]``

exit
