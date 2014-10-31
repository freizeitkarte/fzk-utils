#!/bin/bash

POLYFILE="./poly/$1.poly"

if [ -z "$2" ]
then
   NID=7500000000
else
   NID=$2
fi

if [ -z "$3" ]
then 
   WID=4700000000
else
   WID=$3
fi

echo 
echo "$POLYFILE"
echo "============================================="

PBFPREFIX=$(basename $POLYFILE .poly)

phyghtmap --step=25                         \
          --osm-version=0.6                 \
          --jobs=1                          \
          --polygon=$POLYFILE               \
          --line-cat=500,250                \
          --source=view1,srtm1,view3,srtm3  \
          --start-node-id=$NID              \
          --start-way-id=$WID               \
          --max-nodes-per-tile=0            \
          --pbf                             \
          --write-timestamp                 \
          --output-prefix=./pbf/ele_25_250_500/Hoehendaten_${1}

mv ./pbf/ele_25_250_500/Hoehendaten_${1}*.osm.pbf ./pbf/ele_25_250_500/Hoehendaten_${1}.osm.pbf

phyghtmap --step=10                         \
          --osm-version=0.6                 \
          --jobs=1                          \
          --polygon=$POLYFILE               \
          --line-cat=200,100                \
          --source=view1,srtm1,view3,srtm3  \
          --start-node-id=$NID              \
          --start-way-id=$WID               \
          --max-nodes-per-tile=0            \
          --pbf                             \
          --write-timestamp                 \
          --output-prefix=./pbf/ele_10_100_200/Hoehendaten_${1}
		  
mv ./pbf/ele_10_100_200/Hoehendaten_${1}*.osm.pbf ./pbf/ele_10_100_200/Hoehendaten_${1}.osm.pbf

