# Introduction

TickTick enables you to put JSON in bash scripts.  Yes, just encapsulate them with two back-ticks.

**Note: This is just a fun hack.** You may want to consider using mature languages like Ruby or Perl to solve actual real life problems.  Oh who am I kidding, I use whitespace and brainfuck every day.

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
# API

Arrays
---

A few array manipulation runtime directives are supported:
 
 * `[]` (as new Array) <pre>\`\`arr = ["foo"]\`\`</pre>
 * `[]` (to index)     <pre>echo \`\`arr[0]\`\`</pre>
 * `length`            <pre>arr_len=\`\`arr.length()\`\`; echo ${arr_len}</pre>
 * `push`              <pre>\`\`arr.push(${arr_len})\`\`</pre>
 * `pop`               <pre>echo \`\`arr.pop()\`\`</pre>
 * `shift`             <pre>echo \`\`arr.shift()\`\`</pre>
 * `items`             <pre>for x in \`\`arr.items()\`\`; do echo "${x}"; done</pre>

Objects
---

 * `{}` (as new Object) <pre>\`\`obj = { "foo": "bar", "baz": "qux" }\`\`</pre>
 * `[]` (to index)      <pre>echo \`\`obj["foo"]\`\`</pre>
 * `.` (to index)       <pre>echo \`\`obj.baz\`\`</pre>

Bash variables ($) in JSON
---

Along with assignment operations<sup>1</sup>, and Javascript like indexing into objects and arrays.

Additionally, bash variables (eg., "$name") are preserved in the ticktick blocks.  For instance, once could do

<pre>
`` Var.Data = [] ``
`` Var.Data.push($key) ``
bashvar=`` Var.Data.pop() ``
</pre>

<sup>1</sup>Although Javascript supports $ prefixed variables, this does not.

# LICENSE

This software is available under the following licenses:

  * MIT
  * Apache 2

Parts of this work are derived from [JSON.sh](https://github.com/dominictarr/JSON.sh), which is also available under the aforementioned licenses.
