Parsing Error Detected, see below
#!/bin/bash 
. ../ticktick.sh

# This is reference to issue (1), 
# (test case) e.g., parser goes to infinite loop on dicts

# This should parse ok
__tick_data_data_x="y"

# This is a bug in code, but
# it should say so
__tick_data_data_x="y"
TICKTICK PARSING ERROR: Object without a Key
Parsing stopped here.
