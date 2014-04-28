#!/bin/bash

for POLYFILE in $(find ./poly -name *.poly )
do
   echo 
   echo "$POLYFILE"
   echo "============================================="

   PBFPREFIX=$(basename $POLYFILE .poly)

   phyghtmap --step=10                         \
             --osm-version=0.6                 \
             --jobs=1                          \
             --polygon=$POLYFILE               \
             --line-cat=200,100                \
             --viewfinder-mask=3               \
             --start-node-id=5500000000        \
             --start-way-id=2700000000         \
             --max-nodes-per-tile=0            \
             --pbf                             \
             --write-timestamp                 \
             --output-prefix=./pbf/${PBFPREFIX}_10_100_200

   phyghtmap --step=25                         \
             --osm-version=0.6                 \
             --jobs=1                          \
             --polygon=$POLYFILE               \
             --line-cat=500,250                \
             --viewfinder-mask=3               \
             --start-node-id=5500000000        \
             --start-way-id=2700000000         \
             --max-nodes-per-tile=0            \
             --pbf                             \
             --write-timestamp                 \
             --output-prefix=./pbf/${PBFPREFIX}_25_250_500

done
