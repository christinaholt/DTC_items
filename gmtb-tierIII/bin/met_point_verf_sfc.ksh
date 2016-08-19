#!/bin/ksh -l

##########################################################################
#
# Script Name: met_point_verf_sfc.ksh
#
#     Authors: J.Wolff and M.Harrold 
#              NCAR/RAL & DTC
#
#    Released: 6/7/2016
#
# Description:
#    This script runs the MET/Point-Stat tool to verify gridded output
#    from the WRF PostProcessor using point observations.  The MET/PB2NC
#    tool is run on the PREPBUFR observation files within this script.
#
#             START_TIME = The cycle time to use for the initial time.
#             FCST_TIME  = The three-digit forecast that is to be verified.
#            DOMAIN_LIST = A list of domains to be verified.
#           MET_EXE_ROOT = The full path of the MET executables.
#             MET_CONFIG = The full path of the MET configuration files.
#              UTIL_EXEC = The full path of the ndate executable.
#          MOAD_DATAROOT = Top-level data directory of WRF output.
#                RAW_OBS = Directory containing observations to be used.
#                  MODEL = The model being evaluated.
#
##########################################################################

# Name of this script
SCRIPT=met_point_verf_sfc.ksh

# Set path for manual testing of script
#export CONSTANT=/scratch4/BMC/gmtb/harrold/gmtb-tierIII/bin/constants.ksh

# Make sure ${CONSTANT} exists
if [ ! -x "${CONSTANT}" ]; then
  ${ECHO} "ERROR: ${CONSTANT} does not exist or is not executable"
  exit 1
fi

# Read constants into the current shell
. ${CONSTANT}

# Vars used for manual testing of the script
#export START_TIME=2016012200
#export FCST_TIME="006" 
#export RES_LIST="0p25" 
#export GRID_VX_LIST="G218" 
#export MET_EXE_ROOT=/scratch4/BMC/dtc/MET/met-5.1/bin
#export MET_CONFIG=/scratch4/BMC/gmtb/harrold/gmtb-tierIII/parm/met_config
#export UTIL_EXEC=/scratch4/BMC/gmtb/gmtb-tierIII/util
#export MOAD_DATAROOT=/scratch4/BMC/gmtb/mid_tier/OUTPUT/prtutornems_0p25/DOMAINS/2016012200
#export PNT_OBS_DIR=/scratch4/NCEPDEV/global/noscrub/stat/prepbufr
#export MODEL=GFSnems

# Print run parameters/masks
${ECHO}
${ECHO} "${SCRIPT} started at `${DATE}`"
${ECHO}
${ECHO} "       START_TIME = ${START_TIME}"
${ECHO} "        FCST_TIME = ${FCST_TIME}"
${ECHO} "         RES_LIST = ${RES_LIST}"
${ECHO} "     GRID_VX_LIST = ${GRID_VX_LIST}"
${ECHO} "     MET_EXE_ROOT = ${MET_EXE_ROOT}"
${ECHO} "       MET_CONFIG = ${MET_CONFIG}"
${ECHO} "        UTIL_EXEC = ${UTIL_EXEC}"
${ECHO} "    MOAD_DATAROOT = ${MOAD_DATAROOT}"
${ECHO} "           ROTDIR = ${ROTDIR}"
${ECHO} "      PNT_OBS_DIR = ${PNT_OBS_DIR}"
${ECHO} "            MODEL = ${MODEL}"

# Make sure $MOAD_DATAROOT exists
if [ ! -d "${MOAD_DATAROOT}" ]; then
  ${ECHO} "MOAD_DATAROOT, ${MOAD_DATAROOT} does not exist; will create it now!"
  ${MKDIR} -p ${MOAD_DATAROOT}
fi

# Make sure ROTDIR exists
if [ ! -d "${ROTDIR}" ]; then
  ${ECHO} "ERROR: ROTDIR, ${ROTDIR} does not exist"
  exit 1
fi

# Make sure PNT_OBS_DIR directory exists
if [ ! -d ${PNT_OBS_DIR} ]; then
  ${ECHO} "ERROR: PNT_OBS_DIR, ${PNT_OBS_DIR}, does not exist!"
  exit 1
fi

# Go to working directory
workdir=${MOAD_DATAROOT}/metprd
${MKDIR} -p ${workdir}
cd ${workdir}

export MODEL
export VERSION
export FCST_TIME
${ECHO} "MODEL=${MODEL}"
${ECHO} "VERSION=${VERSION}"
${ECHO} "FCST_TIME=${FCST_TIME}"

