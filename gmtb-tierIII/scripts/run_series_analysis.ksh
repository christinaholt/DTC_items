#!/bin/ksh

base=/d4/projects/GMTB/GFS/2014010100
exe_root=/d3/projects/MET/MET_releases/met-5.1/bin

config="GFSfcstGFSanl"
grid="g104"
inithr_list="00"
#fcsthr_list="03 06 09 12 15 18 21 24 27 30 33 36 39 42 45 48"
fcsthr_list="12"
var_list="HGT"
level_list="P500"

mkdir -p ${base}/series_analysis/output

for var in ${var_list}; do
  for level in ${level_list}; do
    for inithr in ${inithr_list}; do
      for fcsthr in ${fcsthr_list}; do
	# Use grid_stat matched pairs data that contains fcst and obs
	fcst_file=${base}/metprd/grid_stat_GFS_G104_F12_120000L_20140101_120000V_pairs.nc
	out_file=${base}/metprd/${config}_${grid}_${var}_${level}_i${inithr}_f${fcsthr}.nc

	export var
	export level
        export config
		    
        echo "${exe_root}/series_analysis -both ${fcst_file} -out ${out_file} -config ${base}/../../met_config/SeriesAnalysisConfig_${grid}_HGT"
        ${exe_root}/series_analysis -both ${fcst_file} -out ${out_file} -config ${base}/../../met_config/SeriesAnalysisConfig_${grid}_HGT
      done
    done
  done
done
