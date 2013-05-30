#!/bin/bash
. ../ticktick.sh

test_skip

`` key = {"value": 1} ``

[ "``key.value``" == "1" ] || test_error "Key Assignment wrong"
``key.value.delete()``
[ -z "``key.value``" ] || test_error "Key Not Deleted"
