#!/bin/bash
# See bug#25

. ../ticktick.sh

``
database = { 
  "te0st_0" : {
    "1o1e_1" : "two"
  },
  "legit" : [ 0, 1, 2, 3, 4 ]
}
``

test_assert "`` database.te0st_0.1o1e_1 ``" "two"
test_assert "`` database.legit[0] ``" "0"
test_assert "`` database.legit.1 ``" "1"
  
