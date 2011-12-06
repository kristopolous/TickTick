# Introduction

TickTick enables you to put JSON in your bash scripts.  Yes, just encapsulate them with two back-ticks.

## Runtime
A few array manipulation runtime directives are supported:

 * push (implemented)
 * pop (partially implemented)
 * shift (unimplemented)
 * unshift (unimplemented)
 * length<sup>1</sup> (unimplemented)

Along with assignment operations, and Javscript like indexing into objects and arrays.

Additionally, bash variables "$[name]" are preserved in the ticktick blocks.  For instance, once could do

<sup>1</sup>length is a function for now

<pre>
`` Var.Data = [] ``
`` Var.Data.push($key) ``
bashvar=`` Var.Data.pop() ``
</pre>

# Example

<pre>
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
</pre>
