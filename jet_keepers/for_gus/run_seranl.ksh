#!/usr/bin/env ksh

set -x

expt=( HDRF )
#expt=( HDRF )
vars=( SPFH HGT RH TMP UGRD VGRD WIND )
#vars=( HGT TMP RH UGRD VGRD )
#vars=( SPFH TMP )
#vars=( UGRD VGRD )
#vars=(PRMSL)
LEVEL=( 850 700 500 250)
#LEVEL=(1000 850 700 500 250)
#LEVEL=( 0 )
#LEVEL=( 1000 )


for e in ${expt[@]}; do
#  for (( fhr = 0 ; fhr <= 126 ; fhr += 6 )) ; do
#    if [[ $fhr -lt 10 ]] ; then ; fhr=0$fhr ; fi
    for lev in ${LEVEL[@]} ; do
      for var in ${vars[@]} ; do 
         
        qsub -ve=${e},var=${var},lev=${lev} ./SerAna_run.sh 

      done
    done
#  done
done










