#!/usr/bin/env python

# Input: 
#     Environment variables BIG_GRIB (path to original grib file)
#     and LITTLE_GRIB (path to new grib file)
# Description:
#     Script copies prescribed fields listed in *_vars variables
#     from BIG_GRIB and stores them in LITTLE_GRIB. Levels are specified
#     for multilevel variables. All available listed variables will be grabbed 
#     from all available listed levels. 
#    
#     Utilizes the wgrib2, grep, and cat functions. 
#     Matching is done by both the wgrib2 -match option, and the grep tool.

import os


in_grib=os.environ.get('BIG_GRIB')
out_grib=os.environ.get('LITTLE_GRIB')

single_lev_vars  = ['APCP','ACPCP','PWAT']
multi_lev_vars   = ['UGRD', 'VGRD', 'RH', 'TMP']
levels           = "'1000 mb|850 mb|700 mb|600 mb|500 mb|400 mb|300 mb|10 m'"

# Make sure output directory exists
if not os.path.isdir(os.path.dirname(out_grib)):
   os.makedirs(os.path.dirname(out_grib))

# Do single level vars first: 
wg_args      = ' '.join(['-match', ''.join(["'",'|'.join(single_lev_vars),"'"])])
newgrib_args = ' '.join(['-grib', out_grib])
cmd          = ' '.join(['wgrib2', in_grib, wg_args, newgrib_args])

print cmd
os.system(cmd)


# Add the multi-level variables
wg_args      = ' '.join(['-match', ''.join(["'",'|'.join(multi_lev_vars),"'"])])
# grep_args need -Ew for matching any item in the list (E) exactly (w).
grep_arg     = ' '.join(['|', 'grep','-Ew', levels, '|'])
tempgrid_args= ' '.join(['wgrib2', '-i', in_grib, '-grib tmp.grib2'])
cat_args     = ' '.join(['cat tmp.grib2 >>', out_grib]) 
cmd          = ' '.join(['wgrib2', in_grib, wg_args, grep_arg, tempgrid_args])

print cmd
os.system(cmd)

print cat_args
os.system(cat_args)

os.system('rm tmp.grid2')

#How do I extract records 10,12,19 from a grib file
#
#       wgrib2 old_grib -match '^(1|12|19):' -grib new_grib
#
#    The ^ is a special regular-expression character that matches the
#    start of the line. The () denotes an expression and the vertical bar
#    is the OR operator.  See you book on regular expressions for details.


