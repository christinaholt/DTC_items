#!/bin/ksh

# Name of this script
SCRIPT=run_point_stat.ksh

# Base
BASE=/glade/p/ral/jnt/GMTB

# Data root and INIT
INIT=2016012100
DATA_ROOT=$BASE/GFS/${INIT}

# What GFS post-processed res should we use?
GFS_RES="0p25"

#FCST_TIME_LIST="00 03 06 09 12 15 18 21 24 \
#                27 30 33 36 39 42 45 48    \
#                51 54 57 60 63 66 69 72    \
#                75 78 81 84                \
#FCST_TIME_LIST="00 12 24 36 48 60 72 84"
FCST_TIME_LIST="24"

# Point to MET execs
MET_EXE_ROOT=$BASE/code/met-5.1/bin

# Specify the MET Point-Stat configuration files to be used
MET_CONFIG=$BASE/scripts//met_config
CONFIG_ADPUPA="$MET_CONFIG/PointStatConfig_ADPUPA_REGRID"
#CONFIG_ADPSFC="${MET_CONFIG}/PointStatConfig_ADPSFC_NDAS_REGRID"
#CONFIG_ADPSFC_MPR="${MET_CONFIG}/PointStatConfig_ADPSFC_MPR"
#CONFIG_WINDS="${MET_CONFIG}/PointStatConfig_WINDS"

# What grid are we verifying??
GRID_VX="G104"

# NDAS point obs
POINT_OBS=$BASE/vx_data/point/proc/gdas

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
   FCST_FILE=${DATA_ROOT}/${GFS_RES}/pgbf${FCST_TIME}.gfs.${INIT}
#   FCST_FILE=${DATA_ROOT}/postprd/20140102_i00_f003_GFS004.grb2
   if [ ! -e ${FCST_FILE} ]; then
     echo "WARNING: Could not find UPP output file: ${FCST_FILE}"
     continue
   fi

   # Get the observation file
   OBS_FILE=`ls -1 ${POINT_OBS}/${VYYYYMMDD}/prepbufr.ndas.${VYYYYMMDD}.t${VHH}z.*.nc | head -1`
   if [ ! -e ${OBS_FILE} ]; then
     echo "WARNING: Could not find observation file: ${OBS_FILE}"
     continue
   fi

   #######################################################################
   #
   #  Run Point-Stat
   #
   #######################################################################

   # Verify upper air variables only at 00Z and 12Z
   if [ "${VHH}" == "00" -o "${VHH}" == "12" ]; then
     CONFIG_FILE=${CONFIG_ADPUPA}
     ${MET_EXE_ROOT}/point_stat ${FCST_FILE} ${OBS_FILE} ${CONFIG_FILE} \
       -outdir . -v 2
   fi

#   # Verify surface variables for each forecast hour
#   CONFIG_FILE=${CONFIG_ADPSFC}

#   echo "CALLING: ${MET_EXE_ROOT}/point_stat ${FCST_FILE} ${OBS_FILE} ${CONFIG_FILE} -outdir . -v 4"

#   ${MET_EXE_ROOT}/point_stat ${FCST_FILE} ${OBS_FILE} ${CONFIG_FILE} \
#     -outdir . -v 4 

#   # Verify surface variables for each forecast hour - matched pair output
#   CONFIG_FILE=${CONFIG_ADPSFC_MPR}
#
#   echo "CALLING: ${MET_EXE_ROOT}/point_stat ${FCST_FILE} ${OBS_FILE} ${CONFIG_FILE} -outdir . -v 2"
#
#   ${MET_EXE_ROOT}/point_stat ${FCST_FILE} ${OBS_FILE} ${CONFIG_FILE} \
#     -outdir . -v 2

#   # Verify winds for each forecast hour
#   CONFIG_FILE=${CONFIG_WINDS}
#
#   echo "CALLING: ${MET_EXE_ROOT}/point_stat ${FCST_FILE} ${OBS_FILE} ${CONFIG_FILE} -outdir . -v 2"
#
#   ${MET_EXE_ROOT}/point_stat ${FCST_FILE} ${OBS_FILE} ${CONFIG_FILE} \
#     -outdir . -v 2

done

##########################################################################

echo "${SCRIPT} completed at `date`"

exit 0

