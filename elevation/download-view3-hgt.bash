#!/bin/bash

POLYFILE="$1"
LOGFILE="logs/`basename $1`.log"

echo > $LOGFILE
echo "$POLYFILE" >> $LOGFILE
echo "=============================================" >> $LOGFILE

phyghtmap --step=25                         \
          --osm-version=0.6                 \
          --jobs=1                          \
          --polygon=$POLYFILE               \
          --source=view3,srtm1,srtm3        \
          --max-nodes-per-tile=0            \
          --pbf                             \
          --write-timestamp                 \
          --output-prefix=xxxxx/xxxx        \
    | grep using | grep hgt | awk '{print $NF}' | sed 's/.$//' >> $LOGFILE

