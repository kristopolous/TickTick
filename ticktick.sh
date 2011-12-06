#!/bin/bash


# This is from https://github.com/dominictarr/JSON.sh, 
# See LICENSE for more info. {{{
__tick_json_throw () {
  echo "$*" >&2
  exit 1
}

__tick_json_tokenize () {
  local ESCAPE='(\\[^u[:cntrl:]]|\\u[0-9a-fA-F]{4})'
  local CHAR='[^[:cntrl:]"\\]'
  local STRING="\"$CHAR*($ESCAPE$CHAR*)*\""
  local VARIABLE="\\\$[A-Za-z0-9_]*"
  local NUMBER='-?(0|[1-9][0-9]*)([.][0-9]*)?([eE][+-]?[0-9]*)?'
  local KEYWORD='null|false|true'
  local SPACE='[[:space:]]+'
  egrep -ao "$STRING|$VARIABLE|$NUMBER|$KEYWORD|$SPACE|." --color=never |\
    egrep -v "^$SPACE$"  # eat whitespace
}

__tick_json_parse_array () {
  local index=0
  local ary=''

  read -r token

  case "$token" in
    ']') ;;
    *)
      while :
      do
        # We pad the indices to be 12 digits wide so that 
        # lexical sorting will always be equivalent to numerical
        # sorting. This is also done in the expression block
        # below.
        __tick_json_parse_value "$1" "`printf "%012d" $index`"

        let index=$index+1
        ary="$ary""$value" 

        read -r token

        case "$token" in
          ']') break ;;
          ',') ary="${ary}_" ;;
          *) __tick_json_throw "EXPECTED , or ] GOT ${token:-EOF}" ;;
        esac
        read -r token
      done
      ;;
  esac
  value=`printf '[%s]' $ary`
}

__tick_json_parse_object () {
  local key
  local obj=''
  read -r token

  case "$token" in
    '}') ;;
    *)
      while :
      do
        case "$token" in
          '"'*'"'|\$[A-Za-z0-9_]*) key=$token ;;
          *) __tick_json_throw "EXPECTED string GOT ${token:-EOF}" ;;
        esac

        read -r token

        case "$token" in
          ':') ;;
          *) __tick_json_throw "EXPECTED : GOT ${token:-EOF}" ;;
        esac

        read -r token
        __tick_json_parse_value "$1" "$key"
        obj="$obj$key:$value"        

        read -r token

        case "$token" in
          '}') break ;;
          ',') obj="${obj}_" ;;
          *) __tick_json_throw "EXPECTED , or } GOT ${token:-EOF}" ;;
        esac

        read -r token
      done
    ;;
  esac
  value=`printf '{%s}_' "$obj"`
}

__tick_json_parse_value () {
  local collection=1
  local jpath="${1:+$1,}$2"
  local prej="${jpath//,/_}"
  prej=${prej//\"/}
  if [ "$prej" ]; then
    prej="_$prej"
  fi

  case "$token" in
    '{') 
      __tick_json_parse_object "$jpath" 
      ;;

    '[') 
      __tick_json_parse_array  "$jpath" 
      ;;

    # At this point, the only valid single-character tokens are digits.
    ''|[^0-9]) __tick_json_throw "EXPECTED value GOT ${token:-EOF}" ;;

    *) 
      value=$token 

      collection=''

      if [ -z $__tick_var_collection ]; then
        printf "%s%s=%s\n" "__tick_data_$__tick_var_prefix" "$prej" "$value" 
      fi
      ;;
  esac

  # Keep track of things that are a collection
  if [ $collection ] && [ $__tick_var_collection ] ; then 
    echo -n "__tick_collection_$__tick_var_prefix$prej=1;"
  fi
}

__tick_json_parse () {
  read -r token
  __tick_json_parse_value
  read -r token

  case "$token" in
    '') ;;
    *) __tick_json_throw "EXPECTED EOF GOT $token" ;;
  esac
}
# }} End of code from github

