#!/bin/bash
. ../ticktick.sh

``bar = { "foo": 123, "pathname": 456, "bar":[1, 2, "abc", 4, {"obj":["foo", ["nested", "arr ays", 555]]}] }``

test_assert "`tickExport ``bar`` `" '{"pathname":456,"bar":[1,2,"abc",4,{"obj":["foo",["nested","arr ays",555]]}],"foo":123}'
