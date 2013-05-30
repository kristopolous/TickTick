#!/bin/echo This file should be sourced
# Copyright 2013, Andreas Stenius <git@astekk.se> (http://github.com/kaos)
# Based on work by Chris McKenzie and Dominic Tarr
# Licensed under MIT and Apache 2.

ARGV=("$@")

__(){ [ $__tick_debug ] && echo "DBG: $@" 1>&2 || :; }

__tick_error() {
    echo "echo TICKTICK PARSING ERROR in $__tick_source:$__tick_line: $@ 1>&2"
}

# This is from https://github.com/dominictarr/JSON.sh
# See LICENSE for more info. {{{
__tick_json_tokenize() {
    local ESCAPE='(\\[^u[:cntrl:]]|\\u[0-9a-fA-F]{4})'
    local CHAR='[^[:cntrl:]"\\]'
    local STRING="\"$CHAR*($ESCAPE$CHAR*)*\""
    local VARIABLE="\\\$[A-Za-z0-9_]*"
    local NUMBER='-?(0|[1-9][0-9]*)([.][0-9]*)?([eE][+-]?[0-9]*)?'
    local KEYWORD='null|false|true'
    local SPACE='[[:space:]]+'
    egrep -ao "$STRING|$VARIABLE|$NUMBER|$KEYWORD|$SPACE|." --color=never | egrep -v "^$SPACE$"  # eat whitespace
}

__tick_json_parse_array() {
    ((__tick_data_arrays++))
    local obj=__tick_data_arr_${__tick_data_arrays}
    declare -a $obj

    read -r token
    case "$token" in
        ']') ;;
        *)
            while :
            do
                __tick_json_parse_value
                eval "$obj+=($?)"

                read -r token
                case "$token" in
                    ']') break ;;
                    ',') ;;
                    *)
                        __tick_error "Array syntax malformed. Expected \',\' or \']\' but got \'${token:-unexpected end of input}\'"
                        break ;;
                esac
                read -r token
            done
            ;;
    esac

    __tick_env_export __tick_export_data $obj
    __tick_data_value[$__tick_data_values]=$obj
    return $((__tick_data_values++))
}

__tick_json_parse_object() {
    ((__tick_data_objects++))
    local obj=__tick_data_obj_${__tick_data_objects}
    declare -A $obj

    local key

    read -r token
    case "$token" in
        '}') ;;
        *)
            while :
            do
                # The key, it should be valid
                case "$token" in
                    '"'*'"'|\$[A-Za-z0-9_]*)
                        key=$token
                        ;;
                    *)
                        # If we get here then we aren't on a valid key
                        __tick_error "Object syntax malformed. Expected a valid key but got \'${token:-unexpected end of input}\'"
                        break
                        ;;
                esac

                # A colon
                read -r token
                # todo: check that $token indeed is a colon..

                # The value
                read -r token
                __tick_json_parse_value
                eval "$obj[$key]=$?"

                # next key, or end of object
                read -r token
                case "$token" in
                    '}') break ;;
                    ',') ;;
                    *)
                        __tick_error "Object syntax malformed. Expected \',\' or \'}\' but got \'${token:-unexpected end of input}\'"
                        break ;;
                esac
                read -r token
            done
            ;;
    esac

    __tick_env_export __tick_export_data $obj
    __tick_data_value[$__tick_data_values]=$obj
    return $((__tick_data_values++))
}

__tick_json_parse_value() {
    case "$token" in
        '{') __tick_json_parse_object ;;
        '[') __tick_json_parse_array ;;
        *)
            eval __tick_data_value[\$__tick_data_values]=$token
            return $((__tick_data_values++))
            ;;
    esac
    return $?
}

__tick_json_parse() {
    [ -z "$token" ] && read -r token
    : ${Prefix:="default"}
    __tick_json_parse_value
    eval __tick_data_root_$Prefix=$?
    read -r token
}
# }}} End of code from github


__tick_fun_tokenize_expression() {
    __tick_json_tokenize
}

__tick_fun_parse_expression() {
    __ $FUNCNAME $1
    local -a path
    unset Prefix
    while read -r token; do
        case "$token" in
            '['|']'|.)
                path+=( "$Prefix" )
                Prefix=""
                ;;
            '"'|"'")
                ;;
            =)
                read -r token
                ;&
            '{')
                __tick_json_parse
                return ;;
            '*'|'#'|'!')
                path+=( "$Prefix" )
                Prefix="\'$token\'"
                ;;
            *) Prefix+=$token ;;
        esac
    done < <(__tick_fun_tokenize_expression <<<"$1")

    path+=( $Prefix )
    if [ "${path[0]:0:1}" != "$" ]; then
        path[0]='${__tick_data_root_'${path[0]:-default}'}'
    fi

    local tick='`'
    [ "$2" == "1" ] && tick='\`'
    echo -n $tick'__tick_runtime_lookup '${path[@]}$tick
}

