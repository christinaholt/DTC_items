#!/bin/ksh

# Constants
PB2NC=/d3/projects/MET/MET_releases/met-5.1/bin/pb2nc
GDAS=/d4/projects/GMTB/gdas/native
GDAS_NC=/d4/projects/GMTB/gdas/gdas_nc
CONFIG=/d4/projects/GMTB/met_config/PB2NCConfig_GMTB
CMD_SCRIPT=run_pb2nc_cmds_GDAS.sh

# Use -valid_beg and -valid_end YYYYMMDD_HH

rm -f ${CMD_SCRIPT}

# Process each input GDAS file
for PBFILE in `ls ${GDAS}/20*/*.nr`
do

  echo "${PBFILE}"

  # Process time information
  DATE_DIR=`echo ${PBFILE} | cut -d"/" -f7`
  YYYY=`echo ${DATE_DIR}  | cut -c1-4`
  MM=`echo ${DATE_DIR}  | cut -c5-6`
  DD=`echo ${DATE_DIR}  | cut -c7-8`
  HH=`basename ${PBFILE} | cut -d'.' -f2 | cut -c2-3`
  REF_UT=`date -ud ''${YYYY}-${MM}-${DD}' UTC '${HH}:00:00'' +%s`
  VLD_UT=${REF_UT}
  BEG_UT=`expr ${VLD_UT} - 2700`
  END_UT=`expr ${VLD_UT} + 2700`
  BEG_STR=`date -ud '1970-01-01 UTC '${BEG_UT}' seconds' +%Y%m%d_%H%M%S`
  END_STR=`date -ud '1970-01-01 UTC '${END_UT}' seconds' +%Y%m%d_%H%M%S`
  VLD_YMD=`date -ud '1970-01-01 UTC '${VLD_UT}' seconds' +%Y%m%d`
  VLD_HR=`date -ud '1970-01-01 UTC '${VLD_UT}' seconds' +%H`

  # Make the output directory
  mkdir -p ${GDAS_NC}/${VLD_YMD}

  # Create output file name
  OUTFILE="${GDAS_NC}/${VLD_YMD}/prepbufr.gdas.${VLD_YMD}.t${VLD_HR}z.nc"

  # Call PB2NC
  echo "time ${PB2NC} ${PBFILE} ${OUTFILE} ${CONFIG} -valid_beg ${BEG_STR} -valid_end ${END_STR} -v 2" >> ${CMD_SCRIPT}

done

chmod +x ${CMD_SCRIPT}