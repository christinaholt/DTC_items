#!/usr/bin/env ksh

# This script creates a config file, and runs MET series analysis
# filelists have been created that include analysis or forecast
# files 

# The top level directory for the working area
here=/pan2/projects/dtc-hurr/Christina.Holt/H215/MET_anl


#for (( fhr = 24 ; fhr <= 126 ; fhr += 24 )) ; do
#for fhr in 72 ; do
    if [[ $fhr -lt 10 ]] ; then ; fhr=0$fhr ; fi
     exp_filelist=${here}/filelists.h215/fcst_${e}_filelist.f${fhr}
     anl_filelist=${here}/filelists.h215/anl_${e}_filelist.f${fhr} 
     out_loc=${here}/../MET_output/${e}only/
     mkdir -p $out_loc

   # Make a config file 
     thresh='>0.0'
     $here/config/config_template.sh ${e} ${var} ${fhr} ${thresh} ${lev} &
     wait $!

$MET_BUILD_BASE/bin/series_analysis \
-fcst $exp_filelist \
-obs $anl_filelist \
-out $out_loc/${var}_${fhr}_${lev}.nc \
-config $here/config/SeriesAnalysisConfig_${e}_${var}_${lev}.f${fhr} -v 2

#done


