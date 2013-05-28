#!/bin/bash
. common.sh
export __tick_ignore_parse_errors=1

for i in *.test.sh; do
    test_init
    echo "$i {"
    {
        ./$i
        ret=$?
        if (( $ret == 255 )); then
            test_result=SKIPPED
        else
            test_status $ret
        fi
    } > >(sed "s/^/   /g")
    test_done
    echo "}"
    echo
done

test_report
