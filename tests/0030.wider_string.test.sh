#!/bin/bash
# Bug 30: Wider string support
#
# See:
# https://github.com/kristopolous/TickTick/issues/30
__tick_var_debug=1
. ../ticktick.sh

# This code should genuinely work.
``
{
  "colon:separated" : 0,
  "space separated" : 1,
  "period.separated": 2,
  "singlequote'separated" : 3,
  "leftcurly{separated" : 4,
  "rightcurly}separated" : 5,
  "leftbracket[separated" : 6,
  "rightbracket]separated" : 7,
  "comma,separated" : 8,
  "escapedquote\"separated" : 9,
  "multipe 'tokens' [at once] but matching" : 10,
  "multipe 'tokens: ]at once] and not matching" : 11,
  "other:\"tokens.:[at.,once,}and{not{matching" : 12
}
``
