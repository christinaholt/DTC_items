#!/bin/ksh -l

##########################################################################
#
# Script Name: met_grid_anl_verf.ksh
#
# Author: J.Wolff & M.Harrold
#         NCAR/RAL & DTC
#
# Released: 6/7/2016
#
# Description:
#    This script runs the MET/Grid-Stat to verify gridded model output
#    against gridded precipitation analyses.
#
#             START_TIME = The cycle time to use for the initial time.
#         FCST_TIME_LIST = The three-digit forecasts that is to be verified.
#             ACCUM_TIME = The two-digit accumulation time: 03 or 24.
#            DOMAIN_LIST = A list of domains to be verified.
#           MET_EXE_ROOT = The full path of the MET executables.
#             MET_CONFIG = The full path of the MET configuration files.
#              UTIL_EXEC = The full path of the UPP executables.
#          MOAD_DATAROOT = Top-level data directory of WRF output.
#            ANL_OBS_DIR = Directory containing observations to be used.
#         CLIMO_FILE_DIR = Directory containing climo files to be used.
#                  MODEL = The model being evaluated.
#
##########################################################################

# Name of this script
SCRIPT=met_grid_anl_verf.ksh

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
#export FCST_TIME="000" 
#export RES_LIST="0p25" 
#export GRID_VX_LIST="G3" 
#export MET_EXE_ROOT=/scratch4/BMC/dtc/MET/met-5.1/bin
#export MET_CONFIG=/scratch4/BMC/gmtb/harrold/gmtb-tierIII/parm/met_config
#export UTIL_EXEC=/scratch4/BMC/gmtb/gmtb-tierIII/util
#export MOAD_DATAROOT=/scratch4/BMC/gmtb/gmtb-tierIII/OUTPUT/prtutornems_0p25/DOMAINS/2016012200
#export ROTDIR=/scratch4/BMC/gmtb/gmtb-tierIII/prtutornems_0p25/DOMAINS/2016012200
#export ANL_OBS_DIR=/scratch4/BMC/gmtb/gmtb-tierIII/vx_data/analyses/gfs_0p25
#export CLIMO_FILE_DIR=/scratch4/NCEPDEV/global/save/Fanglin.Yang/VRFY/vsdb/nwprod/fix
#export MODEL=GFSnems

# Print run parameters
${ECHO}
${ECHO} "${SCRIPT} started at `${DATE}`"
${ECHO}
${ECHO} "    START_TIME = ${START_TIME}"
${ECHO} "     FCST_TIME = ${FCST_TIME}"
${ECHO} "      RES_LIST = ${RES_LIST}"
${ECHO} "  GRID_VX_LIST = ${GRID_VX_LIST}"
${ECHO} "  MET_EXE_ROOT = ${MET_EXE_ROOT}"
${ECHO} "    MET_CONFIG = ${MET_CONFIG}"
${ECHO} "     UTIL_EXEC = ${UTIL_EXEC}"
${ECHO} " MOAD_DATAROOT = ${MOAD_DATAROOT}"
${ECHO} "        ROTDIR = ${ROTDIR}"
${ECHO} "   ANL_OBS_DIR = ${ANL_OBS_DIR}"
${ECHO} "         MODEL = ${MODEL}"

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

# Make sure RAW_OBS directory exists
if [ ! -d ${ANL_OBS_DIR} ]; then
  ${ECHO} "ERROR: ANL_OBS_DIR, ${ANL_OBS_DIR}, does not exist!"
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

      # Specify mask directory structure
      MASKS=${MET_CONFIG}/masks
      export MASKS

      # Specify the MET Grid-Stat configuration file(s) to be used
      GS_CONFIG_LIST="${MET_CONFIG}/GridStatConfig_AC_REGRID"

      # Compute the verification date
      VDATE=`${UTIL_EXEC}/ndate +${FCST_TIME} ${START_TIME}`
      VYYYYMMDD=`${ECHO} ${VDATE} | ${CUT} -c1-8`
      VMMDD=`${ECHO} ${VDATE} | ${CUT} -c5-8`
      VHH=`${ECHO} ${VDATE} | ${CUT} -c9-10`
      ${ECHO} 'valid time for ' ${FCST_TIME} 'h forecast = ' ${VDATE}

      # Get the forecast to verify
      FCST_FILE=${ROTDIR}/pgrbq${FCST_TIME}.gfs.${START_TIME}.grib2
      ${ECHO} "FCST_FILE: ${FCST_FILE}"

      if [ ! -e ${FCST_FILE} ]; then
        ${ECHO} "ERROR: Could not find UPP output file: ${FCST_FILE}"
        exit 1
      fi
     
      # Get obs/analysis file to verify with 
      ANL_OBS_FILE=`${LS} ${ANL_OBS_DIR}/${VYYYYMMDD}${VHH}/gfs.t${VHH}z.pgrb2.0p25.anl | head -1`
      ${ECHO} "ANL_OBS_FILE: ${ANL_OBS_FILE}"

      if [ ! -e ${ANL_OBS_FILE} ]; then
        ${ECHO} "ERROR: Could not find observation file: ${ANL_OBS_FILE}"
        exit 1
      fi

      # Get climo mean file
      CLIMO_MEAN_FILE=`${LS} ${CLIMO_FILE_DIR}/cmean_1d.1959${VMMDD} | head -1`
      ${ECHO} "CLIMO_MEAN_FILE: ${CLIMO_MEAN_FILE}"

      if [ ! -e ${CLIMO_MEAN_FILE} ]; then
        ${ECHO} "ERROR: Could not find observation file: ${CLIMO_MEAN_FILE}"
        exit 1
      fi

      export CLIMO_MEAN_FILE

      #######################################################################
      #  Run Grid-Stat
      #######################################################################

      for CONFIG_FILE in ${GS_CONFIG_LIST}; do

        # Make sure the Grid-Stat configuration file exists
        if [ ! -e ${CONFIG_FILE} ]; then
          ${ECHO} "ERROR: ${CONFIG_FILE} does not exist!"
          exit 1
        fi

        ${ECHO} "CALLING: ${MET_EXE_ROOT}/grid_stat ${FCST_FILE} ${ANL_OBS_FILE} ${CONFIG_FILE} -outdir . -v 2"

        ${MET_EXE_ROOT}/grid_stat \
          ${FCST_FILE} \
          ${ANL_OBS_FILE} \
          ${CONFIG_FILE} \
          -outdir . \
          -v 2

        error=$?
        if [ ${error} -ne 0 ]; then
          ${ECHO} "ERROR: For ${MODEL}, ${MET_EXE_ROOT}/grid_stat crashed  Exit status: ${error}"
        exit ${error}
        fi

      done

   done # GRID_VX
done # RES

##########################################################################

${ECHO} "${SCRIPT} completed at `${DATE}`"

exit 0
