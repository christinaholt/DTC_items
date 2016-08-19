#!/bin/ksh

xml_loc=/scratch4/BMC/gmtb/gmtb-tierIII/xml
xml_w=GFS_VX.xml
xml_d=GFS_VX.db
cycle=201512050000
#task="archive_task"
#task="graphics_refcst_180"
#task="graphics_refcst_000"
task="met_point_ua_refcst_2015120500_228"

/apps/rocoto/1.2.2/bin/rocotoboot -w ${xml_loc}/${xml_w} -d ${xml_loc}/${xml_d} -c ${cycle} -t ${task}
