#!/bin/bash

for tif_file in $1/*.tif
do
    hgt_file="`basename $tif_file .tif`.hgt"
    hgt_dir="`dirname $tif_file`.hgt"
    gdal_translate -of SRTMHGT $tif_file $hgt_file
done