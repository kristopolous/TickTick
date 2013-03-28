#!/bin/bash

__tick_var_debug=1
. ticktick.sh

bob=Bob

``
  people = {
    "HR" : [
      "Alice",
      $bob,
      "Carol"
    ],
    "Sales": {
      "Gale": { "profits" : 1000 },
      "Harry": { "profits" : 500 }
    }
  }
``

function printEmployees() {
  echo
  echo "  The ``people.Engineering.length()`` Employees listed are:"

  for employee in ``people.Engineering.items()``; do
    printf "    - %s\n" "${!employee}"
  done

  echo 
}

echo Base Assignment
`` people.Engineering = [ "Darren D", "Edith E", "Frank F" ] ``
printEmployees

newPerson="Isaac I"
echo Pushed a new element by variable, $newPerson onto the array
`` people.Engineering.push($newPerson) ``
printEmployees

echo Shifted the first element off: `` people.Engineering.shift() ``
printEmployees

echo Popped the last value off: `` people.Engineering.pop() ``
printEmployees

echo Indexing an array, doing variable assignments

person0=``people.HR[0]``
echo $person0 ``people.HR[1]``
