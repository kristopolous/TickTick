#!/bin/bash
# Bug 18

. ../ticktick.sh

# This is a bug.
# it should print a parsing error.
``a = [``

check_parse_error
