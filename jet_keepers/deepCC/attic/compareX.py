#!/usr/bin/env python

import string
import sys
import os
import re
import shutil
from datetime import datetime
from subprocess import Popen, PIPE, STDOUT
from time import sleep

# ########################################################################################

# NOTES: 
# -----
# WGRIB2
# wgrib2 -d 3 -grib_ieee fileout file.grb2  (write record 3 to fileout.grb fileout.h fileout.head fileout.tail)
# wgrib2 -GRIB fileout test.grb2  (writes all the data to fileout)
# wgrib2 -d 3 file.grb2 -bin fileout.bin  (writes record 3 to fileout.bin)
# wgrib -d 3 rec_num -o fileout.bin file.grb 
#
# I used this to process and input 1 file.
#file='sandy18l.2012102806.hwrforg_n.grb2f00'
#file=raw_input("Enter the filename: ")
# ########################################################################################

numrecs=2000

outputdir='CCoutdir'

grib2id='.grb2'

record_numbers=map(str,range(1,numrecs))


inputdir=raw_input("Enter the inputdir:")
filename=raw_input("Enter the filename:")


#Delete the output dirs each time we process a filename
os.chdir(inputdir)
if os.path.isdir(outputdir):
    shutil.rmtree(outputdir)
os.mkdir(outputdir)

# Write out all the records to individual files.
for rec_num in record_numbers: 
    if grib2id in filename:
        cmd1 = ['wgrib2', '-d', rec_num, inputdir+'/'+filename, '-bin', outputdir+'/file'+rec_num] 
        #cmd1 = ['wgrib2', '-d', rec_num, '-grib_ieee', outputdir+'/file'+rec_num, inputdir+'/'+filename]
    else:
        cmd1 = ['wgrib', '-d', rec_num, '-o', outputdir+'/file'+rec_num, inputdir+'/'+filename ]

    p1 = Popen(cmd1, shell=False, stdout=PIPE, stderr=PIPE, close_fds=False)

    std_out = p1.stdout.read()
    std_err = p1.stderr.read()

    print std_out
    print std_err
    print "===================="

    if not std_out:
        print "No more standard out for GRIB FILE 1 ... must be end of data."
        break
        
sys.exit(0)
