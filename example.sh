#!/bin/bash
. ticktick.sh

function printEmployees() {
  echo
  echo "  The ``people.Engineering[#]`` Employees listed are:"

  for employee in ``people.Engineering[*]``; do
    printf "    - %s\n" "``$employee``"
  done

  echo
}

printEmployees

echo Indexing an array, doing variable assignments

person0=``people.HR[0]``
echo $person0 ``people.HR[1]``

echo
echo "Looping over key/values (using a variable reference)"
obj=``people.Sales``
for person in ``$obj[!]``; do
    echo " $person profits ``$obj[$person].profits``"
done


# Inline data can be kept any were in the file...
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
        },
    "Engineering" : [ "Darren D", "Edith E", "Frank F" ]
}
``
