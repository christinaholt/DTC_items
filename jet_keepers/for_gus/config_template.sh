#!/bin/sh

# Creates a configure file for each constellation of input values, controlled
# by config_template.sh. 



set -x

here=`pwd`
ATCF=${1}
var=${2}
lev=${5}
fhr=${3}
thresh=${4}

# The level can be in several different units. I have only looked at standard 
# pressure levels and height levels near the surface, so this check works. 

if [[ $lev -gt 100 ]] ; then
  lev_letter=P
else
  lev_letter=Z
fi

echo "LEVEL "$lev[1]


cat << EOF > ./config/SeriesAnalysisConfig_${ATCF}_${var}_${lev}.f${fhr}
////////////////////////////////////////////////////////////////////////////////
//
// Series-Analysis configuration file.
//
// For additional information, see the MET_BASE/data/config/README file.
//
////////////////////////////////////////////////////////////////////////////////

//
// Output model name to be written
//
model = "${ATCF}";

////////////////////////////////////////////////////////////////////////////////

//
// Forecast and observation fields to be verified
//
fcst = {


   cat_thresh  = [ $thresh ];
   field = [
        {name  = "$var"; level =[ "${lev_letter}${lev}" ];}
   ];

};
obs = fcst;


////////////////////////////////////////////////////////////////////////////////

//
// Confidence interval settings
//
ci_alpha  = [ 0.05 ];

boot = {
   interval = PCTILE;
   rep_prop = 1.0;
   n_rep    = 0;
   rng      = "mt19937";
   seed     = "";
};

////////////////////////////////////////////////////////////////////////////////

//
// Verification masking regions
//
mask = {
   grid = "FULL";
   poly = "";
};

//
// Number of grid points to be processed concurrently.  Set smaller to use
// less memory but increase the number of passes through the data.
//
block_size = 324000;

//
// Ratio of valid matched pairs to compute statistics for a grid point
//
vld_thresh = 0.001;

////////////////////////////////////////////////////////////////////////////////

//
// Statistical output types
//
output_stats = {
   fho    = [];
   ctc    = [];
   cts    = [];
   mctc   = [];
   mcts   = [];
   cnt    = [ "RMSE", "ME", "MAE", "TOTAL","FBAR","OBAR" ];
   sl1l2  = [];
   pct    = [];
   pstd   = [];
   pjc    = [];
   prc    = [];
};

////////////////////////////////////////////////////////////////////////////////

rank_corr_flag = FALSE;
tmp_dir        = "/tmp";
version        = "V5.0";

////////////////////////////////////////////////////////////////////////////////


EOF