# The purpose of this function is to separate out the Bash code from the
# special "tick tick" code.  We do this by hijacking the IFS and reading
# in a single character at a time
__tick_fun_parse() {
    # code oscillates between being bash or tick tick blocks.
    local code=''
    local IFS=
    local tickParse=0
    local ticktock=0

    __tick_line=1

    # By using -n, we are given that a newline will be an empty token. We
    # can certainly test for that.
    while read -r -n 1 token; do
        case "$token" in
            '`')
                ticktock=$(((ticktock+1)%2))

                # To make sure that we find two sequential backticks, we reset the counter
                # if it's not a backtick.
                if (( ++ticks == 2 )); then

                    # Whether we are in the stanza or not, is controlled by a different
                    # variable
                    if (( tickFlag == 1 )); then
                        tickFlag=0
                        [ "$code" ] && __tick_fun_parse_expression "$code" $ticktock
                    else
                        tickFlag=1
                        if [ $tickParse -gt 0 ] || [ `echo "$code" | grep -c tickParse` -gt 0 ]; then
                            cat <<EOF
if [ ! -z "\$__tick_export_data" ]; then
  eval \$__tick_export_data
  unset __tick_export_data
fi
EOF
                        fi

                        tickParse=0
                        echo -n $code
                    fi

                    unset code
                fi
                ;;

            '') # this is a newline.
                ((__tick_line++))

                if (( ticks == 1 )); then
                    code+='`'
                fi

                ticks=0

                if (( tickFlag == 0 )); then
                    if [ `echo "$code" | grep -c tickParse` -gt 0 ]; then
                        tickParse=1
                    fi
                    echo $code
                    unset code
                fi

                ;;

            *)
                if (( ticks == 1 )); then
                    code+='`'
                fi

                ticks=0
                code+="$token"
                ;;
        esac
    done
}

__tick_fun_tokenize() {
    # This makes sure that when we rerun the code that we are
    # interpreting, we don't try to interpret it again.
    export __tick_var_tokenized=1

    # Using bash's caller function, which is for debugging, we
    # can find out the name of the program that called us.
    export __tick_source=`caller 1 | cut -d ' ' -f 3`
    local dst="${__tick_source}.ticktick"

    __ "ticktick tokenizing $__tick_source"

    __tick_fun_parse < $__tick_source > $dst
    __tick_env_export __tick_export_data ${!__tick_data_*}

    parseErrors=`grep "TICKTICK PARSING ERROR" $dst`
    if [ "$parseErrors" ]; then
        # the ignore parse errors are used by the test scripts
        if [ $__tick_ignore_parse_errors ]; then
            bash $dst "${ARGV[@]}"
            # ignore ret code when there's parse errors
        else
            # print the parse errors
            eval $parseErrors
        fi
        # exit code is number of parse errors reported
        ret=`echo "$parseErrors" | wc -l`
    else
        bash $dst "${ARGV[@]}"
        ret=$?
    fi
    [ $__tick_save_tokenized ] || rm $dst
    exit $ret
}

__tick_env_export() {
    __ export $*
    local e
    for ((i=2; i <= $#; i++)); do
        e="$e `declare -p ${!i}`;"
    done
    eval export $1='${!1}${e[*]};'
}

## Runtime {
__tick_runtime_lookup() {
    __ $FUNCNAME $*
    local val
    case "$1" in
        __tick_data_*)
            val=$1 ;;
        *) val=${__tick_data_value[$1]} ;;
    esac
    case "$2" in
        ''\''*'\''') # values
            local next="$val[*]"
            echo -n ${!next}
            ;;
        ''\''#'\''') # length
            local next="$val[*]"
            eval echo -n '${#'$next'}'
            ;;
        ''\''!'\''') # keys
            local next="$val[*]"
            eval echo -n '${!'$next'}'
            ;;
        *) # index
            local next="$val[$2]"
            shift 2 && __tick_runtime_lookup ${!next} $* || echo -n ${val}
            ;;
    esac
}

tickParse() {
    __tick_fun_parse_expression "$*"
}

tickExport() {
    case "$1" in
        __tick_data_obj_*)
            echo -n "{"
            local i=0
            for k in `__tick_runtime_lookup $1 ''\''!'\'''`; do
                if ((i++)); then echo -n ","; fi
                local n="$1[$k]"
                echo -n '"'$k'":'
                tickExport ${!n}
            done
            echo -n "}"
            ;;
        __tick_data_arr_*)
            echo -n "["
            for k in `__tick_runtime_lookup $1 ''\''!'\'''`; do
                if ((k)); then echo -n ","; fi
                local n="$1[$k]"
                tickExport ${!n}
            done
            echo -n "]"
            ;;
        [0-9]*)
            local v=${__tick_data_value[$1]}
            case "$v" in
                __tick_data_*)
                    tickExport "$v" ;;
                [0-9]*)
                    echo -n "$v" ;;
                *)
                    echo -n '"'$v'"' ;;
            esac
            ;;
        *)
            echo -n '<<que!? ('"$1"') as in, this is a bug!>>'
            ;;
    esac
}

## } End of Runtime

## process input script on first pass
[ $__tick_var_tokenized ] || __tick_fun_tokenize

## import exported data on pass 2
if [ ! -z "$__tick_export_data" ]; then
    eval $__tick_export_data
    unset __tick_export_data
fi

## since we screwed up $0..
O="$__tick_source"
