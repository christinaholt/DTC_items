#!/bin/ksh -l

##########################################################################
#
# Script Name: met_grid_anl_verf.ksh
#
#      Author: John Halley Gotway
#              NCAR/RAL/DTC
#
#    Released: 10/26/2010
#
# Description:
#    This script runs the MET/Grid-Stat and MODE tools to verify gridded
#    precipitation forecasts against gridded precipitation analyses.
#    The precipitation fields must first be placed on a common grid prior
#    to running this script.
#
#             START_TIME = The cycle time to use for the initial time.
#         FCST_TIME_LIST = The three-digit forecasts that is to be verified.
#             ACCUM_TIME = The two-digit accumulation time: 03 or 24.
#            DOMAIN_LIST = A list of domains to be verified.
#           MET_EXE_ROOT = The full path of the MET executables.
#             MET_CONFIG = The full path of the MET configuration files.
#              UTIL_EXEC = The full path of the UPP executables.
#          MOAD_DATAROOT = Top-level data directory of WRF output.
#                RAW_OBS = Directory containing observations to be used.
#                  MODEL = The model being evaluated.
#
##########################################################################

# Set the SGE queueing options
#$ -S /bin/ksh
#$ -pe wcomp 1
#$ -l h_rt=06:00:00
#$ -N met_grid_anl_verf
#$ -j y
#$ -V
#$ -cwd

# Name of this script
SCRIPT=met_grid_anl_verf.ksh

# Set path for manual testing of script
export SCRIPTS=/glade/p/ral/jnt/GMTB/bin

# Make sure $SCRIPTS/constants.ksh exists
if [ ! -x "${SCRIPTS}/constants.ksh" ]; then
  ${ECHO} "ERROR: ${SCRIPTS}/constants.ksh does not exist or is not executable"
  exit 1
fi

# Read constants into the current shell
. ${SCRIPTS}/constants.ksh

# Vars used for manual testing of the script
export START_TIME=2016012200
export FCST_TIME="000" 
export RES_LIST="0p25" 
export GRID_VX_LIST="G104" 
export MET_EXE_ROOT=/glade/p/ral/jnt/GMTB/code/met-5.1/bin
export MET_CONFIG=/glade/p/ral/jnt/GMTB/parm/met_config
export UTIL_EXEC=/glade/p/ral/jnt/GMTB/util
export MOAD_DATAROOT=/glade/p/ral/jnt/GMTB/OUTPUT/prtutornems_0p25/DOMAINS/2016012200
export ANL_OBS_DIR=/glade/p/ral/jnt/GMTB/vx_data/anl
export MODEL=GFSnems

# Specify Experiment name
#PLLN=rrtmg
#typeset -L8 pll3
#pll3=RRTMG
#PLL3=RRTMG

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
${ECHO} "   ANL_OBS_DIR = ${ANL_OBS_DIR}"
${ECHO} "         MODEL = ${MODEL}"

# Make sure $MOAD_DATAROOT exists
if [ ! -d "${MOAD_DATAROOT}" ]; then
  ${ECHO} "ERROR: MOAD_DATAROOT, ${MOAD_DATAROOT} does not exist"
  exit 1
fi

# Make sure $MOAD_DATAROOT/mdlprd exists
if [ ! -d "${MOAD_DATAROOT}/mdlprd" ]; then
  ${ECHO} "ERROR: MOAD_DATAROOT/mdlprd, ${MOAD_DATAROOT}/mdlprd does not exist"
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
   ${ECHO} "FCST_TIME=${FCST_TIME}"

   for GRID_VX in ${GRID_VX_LIST}; do
      export GRID_VX
      ${ECHO} "FCST_TIME=${FCST_TIME}"

      # Specify mask directory structure
      MASKS=${MET_CONFIG}/${RES}/masks
      export MASKS

      # Specify the MET Grid-Stat and MODE configuration files to be used
      GS_CONFIG_LIST="${MET_CONFIG}/${RES}/GridStatConfig_HGT_REGRID \
                   ${MET_CONFIG}/${RES}/GridStatConfig_REGRID"
      #MD_CONFIG_LIST="${MET_CONFIG}/WrfModeConfig_${ACCUM_TIME}h_hires \
      #                ${MET_CONFIG}/WrfModeConfig_${ACCUM_TIME}h_lores"
      MD_CONFIG_LIST=""

      # Compute the verification date
      VDATE=`${UTIL_EXEC}/ndate +${FCST_TIME} ${START_TIME}`
      VYYYYMMDD=`${ECHO} ${VDATE} | ${CUT} -c1-8`
      VHH=`${ECHO} ${VDATE} | ${CUT} -c9-10`
      ${ECHO} 'valid time for ' ${FCST_TIME} 'h forecast = ' ${VDATE}

      # Get the forecast to verify
      # Get the forecast to verify
      FCST_FILE=${MOAD_DATAROOT}/mdlprd/pgrbq${FCST_TIME}.gfs.${START_TIME}.grib2
      ${ECHO} "FCST_FILE: ${FCST_FILE}"

      if [ ! -e ${FCST_FILE} ]; then
        ${ECHO} "ERROR: Could not find UPP output file: ${FCST_FILE}"
        exit 1
      fi
      
      ANL_OBS_FILE=`${LS} ${ANL_OBS_DIR}/gfs/${VYYYYMMDD}/gfs.t${VHH}z.pgrb2.0p25.anl | head -1`
      ${ECHO} "ANL_OBS_FILE: ${ANL_OBS_FILE}"

      if [ ! -e ${ANL_OBS_FILE} ]; then
        ${ECHO} "ERROR: Could not find observation file: ${ANL_OBS_FILE}"
        exit 1
      fi

      #######################################################################
      #
      #  Run Grid-Stat
      #
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

      #######################################################################
      #
      #  Run MODE
      #
      #######################################################################

      for CONFIG_FILE in ${MD_CONFIG_LIST}; do

        # Make sure the MODE configuration file exists
        if [ ! -e ${CONFIG_FILE} ]; then
          ${ECHO} "ERROR: ${CONFIG_FILE} does not exist!"
          exit 1
        fi

        ${ECHO} "CALLING: ${MET_EXE_ROOT}/mode ${FCST_FILE} ${ANL_OBS_FILE} ${CONFIG_FILE} -outdir . -obj_plot -v 2"

        ${MET_EXE_ROOT}/mode \
          ${FCST_FILE} \
          ${ANL_OBS_FILE} \
          ${CONFIG_FILE} \
          -outdir . \
          -obj_plot \
          -v 2

        error=$?
        if [ ${error} -ne 0 ]; then
          ${ECHO} "ERROR: For ${MODEL}, ${MET_EXE_ROOT}/mode crashed  Exit status: ${error}"
        exit ${error}
        fi
      done

   done # GRID_VX
done # RES

##########################################################################

${ECHO} "${SCRIPT} completed at `${DATE}`"

exit 0
