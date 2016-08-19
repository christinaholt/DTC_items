#!/usr/bin/env ksh


set -x
# Script will perform the following tasks:
# 1. Find all of the 5-day forecasts for the experiment on disk.
# 2. Regrib experiment to mega_domain.
# 3. Pull the GFS analysis for the corresponding time to put in Christina's area.
# 4. Regrib GFS to mega_domain.


# A second script will do the following
# 2. Write file containing the forecast file names for those locations/filenames.
# 4. Write a matching file for the GFS analyses. 



grid='255 0 641 341 60000 -150000 128 -25000 10000 250 250 0'
copygb=~dtc/TNE_RRTMG_PCl/HDRF/sorc/UPP/bin/copygb.exe

# Locations of regridded 
HWRF_data=/pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/MET_anl/HWRF_data
GFS_data=/pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/MET_anl/GFS_data


# 1. Find all of the 5 day forecasts for experiments on disk

EXPT=('HDRF' 'HDGF')
DISK=(pan2 lfs2)

# Loop over experiments
for expt in ${EXPT[@]}; do
   # Loop over disks
   for disk in ${DISK[@]}; do 
      com=/${disk}/projects/dtc-hurr/dtc/${expt}/pytmp/${expt}/com
      dirs=`grep "forecast_length = 126" $com/*/*/storm1.conf -l`

        # Loop over each date in com directory with a 126 hr fcst
        for i in ${dirs[@]}; do
           DATES=`echo $i | cut -c 49-58`
           STID=`echo $i | cut -c 60-62`

           # Regrid the entire forecast to a megadomain and put in a local area
           hwrf_re=${HWRF_data}/${expt}/${DATES}/${STID}
           mkdir -p $hwrf_re
           C_GRID=hwrfprs_p.grb2f
           in_fn=${com}/${DATES}/${STID}/*${C_GRID}*
           # Loop over each file 
           for ifile in $( ls ${in_fn} ) ; do
               # REGRID
               FH=`echo $ifile | rev | cut -c 1-3 | rev`
               if [[ `echo $FH | cut -c 1-1` = "f" ]] ; then ; FH=`echo $FH | cut -c 2-3` ;  fi
 	       # Only do the daily forecasts
               if [[ ${FH} -eq 0 || ${FH}%24 -eq 0 ]]; then
                       out_fn=${hwrf_re}/d01_mega_025.f${FH}
                       echo 'REGRID HERE in out '$ifile ${out_fn}
		   typeset -i ofn_size
		   ofn_size=`du -ak ${out_fn} | cut -c 1-7 | cut -d/ -f2-`
                   if [[ ! -e ${out_fn} || ${ofn_size} -lt 10000 ]] ; then 
 		    cnvgrib -g21 ${ifile} ${hwrf_re}/hwrf.tmp
		    wait $!
                   
          	       $copygb -g "$grid" -x "${hwrf_re}/hwrf.tmp" "${out_fn}"
		       wait $!
 		   fi
                    rm -rf ${hwrf_re}/hwrf.tmp
                      valid_t=`~/bin/ndate.exe ${FH} ${DATES}`



               fi
           done
        done
   done
done
