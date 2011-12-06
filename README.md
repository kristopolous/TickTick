# Introduction

TickTick enables you to put JSON in your bash scripts.  Yes, just encapsulate them with two back-ticks.

## Runtime
A few array manipulation runtime directives are supported:

 * length
 * push 
 * pop
 * shift
 * items

Along with assignment operations<sup>1</sup>, and Javscript like indexing into objects and arrays.

Additionally, bash variables "$[name]" are preserved in the ticktick blocks.  For instance, once could do

<sup>1</sup>Although Javascript supports $ prefixed variables, this does not.

<pre>
`` Var.Data = [] ``
`` Var.Data.push($key) ``
bashvar=`` Var.Data.pop() ``
</pre>

# Example

<pre>
#!/bin/bash

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
    printf "    - %s\n" ${!employee}
  done

  echo 
}

echo Base Assignment
`` people.Engineering = [ "Darren", "Edith", "Frank" ] ``
printEmployees

newPerson=Isaac
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
</pre>
