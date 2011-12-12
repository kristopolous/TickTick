#!/bin/bash
. ../ticktick.sh

DATA=`cat data.json`

tickParse "$DATA"

echo ``pathname``
echo ``headers["user-agent"]``
