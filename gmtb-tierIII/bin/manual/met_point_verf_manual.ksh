#!/bin/ksh -l

##########################################################################
#
# Script Name: met_point_verf_all.ksh
#
#      Author: John Halley Gotway
#              NCAR/RAL/DTC
#
#    Released: 10/26/2010
#
# Description:
#    This script runs the MET/Point-Stat tool to verify gridded output
#    from the WRF PostProcessor using point observations.  The MET/PB2NC
#    tool must be run on the PREPBUFR observation files to be used prior
#    to running this script.
#
#             START_TIME = The cycle time to use for the initial time.
#             FCST_TIME  = The two-digit forecast that is to be verified.
#            DOMAIN_LIST = A list of domains to be verified.
#           MET_EXE_ROOT = The full path of the MET executables.
#             MET_CONFIG = The full path of the MET configuration files.
#              UTIL_EXEC = The full path of the ndate executable.
#          MOAD_DATAROOT = Top-level data directory of WRF output.
#                RAW_OBS = Directory containing observations to be used.
#                  MODEL = The model being evaluated.
#
##########################################################################

# Set the SGE queueing options
#$ -S /bin/ksh
#$ -pe wcomp 1
#$ -l h_rt=06:00:00
#$ -N met_point_verf
#$ -j y
#$ -V
#$ -cwd

# Name of this script
SCRIPT=met_point_verf.ksh

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
export PNT_PROC_OBS_DIR=/glade/p/ral/jnt/GMTB/vx_data/point/proc
export MODEL=GFSnems

# Specify Experiment name
#PLLN=arwref
#typeset -L8 pll3
#pll3=ARWref
#PLL3=ARWref

# Print run parameters/masks
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
${ECHO} " PNT_PROC_OBS_DIR = ${PNT_PROC_OBS_DIR}"
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

