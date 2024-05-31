#update:2019/3/15
#!/usr/bin/env bash


INPUT_DIR=./hgt/ALOS1
OUTPUT_DIR=./hgt/ALOS1.hgt
vrtfile=./hgt/ALOS1_input.vrt


[ -d "$OUTPUT_DIR" ] || mkdir -p $OUTPUT_DIR || { echo "error: $OUTPUT_DIR " 1>&2; exit 1; }

gdalbuildvrt -overwrite -srcnodata -9999 -vrtnodata -9999 ${vrtfile} ${INPUT_DIR}/*.tif

res=`echo 1/3600/2 |bc -l`
for aw3d30 in  ${INPUT_DIR}/*.tif
do
   [ -f "${aw3d30}" ] || continue
   srtm="`basename -s .tif ${aw3d30}`.hgt"
   #srtm=`echo ${aw3d30} | awk -F / '{print substr($NF,1,1)substr($NF,3,6)".hgt"}'`
   echo $aw3d30
   echo $srtm
   [ -f "${OUTPUT_DIR}/${srtm}" ] && { echo "skip ${srtm}" 1>&2; continue; }
   xmin=`echo ${aw3d30} | awk -F / 'substr($NF,4,1)=="E"{print substr($NF,5,3)*1} substr($NF,5,1)=="W"{print substr($NF,5,3)*(-1)}'`
   ymin=`echo ${aw3d30} | awk -F / 'substr($NF,1,1)=="N"{print substr($NF,2,3)*1} substr($NF,1,1)=="S"{print substr($NF,2,3)*(-1)}'`
   xmax=`echo ${xmin}+1 | bc`
   ymax=`echo ${ymin}+1 | bc`
   xmin=`echo ${xmin}-${res} | bc`
   ymin=`echo ${ymin}-${res} | bc`
   xmax=`echo ${xmax}+${res} | bc`
   ymax=`echo ${ymax}+${res} | bc`
   gdalwarp   -te ${xmin} ${ymin} ${xmax} ${ymax} -ts 3601 3601 -r bilinear ${vrtfile} ${OUTPUT_DIR}/${srtm}.tif
   gdal_translate -of SRTMHGT ${OUTPUT_DIR}/${srtm}.tif ${OUTPUT_DIR}/${srtm}
   rm -f ${OUTPUT_DIR}/${srtm}.tif

done

rm $vrtfile

