import os,sys,subprocess
ncep_grids = {
              'G104': 'nps:255:60 220.525:147:90755 -0.268:110:90755' ,
              'G218': 'lambert:265.000:25 226.514:614:12190.58 12.190:428:12190.58'  ,
                'G3': 'ncep grid 3'
              }
# MET Definitions:
#{ "G104", 'N',  60.0,  -0.268,  139.475, 0.0, 0.0,  105.0,  90.755,  ncep_earth_radius_km,  147, 110 },
#{ "G218", 25.0, 25.0, 12.19,   133.459, 0.0, 0.0,  95.0, 12.191,    ncep_earth_radius_km,  614,  428 },


#NCEP Descriptions: 
#G218: LC CONUS nx=614,ny=428,La1=12.19,Lo1=226.514E=133.459W,Lov=265E=95W
#       dx=dy=12.19058,pole @(347.668, 1190.097)

class new_grid(object):
    def __init__(self,outgrid,infile,outfile,wind_rot=None): 
         self.outgrid = outgrid
         self.infile  = infile
         self.outfile = outfile
         self.wind_rot = wind_rot

    def regrid(self): 
         options = ' '.join(['-set_grib_type same -new_grid_winds ',self.wind_rot, ' -new_grid', ncep_grids.get(self.outgrid)])
         print "running: %s" % (' '.join(['wgrib2 ', self.infile, options,  self.outfile]))
         os.system(' '.join(['wgrib2', self.infile, options,  self.outfile]))
#         subprocess.call(['wgrib2', self.infile, options, self.outfile])
         return
