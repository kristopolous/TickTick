#!/usr/bin/env bash
ARGV=$@
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
  local index=0
  local ary=''

  read -r Token

  case "$Token" in
    ']') ;;
    *)
      while :
      do
        __tick_json_parse_value "$1" "`printf "%012d" $index`"

        (( index++ ))
        ary+="$Value" 

        read -r Token
        case "$Token" in
          ']') break ;;
          ',') ary+=_ ;;
        esac
        read -r Token
      done
      ;;
  esac
}

__tick_json_parse_object() {
  local key
  local obj=''
  read -r Token

  case "$Token" in
    '}') ;;
    *)
      while :
      do
        case "$Token" in
          '"'*'"'|\$[A-Za-z0-9_]*) key=$Token ;;
        esac

        read -r Token

        read -r Token
        __tick_json_parse_value "$1" "$key"
        obj+="$key:$Value"        

        read -r Token
        case "$Token" in
          '}') break ;;
          ',') obj+=_ ;;
        esac
        read -r Token
      done
    ;;
  esac
}

__tick_json_parse_value() {
  local jpath="${1:+$1_}$2"
  local prej=${jpath//\"/}

  [ "$prej" ] && prej="_$prej"
  [ "$prej" ] && prej=${prej/-/__hyphen__}

  case "$Token" in
    '{') __tick_json_parse_object "$jpath" ;;
    '[') __tick_json_parse_array  "$jpath" ;;

    *) 
      Value=$Token 
      Path="$Prefix$prej"
      Path=${Path/#_/}
      echo __tick_data_$Path=$Value 
      ;;
  esac
}

__tick_json_parse() {
  read -r Token
  __tick_json_parse_value
  read -r Token
}
# }}} End of code from github

__tick_fun_tokenize_expression() {
  CHAR='[A-Za-z_$\\]'
  FUNCTION="(push|pop|shift|items|length)"
  NUMBER='[0-9]*'
  STRING="$CHAR*($CHAR*)*"
  PAREN="[()]"
  QUOTE="[\"\']"
  SPACE='[[:space:]]+'
  egrep -ao "$FUNCTION|$STRING|$QUOTE|$PAREN|$NUMBER|$SPACE|." --color=never |\
    sed "s/^/S/g;s/$/E/g" # Make sure spaces are respected
}

__tick_fun_parse_expression() {
  local paren=0

  while read -r token; do
    token=${token/#S/}
    token=${token/%E/}

    if [ $done ]; then
      suffix+="$token"
    else
      case "$token" in
        push|pop|shift|items|length) function=$token ;;
        '(') (( paren++ )) ;;
        ')') 
          case $function in
            items) echo '${!__tick_data_'"$Prefix"'*}' ;;
            pop) echo '"$( __tick_runtime_last ${!__tick_data_'"$Prefix"'*} )"; __tick_runtime_pop ${!__tick_data_'"$Prefix"'*}' ;;
            shift) echo '`__tick_runtime_first ${!__tick_data_'"$Prefix"'*}`; __tick_runtime_shift ${!__tick_data_'"$Prefix"'*}' ;;
            length) echo '`__tick_runtime_length ${!__tick_data_'"$Prefix"'*}`' ;;
            *) echo "__tick_runtime_$function \"$arguments\" __tick_data_$Prefix "'${!__tick_data_'"$Prefix"'*}'
          esac

          return
          ;;

        [0-9]*) Prefix+=`printf "%012d" $token` ;;
        '['|.) Prefix+=_ ;;
        '"'|"'"|']') ;;
        =) done=1 ;;
        # Only respect a space if its in the args.
        ' ') [ $paren -gt 0 ] && arguments+="$token" ;;
        *) [ $paren -gt 0 ] && arguments+="$token" || Prefix+="$token" ;;
      esac
    fi
  done

  if [ "$suffix" ]; then
    echo "$suffix" | __tick_json_tokenize | __tick_json_parse
  else
    Prefix=${Prefix/-/__hyphen__}
    echo '${__tick_data_'$Prefix'}'
  fi
}

__tick_fun_parse() {
  local open=0

  while read -r token; do
    token=${token/#S/}
    token=${token/%E/}

    case "$token" in
      '``') (( open++ )) ;;
      __tick_fun_append) echoopts=-n ;;
      *) 
        if (( open % 2 == 1 )); then 
          [ "$token" ] && echo $echoopts "`echo $token | __tick_fun_tokenize_expression | __tick_fun_parse_expression`"
        else
          echo $echoopts "$token"
        fi
        unset echoopts 
        ;;
    esac
  done
}

__tick_fun_tokenize() {
  export __tick_var_tokenized=1

  local code=$(awk -F '``' '{\
    if (NF > 1) {\
      if (length($1))\
        print "__tick_fun_append\n"$1;\
      for(i = 2; i <= NF; i++) {\
        if (++open % 2 == 0)\
          print "";\
        if (i % 2 == 0 && length($(i + 1)))\
          print "__tick_fun_append";\
        printf "%s\n%s", FS, $i;\
      }\
    } else {\
      printf "%s", $0;\
      if (open % 2 == 0)\
        print ""\
    }\
  }' `caller 1 | cut -d ' ' -f 3` | sed "s/^/S/g;s/$/E/g" | __tick_fun_parse)
  bash -c "$code" -- $ARGV
  exit
}

## Runtime {
__tick_runtime_length() { echo $#; }
__tick_runtime_first() { echo ${!1}; }
__tick_runtime_last() { eval 'echo $'${!#}; }
__tick_runtime_pop() { eval unset ${!#}; }

__tick_runtime_shift() {
  local left=
  local right=

  for (( i = 1; i <= $# + 1; i++ )) ; do
    if [ "$left" ]; then
      eval "$left=\$$right"
    fi
    left=$right
    right=${!i}
  done
  eval unset $left
}
__tick_runtime_push() {
  local value="${1/\'/\\\'}"
  local base=$2
  local lastarg=${!#}

  let nextval=${lastarg/$base/}+1
  nextval=`printf "%012d" $nextval`

  eval $base$nextval=\'$value\'
}

tickParse() {
  eval `echo "$1" | __tick_json_tokenize | __tick_json_parse | tr '\n' ';'`
}
## } End of Runtime


[ $__tick_var_tokenized ] || __tick_fun_tokenize
