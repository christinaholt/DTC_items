#!/bin/bash




comdir=/mnt/pan2/projects/dtc-hurr/dtc/HDGF/pytmp/HDGF/com

archive=/HFIP/dtc-hurr/HDGF

for d in $( ls $comdir ) ; do
   for s in $( ls $comdir/$d ) ; do
      echo $comdir/$d/$s
      filename=com_${d}_$s.tar
      echo $archive/$filename

      # Make a list of files to transfer

      # Archive the files
      #echo '-cvf $archive/$filename << files.txt'
      htar -cvf $archive/$filename $comdir/$d/$s/* &
      wait $!
   done
done

