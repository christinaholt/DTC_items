#!/bin/ksh -l

##########################################################################
#
# Script Name: met_tc.ksh
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
SCRIPT=met_tc.ksh

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
${ECHO} "      TRK_OBS_DIR = ${TRK_OBS_DIR}"
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

# Make sure TRK_OBS_DIR directory exists
if [ ! -d ${TRK_OBS_DIR} ]; then
  ${ECHO} "ERROR: TRK_OBS_DIR, ${TRK_OBS_DIR}, does not exist!"
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
# Run tc+pairs for each grid resolution and ATCF file
########################################################################

# Get the forecast to verify
FCST_FILE=${ROTDIR}/trak.gfso.atcfunix.altg.${START_TIME}
${ECHO} "FCST_FILE: ${FCST_FILE}"

if [ ! -e ${FCST_FILE} ]; then
  ${ECHO} "ERROR: Could not find ATCF file: ${FCST_FILE}"
  exit 1
fi


   for STORM_ID in ${STORM_ID_LIST}; do
      ${ECHO} "FCST_TIME=${FCST_TIME}"

      # Specify new mask directory structure
      MASKS=${MET_CONFIG}/masks
      export MASKS

      # Specify the MET TC-pairs configuration files to be used
      CONFIG_TC="${MET_CONFIG}/TCPairsConfig_GSMtest"

      # Make sure the MET TC-pairs configuration files exists
      if [ ! -e ${CONFIG_TC} ]; then
          ${ECHO} "ERROR: ${CONFIG_TC} does not exist!"
          exit 1
      fi


      al022014
      OBS_FILE="${pb2nc}/a${STORM_ID}.dat"

      # Check the best track observation file
      ${ECHO} "OBS_FILE: ${OBS_FILE}"

      if [ ! -e ${OBS_FILE} ]; then
        ${ECHO} "ERROR: Could not find best track observation file: ${OBS_FILE}"
        exit 1
      fi

      #######################################################################
      #  Run TC-Pairs 
      #######################################################################

      # Verify surface variables for each forecast hour
      CONFIG_FILE=${CONFIG_TC}

      ${ECHO} "CALLING: ${MET_EXE_ROOT}/tc_pairs -adeck ${FCST_FILE} -bdeck ${OBS_FILE} -config ${CONFIG_FILE} -out . -v 2"

      /usr/bin/time ${MET_EXE_ROOT}/tc_pairs -adeck ${FCST_FILE} -bdeck ${OBS_FILE} -config ${CONFIG_FILE} \
        -out . -v 2

      error=$?
      if [ ${error} -ne 0 ]; then
        ${ECHO} "ERROR: For ${MODEL}, ${MET_EXE_ROOT}/point_stat ${CONFIG_FILE} crashed  Exit status: ${error}"
        exit ${error}
      fi

   done # GRID_VX

##########################################################################

${ECHO} "${SCRIPT} completed at `${DATE}`"

exit 0

