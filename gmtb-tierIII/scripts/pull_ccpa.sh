#!/bin/sh

# Use this script to pull non-restriced NDAS PrepBufr data from the NCEP HPSS
# A single argument is required - a file containing the list of dates
# Prior to running this script you must run "module load hpss"

# Check for a single argument
if [ $# != 1 ]; then
   echo
   echo "ERROR: You must specify a file containing a list of dates in YYYYMMDDHH format"
   echo
   exit 1
fi

echo "INPUT FILE: $1"

for CurDate in `cat $1`; do

   echo "CURRENT DATE: $CurDate"
   YYYY=`echo $CurDate | cut -c1-4`
     MM=`echo $CurDate | cut -c5-6`
     DD=`echo $CurDate | cut -c7-8`
     HH=`echo $CurDate | cut -c9-10`

   # Make an output directory and enter it
   echo "CALLING: rm -rf ${CurDate}"
   rm -rf ${CurDate}
   echo "CALLING: mkdir -p ${CurDate}; cd ${CurDate}"
   mkdir -p ${CurDate}; cd ${CurDate}

   # Pull the files
   TarFile="/NCEPPROD/hpssprod/runhistory/rh${YYYY}/${YYYY}${MM}/${YYYY}${MM}${DD}/com_gens_prod_gefs.${YYYY}${MM}${DD}_${HH}.ccpa.tar"
   #TarCommand="htar -xvf ${TarFile} \`htar -tf ${TarFile} | egrep \"ccpa_conus_hrap\" | awk '{print $7}'\`" 
   TarCommand="htar -xvf ${TarFile} \`htar -tf ${TarFile} | egrep \"ccpa_conus_hrap\" | egrep \"06h_gb2\" | awk '{print $7}'\`" 
   echo "CALLING: time ${TarCommand}"
   time htar -xvf ${TarFile} `htar -tf ${TarFile} | egrep "ccpa_conus_hrap" | egrep "06h_gb2" | awk '{print $7}'`
   Status=$?
   cd ..

#   # Check the return status
#   if [ ${Status} != 0 ]; then
#      echo "WARNING: Bad return status (${Status}) for date \"${CurDate}\".  Did you forget to run \"module load hpss\"?"
#      echo "WARNING: ${TarCommand}" 
#   else
#      # Tar up the output directory
#      echo "CALLING: tar -cvzf ${CurDate}_ccpa.tar.gz ${CurDate}"
#      tar -cvzf ${CurDate}_ccpa.tar.gz ${CurDate}
#
#      # Remove output directory
#      echo "CALLING: rm -rf ${CurDate}"
#      rm -rf ${CurDate}
#   fi

done

