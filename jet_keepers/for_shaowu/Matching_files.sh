#!/bin/ksh


set -x


# Set the locations of the input files
HDGF=/pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/MET_anl/HWRF_data/HDGF/
HDRF=/pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/MET_anl/HWRF_data/HDRF/
HDRT=/lfs2/projects/dtc-hurr/Shaowu.Bao/HDRT/pytmp/HDRT
GFS=/pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/MET_anl/GFS_data



# Remove old filelists in ./filelist directory
rm filelists/*filelist.f*

# Loop over all the analysis times in HDGF
for HWRF_ANL in `ls $HDGF/*/*/ -d` ; do
    anl_time=`echo $HWRF_ANL | rev | cut -c 6-15 | rev`
    sid=`echo $HWRF_ANL | rev | cut -c 2-5 | rev`
    for (( fhr = 0 ; fhr <= 126; fhr += 24 )) ; do
       if [[ $fhr -lt 10 ]] ; then ; fhr=0$fhr ; fi
          valid_time=`~/bin/ndate.exe $fhr ${anl_time}`
       ff_HDGF=$HDGF/${anl_time}/${sid}/d01_mega_025.f${fhr}
       ff_HDRF=$HDRF/${anl_time}/${sid}/d01_mega_025.f${fhr}
       ff_HDRT=$HDRT/${anl_time}/${sid}/d01_mega_025.f${fhr}
       gfs_anl=$GFS/${valid_time}/gfs.${valid_time}.mega_025.f00

       if [[ -f "${ff_HDGF}" && -f "${af_HDRF}" && -f "${af_HDRT}" && -f "${gfs_anl}" ]]; then
             echo ${ff_HDGF} >> filelists/fcst_HDGF_filelist.f${fhr}
             echo ${ff_HDRF} >> filelists/fcst_HDRF_filelist.f${fhr}
             echo ${ff_HDRT} >> filelists/fcst_HDRT_filelist.f${fhr}
             echo ${gfs_anl} >> filelists/anl_GFS_filelist.f${fhr}
       fi
    done
done

