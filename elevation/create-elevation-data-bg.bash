#!/bin/bash

# Default Configurations (adoptable)
# ===========================================
# Datasources (view1,view3,srtm1,srtm3)
# -------------------------------------
DATASRC="view1"
#DATASRC="srtm1,srtm3"
#DATASRC="view1,view3,srtm1,srtm3"

# Default Node and Way IDs
# -------------------------------------
NID_DEFAULT=7500000000
WID_DEFAULT=4700000000

# No configurations needed below
# ===========================================

# Reusable call of phyghtmap
# --------------------------
function createcontour {
  
  # Get the given arguments
  ELESTEP=$1
  ELEMEDIUM=$2
  ELEMAJOR=$3

  # Calculate some values used lateron
  ELECAT="${ELEMAJOR},${ELEMEDIUM}"
  ELEPATH="ele_${ELESTEP}_${ELEMEDIUM}_${ELEMAJOR}"
  LOGFILE="logs/$MAPNAME-ele${ELESTEP}.log"

  # Create the log directory if needed
  if [ ! -d "logs" ]
  then
    mkdir logs
  fi
  
  # Create the elevation categories subdirectory if needed
  if [ ! -d "pbf/${ELEPATH}" ]
  then
    mkdir -p "pbf/${ELEPATH}"
  fi

  # Creating some output
  echo
  echo "${ELESTEP}/${ELEMEDIUM}/${ELEMAJOR} m"
  echo "---------------------------------------------"
  
  # Actually call phyghtmap
  # -----------------------
  phyghtmap --step=${ELESTEP}                 \
            --osm-version=0.6                 \
            --jobs=1                          \
            --polygon=${POLYFILE}             \
            --line-cat=${ELECAT}              \
            --source=${DATASRC}               \
            --start-node-id=${NID}            \
            --start-way-id=${WID}             \
            --max-nodes-per-tile=0            \
            --pbf                             \
            --write-timestamp                 \
            --output-prefix=./pbf/${ELEPATH}/Hoehendaten_${MAPNAME} | tee >(grep using | grep hgt | awk '{print $NF}' | sed 's/.$//' > $LOGFILE)
  
  
  # if there is already a file with the needed name, remove it
  echo "checking for existing ./pbf/${ELEPATH}/Hoehendaten_${MAPNAME}.osm.pbf ... "
  if [ -f ./pbf/${ELEPATH}/Hoehendaten_${MAPNAME}.osm.pbf ]
  then
     echo "... removing existing file."
     rm ./pbf/${ELEPATH}/Hoehendaten_${MAPNAME}.osm.pbf
  else
     echo "... nothing to delete"
  fi
  
  # Check if there is output created to be renamed
  echo "Checking if output has been generated ... "
  if [ -f ./pbf/${ELEPATH}/Hoehendaten_${MAPNAME}*.osm.pbf ]
  then
     echo "... enaming that to ./pbf/${ELEPATH}/Hoehendaten_${MAPNAME}.osm.pbf"
     mv ./pbf/${ELEPATH}/Hoehendaten_${MAPNAME}*.osm.pbf ./pbf/${ELEPATH}/Hoehendaten_${MAPNAME}.osm.pbf
  else
     echo "... no output generated, failed ?"
  fi
  
}

# Main Part
# ====================
# Get the MAPNAME and set some defaults
MAPNAME="$1"
POLYFILE="./poly/$MAPNAME.poly"

# Check if ID's are given, else set default
if [ -z "$2" ]
then
   NID=$NID_DEFAULT
else
   NID=$2
fi

if [ -z "$3" ]
then 
   WID=$WID_DEFAULT
else
   WID=$3
fi

# Create the output
echo 
echo "$POLYFILE"
echo "============================================="

# Call the functions to really do the work
createcontour 20 100 500
createcontour 25 250 500
createcontour 10 100 200

