#!/bin/bash

# Default Configurations (adoptable)
# ===========================================
# Datasources (view1,view3,srtm1,srtm3)
# -------------------------------------
#DATASRC="view1,view3"
DATASRC="view3"
#DATASRC="srtm1,srtm3"
#DATASRC="view1,view3,srtm1,srtm3"

# Number of jobs to be run in parallel (POSIX)
# --------------------------------------------
# - if not set (nproc/2) is used as default
# - debian 7 runs faster with JOBS=1
JOBS=1

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

  # Calculate some values used later on
  ELECAT="${ELEMAJOR},${ELEMEDIUM}"
  ELEPATH="ele_${ELESTEP}_${ELEMEDIUM}_${ELEMAJOR}"
  #LOGFILE="logs/$MAPNAME-ele${ELESTEP}.log"
  LOGFILE="pbf/${ELEPATH}/Hoehendaten_${MAPNAME}.osm.pbf.info"
  DATE=`date +'%Y-%m-%d %H:%M:%S'`
  PHYGHTMAPREL=`phyghtmap -v`

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

  # Creating some output to screen
  echo
  echo "${ELESTEP}/${ELEMEDIUM}/${ELEMAJOR} m (datasource: ${DATASRC})"
  echo "------------------------------------------------------------"
  
  # Create some output to the info file
  echo "# General Information:"                       >  $LOGFILE
  echo "# ------------------------------------------------------------" >> $LOGFILE
  echo "# Filename:   Hoehendaten_${MAPNAME}.osm.pbf" >>  $LOGFILE
  echo "# Build Date: $DATE"                          >> $LOGFILE
  echo "# Created by: $PHYGHTMAPREL"                  >> $LOGFILE
  echo "#"                                            >> $LOGFILE
  echo "# phyghtmap parameters:"                      >> $LOGFILE
  echo "# ------------------------------------------------------------" >> $LOGFILE
  echo "# Datasource: ${DATASRC}"                     >> $LOGFILE
  echo "# Step:       ${ELESTEP} m"                   >> $LOGFILE
  echo "# Medium:     ${ELEMEDIUM} m"                 >> $LOGFILE
  echo "# Major:      ${ELEMAJOR} m"                  >> $LOGFILE
  echo "# Poly File:  ${POLYFILE}"                    >> $LOGFILE
  echo "# Start NID:  ${NID}"                         >> $LOGFILE
  echo "# Start WID:  ${WID}"                         >> $LOGFILE
  echo "#"                                            >> $LOGFILE
  echo "# Used hgt files:"                            >> $LOGFILE
  echo "# ------------------------------------------------------------" >> $LOGFILE

  
  
  # Actually call phyghtmap
  # -----------------------
  phyghtmap --step=${ELESTEP}                 \
            --osm-version=0.6                 \
            --jobs=${JOBS}                    \
            --polygon=${POLYFILE}             \
            --line-cat=${ELECAT}              \
            --source=${DATASRC}               \
            --start-node-id=${NID}            \
            --start-way-id=${WID}             \
            --max-nodes-per-tile=0            \
            --pbf                             \
            --write-timestamp                 \
            --output-prefix=./pbf/${ELEPATH}/Hoehendaten_${MAPNAME} | tee >(grep using | grep hgt | awk '{print $NF}' | sed 's/.$//' >> $LOGFILE)
  
  
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
     echo "... renaming that to ./pbf/${ELEPATH}/Hoehendaten_${MAPNAME}.osm.pbf"
     mv ./pbf/${ELEPATH}/Hoehendaten_${MAPNAME}_lon*lat*.osm.pbf ./pbf/${ELEPATH}/Hoehendaten_${MAPNAME}.osm.pbf
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

# Calculate the parallel jobs to be run
if [ -z "$JOBS" ]
then
   JOBS=`nproc`
   JOBS=$((JOBS+1))
   JOBS=$((JOBS/2))
fi
# In case JOBS is 0, set it to one
if [ "0$JOBS" -lt "1" ]
then
  JOBS=1
fi

# Create the output
echo 
echo "$POLYFILE"
echo "============================================="

# Call the functions to really do the work
createcontour 20 100 500
#createcontour 25 250 500
#createcontour 10 100 200

