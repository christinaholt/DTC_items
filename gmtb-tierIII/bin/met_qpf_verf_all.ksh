#!/bin/ksh -l

##########################################################################
#
# Script Name: met_qpf_verf_all.ksh
#
#      Author: J.Wolff & M.Harrold
#              NCAR/RAL & DTC
#
#    Released: 6/7/2016
#
# Description:
#    This script runs the MET/Grid-Stat tool to verify gridded
#    precipitation forecasts against gridded precipitation analyses.
#    The precipitation fields must first be placed on a common grid prior
#    to running this script.
#
#             START_TIME = The cycle time to use for the initial time.
#              FCST_TIME = The three-digit forecasts that is to be verified.
#             ACCUM_TIME = The two-digit accumulation time: 03 or 24.
#           MODEL_BUCKET = The accumulation time in the model (bucket): 6.
#             OBS_BUCKET = The accumulation time in the obs (bucket): 6 (ccpa) 1 (cmorph).
#           MET_EXE_ROOT = The full path of the MET executables.
#             MET_CONFIG = The full path of the MET configuration files.
#              UTIL_EXEC = The full path of the UPP executables.
#          MOAD_DATAROOT = Top-level data directory of WRF output.
#                RAW_OBS = Directory containing observations to be used.
#                 OBTYPE = Gridded observation source data.
#                  MODEL = The model being evaluated.
#              OP_SWITCH = Op-like data (TRUE) to determine if different processing for after 240 h.
#
##########################################################################

# Name of this script
SCRIPT=met_qpf_verf_all.ksh

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
#export FCST_TIME=036
#export ACCUM_TIME=24
#export MODEL_BUCKET=6
#export OBS_BUCKET=1
#export RES_LIST="0p25"
#export GRID_VX_LIST="G3"
#export MET_EXE_ROOT=/scratch4/BMC/dtc/MET/met-5.2_beta3/bin
#export MET_CONFIG=/scratch4/BMC/gmtb/gmtb-tierIII/parm/met_config
#export UTIL_EXEC=/scratch4/BMC/gmtb/gmtb-tierIII/util
#export MOAD_DATAROOT=/scratch4/BMC/gmtb/gmtb-tierIII/vx_out/refcst/2016011500
#export RAW_OBS=/scratch3/BMC/dtc-hwrf/GMTB/vx_data/cmorph
#export ROTDIR=/scratch4/BMC/gmtb/gmtb-tierIII/refcst/2016011500
#export OBTYPE=cmorph
#export MODEL=refcst
#export OP_SWITCH=TRUE

# Print run parameters
${ECHO}
${ECHO} "${SCRIPT} started at `${DATE}`"
${ECHO}
${ECHO} "    START_TIME = ${START_TIME}"
${ECHO} "     FCST_TIME = ${FCST_TIME}"
${ECHO} "    ACCUM_TIME = ${ACCUM_TIME}"
${ECHO} "  MODEL_BUCKET = ${MODEL_BUCKET}"
${ECHO} "    OBS_BUCKET = ${OBS_BUCKET}"
${ECHO} "  MET_EXE_ROOT = ${MET_EXE_ROOT}"
${ECHO} "    MET_CONFIG = ${MET_CONFIG}"
${ECHO} "     UTIL_EXEC = ${UTIL_EXEC}"
${ECHO} " MOAD_DATAROOT = ${MOAD_DATAROOT}"
${ECHO} "        ROTDIR = ${ROTDIR}"
${ECHO} "       RAW_OBS = ${RAW_OBS}"
${ECHO} "        OBTYPE = ${OBTYPE}"
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
if [ ! -d ${RAW_OBS} ]; then
  ${ECHO} "ERROR: RAW_OBS, ${RAW_OBS}, does not exist!"
  exit 1
fi

export MODEL
export VERSION
export OBTYPE
export FCST_TIME
export OP_SWITCH
${ECHO} "MODEL=${MODEL}"
${ECHO} "VERSION=${VERSION}"
${ECHO} "OBTYPE=${OBTYPE}"
${ECHO} "FCST_TIME=${FCST_TIME}"
${ECHO} "OP_SWITCH=${OP_SWITCH}"

