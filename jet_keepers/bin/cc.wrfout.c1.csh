#!/bin/csh


# HOW TO: CC Check for WRF model ouput files
# ==========================================
# EDIT dirtrunk, dircc, and io_netcdf_diffwrf as needed.
# ALSO EDIT, the find command filename search pattern ie. "SANDY.000*".


set startingdir = `pwd`

# SANDY
# 4 Christina
#set dirtrunk='/pan2/projects/dtc-hurr/Christina.Holt/CC_trunk_20160205/pytmp/CC_trunk_20160205/2012102812/18L/runwrf'
#set dircc='/pan2/projects/dtc-hurr/Christina.Holt/CC_20160205/pytmp/CC_20160205/2012102812/18L/runwrf'


set dirtrunk='/mnt/pan2/projects/dtc-hurr/James.T.Frimel/pytmp/hwrf_trunk/2012102812/18L/runwrf' 
set dircc='/mnt/pan2/projects/dtc-hurr/James.T.Frimel/pytmp/hwrf_multistorm.CC/2012102812/18L/runwrf'
#set dircc='/mnt/pan2/projects/dtc-hurr/James.T.Frimel/pytmp/a.hwrf_multistorm/2012102806/18L/runwrf'

#set dirtrunk='/lfs3/projects/hwrfv3/Zhan.Zhang/pytmp/H215_test2/2012102806/18L/runwrf'
#set dircc='/mnt/pan2/projects/dtc-hurr/James.T.Frimel/pytmp/hwrf_trunk.2/2012102806/18L/runwrf'

#set dirtrunk='/mnt/pan2/projects/dtc-hurr/James.T.Frimel/pytmp/hwrf_trunk.2/2012102806/18L/runwrf'
#set dirtrunk='/mnt/pan2/projects/dtc-hurr/James.T.Frimel/pytmp/a.hwrf_multistorm.ms=yes.2cyc.2storms/2012071000/00L/runwrf'
#set dircc='/mnt/pan2/projects/dtc-hurr/James.T.Frimel/pytmp/hwrf_trunk.test1/2012071000/00L/runwrf'

#set io_netcdf_diffwrfdir='/mnt/pan2/projects/dtc-hurr/James.T.Frimel/hwrf_trunk/sorc/WRFV3/external/io_netcdf'
#set io_netcdf_diffwrfdir='/mnt/pan2/projects/dtc-hurr/James.T.Frimel/a.hwrf_multistorm.hrd/sorc/WRFV3/external/io_netcdf'
#set io_netcdf_diffwrfdir='/mnt/pan2/projects/dtc-hurr/James.T.Frimel/hwrf_multistorm/sorc/WRFV3/external/io_netcdf'
set io_netcdf_diffwrfdir='/mnt/pan2/projects/dtc-hurr/James.T.Frimel/hwrf_trunk/sorc/WRFV3/external/io_netcdf'

# 4 Christina
#set io_netcdf_diffwrfdir='/pan2/projects/dtc-hurr/Christina.Holt/trunk_CC_1029/sorc/WRFV3/external/io_netcdf'
#set io_netcdf_diffwrfdir='/pan2/projects/dtc-hurr/Christina.Holt/CC_trunk_20160205/sorc/WRFV3/external/io_netcdf'

# DANIEL
#set dirtrunk='/mnt/pan2/projects/dtc-hurr/James.T.Frimel/pytmp/hwrf.trunk/2012070406/04E/runwrf'
#set dircc='/mnt/pan2/projects/dtc-hurr/James.T.Frimel/pytmp/hwrf.cc/2012070406/04E/runwrf'
#set io_netcdf_diffwrfdir='/mnt/pan2/projects/dtc-hurr/James.T.Frimel/hwrf.trunk/sorc/WRFV3/external/io_netcdf'


cd $dirtrunk
set filelisttrunk = `find -name  "wrfout_d0*"`

cd $io_netcdf_diffwrfdir
echo `pwd`

@ counter = 1
foreach filetrunk ($filelisttrunk)
    set filename=`basename $filetrunk`
    #echo $filetrunk
    #echo $filename
    
    # For wrfout files must use diffwrf
    #echo "./diffwrf $dirtrunk/$filename $dircc/$filename"
    echo "File $counter ============================"
    echo "$dirtrunk/$filename"
    echo "$dircc/$filename"
    ./diffwrf $dirtrunk/$filename $dircc/$filename
    #echo "----"
    # Using just cmp or diff is ok also, 
    # I prefer cmp since it is byte by byte and faster.
    #echo "diff $dirtrunk/$filename $dircc/$filename \n"
    #diff $dirtrunk/$filename $dircc/$filename
    #echo "----"
    #echo "cmp $dirtrunk/$filename $dircc/$filename\n"
    #cmp $dirtrunk/$filename $dircc/$filename
    echo "---- "
    echo ""
    @ counter ++
end
