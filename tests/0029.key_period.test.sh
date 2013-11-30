#!/bin/bash
# Bug 29: Problem when key contains period character
#
# See:
# https://github.com/kristopolous/TickTick/issues/29
#
# And:
# https://groups.google.com/forum/#!topic/ticktick-project/CbOZjQ0RGmc
. ../ticktick.sh

# This code should genuinely work.
# The tricky part is the second key, where you see the helloService(.)
``
key = {
  "bootstrap" : {
    "healthy" : true
  },
  "helloService.checkGreetingHealthCheck" : {
    "healthy" : true,
    "message" : "Greeting set to Hello"
  }
}
``
