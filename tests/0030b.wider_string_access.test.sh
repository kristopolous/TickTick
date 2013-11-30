#!/bin/bash
# Bug 30: Wider string support
#
# See:
# https://github.com/kristopolous/TickTick/issues/30
. ../ticktick.sh

# This code should genuinely work.
``
key = {
  "colon:separated" : 0,
  "space separated" : 1,
  "period.separated": 2,
  "singlequote'separated" : 3,
  "leftcurly{separated" : 4,
  "rightcurly}separated" : 5,
  "leftbracket[separated" : 6,
  "rightbracket]separated" : 7,
  "leftparen(separated" : 8,
  "rightparen)separated" : 9,
  "equal=separated" : 10,
  "semicolon;separated" : 11,
  "comma,separated" : 12,
  "hyphen-separated" : 13,
  "escapedquote\"separated" : 14,
  "multipe 'tokens' [at once] but matching" : 15,
  "multipe 'tokens: ]at once] and not matching" : 16,
  "other:\"tokens.:[slashed.,once,}and{not{matching" : 17,
  "other=((tokens){;at\nonce\tand)not[matching" : 18 
}
``

echo ``key["colon:separated"]``
echo ``key["space separated"]``
echo ``key["period.separated"]``
echo ``key["singlequote'separated"]``
echo ``key["leftcurly{separated"]``
echo ``key["rightcurly}separated"]``
echo ``key["leftbracket[separated"]``
echo ``key["rightbracket]separated"]``
echo ``key["leftparen(separated"]``
echo ``key["rightparen)separated"]``
echo ``key["equal=separated"]``
echo ``key["semicolon;separated"]``
echo ``key["comma,separated"]``
echo ``key["hyphen-separated"]``
echo ``key["escapedquote\"separated"]``
echo ``key["multipe 'tokens' [at once] but matching"]``
echo ``key["multipe 'tokens: ]at once] and not matching"]``
echo ``key["other:\"tokens.:[slashed.,once,}and{not{matching"]``
echo ``key["other=((tokens){;at\nonce\tand)not[matching"]``
