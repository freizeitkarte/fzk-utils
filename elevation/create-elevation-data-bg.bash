#!/bin/bash

# History
# -------
# 20231122/pab: - adding support for pyhgtmap fork of agrenott
#               - adding support for Sonny Download sources (SONN1 SONN3)

# Usage
# ===========================================
# ./create-elevation-data-bg.bash [options] <MAPNAME>
#
# Options:
# -s  datasource to be used (pyghtmap)
#     default: srtm1
#     supported: srtm1, srtm3, sonn1, sonn3, view1, view3
# -n  start node ID for the generation of the contour lines (pyghtmap)
#     default: 750 000 000 000
# -w  start way ID for the generation of the contour lines (pyghtmap)
#     default: 750 000 000 000
# -e  elevation steps and categories
#     default: "20,100,500"
#     other value that is actually supported by fzk: "10,100,200"
# -d  alternative hgt directory
#     default: "./hgt/"
#     other values possible: "./hgt-special/AUT/hgt/"
# -v  srtm-version
#     default: 3
#     also possible: 2.1
#     pyghtmap option: srtm-version
#
# Examples:
# ./create-elevation-data-bg.bash 
#    [-s "view1,view3"]
#    [-n 7000000000]
#    [-w 4200000000]
#    [-e "10,100,200"]
#    Freizeitkarte_ALB 
#
# ./create-elevation-data-bg.bash -e "10,100,200" -d "hgt-special/SWE/hgt/" Freizeitkarte_SWE

# Which pyhgtmap
# --------------
# Katze
#PYHGTMAP=phyhgtmap
# https://github.com/agrenott/pyhgtmap
PYHGTMAP=pyhgtmap

# Default Configurations (adoptable)
# ===========================================
# Datasources (view1,view3,srtm1,srtm3)
# -------------------------------------
DATASRC_DEFAULT="srtm1"

# Number of jobs to be run in parallel (POSIX)
# --------------------------------------------
# - if not set (nproc/2) is used as default
# - debian 7 runs faster with JOBS=1
JOBS=1

# Default Node and Way IDs
# -------------------------------------
#NID_DEFAULT=7500000000
#WID_DEFAULT=4700000000
NID_DEFAULT=750000000000
WID_DEFAULT=750000000000

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

# FZK License file handling
# ==============================
LICENSE_FILE="fzk.license"
LICENSE_DIR="./license/"

# Default srtm-version
# ---------------------
SRTMVERSION_DEFAULT="3"



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
  PYGHTMAPREL=`$PYHGTMAP -v`

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
  echo "# Created by: $PYGHTMAPREL"                   >> $LOGFILE
  echo "#"                                            >> $LOGFILE
  echo "# $PYHGTMAP parameters:"                      >> $LOGFILE
  echo "# ------------------------------------------------------------" >> $LOGFILE
  if [ $SPECIALSRC -eq 1 ]
  then
     echo "# Datasource: special source"                 >> $LOGFILE  
  else
     echo "# Datasource: ${DATASRC}"                     >> $LOGFILE  
  fi
  if [ ${DATASRC} = "srtm1" ] || [ ${DATASRC} = "srtm3" ]
  then
     echo "# Srtmversion:${SRTMVERSION}"                 >> $LOGFILE
  fi
  echo "# Step:       ${ELESTEP} m"                   >> $LOGFILE
  echo "# Medium:     ${ELEMEDIUM} m"                 >> $LOGFILE
  echo "# Major:      ${ELEMAJOR} m"                  >> $LOGFILE
  echo "# Poly File:  ${MAPNAME}.poly"                >> $LOGFILE
  echo "# Start NID:  ${NID}"                         >> $LOGFILE
  echo "# Start WID:  ${WID}"                         >> $LOGFILE
  echo "#"                                            >> $LOGFILE
  echo "# Used source files:"                         >> $LOGFILE
  echo "# ------------------------------------------------------------" >> $LOGFILE

  
  
  # Actually call phyghtmap
  # -----------------------
  $PYHGTMAP --step=${ELESTEP}                   \
            --osm-version=0.6                   \
            --jobs=${JOBS}                      \
            --polygon=${POLYFILE}               \
            --line-cat=${ELECAT}                \
            --source=${DATASRC}                 \
            ${SRTMVERSION_TXT}                  \
            --start-node-id=${NID}              \
            --start-way-id=${WID}               \
            --max-nodes-per-tile=0              \
            --pbf                               \
            --write-timestamp                   \
			   --hgtdir=${HGTDIR}                  \
            --output-prefix=./pbf/${ELEPATH}/Hoehendaten_${MAPNAME} | tee >(sed -n 's/^... file \(.*\): .*bbox.*/\1/p' >> $LOGFILE)
  
  
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
  if [ -f ./pbf/${ELEPATH}/Hoehendaten_${MAPNAME}_lon*lat*.osm.pbf ]
  then
     echo "... renaming that to ./pbf/${ELEPATH}/Hoehendaten_${MAPNAME}.osm.pbf"
     mv ./pbf/${ELEPATH}/Hoehendaten_${MAPNAME}_lon*lat*.osm.pbf ./pbf/${ELEPATH}/Hoehendaten_${MAPNAME}.osm.pbf

     # Check if there is a license file to be copied
     LICENSE_FILE_FULL=''
     if [ -f  ${HGTDIR}/${LICENSE_FILE} ]
     then
        LICENSE_FILE_FULL=${HGTDIR}/${LICENSE_FILE}
     elif [ -f  ${LICENSE_DIR}/${LICENSE_FILE}.${DATASRC} ]
     then
        LICENSE_FILE_FULL=${LICENSE_DIR}/${LICENSE_FILE}.${DATASRC}
     elif [ -f  ${LICENSE_DIR}/${LICENSE_FILE} ]
     then
        LICENSE_FILE_FULL=${LICENSE_DIR}/${LICENSE_FILE}
     fi
     if [ -n ${LICENSE_FILE_FULL} ]
     then
        echo "... license file found"
        echo "... copying ${LICENSE_FILE_FULL} to ./pbf/${ELEPATH}/Hoehendaten_${MAPNAME}.osm.pbf.license"
        cp ${LICENSE_FILE_FULL} ./pbf/${ELEPATH}/Hoehendaten_${MAPNAME}.osm.pbf.license
     fi

  else
     echo "... no output generated, failed ?"
  fi
  
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
SRTMVERSION=''

# Get given options if present
# ----------------------------
while getopts 's:n:w:e:d:v:' flag
do
   case "${flag}" in
      s) DATASRC="${OPTARG}";;
      n) NID="${OPTARG}";;
      w) WID="${OPTARG}";;
      e) ELEDETAIL="${OPTARG}";;
      d) HGTDIR="${OPTARG}";;
      v) SRTMVERSION="${OPTARG}";;
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
   DATASRC="srtm1"
#   DATASRC="view1"
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

# Create the srtm version if needed
if [ ${DATASRC} = "srtm1" ] || [ ${DATASRC} = "srtm3" ]
then
   if [ -z "${SRTMVERSION}" ]
   then
      SRTMVERSION=$SRTMVERSION_DEFAULT
   fi
   SRTMVERSION_TXT="--srtm-version=${SRTMVERSION}"
else
   SRTMVERSION_TXT=''
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

