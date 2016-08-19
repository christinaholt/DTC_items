#!/bin/ksh --login

## this script calls the chgres script which changes resolution of the initial condition files. 
##   It also makes links to the initial condition files from $ROTDIR
##
##  J. Henderson    07/2016


# print out required environment variables
echo entering chgres_driver.ksh
echo "CHGRES_DIR  =  ${CHGRES_DIR}"
echo "yyyymmddhh  =  ${yyyymmddhh}"  
echo "ROTDIR      =  ${ROTDIR}"
echo "STMP        =  ${STMP}"

# initialize
resolution=574
LN=/bin/ln
export COMROT=$CHGRES_DIR/input
export SAVDIR=$CHGRES_DIR/chgres_out
export STMP 

# change resolution 
cd $CHGRES_DIR
./run_chgres_nemsio.sh -c $yyyymmddhh -d gfs -j $resolution

# create links
mkdir -p ${ROTDIR}/${yyyymmddhh}
cd ${ROTDIR}/${yyyymmddhh}
if [[ -f $SAVDIR/gfnanl.gfs.$yyyymmddhh ]]; then 
  ln -s $SAVDIR/gfnanl.gfs.$yyyymmddhh 
else 
  echo "missing file $SAVDIR/gfnanl.gfs.$yyyymmddhh"
  exit 1
fi

if [[ -f $SAVDIR/sfnanl.gfs.$yyyymmddhh ]]; then 
  ln -s $SAVDIR/sfnanl.gfs.$yyyymmddhh
else
  echo "missing file $SAVDIR/sfnanl.gfs.$yyyymmddhh"
  exit 1
fi
