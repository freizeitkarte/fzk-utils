#!/bin/bash

# Usage
# ===========================================
# ./create-elevation-data-bg.bash [options] <MAPNAME>
#
# Options:
# -s  datasource to be used (phyghtmap)
#     default: view3
# -d  alternative hgt directory
#     default: "./hgt/"
#     other values possible: "./hgt-special/AUT/hgt/"
#
# Example:
# ./create-elevation-data-bg.bash 
#    [-s "view1,view3"]
#    Freizeitkarte_ALB 

# ./create-elevation-data-bg.bash -d "hgt-special/SWE/hgt/" Freizeitkarte_SWE


# Default Configurations (adoptable)
# ===========================================
# Datasources (view1,view3,srtm1,srtm3)
# -------------------------------------
DATASRC_DEFAULT="view3"

# Number of jobs to be run in parallel (POSIX)
# --------------------------------------------
# - if not set (nproc/2) is used as default
# - debian 7 runs faster with JOBS=1
JOBS=1

# Default Node and Way IDs
# -------------------------------------
NID_DEFAULT=7500000000
WID_DEFAULT=4700000000

# Default elevation categorization
# ---------------------------------
# Sensful combinations for fzk: 
#   20,100,500
#   10,100,200
ELESTEP_DEFAULT=20
ELEMEDIUM_DEFAULT=100
ELEMAJOR_DEFAULT=500

# Default HGT Directory
# ---------------------
HGTDIR_DEFAULT="./hgt/"

# No configurations needed below
# ===========================================

# Reusable call of phyghtmap
# --------------------------
function createcontour {
  
#  # Get the given arguments
#  ELESTEP=$1
#  ELEMEDIUM=$2
#  ELEMAJOR=$3

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
			--hgtdir=${HGTDIR}                \
			--download-only                   \
            --output-prefix=./pbf/${ELEPATH}/Hoehendaten_${MAPNAME} 
        
			
# call phyghtmap
#---------------
#--step=${ELESTEP}                 \
#--osm-version=0.6                 \
#--jobs=${JOBS}                    \
#--polygon=${POLYFILE}             \
#--line-cat=${ELECAT}              \
#--source=${DATASRC}               \
#--start-node-id=${NID}            \
#--start-way-id=${WID}             \
#--max-nodes-per-tile=0            \
#--pbf                             \
#--write-timestamp                 \
#--hgtdir=${HGTDIR}                \
#--output-prefix=./pbf/${ELEPATH}/Hoehendaten_${MAPNAME} | tee >(grep using | grep hgt | awk '{print $NF}' | sed 's/.$//' >> $LOGFILE)
      
}

# Main Part
# ====================
# Initialize values possibly overwritten by arguments
# ---------------------------------------------------
NID=''
WID=''
DATASRC=''
ELEDETAIL=''
HGTDIR=''

# Get given options if present
# ----------------------------
while getopts 's:n:w:e:d:' flag
do
   case "${flag}" in
      s) DATASRC="${OPTARG}";;
      n) NID="${OPTARG}";;
      w) WID="${OPTARG}";;
      e) ELEDETAIL="${OPTARG}";;
	  d) HGTDIR="${OPTARG}";;
      *) echo "Unexpected option ${flag}"
         exit 1
         ;;
   esac
done

# Shift forward to the rest of the arguments
shift $((OPTIND-1))


# Get the MAPNAME and set some defaults
MAPNAME="$1"
POLYFILE="./poly.work/$MAPNAME.poly"

# Check if ID's are given, else set default
if [ -z "${NID}" ]
then
   NID=$NID_DEFAULT
fi
if [ -z "${WID}" ]
then 
   WID=$WID_DEFAULT
fi

# Check if different Datasource is given, else set default
if [ -z "${DATASRC}" ]
then 
   DATASRC=$DATASRC_DEFAULT
fi

# If different hgt directory is given set SPECIALSRC flag and reset DATASRC to srtm1, else set default
if [ -n "${HGTDIR}" ]
then 
   SPECIALSRC=1
#   DATASRC="srtm1"
   DATASRC="view1"
else
   HGTDIR=$HGTDIR_DEFAULT
   SPECIALSRC=0
fi


# Check if different elevation categorization is choosen, else set default
if [ -z "${ELEDETAIL}" ]
then 
   ELESTEP=$ELESTEP_DEFAULT
   ELEMEDIUM=$ELEMEDIUM_DEFAULT
   ELEMAJOR=$ELEMAJOR_DEFAULT
else
   # arguments given, let's split it up
   # Let's check if we have 3 arguments in there, else exit
   if [ `echo $ELEDETAIL | sed 's/,/ /g' | wc -w` -eq 3 ]
   then
      ELESTEP=`echo $ELEDETAIL | cut -d, -f1`
      ELEMEDIUM=`echo $ELEDETAIL | cut -d, -f2`
      ELEMAJOR=`echo $ELEDETAIL | cut -d, -f3`
   else
      echo "ERROR: there is something wrong with $ELEDETAIL"
   fi 
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
createcontour

