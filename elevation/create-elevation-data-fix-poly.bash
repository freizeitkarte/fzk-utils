#!/bin/bash

for POLYFILE in $(find ./poly -name *.poly )
do
   PBFPREFIX=$(basename $POLYFILE .poly)

   ./create-elevation-data-bg.bash $PBFPREFIX

done
