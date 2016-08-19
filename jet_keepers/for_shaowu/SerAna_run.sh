#!/usr/bin/env ksh

#PBS -A dtc-hurr
#PBS -l partition=ujet:tjet:sjet:vjet:njet
#PBS -j oe
#PBS -q batch # queue
#PBS -l procs=1
#PBS -l vmem=20Gb
#PBS -l walltime=03:59:00
#PBS -N met_seranl_${var}_${lev}

cd $PBS_O_WORKDIR

set -x

here=/pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/MET_anl/scripts

#Loop through forecast hours
for (( fhr = 0 ; fhr <= 126 ; fhr += 24 )) ; do
    if [[ $fhr -lt 10 ]] ; then ; fhr=0$fhr ; fi
     exp_filelist=${here}/filelist/fcst_${e}_filelist.f${fhr}
     anl_filelist=${here}/filelist/anl_gfs_filelist.f${fhr} 
     out_loc=${here}/../MET_output/${e}
     mkdir -p $out_loc

   # Make a config file 
     thresh='>0.0'
     $here/config/config_template.sh ${e} ${var} ${fhr} ${thresh} ${lev} &
     wait $!

# Run MET
$MET_BUILD_BASE/bin/series_analysis \
-fcst $exp_filelist \
-obs $anl_filelist \
-out $out_loc/hwrf_vx/${var}_${fhr}_${lev}.nc \
-config $here/config/SeriesAnalysisConfig_${e}_${var}_${lev}.f${fhr} -v 2

done


