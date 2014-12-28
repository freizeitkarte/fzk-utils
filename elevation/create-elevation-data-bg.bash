#!/bin/bash

MAPNAME="$1"
POLYFILE="./poly/$MAPNAME.poly"
ELE10="ele_10_100_200"
ELE20="ele_20_100_500"
ELE25="ele_25_250_500"
#DATASRC="view1,view3"
DATASRC="view1,view3,srtm1,srtm3"

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
echo "20/100/500 m"
echo "---------------------------------------------"
LOGFILE="logs/$MAPNAME-ele20.log"
phyghtmap --step=20                         \
          --osm-version=0.6                 \
          --jobs=1                          \
          --polygon=${POLYFILE}             \
          --line-cat=500,100                \
          --source=${DATASRC}               \
          --start-node-id=${NID}            \
          --start-way-id=${WID}             \
          --max-nodes-per-tile=0            \
          --pbf                             \
          --write-timestamp                 \
          --output-prefix=./pbf/${ELE20}/Hoehendaten_${MAPNAME} | tee >(grep using | grep hgt | awk '{print $NF}' | sed 's/.$//' > $LOGFILE)


if [ -f ./pbf/${ELE20}/Hoehendaten_${MAPNAME}.osm.pbf ]
then
   rm ./pbf/${ELE20}/Hoehendaten_${MAPNAME}.osm.pbf
fi
mv ./pbf/${ELE20}/Hoehendaten_${MAPNAME}*.osm.pbf ./pbf/${ELE20}/Hoehendaten_${MAPNAME}.osm.pbf

echo
echo "25/250/500 m"
echo "---------------------------------------------"
LOGFILE="logs/$MAPNAME-ele25.log"
phyghtmap --step=25                         \
          --osm-version=0.6                 \
          --jobs=1                          \
          --polygon=${POLYFILE}             \
          --line-cat=500,250                \
          --source=${DATASRC}               \
          --start-node-id=${NID}            \
          --start-way-id=${WID}             \
          --max-nodes-per-tile=0            \
          --pbf                             \
          --write-timestamp                 \
          --output-prefix=./pbf/${ELE25}/Hoehendaten_${MAPNAME} | tee >(grep using | grep hgt | awk '{print $NF}' | sed 's/.$//' > $LOGFILE)

if [ -f ./pbf/${ELE25}/Hoehendaten_${MAPNAME}.osm.pbf ]
then
   rm ./pbf/${ELE25}/Hoehendaten_${MAPNAME}.osm.pbf
fi
mv ./pbf/${ELE25}/Hoehendaten_${MAPNAME}*.osm.pbf ./pbf/$ELE25/Hoehendaten_${MAPNAME}.osm.pbf


echo 
echo "10/100/200 m"
echo "---------------------------------------------"
LOGFILE="logs/$MAPNAME-ele10.log"
phyghtmap --step=10                         \
          --osm-version=0.6                 \
          --jobs=1                          \
          --polygon=$POLYFILE               \
          --line-cat=200,100                \
          --source=${DATASRC}               \
          --start-node-id=${NID}            \
          --start-way-id=${WID}             \
          --max-nodes-per-tile=0            \
          --pbf                             \
          --write-timestamp                 \
          --output-prefix=./pbf/${ELE10}/Hoehendaten_${MAPNAME} | tee >(grep using | grep hgt | awk '{print $NF}' | sed 's/.$//' > $LOGFILE)
		  
if [ -f ./pbf/${ELE10}/Hoehendaten_${MAPNAME}.osm.pbf ]
then
   rm ./pbf/${ELE10}/Hoehendaten_${MAPNAME}.osm.pbf
fi
mv ./pbf/${ELE10}/Hoehendaten_${MAPNAME}*.osm.pbf ./pbf/${ELE10}/Hoehendaten_${MAPNAME}.osm.pbf

echo
