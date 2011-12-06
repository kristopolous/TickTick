# Introduction

TickTick enables you to put JSON in your bash scripts.  Yes, just encapsulate them with two back-ticks.

## Runtime
A few array manipulation runtime directives are supported:

 * push 
 * pop
 * shift
 * items

Along with assignment operations, and Javscript like indexing into objects and arrays.

Additionally, bash variables "$[name]" are preserved in the ticktick blocks.  For instance, once could do

<pre>
`` Var.Data = [] ``
`` Var.Data.push($key) ``
bashvar=`` Var.Data.pop() ``
</pre>

# Example

<pre>
#!/bin/bash

. ticktick.sh

# Variable Assignment
bob=Bob

function iteration() {
  for employee in ``people.Engineering.items()``; do
    printf "\t%s\n" ${!employee}
  done
}

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
`` people.Engineering = [ "Darren", "Edith", "Frank" ] ``
`` people.Engineering.push("Isaac") ``



echo "Iteration"
iteration

echo "Shifted the first element off: "`` people.Engineering.shift("") ``
iteration

echo "Popped the last value off: "`` people.Engineering.pop() ``
iteration

echo
echo "Indexing an array, doing variable assignments"

person0=``people.HR[0]``
echo $person0 ``people.HR[1]``
</pre>
