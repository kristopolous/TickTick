Parsing Error Detected, see below
#!/bin/bash
# Bug 18

. ../ticktick.sh

# This is a bug.
# The code should not execute and instead
# print a parsing error.
__tick_data_a_000000000000=
TICKTICK PARSING ERROR: Array syntax malformed
Parsing stopped here.
