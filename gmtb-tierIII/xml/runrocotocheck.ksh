#!/bin/ksh

xml_loc=/scratch4/BMC/gmtb/gmtb-tierIII/xml
xml_w=GFS_VX.xml
xml_d=GFS_VX.db
cycle=201512160000
#task="met_grid_anl_refcst_000"
#task="met_qpf_global_24h_refcst_036"
#task="met_point_ua_refcst_240"
#task="graphics_refcst_180"
#task="met_qpf_global_24h_refcst_372"
#task="cp_vx_refcst"
task="archive"
#task="met_point_ua_refcst_228"

/apps/rocoto/1.2.2/bin/rocotocheck -w ${xml_loc}/${xml_w} -d ${xml_loc}/${xml_d} -c ${cycle} -t ${task}
