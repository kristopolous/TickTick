#!/bin/bash
# Bug 18

. ../ticktick.sh

# This is a bug.
# The code should not execute and instead
# print a parsing error.
``a = [``