# Go to working directory
workdir=${MOAD_DATAROOT}/metprd
${MKDIR} -p ${workdir}
pcp_combine_dir_obs=${MOAD_DATAROOT}/metprd/pcp_combine/${OBTYPE}
${MKDIR} -p ${pcp_combine_dir_obs}
pcp_combine_dir_model=${MOAD_DATAROOT}/metprd/pcp_combine/${MODEL}
${MKDIR} -p ${pcp_combine_dir_model}
cd ${workdir}

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

     # Specify mask directory structure
     MASKS=${MET_CONFIG}/masks
     export MASKS

     # Specify the MET Grid-Stat configuration file to be used
     GS_CONFIG="${MET_CONFIG}/GridStatConfig_APCP${ACCUM_TIME}_REGRID_${OBTYPE}"

     # Make sure the Point-Stat configuration files exists
     if [ ! -e ${GS_CONFIG} ]; then
       ${ECHO} "ERROR: ${GS_CONFIG} does not exist!"
       exit 1
     fi

     # Compute the verification date
     YYYYMMDD=`${ECHO} ${START_TIME} | ${CUT} -c1-8`
     HH=`${ECHO} ${START_TIME} | ${CUT} -c9-10`
     VDATE=`${UTIL_EXEC}/ndate +${FCST_TIME} ${START_TIME}`
     VYYYYMMDD=`${ECHO} ${VDATE} | ${CUT} -c1-8`
     VHH=`${ECHO} ${VDATE} | ${CUT} -c9-10`
     ${ECHO} 'valid time for ' ${FCST_TIME} 'h forecast = ' ${VDATE}

     PVDATE=`${UTIL_EXEC}/ndate -24 ${VDATE}`
     PVYYYYMMDD=`${ECHO} ${PVDATE} | ${CUT} -c1-8`

     # Run pcp_combine on model to make appropriate accumulation times
     FCST_GRIB_FILE_DIR=${ROTDIR}
     if [ ! -e ${FCST_GRIB_FILE_DIR} ]; then
       ${ECHO} "ERROR: ${FCST_GRIB_FILE_DIR} does not exist!"
       exit 1
     fi	 

     # 6-h accumulations from the model: Simply pass through because already in 6-hrly buckets (just create .nc file)
     # /scratch4/BMC/dtc/MET/met-5.1/bin/pcp_combine -sum 20160122_000000 6 20160122_060000 06 -pcpdir /scratch4/BMC/gmtb/mid_tier/OUTPUT/prtutornems_0p25/DOMAINS/2016012200/mdlprd -name "APCP_06" /scratch4/BMC/gmtb/mid_tier/OUTPUT/prtutornems_0p25/DOMAINS/2016012200/metprd/pcp_combine/test_pgrbq006.gfs.2016012200_06h.nc

     # 24-h accumulations from the model: Add (4) 6-hr files (valid 12-12 UTC)
     # /scratch4/BMC/dtc/MET/met-5.1/bin/pcp_combine -sum 20160122_000000 6 20160123_120000 24 -pcpdir /scratch4/BMC/gmtb/mid_tier/OUTPUT/prtutornems_0p25/DOMAINS/2016012200/mdlprd  -name "APCP_24" /scratch4/BMC/gmtb/mid_tier/OUTPUT/prtutornems_0p25/DOMAINS/2016012200/metprd/pcp_combine/test_pgrbq036.gfs.2016012200_24h.nc

     FCST_FILE=${pcp_combine_dir_model}/pgrbq${FCST_TIME}.gfs.${START_TIME}_${ACCUM_TIME}h.nc

     if [[ ! -e ${FCST_FILE} ]]; then
       if [[ ${OP_SWITCH} == "FALSE" ]]; then
         PCP_COMBINE_ARGS="-sum ${YYYYMMDD}_${HH}0000 ${MODEL_BUCKET} ${VYYYYMMDD}_${VHH}0000 ${ACCUM_TIME} -pcpdir ${FCST_GRIB_FILE_DIR} -name "APCP_${ACCUM_TIME}" ${FCST_FILE}"
       elif [[ ${OP_SWITCH} == "TRUE" ]]; then
         if [[ ${HH} == "00" && ${FCST_TIME} -le 252 ]]; then
           MODEL_BUCKET=${MODEL_BUCKET}
           PCP_COMBINE_ARGS="-sum ${YYYYMMDD}_${HH}0000 ${MODEL_BUCKET} ${VYYYYMMDD}_${VHH}0000 ${ACCUM_TIME} -pcpdir ${FCST_GRIB_FILE_DIR} -name "APCP_${ACCUM_TIME}" ${FCST_FILE}"
         elif [[ ${HH} == "00" && ${FCST_TIME} -gt 252 ]]; then
           MODEL_BUCKET=12
           PCP_COMBINE_ARGS="-sum ${YYYYMMDD}_${HH}0000 ${MODEL_BUCKET} ${VYYYYMMDD}_${VHH}0000 ${ACCUM_TIME} -pcpdir ${FCST_GRIB_FILE_DIR} -name "APCP_${ACCUM_TIME}" ${FCST_FILE}"
         elif [[ ${HH} == "00" && ${FCST_TIME} -eq 252 ]]; then
           export FIELD='name="CMORPH";level="(0,*,*)";'
           F1=${FCST_GRIB_FILE_DIR}/pgbq234.gfs.${START_TIME}.grib2
           F2=${FCST_GRIB_FILE_DIR}/pgbq240.gfs.${START_TIME}.grib2
           F3=${FCST_GRIB_FILE_DIR}/pgbq252.gfs.${START_TIME}.grib2
           PCP_COMBINE_ARGS="-add ${F1} '${FIELD}' ${F2} '${FIELD}' ${F3} '${FIELD}' -name "APCP_${ACCUM_TIME}" ${FCST_FILE}"
         else
           ${ECHO} "Bad init and/or FCST_TIME specified OR not supported!"
           exit 1
         fi
       else
         ${ECHO} "Bad OP_SWITCH specified!"
         exit 1
       fi

       # Run the PCP-Combine command
       ${ECHO} "CALLING: ${MET_EXE_ROOT}/pcp_combine ${PCP_COMBINE_ARGS}"

       ${MET_EXE_ROOT}/pcp_combine ${PCP_COMBINE_ARGS}
       error=$?
       if [ ${error} -ne 0 ]; then
         ${ECHO} "${MET_EXE_ROOT}/pcp_combine crashed!  Exit status=${error}"
         exit ${error}
       fi
     fi # End forecase file processing, if necessary.


     # Run pcp_combine on CCPA/CMORPH observations to make appropriate accumulation times
     RAW_OBS_DIR=${RAW_OBS}/${VYYYYMMDD}
     if [ ! -e ${RAW_OBS_DIR} ]; then
       ${ECHO} "ERROR: ${RAW_OBS_DIR} does not exist!"
       exit 1
     fi	 
     PREV_RAW_OBS_DIR=${RAW_OBS}/${PVYYYYMMDD}
     if [ ! -e ${PREV_RAW_OBS_DIR} ]; then
       ${ECHO} "ERROR: ${PREV_RAW_OBS_DIR} does not exist!"
       exit 1
     fi	 

     # 6-h accumulations from the CCPA observations: One 6-hrly files
     # /scratch4/BMC/dtc/MET/met-5.1/bin/pcp_combine -sum 00000000_000000 6 20160122_060000 06 -pcpdir /scratch4/BMC/gmtb/mid_tier/vx_data/gridded/raw/ccpa/20160122 -pcpdir /scratch4/BMC/gmtb/mid_tier/vx_data/gridded/raw/ccpa/20160121 -name "APCP_06" /scratch4/BMC/gmtb/mid_tier//OUTPUT/prtutornems_0p25/DOMAINS/2016012200/metprd/pcp_combine/ccpa_20160122_060000_06h.nc

     # 24-h accumulations from the CCPA observations: Add (8) 3-hrly files (valid 12-12 UTC)
     # /scratch4/BMC/dtc/MET/met-5.1/bin/pcp_combine -sum 00000000_000000 6 20160123_120000 24 -pcpdir /scratch4/BMC/gmtb/mid_tier/vx_data/gridded/raw/ccpa/20160123 -pcpdir /scratch4/BMC/gmtb/mid_tier/vx_data/gridded/raw/ccpa/20160122 -name "APCP_24" /scratch4/BMC/gmtb/mid_tier//OUTPUT/prtutornems_0p25/DOMAINS/2016012200/metprd/pcp_combine/ccpa_20160123_0120000_24h.nc

     # 24-h accumulations from the CMORPH observations: Add (24) 1-hrly files (valid 12-12 UTC)
     # /scratch4/BMC/dtc/MET/met-5.1/bin/pcp_combine -sum 00000000_000000 1 20160123_120000 24 -pcpdir /scratch4/BMC/gmtb/mid_tier/vx_data/gridded/proc/cmorph/20160123 -pcpdir /scratch4/BMC/gmtb/mid_tier/vx_data/gridded/proc/cmorph/20160122 -name "APCP_24" /scratch4/BMC/gmtb/mid_tier//OUTPUT/prtutornems_0p25/DOMAINS/2016012200/metprd/pcp_combine/cmorph_20160123_0120000_24h.nc

     if [[ ${OBTYPE} == "ccpa" ]]; then
       OBS_FILE=${pcp_combine_dir_obs}/${OBTYPE}_${VYYYYMMDD}_${VHH}0000_${ACCUM_TIME}h.nc
       PCP_COMBINE_ARGS="-sum 00000000_000000 ${OBS_BUCKET} ${VYYYYMMDD}_${VHH}0000 ${ACCUM_TIME} -pcpdir ${RAW_OBS_DIR} -pcpdir ${PREV_RAW_OBS_DIR} -name "APCP_${ACCUM_TIME}" ${OBS_FILE}"

       # Run the PCP-Combine command
       ${ECHO} "CALLING: ${MET_EXE_ROOT}/pcp_combine ${PCP_COMBINE_ARGS}"

       ${MET_EXE_ROOT}/pcp_combine ${PCP_COMBINE_ARGS}
       error=$?
       if [ ${error} -ne 0 ]; then
         ${ECHO} "${MET_EXE_ROOT}/pcp_combine crashed!  Exit status=${error}"
         exit ${error}
       fi

     elif [[ ${OBTYPE} == "cmorph" ]]; then
       OBS_FILE=${CMORPH_24H_BUCKET}/${VYYYYMMDD}/CMORPH_${VYYYYMMDD}_${VHH}0000_${ACCUM_TIME}h.nc
       if [[ ! -e ${OBS_FILE} ]]; then 
         OBS_FILE=${pcp_combine_dir_obs}/${OBTYPE}_${VYYYYMMDD}_${VHH}0000_${ACCUM_TIME}h.nc
         export FIELD='name="CMORPH";level="(0,*,*)";'
         PCP_COMBINE_ARGS="-sum 00000000_000000 ${OBS_BUCKET} ${VYYYYMMDD}_${VHH}0000 ${ACCUM_TIME} -pcpdir ${RAW_OBS_DIR} -pcpdir ${PREV_RAW_OBS_DIR} -field '${FIELD}' -name "APCP_${ACCUM_TIME}" ${OBS_FILE}"

         # Run the PCP-Combine command
         ${ECHO} "CALLING: ${MET_EXE_ROOT}/pcp_combine ${PCP_COMBINE_ARGS}"

         ${MET_EXE_ROOT}/pcp_combine ${PCP_COMBINE_ARGS}
         error=$?
         if [ ${error} -ne 0 ]; then
           ${ECHO} "${MET_EXE_ROOT}/pcp_combine crashed!  Exit status=${error}"
           exit ${error}
         fi
       fi
     else
       ${ECHO} "ERROR: Bad OBTYPE specified!"
       exit 1
     fi