########################################################################
# Compute VX date - only need to run once
########################################################################

# Compute the verification date
VDATE=`${UTIL_EXEC}/ndate +${FCST_TIME} ${START_TIME}`
VYYYYMMDD=`${ECHO} ${VDATE} | ${CUT} -c1-8`
VHH=`${ECHO} ${VDATE} | ${CUT} -c9-10`
${ECHO} 'valid time for ' ${FCST_TIME} 'h forecast = ' ${VDATE}

########################################################################
# Run pb2nc on prepbufr obs file - only need to run once
########################################################################

# Specify the MET PB2NC configuration file to be used
export CONFIG_PB2NC="${MET_CONFIG}/PB2NCConfig_GMTB"

# Make sure the MET configuration files exists
if [ ! -e ${CONFIG_PB2NC} ]; then
  echo "ERROR: ${CONFIG_PB2NC} does not exist!"
  exit 1
fi

# Process time information -- NDAS specific
# For retro NDAS vx, use "late" files, which are tm09 and tm12.
if [[ ${VHH} == "00" || ${VHH} == "06" || ${VHH} == "12" || ${VHH} == "18" ]]; then
  TMMARK="tm12"
elif [[ ${VHH} == "03" || ${VHH} == "09" || ${VHH} == "15" || ${VHH} == "21" ]]; then
  TMMARK="tm09"
else
  echo "ERROR: Valid hour is not compatible with using NDAS data."
  exit 1
fi

# For finding NDAS files in traditional naming convention and placements, uncomment.
# For GMTB, we organized the data by valid time.
#TM_HR=`echo ${TMMARK} | cut -c3-4`

#VYYYY=`echo ${VYYYYMMDD}  | cut -c1-4`
#VMM=`echo ${VYYYYMMDD}  | cut -c5-6`
#VDD=`echo ${VYYYYMMDD}  | cut -c7-8`
#SEC_OFF=`expr ${TM_HR} \* 3600`
#REF_UT=`date -ud ''${VYYYY}-${VMM}-${VDD}' UTC '${VHH}:00:00'' +%s`
#NDAS_UT=`expr ${REF_UT} + ${SEC_OFF}`
#NDAS_YMD=`date -ud '1970-01-01 UTC '${NDAS_UT}' seconds' +%Y%m%d`
#NDAS_HR=`date -ud '1970-01-01 UTC '${NDAS_UT}' seconds' +%H`
#BEG_UT=`expr ${REF_UT} - 2700`
#END_UT=`expr ${REF_UT} + 2700`
#BEG_STR=`date -ud '1970-01-01 UTC '${BEG_UT}' seconds' +%Y%m%d_%H%M%S`
#END_STR=`date -ud '1970-01-01 UTC '${END_UT}' seconds' +%Y%m%d_%H%M%S`

TM_HR=`echo ${TMMARK} | cut -c3-4`

VYYYY=`echo ${VYYYYMMDD}  | cut -c1-4`
VMM=`echo ${VYYYYMMDD}  | cut -c5-6`
VDD=`echo ${VYYYYMMDD}  | cut -c7-8`
REF_UT=`date -ud ''${VYYYY}-${VMM}-${VDD}' UTC '${VHH}:00:00'' +%s`
BEG_UT=`expr ${REF_UT} - 2700`
END_UT=`expr ${REF_UT} + 2700`
BEG_STR=`date -ud '1970-01-01 UTC '${BEG_UT}' seconds' +%Y%m%d_%H%M%S`
END_STR=`date -ud '1970-01-01 UTC '${END_UT}' seconds' +%Y%m%d_%H%M%S`


# List observation file to be run through pb2nc
#PB_FILE=`${LS} ${PNT_OBS_DIR}/ndas/ndas.${NDAS_YMD}/ndas.t${NDAS_HR}z.prepbufr.${TMMARK} | head -1`
PB_FILE=`${LS} ${PNT_OBS_DIR}/${VYYYYMMDD}/prepbufr.ndas.${VYYYYMMDD}.t${VHH}z.${TMMARK} | head -1`
if [ ! -e ${PB_FILE} ]; then
  echo "ERROR: Could not find observation file: ${PB_FILE}"
  exit 1
fi

# Go to prepbufr dir
pb2nc=${workdir}/pb2nc
${MKDIR} -p ${pb2nc}

