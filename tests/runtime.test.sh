#!/bin/bash
. ../ticktick.sh
. ./common.sh

DATA=`cat data.json`

tickParse "$DATA"

[ "``pathname``" == "/echo/request.json" ] || test_error "Pathname wrong"
[ "``headers["user-agent"]``" == "curl/7.21.6 (i686-pc-linux-gnu) libcurl/7.21.6 OpenSSL/1.0.0e zlib/1.2.3.4 libidn/1.22 librtmp/2.3" ] || test_error "User-agent wrong"

test_done
