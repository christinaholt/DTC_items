#!/bin/ksh

xml_loc=/scratch4/BMC/gmtb/gmtb-tierIII/xml
xml_w=GFS_RUN.xml
xml_d=GFS_RUN.db
task=$1
cycle=201601220000

/apps/rocoto/1.2.2/bin/rocotorewind -w ${xml_loc}/${xml_w} -d ${xml_loc}/${xml_d} -c ${cycle} -t ${task} -v 10