# Create a PB2NC output file name
OBS_FILE="${pb2nc}/prepbufr.ndas.${VYYYYMMDD}.t${VHH}z.nc"

# Call PB2NC
echo "CALLING: ${MET_EXE_ROOT}/pb2nc ${PB_FILE} ${OBS_FILE} ${CONFIG_PB2NC} -v 2"

${MET_EXE_ROOT}/pb2nc ${PB_FILE} ${OBS_FILE} ${CONFIG_PB2NC} -valid_beg ${BEG_STR} -valid_end ${END_STR} -v 2

########################################################################
# Run point stat for each grid resolution and verification grid
########################################################################

# Loop through the domain list
for RES in ${RES_LIST}; do
   
   export RES
   ${ECHO} "RES=${RES}"

   for GRID_VX in ${GRID_VX_LIST}; do
      GRID_VX_NUM=`${ECHO} ${GRID_VX} | cut -c2-`
      typeset -Z3 GRID_VX_NUM
      GRID_VX_FORMAT="G${GRID_VX_NUM}"

      export GRID_VX
      export GRID_VX_FORMAT

      ${ECHO} "FCST_TIME=${FCST_TIME}"

      # Specify new mask directory structure
      MASKS=${MET_CONFIG}/masks
      export MASKS

      # Specify the MET Point-Stat configuration files to be used
      CONFIG_ADPSFC="${MET_CONFIG}/PointStatConfig_ADPSFC_NDAS_REGRID"
      CONFIG_ADPSFC_MPR="${MET_CONFIG}/PointStatConfig_ADPSFC_MPR_NDAS_REGRID"

      # Make sure the Point-Stat configuration files exists
      if [ ! -e ${CONFIG_ADPSFC} ]; then
          ${ECHO} "ERROR: ${CONFIG_ADPSFC} does not exist!"
          exit 1
      fi
      if [ ! -e ${CONFIG_ADPSFC_MPR} ]; then
          ${ECHO} "ERROR: ${CONFIG_ADPSFC_MPR} does not exist!"
          exit 1
      fi

      # Check the NDAS observation file (created from previous command to run pb2nc)
      ${ECHO} "OBS_FILE: ${OBS_FILE}"

      if [ ! -e ${OBS_FILE} ]; then
        ${ECHO} "ERROR: Could not find observation file: ${OBS_FILE}"
        exit 1
      fi

      # Get the forecast to verify
      FCST_FILE=${ROTDIR}/pgrbq${FCST_TIME}.gfs.${START_TIME}.grib2
      ${ECHO} "FCST_FILE: ${FCST_FILE}"

      if [ ! -e ${FCST_FILE} ]; then
        ${ECHO} "ERROR: Could not find UPP output file: ${FCST_FILE}"
        exit 1
      fi

      #######################################################################
      #  Run Point-Stat
      #######################################################################

      # Verify surface variables for each forecast hour
      CONFIG_FILE=${CONFIG_ADPSFC}

      ${ECHO} "CALLING: ${MET_EXE_ROOT}/point_stat ${FCST_FILE} ${OBS_FILE} ${CONFIG_FILE} -outdir . -v 2"

      /usr/bin/time ${MET_EXE_ROOT}/point_stat ${FCST_FILE} ${OBS_FILE} ${CONFIG_FILE} \
        -outdir . -v 2

      error=$?
      if [ ${error} -ne 0 ]; then
        ${ECHO} "ERROR: For ${MODEL}, ${MET_EXE_ROOT}/point_stat ${CONFIG_FILE} crashed  Exit status: ${error}"
        exit ${error}
      fi

      # Verify surface variables for each forecast hour - MPR output
      CONFIG_FILE=${CONFIG_ADPSFC_MPR}

      ${ECHO} "CALLING: ${MET_EXE_ROOT}/point_stat ${FCST_FILE} ${OBS_FILE} ${CONFIG_FILE} -outdir . -v 2"

      /usr/bin/time ${MET_EXE_ROOT}/point_stat ${FCST_FILE} ${OBS_FILE} ${CONFIG_FILE} \
        -outdir . -v 2

      error=$?
      if [ ${error} -ne 0 ]; then
        ${ECHO} "ERROR: For ${MODEL}, ${MET_EXE_ROOT}/point_stat ${CONFIG_FILE} crashed  Exit status: ${error}"
        exit ${error}
      fi

   done # GRID_VX
done # RES

##########################################################################

${ECHO} "${SCRIPT} completed at `${DATE}`"

exit 0

