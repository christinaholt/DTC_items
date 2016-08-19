
README.deepCC.txt


THE DEEP CC
=============
You can run the linux "cmp" command to compare 2 grib files.
They may be identical or they may differ.

If they differ, this may be do to the order of the records in the
file, or duplicate records in a file and not a difference in the data. 

The DEEP CC is meant to be run  on these differing files and does a 
record by record comparison.


HOW TO DEEP CC grib1 and grib2 files.
======================================

NOTE: The DEEP CC takes a while ... for example
      comparing 174 grib files w/744 records per file 
      takes about 8 hours. (approx 2.5 min/file)

NOTE: compare.make.differ.file.csh WILL NOT create
      a differ file if there are no differences.
      You can see this by reviewing the standard output.   

1. 
Edit compare.make.differ.file.csh and set the following variables.

differfile=
file_a_only=
dir_a=
dir_b=
filelist_a =
filelist_b =

2. 
Run ./compare.make.differ.file.csh

This will run "cmp" against a list of files and any files that are
different will end up in a differfile="differ.txt" file for a deeper look.


3. 
Edit compare.py

* since you are unpacking the records in a grib file make sure your
  "outputdir1" and "outputdir2" are in a location with enough space
   ie. pan2

Edit and set these  variables in "compare.py"
scriptdir=
compare_script=
diff_report=
diff_file=
dir1=
dir2= 
outputdir1=
outputdir2=

4.
module load wgrib2
module load wgrib

5. 

** Run linux "screen" command first 
   since compare.py can take 8 hours to run.

Run ./compare.py

This breaks out the grib files in to individual records
and does a "cmp" record by record.


6.
Look at the report

It takes a while to run ... you can tail the report ....

Sometimes there may be duplicate records in a grib file so 
you my see something like file1: 744 741   (which means 3 records had duplicates.)

If there is NO Standard Out: or NO Standard Error: in each file
being processed ... then they are identical.


But typically you will see something like this .... for each file.
Which is an example of two identical files.
=====================================================================
Processing file 9 sandy18l.2012102806.hwrfprs.d23.0p02.f000.grb2 
Total and Unique records in grib file 1: 744 744
Total and Unique records in grib file 2: 744 744
I'm done with wgrib ouput ... lets diff 
Standard Out:

Standard Error: 

I'm done with diff....
======================================================================


