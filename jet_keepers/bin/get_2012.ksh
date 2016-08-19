#! /usr/bin/env ksh
set -x 
hpssloc=/NCEPDEV/hpssuser/g01/hurpara/GFS-PROD-2012

# SANDY
#startdate=2012102112
#enddate=2012103018

# DANIEL & EMILIA
#startdate=2012070406
#enddate=2012071818

# HILARY & OPHELIA
startdate=2011091718
enddate=2011100312

# CRISTINA
#startdate=2014060706
#enddate=2014061518

# MARIE
#startdate=2014081918
#enddate=2014082906

# NORBERT
#startdate=2014082118
#enddate=2014090806


#startdate=
#enddate=

diskloc=/lfs2/projects/dtc-hurr/hwrf-input

cmd='htar -xvf'
#cmd=echo

cdate=$startdate
#cdate='201210[2,3]*'
while [[ $cdate -le $enddate ]] ;
do

     YYYY=`echo $cdate | cut -c1-4`
     file1=gdasr-gdas1-enkf-$cdate.tar
     file2=gfs-loop-$cdate.tar
     gdas=GDAS1/$YYYY/$cdate/
     enkf=ENKF/$YYYY/$cdate/
     hist=HISTORY/GFS.$YYYY/$cdate/
     
     # HISTORY FILES: !(*.pgrb2f*) !(*.sf*)
     # NEED *.pgrb2f(00-12) *sf(00-12)
     # Copy ENKF and GDAS
#     `$cmd $hpssloc/$file1 $gdas`  
#	if [ $? -ne 0 ]; then
#	  echo “CRITICAL: HTAR FAILED for GDAS”
#	  continue
#	else
#	  wait $!
#	fi
     wait $!
  if [[ ! -d $enkf || ! -d $gdas ]]; then
     `$cmd $hpssloc/$file1 $enkf $gdas`  
  fi
#	if [ $? -ne 0 ]; then
#	  echo “CRITICAL: HTAR FAILED for ENKF”
#	  continue
#	else
#	  wait $!
#	fi
     wait $!
     
     # Copy HISTORY
  if [[ ! -d $hist ]]; then
     `$cmd $hpssloc/$file2 $hist` 
  fi
#	if [ $? -ne 0 ]; then
#	  echo “CRITICAL: HTAR FAILED for HISTORY”
#	  continue
#	else
#	  wait $!
#	fi
     wait $!

#     for job in `jobs -p` ;
#     do
#     echo $job
#         wait $job 
#     done
     
     cdate=`~Christina.Holt/bin/ndate.exe 6 $cdate`
done

