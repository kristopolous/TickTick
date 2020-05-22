#!/bin/bash
. ../ticktick.sh

``
  people = {
    "H R" : [
      "Al ice",
      "Bo b",
      "Ca rol"
    ]
  }
``

for employee in ``people["H R"].items()``; do
  printf "    - %s\n" "${!employee}"
done
