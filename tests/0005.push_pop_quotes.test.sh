#!/bin/bash 
. ../ticktick.sh

# This is reference to issue 5.
# See https://github.com/kristopolous/TickTick/issues/5

`` data = [ 1, 2, 3, 4 ] ``

echo "This value: `` data.pop() `` should be 4."
echo "This value: `` data.length() `` should be 3."
