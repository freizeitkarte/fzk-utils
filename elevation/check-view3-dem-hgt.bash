#!/bin/bash

# Usage
# ===========================================
# ./check-view3-dem-hgt.bash <INFOFILE>
#
# parses an elevation info file to see if all needed hgt files for the specific map
# are available to build a map with DEM data.
# To be started in the elevation root directory.

# Options:
# <INFOFILE>: the info file that gets built together with the elevation data
#     example: /var/www/fzk-develop/ele_20_100_500/Hoehendaten_Freizeitkarte_NLD.osm.pbf.info

FILES=`cat $1 | grep -v ^# | grep -v ^$`

FILESMISSING=0
FILESOK=0

for SINGLEFILE in $FILES
do
  if [ -f "$SINGLEFILE" ]
  then
     echo "$SINGLEFILE:  OK"
	 FILESOK=$((FILESOK + 1))
  else
	 FILESMISSING=$((FILESMISSING + 1))
  fi
done

echo
echo "$1"
echo "----------------------------------------------------------------------------"
echo "OK:       $FILESOK hgt files"
echo "MISSING:  $FILESMISSING hgt files"