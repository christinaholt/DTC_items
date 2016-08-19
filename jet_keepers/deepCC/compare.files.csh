#!/bin/csh

# THIS SCRIPT IS CALLED BY the Python script compare.py

set startingdir = `pwd`

#set dir_a='/home/James.T.Frimel/compare/deepCC/output1'
#set dir_b='/home/James.T.Frimel/compare/deepCC/output2'

set dir_a=$1
set dir_b=$2

#cd $dir_a
#set filelist_a = `find . -type f`

# Diff is nice since it allows comparison of 2 directories.
# and if they contain different files it handles it.
diff -rq $dir_a $dir_b


# Compare is for specifying each file. Good also BUT
# Should add logic to handle which dir has more files.
#
#foreach file_a ($filelist_a)
#    set filename=`basename $file_a`
#    cmp $dir_a/$filename $dir_b/$filename | grep 'differ'
#end

#echo "End of compare"

