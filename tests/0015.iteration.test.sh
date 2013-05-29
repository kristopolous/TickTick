#!/bin/bash
. ../ticktick.sh

``
people = [
    {
        "name":"Alice",
        "age":23
        },
    {
        "name":"Bob",
        "age":43
        },
    {
        "name":"Harry",
        "age":13
    }
]
``

iterate_people() {
    for person in ``people[*]``; do
        echo -n "``$person.name`` ``$person.age``;"
    done
}

test_assert "`iterate_people`" "Alice 23;Bob 43;Harry 13;"
