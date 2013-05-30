#!/bin/bash
. ../ticktick.sh

``
database = [
    {
        "artist": "Ludwig Van Beethoven",
        "title": "Moonlight Sonata"
        },
    {
        "artist": "Johann Pachelbel",
        "title": "Canon in D Major"
        },
    {
        "artist": "Johann Sebastian Bach",
        "title": "Air on a G String"
    }
]
``

test_assert 3 ``database[#]``
