#!/bin/bash
. ../ticktick.sh

# This is reference to issue (1),
# (test case) e.g., parser goes to infinite loop on dicts

# This should parse ok
`` data = { "x" : "y" } ``

# This is a bug in code, but
# it should say so
`` data = { "x" : "y", } ``

check_parse_error
