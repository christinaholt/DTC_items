#!/bin/ksh -l

##########################################################################
#
# Script Name: cp_vx.ksh
#
#      Author: M.Harrold 
#              NCAR/RAL & DTC
#
#    Released: 6/7/2016
#
# Description:
#    This script copies verification/graphics data from the work directory
#    to the specified temp space for further processing/diagnostics.
#
#             START_TIME = The cycle time to use for the initial time.
#          MOAD_DATAROOT = Top-level data directory of VX/graphics output.
#                 ROTDIR = Top-level data directory of GFS/GSM output.
#            VX_SAVE_DIR = Dir where VX/graphics output is stored for futher evaluation.
#                  MODEL = The model being evaluated.
#
##########################################################################

# Name of this script
SCRIPT=cp_vx.ksh

# Set path for manual testing of script
#export CONSTANT=/scratch4/BMC/gmtb/gmtb-tierIII/bin/constants.ksh

# Make sure ${CONSTANT} exists
if [ ! -x "${CONSTANT}" ]; then
  ${ECHO} "ERROR: ${CONSTANT} does not exist or is not executable"
  exit 1
fi

# Read constants into the current shell
. ${CONSTANT}

# Vars used for manual testing of the script
#export START_TIME=2016011500
#export MOAD_DATAROOT=/scratch4/BMC/gmtb/gmtb-tierIII/vx_out/refcst/2016011500
#export ROTDIR=/scratch4/BMC/gmtb/gmtb-tierIII/refcst/2016011500
#export VX_SAVE_DIR=/scratch3/BMC/dtc-hwrf/GMTB/vx_out
#export MODEL=refcst

# Print run parameters/masks
${ECHO}
${ECHO} "${SCRIPT} started at `${DATE}`"
${ECHO}
${ECHO} "       START_TIME = ${START_TIME}"
${ECHO} "    MOAD_DATAROOT = ${MOAD_DATAROOT}"
${ECHO} "           ROTDIR = ${ROTDIR}"
${ECHO} "      VX_SAVE_DIR = ${VX_SAVE_DIR}"
${ECHO} "            MODEL = ${MODEL}"

# Make sure $MOAD_DATAROOT exists
if [ ! -d "${MOAD_DATAROOT}" ]; then
  ${ECHO} "MOAD_DATAROOT, ${MOAD_DATAROOT} does not exist!"
  exit 1
fi

# Make sure $ROTDIR exists
if [ ! -d "${ROTDIR}" ]; then
  ${ECHO} "ROTDIR, ${ROTDIR} does not exist!"
  exit 1
fi

VX_SAVE_DATE="${VX_SAVE_DIR}/${START_TIME}"

${MKDIR} -p ${VX_SAVE_DATE}
${MKDIR} -p ${VX_SAVE_DATE}/figprd
${MKDIR} -p ${VX_SAVE_DATE}/metprd

${ECHO} "Copying figures...."
${CP} -r ${MOAD_DATAROOT}/figprd/*.png ${VX_SAVE_DATE}/figprd
${ECHO} "Copying MET output...."
${CP} ${MOAD_DATAROOT}/metprd/*.stat ${VX_SAVE_DATE}/metprd

if [[ ${MODEL} != "refcst" ]]; then
  ${MKDIR} -p ${VX_SAVE_DATE}/mdlprd
  ${ECHO} "Copying ATCF data...."
  ${CP} ${ROTDIR}/*atcf* ${VX_SAVE_DATE}/mdlprd
fi

##########################################################################

${ECHO} "${SCRIPT} completed at `${DATE}`"

exit 0

