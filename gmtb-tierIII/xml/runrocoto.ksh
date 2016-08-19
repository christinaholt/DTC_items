#!/bin/ksh

xml_loc=/scratch4/BMC/gmtb/gmtb-tierIII/xml
xml_w=GFS_VX.xml
xml_d=GFS_VX.db

/apps/rocoto/1.2.2/bin/rocotorun -w ${xml_loc}/${xml_w} -d ${xml_loc}/${xml_d} -v 10

cp ${xml_loc}/${xml_d} ~/.
