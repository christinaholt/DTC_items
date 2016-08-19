#!/bin/ksh

xml_loc=/scratch4/BMC/gmtb/gmtb-tierIII/xml
xml_w=GFS_VX.xml
xml_d=GFS_VX.db
cycle=201512160000

/apps/rocoto/1.2.2/bin/rocotostat -w ${xml_loc}/${xml_w} -d ${xml_loc}/${xml_d} -c ${cycle}
