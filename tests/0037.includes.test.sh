#!/bin/bash
. ../ticktick.sh
. 0037a.includes.sh  

``
  people = {
    "HR" : [
      "Alice",
      "BoB",
      "Carol"
    ]
  }
``

firstPerson

echo "Second Person"
echo `` people.HR[1] ``

exit
