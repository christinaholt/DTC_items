#!/bin/ksh

# Constants
PB2NC=/scratch4/BMC/dtc/MET/met-5.1/bin/pb2nc
NDAS=/scratch4/BMC/gmtb/mid_tier/vx_data/point/raw/ndas
NDAS_NC=/scratch4/BMC/gmtb/mid_tier/vx_data/point/proc/ndas
CONFIG=/scratch4/BMC/gmtb/mid_tier/parm/met_config/0p25/PB2NCConfig_GMTB
CMD_SCRIPT=run_pb2nc_cmds_NDAS.sh

# Use -valid_beg and -valid_end YYYYMMDD_HH

rm -f ${CMD_SCRIPT}

# Process each input NDAS file
for PBFILE in `ls ${NDAS}/2016*/*.nr`
do

  echo "${PBFILE}"

  # Process time information
  DATE_DIR=`echo ${PBFILE} | cut -d"/" -f10`
  YYYY=`echo ${DATE_DIR}  | cut -c1-4`
  MM=`echo ${DATE_DIR}  | cut -c5-6`
  DD=`echo ${DATE_DIR}  | cut -c7-8`
  HH=`basename ${PBFILE} | cut -d'.' -f2 | cut -c2-3`
  HR_OFF=`basename ${PBFILE} | cut -d'.' -f4 | cut -c3-4`
  SEC_OFF=`expr ${HR_OFF} \* 3600`
  REF_UT=`date -ud ''${YYYY}-${MM}-${DD}' UTC '${HH}:00:00'' +%s`
  VLD_UT=`expr ${REF_UT} - ${SEC_OFF}`
  BEG_UT=`expr ${VLD_UT} - 2700`
  END_UT=`expr ${VLD_UT} + 2700`
  BEG_STR=`date -ud '1970-01-01 UTC '${BEG_UT}' seconds' +%Y%m%d_%H%M%S`
  END_STR=`date -ud '1970-01-01 UTC '${END_UT}' seconds' +%Y%m%d_%H%M%S`
  VLD_YMD=`date -ud '1970-01-01 UTC '${VLD_UT}' seconds' +%Y%m%d`
  VLD_HR=`date -ud '1970-01-01 UTC '${VLD_UT}' seconds' +%H`

  # Make the output directory
  mkdir -p ${NDAS_NC}/${VLD_YMD}

  # Create output file name
  OUTFILE="${NDAS_NC}/${VLD_YMD}/prepbufr.ndas.${VLD_YMD}.t${VLD_HR}z.tm${HR_OFF}.nc"

  # Call PB2NC
  echo "time ${PB2NC} ${PBFILE} ${OUTFILE} ${CONFIG} -valid_beg ${BEG_STR} -valid_end ${END_STR} -v 2" >> ${CMD_SCRIPT}

done

chmod +x ${CMD_SCRIPT}
