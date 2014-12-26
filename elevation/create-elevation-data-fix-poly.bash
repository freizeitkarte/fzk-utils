#!/bin/bash

for POLYFILE in $(find ./poly -name *.poly )
do
   MAPNAME=$(basename $POLYFILE .poly)

   ./create-elevation-data-bg.bash $MAPNAME

done
