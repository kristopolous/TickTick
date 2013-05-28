#!/bin/echo this file should be sourced

declare -A test_stats

## test runner api
test_init() {
    unset test_result
    test_failed=0
    test_parse_error=0
}

test_status() {
    case "$1" in
        0) test_result=PASS ;;
        *)
            if (($1 == $test_parse_error )); then
                test_result=PASS
            else
                test_result="Unexpected parse error(s)"
            fi ;;
    esac
}

test_done() {
    [ $test_failed -eq 0 ] && test_success || test_failed
}

test_failed() {
    echo "=== >> FAILED << === "
    ((test_stats[FAILED]++))
    return 0
}

test_success() {
    echo "   :: ${test_result:=UNKNOWN} ::"
    ((test_stats[$test_result]++))
    return 0
}

test_report() {
    for s in ${!test_stats[*]}; do
        echo "$s: ${test_stats[$s]}"
    done
}

trap test_trap_usr1 USR1
test_trap_usr1() {
    ((test_parse_error++))
}

trap test_trap_hup HUP
test_trap_hup() {
    ((test_failed++))
}

## test code api
export TEST_RUNNER=$$

test_assert() {
    [ "$1" == "$2" ] || test_error "${3:?Assert failure}: $1 != $2"
}

check_parse_error() {
    grep "TICKTICK PARSING ERROR" "${BASH_SOURCE[1]}" > /dev/null || test_error "Missing parse error"
    kill -s USR1 $TEST_RUNNER
}

test_error() {
    echo "$1"
    kill -s HUP $TEST_RUNNER
}

test_skip() {
    exit 255
}

export -f test_assert test_error test_skip check_parse_error
