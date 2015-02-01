#!/bin/bash

for POLYFILE in $(find ./poly.work -name *.poly )
do
   MAPNAME=$(basename $POLYFILE .poly)

   ./create-elevation-data-bg.bash $MAPNAME

done