#######################################################################
#
#  Run Grid-Stat
#
#######################################################################

     # Make sure the Grid-Stat configuration file exists
     if [ ! -e ${GS_CONFIG} ]; then
       ${ECHO} "ERROR: ${GS_CONFIG} does not exist!"
       exit 1
     fi

     # Make sure the forecast file run through pcp_combine exists
     if [ ! -e ${FCST_FILE} ]; then
       ${ECHO} "ERROR: Could not find observation file: ${OBS_FILE}"
       exit 1
     fi

     # Make sure the observation file run through pcp_combine exists
     if [ ! -e ${OBS_FILE} ]; then
       ${ECHO} "ERROR: Could not find observation file: ${OBS_FILE}"
       exit 1
     fi

     ${ECHO} "CALLING: ${MET_EXE_ROOT}/grid_stat ${FCST_FILE} ${OBS_FILE} ${GS_CONFIG} -outdir . -v 2"

     ${MET_EXE_ROOT}/grid_stat \
     ${FCST_FILE} \
     ${OBS_FILE} \
     ${GS_CONFIG} \
     -outdir . \
     -v 2

    error=$?
    if [ ${error} -ne 0 ]; then
      ${ECHO} "ERROR: For ${MODEL}, ${MET_EXE_ROOT}/grid_stat crashed  Exit status: ${error}"
      exit ${error}
    fi

  done
done

##########################################################################

${ECHO} "${SCRIPT} completed at `${DATE}`"

exit 0
