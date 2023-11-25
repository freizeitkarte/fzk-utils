#!/bin/bash

tif_dir=${$1%/}
hgt_dir="${tif_dir}.hgt"
mkdir $hgt_dir

for tif_file in $1/*.tif
do
    hgt_file="`basename $tif_file .tif`.hgt"
    gdal_translate -of SRTMHGT $tif_file $hgt_dir/$hgt_file
done