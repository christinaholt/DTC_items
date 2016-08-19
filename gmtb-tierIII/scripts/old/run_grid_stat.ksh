#!/bin/ksh

# Name of this script
SCRIPT=run_grid_stat.ksh

# Data root and INIT
INIT=2014010100
DATA_ROOT=/d4/projects/GMTB/GFS/${INIT}

#FCST_TIME_LIST="00 03 06 09 12 15 18 21 24 \
#                27 30 33 36 39 42 45 48    \
#                51 54 57 60 63 66 69 72    \
#                75 78 81 84 87 90 93 96    \
#                99 102 105 108 111 114 117 120"
#FCST_TIME_LIST="00 12 24 36 48 60 72 84 96 108 120"
FCST_TIME_LIST="12"

# Point to MET execs
MET_EXE_ROOT=/d3/projects/MET/MET_releases/met-5.1/bin

# Specify the MET Grid-Stat configuration files to be used
MET_CONFIG=/d4/projects/GMTB/met_config
CONFIG_HGT="${MET_CONFIG}/GridStatConfig_HGT_REGRID"

# What grid are we verifying??
GRID_VX="G104"

# GFS Analysis file
OBS_DIR=/d4/projects/GMTB/obs_anl/gfs_analysis

# Go to working directory
workdir=${DATA_ROOT}/metprd
mkdir -p ${workdir}
cd ${workdir}

# Loop through the forecast times
for FCST_TIME in ${FCST_TIME_LIST}; do

   export FCST_TIME
   export GRID_VX

   # Compute the verification date
   FCST_TIME_SEC=`expr ${FCST_TIME} \* 3600` # convert forecast lead hour to seconds
   YYYY=`echo ${INIT} | cut -c1-4`  # year (YYYY) of initialization time
   MM=`echo ${INIT} | cut -c5-6`    # month (MM) of initialization time
   DD=`echo ${INIT} | cut -c7-8`    # day (DD) of initialization time
   HH=`echo ${INIT} | cut -c9-10`   # hour (HH) of initialization time
   INIT_UT=`date -ud ''${YYYY}-${MM}-${DD}' UTC '${HH}':00:00' +%s` # convert initialization time to universal time
   VDATE_UT=`expr ${INIT_UT} + ${FCST_TIME_SEC}` # calculate current forecast time in universal time
   VDATE=`date -ud '1970-01-01 UTC '${VDATE_UT}' seconds' +%Y%m%d%H` # convert universal time to standard time
   VYYYYMMDD=`echo ${VDATE} | cut -c1-8`  # forecast time (YYYYMMDD)
   VHH=`echo ${VDATE} | cut -c9-10`       # forecast hour (HH)
   echo 'valid time for ' ${FCST_TIME} 'h forecast = ' ${VDATE}

   # Get the forecast to verify
   FCST_FILE=${DATA_ROOT}/postprd/pgbf${FCST_TIME}.gfs.${INIT}
   if [ ! -e ${FCST_FILE} ]; then
     echo "WARNING: Could not find UPP output file: ${FCST_FILE}"
     continue
   fi

   # Get the observation file
   OBS_FILE=`ls -1 ${OBS_DIR}/${VYYYYMMDD}/${VYYYYMMDD}_i${VHH}_f000_GFS004.grb2`
   if [ ! -e ${OBS_FILE} ]; then
     echo "WARNING: Could not find observation file: ${OBS_FILE}"
     continue
   fi

   #######################################################################
   #
   #  Run Grid-Stat
   #
   #######################################################################

   # Verify HGT for each forecast hour
   CONFIG_FILE=${CONFIG_HGT}

   echo "CALLING: ${MET_EXE_ROOT}/grid_stat ${FCST_FILE} ${OBS_FILE} ${CONFIG_FILE} -outdir . -v 2"

   ${MET_EXE_ROOT}/grid_stat ${FCST_FILE} ${OBS_FILE} ${CONFIG_FILE} \
     -outdir . -v 2

   error=$?
   if [ ${error} -ne 0 ]; then
     echo "WARNING: For ${MODEL}, ${MET_EXE_ROOT}/grid_stat ${CONFIG_FILE} crashed  Exit status: ${error}"
     continue
   fi

done

##########################################################################

echo "${SCRIPT} completed at `date`"

exit 0

