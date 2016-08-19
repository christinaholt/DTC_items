#!/usr/bin/env ksh

set -x

expt=( HDRT ) 
vars=( HGT RH TMP UGRD VGRD WIND ) # These are available in GFS ANL
#vars=( SPFH TMP )
#vars=( UGRD VGRD )
#vars=(PRMSL)
LEVEL=(1000 900 850 700 600 500 400 300 250)
#LEVEL=( 0 ) # Surface vars
#LEVEL=( 2 ) # 2 m vars
#LEVEL=( 10 ) # 10 m vars


for e in ${expt[@]}; do
    for lev in ${LEVEL[@]} ; do
      for var in ${vars[@]} ; do 
         
        qsub -ve=${e},var=${var},lev=${lev} ./SerAna_run.sh 

      done
    done
done










