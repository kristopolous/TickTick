# Introduction

TickTick enables you to put JSON in bash scripts.  Yes, just encapsulate them with two back-ticks.

**Note: This is just a fun hack.** You may want to consider using mature languages like Ruby or Perl to solve actual real life problems.  Oh who am I kidding, I use whitespace and brainfuck every day.

**Note 2: Data backend reimplemented**
The underlying data backend has been reimplemented using arrays
(and associative arrays) and all previous functionality has not been
migrated (yet, if ever..).
Also, I was unable to avoid saving a temp file to disk during
tokenization.. feel free to solve that ;)


# Usage

Proper usage (if there is such a thing), is to place the following line right after the "shebang" at the top of your script. For instance:

    #!/bin/bash
    #
    # Nuclear_meltdown_preventer.sh
    #
    # This is really important stuff. Don't edit it!
    #
    . ticktick.sh

    ..

See how that's near the tippity-top? That's where it's supposed to go. If you put it lower, all bets are off. :-(

# API

 * `.`                 <pre>echo \`\`elem.sub.value\`\`</pre>
 * `[]`                <pre>echo \`\`elem[0]\`\`</pre>
 * `[#]`               <pre>len=\`\`elem[#]\`\`; echo ${len}</pre>
 * `[*]`               <pre>for val in \`\`elem[*]\`\`; do echo "``$val``"; done</pre>
 * `[!]`               <pre>for key in \`\`elem[!]\`\`; do echo "$key = ``elem[$key]``"; done</pre>

# Examples

Inline Parsing
---

    #!/bin/bash
    . ticktick.sh

    function printEmployees() {
      echo
      echo "  The ``people.Engineering[#]`` Employees listed are:"

      for employee in ``people.Engineering[*]``; do
        printf "    - %s\n" "``${employee}``"
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
          $bob,
          "Carol"
        ],
        "Sales": {
          "Gale": { "profits" : 1000 },
          "Harry": { "profits" : 500 }
        }
      }
    ``

Using a File or cURL
---

    #!/bin/bash
    . ../ticktick.sh

    # File
    DATA=`cat data.json`
    # cURL
    #DATA=`curl http://foobar3000.com/echo/request.json`

    tickParse "$DATA"

    echo ``.pathname``
    echo ``.headers["user-agent"]``

If you have many calls to tickParse, you may want to add each one to a
separate root object:

    tickParse "data = $DATA"
    echo ``data.pathname``
    
## Mailing List

Join it [over here](http://groups.google.com/group/ticktick-project).

## LICENSE

This software is available under the following licenses:

  * MIT
  * Apache 2

Parts of this work are derived from [JSON.sh](https://github.com/dominictarr/JSON.sh), which is also available under the aforementioned licenses.
This version of TickTick is heavily modified by [Kaos](https://github.com/kaos).
