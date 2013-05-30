#!/bin/bash
. ../ticktick.sh

``
{
    "shows":[
        {
            "Name":"Luceaferul",
            "id":"1",
            "DayOfWeek":1
            },
        {
            "Name":"Ghettoblaster",
            "id":"2",
            "DayOfWeek":1
        }
    ]
}
``

find_by_id() {
    for obj in ``.shows[*]``; do
        if [ "``$obj.id``" == "$1" ]; then
            echo -n $obj
            return 0
        fi
    done

    return 1
}

found=`find_by_id 2 || test_error "find_by_id failed"`
attr="Name"
# can use either . or [] to lookup the object attribute
test_assert "``$found.$attr``" "Ghettoblaster"
test_assert "``$found[$attr]``" "Ghettoblaster"
