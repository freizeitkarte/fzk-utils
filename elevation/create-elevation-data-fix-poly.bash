#!/bin/bash
# Runs through all poly files in the poly.work directory
#
# Usage examples:
# ./create-elevation-data-fix-poly.bash
# ./create-elevation-data-fix-poly.bash -e "10,100,200"

for POLYFILE in $(find ./poly.work -name *.poly )
do
   MAPNAME=$(basename $POLYFILE .poly)

   ./create-elevation-data-bg.bash $* $MAPNAME

done
