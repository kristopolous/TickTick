#!/bin/bash
. ../ticktick.sh

DATA=`cat data.json`

tickParse "$DATA"

test_assert "``.pathname``" "/echo/request.json" "Pathname wrong"
test_assert "``.headers[user-agent]``" "curl/7.21.6 (i686-pc-linux-gnu) libcurl/7.21.6 OpenSSL/1.0.0e zlib/1.2.3.4 libidn/1.22 librtmp/2.3" "User-agent wrong"