# Make sure PNT_PROC_OBS_DIR directory exists
if [ ! -d ${PNT_PROC_OBS_DIR} ]; then
  ${ECHO} "ERROR: PNT_PROC_OBS_DIR, ${PNT_PROC_OBS_DIR}, does not exist!"
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
      export GRID_VX
      ${ECHO} "FCST_TIME=${FCST_TIME}"

      # Specify new mask directory structure
      MASKS=${MET_CONFIG}/${RES}/masks
      export MASKS

      # Specify the MET Point-Stat configuration files to be used
      CONFIG_ADPUPA="${MET_CONFIG}/${RES}/PointStatConfig_ADPUPA_REGRID"
      CONFIG_ADPSFC="${MET_CONFIG}/${RES}/PointStatConfig_ADPSFC_NDAS_REGRID"
      #CONFIG_ADPSFC_MPR="${MET_CONFIG}/${RES}/PointStatConfig_ADPSFC_MPR"
      #CONFIG_WINDS="${MET_CONFIG}/${RES}/PointStatConfig_WINDS"

      # Make sure the Point-Stat configuration files exists
      if [ ! -e ${CONFIG_ADPUPA} ]; then
          ${ECHO} "ERROR: ${CONFIG_ADPUPA} does not exist!"
          exit 1
      fi
      if [ ! -e ${CONFIG_ADPSFC} ]; then
          ${ECHO} "ERROR: ${CONFIG_ADPSFC} does not exist!"
          exit 1
      fi
      # if [ ! -e ${CONFIG_ADPSFC_MPR} ]; then
          # ${ECHO} "ERROR: ${CONFIG_ADPSFC_MPR} does not exist!"
          # exit 1
      # fi
      # if [ ! -e ${CONFIG_WINDS} ]; then
          # ${ECHO} "ERROR: ${CONFIG_WINDS} does not exist!"
          # exit 1
      # fi

      # Compute the verification date
      VDATE=`${UTIL_EXEC}/ndate +${FCST_TIME} ${START_TIME}`
      VYYYYMMDD=`${ECHO} ${VDATE} | ${CUT} -c1-8`
      VHH=`${ECHO} ${VDATE} | ${CUT} -c9-10`
      ${ECHO} 'valid time for ' ${FCST_TIME} 'h forecast = ' ${VDATE}

      # Get the forecast to verify
      FCST_FILE=${MOAD_DATAROOT}/mdlprd/pgrbq${FCST_TIME}.gfs.${START_TIME}.grib2
      ${ECHO} "FCST_FILE: ${FCST_FILE}"

      if [ ! -e ${FCST_FILE} ]; then
        ${ECHO} "ERROR: Could not find UPP output file: ${FCST_FILE}"
        exit 1
      fi

      # Get the NDAS observation file
      NDAS_OBS_FILE=`${LS} ${PNT_PROC_OBS_DIR}/ndas/${VYYYYMMDD}/prepbufr.ndas.${VYYYYMMDD}.t${VHH}z.*.nc | head -1`
      ${ECHO} "NDAS_OBS_FILE: ${NDAS_OBS_FILE}"

      if [ ! -e ${NDAS_OBS_FILE} ]; then
        ${ECHO} "ERROR: Could not find observation file: ${NDAS_OBS_FILE}"
        exit 1
      fi

      # Get the GDAS observation file
      # GDAS_OBS_FILE=`${LS} ${PNT_PROC_OBS_DIR}/gdas/${VYYYYMMDD}/prepbufr.gdas.${VYYYYMMDD}.t${VHH}z.*.nc | head -1`
      # ${ECHO} "GDAS_OBS_FILE: ${GDAS_OBS_FILE}"

      # if [ ! -e ${GDAS_OBS_FILE} ]; then
        # ${ECHO} "ERROR: Could not find observation file: ${GDAS_OBS_FILE}"
        # exit 1
      # fi

      #######################################################################
      #
      #  Run Point-Stat
      #
      #######################################################################

      # Verify upper air variables only at 00Z and 12Z
      if [ "${VHH}" == "00" -o "${VHH}" == "12" ]; then
        CONFIG_FILE=${CONFIG_ADPUPA}
   
        /usr/bin/time ${MET_EXE_ROOT}/point_stat ${FCST_FILE} ${NDAS_OBS_FILE} ${CONFIG_FILE} \
          -outdir . -v 2

        error=$?
        if [ ${error} -ne 0 ]; then
          ${ECHO} "ERROR: For ${MODEL}, ${MET_EXE_ROOT}/point_stat ${CONFIG_FILE} crashed  Exit status: ${error}"
          exit ${error}
        fi
      fi
   
      # Verify surface variables for each forecast hour
      CONFIG_FILE=${CONFIG_ADPSFC}

      ${ECHO} "CALLING: ${MET_EXE_ROOT}/point_stat ${FCST_FILE} ${OBS_FILE} ${CONFIG_FILE} -outdir . -v 2"

      /usr/bin/time ${MET_EXE_ROOT}/point_stat ${FCST_FILE} ${NDAS_OBS_FILE} ${CONFIG_FILE} \
         -outdir . -v 2

      error=$?
      if [ ${error} -ne 0 ]; then
        ${ECHO} "ERROR: For ${MODEL}, ${MET_EXE_ROOT}/point_stat ${CONFIG_FILE} crashed  Exit status: ${error}"
        exit ${error}
      fi

      # Verify surface variables for each forecast hour - MPR output
      # CONFIG_FILE=${CONFIG_ADPSFC_MPR}

      # ${ECHO} "CALLING: ${MET_EXE_ROOT}/point_stat ${FCST_FILE} ${OBS_FILE} ${CONFIG_FILE} -outdir . -v 2"

      # /usr/bin/time ${MET_EXE_ROOT}/point_stat ${FCST_FILE} ${OBS_FILE} ${CONFIG_FILE} \
      #   -outdir . -v 2

      # error=$?
      # if [ ${error} -ne 0 ]; then
        # ${ECHO} "ERROR: For ${MODEL}, ${MET_EXE_ROOT}/point_stat ${CONFIG_FILE} crashed  Exit status: ${error}"
        # exit ${error}
      # fi

      # Verify winds for each forecast hour
      # CONFIG_FILE=${CONFIG_WINDS}

      # ${ECHO} "CALLING: ${MET_EXE_ROOT}/point_stat ${FCST_FILE} ${OBS_FILE} ${CONFIG_FILE} -outdir . -v 2"

      # /usr/bin/time ${MET_EXE_ROOT}/point_stat ${FCST_FILE} ${OBS_FILE} ${CONFIG_FILE} \
      #   -outdir . -v 2

      # error=$?
      # if [ ${error} -ne 0 ]; then
        # ${ECHO} "ERROR: For ${MODEL}, ${MET_EXE_ROOT}/point_stat ${CONFIG_FILE} crashed  Exit status: ${error}"
        # exit ${error}
      # fi

   done # GRID_VX
done # RES

##########################################################################

${ECHO} "${SCRIPT} completed at `${DATE}`"

exit 0

