PS1='\h:\w $ '

export COLUMNS=550
export EDITOR='vim'

# export LD_LIBRARY_PATH=/lfs2/projects/dtc-hurr/MET/MET_releases/external_libs/lib:${LD_LIBRARY_PATH}
# export MET_BUILD_BASE=/lfs2/projects/dtc-hurr/MET/MET_releases/met-5.0
# export MET_BASE=/lfs2/projects/dtc-hurr/MET/MET_releases/met-5.0/share/met


export h2=/pan2/projects/dtc-hurr/Christina.Holt
export hrap=/lfs3/projects/rtwbl/Christina.Holt
export jb=/lfs3/projects/rtwbl/beck/rapretro/jul2014_wrf36_v2/
export ej=/lfs3/projects/rtwbl/ejames/rapretro/jul2014_wrf36_v2/

alias h2="cd /pan2/projects/dtc-hurr/Christina.Holt"
alias hrap="cd /lfs3/projects/rtwbl/Christina.Holt"
alias ls="ls --color=auto"
alias ll='ls -l'
alias vi='vim'
alias me='qstat -u Christina.Holt'
alias watchme='watch "qstat -u Christina.Holt"'
alias dtc='qstat -u dtc'
alias getgsi='svn co https://gsi.fsl.noaa.gov/svn/comgsi/trunk GSI'
#ulimit -s 6144000
ulimit -s unlimited
#ulimit -s 2024000
#ulimit -s 10240
#limit stacksize unlimited

export PATH=${PATH}:${MET_BUILD_BASE}/bin:~/bin
export PATH=/lfs3/projects/hwrfv3/Samuel.Trahan/rocoto/bin:$PATH

	. /apps/lmod/lmod/init/sh
module purge
        module load intel
# 	module load pgi/13.2-0
        module load mvapich2
        module load netcdf
        module load pnetcdf
        module unload netcdf
        module load szip hdf5 netcdf4
        module load hsms
 	module load nco
 	module load ncl
        module load ncview
	module load grads
	module load cnvgrib
	module load xxdiff
        module load wgrib2
	module load rocoto/1.2

module use /contrib/modulefiles
module load anaconda


export PYTHONUSERBASE=/home/Christina.Holt/bin

#module use /home/George.Carr/modulefiles
##module load pnetcdf/1.5.0-intel-mvapich
#module load pnetcdf/1.5.0-pgi-mvapich
#module unuse /home/George.Carr/modulefiles

#if [ -d /pan2/projects/dtc-hurr/apps/modulefiles/ ]; then
#        module use /pan2/projects/dtc-hurr/apps/modulefiles/
#	module load pnetcdf
#fi 


# Wrapper around enscript
function ens() { 
    /usr/share/zsh/4.3.10/functions/_enscript -p - -E -r -2 -G --color $1 | \
    /opt/local/bin/gs -q -sDEVICE=pdfwrite -sOutputFile=$1.pdf \
        -dBATCH -dNOPAUSE -dSAFER -
}


export HWRF=1
export WRF_NMM_CORE=1
export PNETCDF_QUILT=1
export WRF_NMM_NEST=1
export WRFIO_NCD_LARGE_FILE_SUPPORT=1
export LIB_Z_PATH=/usr/lib64
export LIB_PNG_PATH=/usr/lib64
export LIB_JASPER_PATH=/usr/lib64
export INC_JASPER_PATH=/usr/include
export JASPERLIB=/usr/lib64
export JASPERINC=/usr/include
export PYTHONPATH=/home/Christina.Holt/bin:$PYTHONPATH