__tick_fun_parse_expression () {
  local done=""
  local prefix=""
  local suffix=""

  local function=""
  local arguments=""

  local paren=0

  while read -r token; do
    if [ $done ]; then
      suffix="$suffix$token"
    else
      case "$token" in
        push|pop|shift|unshift|length) function=$token ;;
        '(') let paren=$paren+1 ;;

        ')') 
          let paren=$paren-1
          if (( paren == 0 )); then
            if [ -z $__tick_var_collection ]; then
              # There's some tricks here since bash functions don't actually return strings, just integers
              # A pop is a subshell execution followed by an unassignment for instance.
              case $function in
                pop) echo '$( __tick_runtime_last ${!__tick_data_'"$prefix"'*} ); __tick_runtime__pop ${!__tick_data_'"$prefix"'*}' ;;
                # length) echo "\$( __tick_runtime_$function \"$arguments\" __tick_data_$prefix "'${!__tick_data_'"$prefix"'*} )' ;;
                *) echo "__tick_runtime_$function \"$arguments\" __tick_data_$prefix "'${!__tick_data_'"$prefix"'*}'
              esac

              return
            fi
          fi
          ;;

        '$') prefix="$prefix"DOLLARSIGN ;;
        [0-9]*) prefix="$prefix"`printf "%012d" $token` ;;
        '['|.) prefix="$prefix"_ ;;
        '"'|"'"|']') ;;
        =) done=1 ;;
        *) 
          if (( paren > 0 )); then
            arguments="$arguments$token"
          else
            prefix="$prefix$token" 
          fi
          ;;
      esac
    fi
  done

  if [ $suffix ]; then
    __tick_var_prefix="$prefix"
    echo "$suffix" | __tick_json_tokenize | __tick_json_parse
  elif [ -z $__tick_var_collection ]; then
    if (( $(( __tick_collection_$prefix )) )); then
      echo '${!'__tick_data_$prefix'_*}'
    else
      echo '${'__tick_data_$prefix'}'
    fi
  fi
}

__tick_fun_tokenize_expression () {
  local CHAR='[A-Za-z_\\]'
  local FUNCTION="(push|pop|unshift|shift|length)"
  local NUMBER='[0-9]*'
  local STRING="$CHAR*($CHAR*)*"
  local PAREN="[()]"
  local QUOTE="[\"\']"
  local SPACE='[[:space:]]+'
  egrep -ao "$FUNCTION|$STRING|$QUOTE|$PAREN|$NUMBER|$SPACE|." --color=never 
}

__tick_fun_parse() {
  local open=0
  local echoopts=''

  while read -r token; do
    case "$token" in
      '``') (( open++ )) ;;
      __tick_fun_append) echoopts='-n' ;;
      *) 
        if (( open % 2 == 1 )); then 
          if [ "$token" ]; then
            __tick_var_collection=1
            eval `echo "$token" | __tick_fun_tokenize_expression | __tick_fun_parse_expression`
            __tick_var_collection=''
            out=`echo $token | __tick_fun_tokenize_expression | __tick_fun_parse_expression`
            echo $echoopts "$out"
          fi
        else
          echo $echoopts "${token/%EOL/}"
        fi
        unset echoopts 
        ;;
    esac
  done
}

__tick_fun_tokenize()  {
  export __tick_var_tokenized=1

  local file=`caller 1 | cut -d ' ' -f 3`

  awk -F '``' '{\
    if (NF < 2) {\
      printf "%s", $0\
    } else {\
      if (length($1))\
        printf "__tick_fun_append\n%sEOL\n", $1;\
      else\
        print $1;\
      for(i = 2; i <= NF; i++) {\
        if (++open % 2 == 0)\
          print "";\
        if ( (i + 1) % 2 == 1 && length($(i + 1)))\
          print "__tick_fun_append";\
        if ( i % 2 == 1 && length($i))\
          printf "%s\n%sEOL", FS, $i;\
        else\
          printf "%s\n%s", FS, $i;\
      }\
    }\
    if (open % 2 == 0)\
      print ""\
  }' $file | __tick_fun_parse | bash

  exit
}

__tick_runtime_length() {
  return $(( $# - 2 ));
}
__tick_runtime_unshift() {
  echo "unshift - TODO"
}
__tick_runtime_shift() {
  echo "shift - TODO"
}
__tick_runtime_last() {
  eval 'echo $'"${!#}"
}
__tick_runtime__pop() {
  local lastarg="${!#}"
  eval "unset $lastarg"
}
__tick_runtime_push() {
  local value=$1
  local base=$2
  local lastarg="${!#}"

  let nextval=${lastarg/$base/}+1
  nextval=`printf "%012d" $nextval`

  eval "$base$nextval=$value"
}

[ $__tick_var_tokenized ] || __tick_fun_tokenize
