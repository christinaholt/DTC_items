#!/bin/csh


# This simple script generates the file the.files.that.differ.txt.
# Which contains a list of only *.grb and *.grb2 files that differ.
# 
# The file is then read by compare.py
#
# It can also be used to compare any set of desired text files.

set startingdir = `pwd`

#set differfile='differ.file.trunk.test1.hrdproducts.06Z.txt'

# Set this the output filename you want.
set differfile='the.files.that.differ.txt'
#set differfile='differ.file.CC_trunk_20160205.2012102812.18L.txt'
#set differfile='differ.file.CC_trunk_20160205.2012102812.18L.TRAK.txt'


# SET Process only filelist_a ?
# yes or no
# default is no  (builds a list of all grib and grib2 files to be compared)
# ================================================================
# This just allows you to build a larger file list to be compared.
set file_a_only='no'


# SET dir_a and dir_b , THE directories you want to compare files.
# ===============================================================
#set dir_a='/mnt/pan2/projects/dtc-hurr/James.T.Frimel/pytmp/hwrf_trunk.baseline2.2cyc.defaults/com/2012102806/18L'
#set dir_a='/mnt/pan2/projects/dtc-hurr/James.T.Frimel/pytmp/a.hwrf_multistorm.ms=no.2cyc.defaults/com/2012102806/18L'
#set dir_a='/mnt/pan2/projects/dtc-hurr/James.T.Frimel/pytmp/a.hwrf_multistorm.ms=yes.2cyc.2storms/com/2012071000/04E'
#set dir_b='/mnt/pan2/projects/dtc-hurr/James.T.Frimel/pytmp/hwrf_trunk.test1/com/2012071000/04E'

#set dir_a='/lfs3/projects/hwrfv3/Zhan.Zhang/pytmp/H215_test2/com/2012102806/18L/'
#set dir_b='/lfs3/projects/hwrfv3/Zhan.Zhang/pytmp/H215_test3/com/2012102806/18L/'

set dir_a='/pan2/projects/dtc-hurr/Christina.Holt/UPP_test_20160531/pytmp/bUPP/2012102806/18L/intercom/nonsatpost-f12h00m/nonsatpost-f12h00m'
set dir_b='/pan2/projects/dtc-hurr/Christina.Holt/UPP_test_20160531/pytmp/UPP_test_20160531/2012102806/18L/intercom/nonsatpost-f12h00m/nonsatpost-f12h00m'



# Change to directory dir_a and generate the filelists
# ======================================================
cd $dir_a


set filelist_a = `find . -type f -name "*grb"`
#set filelist_a = `find . -type f -name "*f000*\.grb" -or -name "*f001*\.grb" -or -name "*f063*\.grb" -or -name "*f126*\.grb"`
#set filelist_a = `find . -type f -name "*atcf*" -or -name "*raw" -or -name "*short*" -or -name "*htcf*"`
# ATCFUNIX products
#set filelist_a = `find . -type f -name "*atcf*" -or -name "*raw" -or -name "*short*"` 
# HRD products.
#set filelist_a = `find . -type f -name "*htcf*"  -or -name "*swath*" -or -name "*.ascii" -or -name "*stats*" -or -name "*.afos" -or -name "*.dat" -or -name "*.resolution"`

set filelist_a2 = `find . -type f -name "*\.grb2"`
#set filelist_a2 = `find . -type f -name "*f000*\.grb2" -or -name "*f001*\.grb2" -or -name "*f063*\.grb2" -or -name "*f126*\.grb2"`
#set filelist_a = `find . -type f -and -not -name "*wrfout*" -and -not -name "*ensda*" -and -not -name "*jetbqs3*" -and -not -name "*trak.hwrf.atcfunix.mem*"`
#set filelist_a = `find -name  "gfs*"`
#set filelist_a = `find  . -type f -name "*trak*" -and -not -name "*trak.hwrf.atcfunix.mem*"`

cd $startingdir
echo `pwd`

foreach file_a ($filelist_a)
    set filename=`basename $file_a`
    echo "========================================="
    echo "$dir_a/$filename"
    echo "$dir_b/$filename"

    # Using just cmp or diff is ok also, 
    # I prefer cmp since it is byte by byte and faster.
    #echo "cmp $dir_a/$filename $dir_b/$filename"
    #cmp $dir_a/$filename $dir_b/$filename | grep 'differ'
    cmp $dir_a/$filename $dir_b/$filename
    if ($status > 0) then
        echo "Files differ ... add to differ file."
        echo $filename >> $differfile
    endif
    #diff -q $dir_a/$filename $dir_b/$filename
end

if ($file_a_only == "yes") then
    echo "Only processing file_a list"
    exit
endif
foreach file_a2 ($filelist_a2)
    set filename=`basename $file_a2`
    echo "========================================="
    echo "$dir_a/$filename"
    echo "$dir_b/$filename"
    cmp $dir_a/$filename $dir_b/$filename
    if ($status > 0) then
        echo "Files differ ... add to differ file."
        echo $filename >> $differfile
    endif
end





