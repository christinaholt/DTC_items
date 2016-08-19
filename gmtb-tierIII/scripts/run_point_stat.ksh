#!/bin/ksh

# Name of this script
SCRIPT=run_point_stat.ksh

# Base
BASE=/glade/p/ral/jnt/GMTB

# Data root and INIT
INIT=2016012100
IHR=`echo $INIT | cut -c9-10`
DATA_ROOT=/d4/projects/GMTB/GFS/${INIT}

# What grid is the post-processed data on?
RES="0p25"

#FCST_TIME_LIST="000 003 006 009 012 015 018 021 024 \
  #                027 030 033 036 039 042 045 048    \
  #                051 054 057 060 063 066 069 072    \
  #                075 078 081 084 087 090 093 096    \
  #                099 102 105 108 111 114 117 120"
FCST_TIME_LIST="000 003 006 009 012 015 018 021 024"

# Point to MET execs
MET_EXE_ROOT=/d3/projects/MET/MET_releases/met-5.1/bin

# Specify the MET Point-Stat configuration files to be used
MET_CONFIG=/d4/projects/GMTB/met_config
CONFIG_ADPUPA="${MET_CONFIG}/PointStatConfig_ADPUPA_REGRID"
CONFIG_ADPSFC="${MET_CONFIG}/PointStatConfig_ADPSFC_NDAS_REGRID"
#CONFIG_ADPSFC_MPR="${MET_CONFIG}/PointStatConfig_ADPSFC_MPR"
#CONFIG_WINDS="${MET_CONFIG}/PointStatConfig_WINDS"

# What grid are we verifying??
GRID_VX="G104"

# NDAS point obs
POINT_OBS=/d4/projects/GMTB/obs_anl/ndas/ndas_nc

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
#   FCST_FILE=${DATA_ROOT}/postprd/pgbf${FCST_TIME}.gfs.${INIT}
#   FCST_FILE=${DATA_ROOT}/postprd/20140102_i00_f003_GFS004.grb2
   FCST_FILE=${DATA_ROOT}/postprd/${RES}/gfs.t${IHR}z.pgrb2.${RES}.f${FCST_TIME}
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

   # Verify surface variables for each forecast hour
   CONFIG_FILE=${CONFIG_ADPSFC}

   echo "CALLING: ${MET_EXE_ROOT}/point_stat ${FCST_FILE} ${OBS_FILE} ${CONFIG_FILE} -outdir . -v 4"

   ${MET_EXE_ROOT}/point_stat ${FCST_FILE} ${OBS_FILE} ${CONFIG_FILE} \
     -outdir . -v 4 

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

