#! bin/csh -f

#CMORPH data reorg
foreach i (/scratch3/BMC/dtc-hwrf/GMTB/vx_data/cmorph/201*)
echo $i
setenv j `echo $i | cut -d "/" -f 8`
echo $j
mkdir $j
cp $i/proc/CMORPH*.nc $j
end

#CCPA data reorg prior to upgrade
foreach i (/scratch4/BMC/dtc/harrold/gmtb/ccpa/201512*)
echo $i
setenv j `echo $i | cut -d "/" -f 8 | cut -c 1-8`
echo $j
mkdir $j
cp $i/ccpa/* $j
end

#CCPA data reargue post upgrade (rename to old name since there were fewer of these dates to change...
foreach i (/scratch4/BMC/dtc/harrold/gmtb/ccpa/201604*)
echo $i
setenv j `echo $i | cut -d "/" -f 8`
echo $j
mkdir $j
cp $i/00/ccpa.t00z.06h.hrap.conus.gb2 $j/ccpa_conus_hrap_t00z_06h_gb2
cp $i/06/ccpa.t06z.06h.hrap.conus.gb2 $j/ccpa_conus_hrap_t06z_06h_gb2
cp $i/12/ccpa.t12z.06h.hrap.conus.gb2 $j/ccpa_conus_hrap_t12z_06h_gb2
cp $i/18/ccpa.t18z.06h.hrap.conus.gb2 $j/ccpa_conus_hrap_t18z_06h_gb2
end
