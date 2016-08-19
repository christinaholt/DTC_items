#!/bin/ksh -l

##########################################################################
#
# Script Name: constants.ksh
#
# Description:
#    This script localizes several tools specific to this platform.  It
#    should be called by other workflow scripts to define common
#    variables.
#
##########################################################################

# Usin GMT time zone for time computations
export TZ="GMT"

# Give other group members write access to the output files
umask 2

# Load modules
#source /glade/apps/opt/lmod/lmod/init/ksh
#export MODULEPATH_ROOT=/glade/apps/opt/modulefiles
#export MODULEPATH=$MODULEPATH_ROOT/compilers/:$MODULEPATH_ROOT/idep/:$MODULEPATH_ROOT/cdep/intel

module load intel/15.0.0
module load netcdf/4.3.0
module load ncl/6.3.0
module list

# Set up paths to shell commands
AWK="/bin/gawk --posix"
BASENAME=/bin/basename
BC=/usr/bin/bc
CAT=/bin/cat
CHMOD=/bin/chmod
CONVERT=/apps/ImageMagick/6.9.0/bin/convert
#COPYGB=/glade/p/ral/jnt/MMET/CODE/UPP/v3.0/UPPV3.0/bin/copygb.exe
CP=/bin/cp
CTRANS=/apps/ncl/6.3.0-nodap_gcc447/bin/ctrans
CUT=/bin/cut
DATE=/bin/date
DIRNAME=/usr/bin/dirname
ECHO=/bin/echo
EXPR=/usr/bin/expr
GREP=/bin/grep
LN=/bin/ln
LS=/bin/ls
MKDIR=/bin/mkdir
MV=/bin/mv
OD=/usr/bin/od
RM=/bin/rm
RSYNC=/usr/bin/rsync
SED=/bin/sed
TAIL=/usr/bin/tail
TAR=/bin/tar
TOUCH=/bin/touch
TR=/usr/bin/tr
WC=/usr/bin/wc
WGRIB2=/apps/wgrib2/0.1.9.5.1/bin/wgrib2
