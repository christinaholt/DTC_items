#!/usr/bin/env python



import matplotlib as mpl 
mpl.use('Agg')
import pygrib
from mpl_toolkits.basemap import Basemap
import numpy as np
import matplotlib.pyplot as plt
import datetime
import os,sys
import maps, regrib
import get_grib_field as ggf


def set_def_maps(preset_flag):
    '''Defines the standard set of figures produced by the graphics package. 
       Top key is user's choice of a short descriptor for the figure generated. 
       Subdictionary for each individual figure with following params: 
          lev: 'lev' for desired variable in grib file
          sname: 'shortName' value of desired variable from grib file
          pname: 'parameterName' value of desired variable from grib file. Used when shortName is unavailable
          step:  'stepType' value of desired variable from grib file. e.g., avg or instant
          barbs: flag for plotting winds over variable
          hgt: flag for plotting height over variable
          vc: 'typeOfLevel' value in grib to set vertical coordinate

       Both lev and vc are required to determine the appropriate level of the given variable. 
       sname and pname are alternative methods to define the variable name. sname is preferred. 
       If pname is used, the title and file names will reflect the top-level dictionary entry. A corresponding
         variable entry to match the figure describer must be made in the maps.py dictionary of variables. 

     '''
    if preset_flag == 'testbed': 
        map_confs = {
            '250_wind':   {'lev': '250', 'sname':  'wind', 'barbs':  True,  'hgt':  True, 'vc': 'isobaricInhPa'},
            '250_temp':   {'lev': '250', 'sname':     't', 'barbs':  True,  'hgt':  True, 'vc': 'isobaricInhPa'},
            '500_hgt':    {'lev': '500', 'sname':    'gh', 'barbs':  True,  'hgt':  True, 'vc': 'isobaricInhPa'},
            '500_temp':   {'lev': '500', 'sname':     't', 'barbs':  True,  'hgt':  True, 'vc': 'isobaricInhPa'},
            '500_vort':   {'lev': '500', 'sname':  'absv', 'barbs': False,  'hgt':  True, 'vc': 'isobaricInhPa'},
            '700_temp':   {'lev': '700', 'sname':     't', 'barbs':  True,  'hgt':  True, 'vc': 'isobaricInhPa'},
            '700_vvel':   {'lev': '700', 'sname':     'w', 'barbs': False,  'hgt':  True, 'vc': 'isobaricInhPa'},
            '850_hgt':    {'lev': '850', 'sname':    'gh', 'barbs':  True,  'hgt': False, 'vc': 'isobaricInhPa'},
            '850_temp':   {'lev': '850', 'sname':     't', 'barbs':  True,  'hgt':  True, 'vc': 'isobaricInhPa'},
            '850_rh':     {'lev': '850', 'sname':     'r', 'barbs':  True,  'hgt':  True, 'vc': 'isobaricInhPa'},
            '2m_tmp':     {'lev':   '2', 'sname':    '2t', 'barbs': False,  'hgt': False, 'vc': 'heightAboveGround'},
            '2m_dpt':     {'lev':   '2', 'sname':    '2d', 'barbs': False,  'hgt': False, 'vc': 'heightAboveGround'},
            '6h_acpcp':   {'lev':   '0', 'sname': 'acpcp', 'barbs': False,  'hgt': False, 'vc': 'surface'},
            '6h_apcp':    {'lev':   '0', 'sname':    'tp', 'barbs': False,  'hgt': False, 'vc': 'surface'}
                    }
    elif preset_flag == 'reg_test_flx':
        # Winds and height aren't included in flx file, so turn all to False.
        map_confs = {
            '2m_tmp':     {'lev':   '2', 'sname':     '2t', 'barbs': False,  'hgt': False, 'vc': 'heightAboveGround'},
            '2m_spfh':    {'lev':   '2', 'sname':      'q', 'barbs': False,  'hgt': False, 'vc': 'heightAboveGround'},
            'pwat':       {'lev':   '0', 'sname':   'pwat', 'barbs': False,  'hgt': False, 'vc':  'entireAtmosphere'},
            'prate':       {'lev':   '0', 'sname': 'prate', 'barbs': False,  'hgt': False, 'vc':           'surface'},
            '10m_u':       {'lev':  '10', 'sname':   '10u', 'barbs': False,  'hgt': False, 'vc':  'heightAboveGround'},
            '10m_v':       {'lev':  '10', 'sname':   '10v', 'barbs': False,  'hgt': False, 'vc':  'heightAboveGround'},
                    }
    elif preset_flag == 'reg_test_unknown':
        map_confs = {
            'ULWRF':     {'lev':   '0', 'pname':     '212', 'barbs': False,  'hgt': False, 'vc': 'surface', 'step': 'avg'},
                    }
    return map_confs


def main():
    # Set the input and output directories in config_REG
    indir=os.getenv('IDIR')
    outdir=os.getenv('ODIR')

    # Loop over all fhrs: range(start, stop, interval)
    for fhr in range(6,48,120):
        # Set the file name with the appropriate prefix: sigf or flxf
        fnbase=os.getenv('FBASE')
        filename=''.join([fnbase,'{:02d}'.format(fhr)])
        #filename=''.join(['flxf','{:02d}'.format(fhr)])
        # Change preset_flag based on which types of files you want to plot
        # Options: 
        #    reg_test_flx - flux files
        #    reg_test_sig - sig files
        preset_flag='reg_test_unknown'
        grib='/'.join([indir, filename])
        print grib
        # Set user_def = True if you want to plot multiple levels of a given variable
        # Suggest "True" for sigf files and "False" for flxf files.
        user_def = False
        date='2012010100'    
        plot_wind=True
        print grib, outdir, fhr
    
        # Set forecast hour
        sname=['wind', 'q', 't']
        # Sets up the plotting for several different levels: range(min, max, int)
        plevels=range(1,64,10)
        coord='hybrid'
        if user_def:  
            for var in sname:
                for level in plevels: 
                  
                    if plot_wind or var == 'wind': 
                        u = ggf.get_ua_field(grib,level,coord,shortName='u')
                        v = ggf.get_ua_field(grib,level,coord,shortName='v')
                        winds=[u,v]
                    else:
                        winds=None

                    # Get the variable from file by passing key,value pairs from the grib file. If you do not want to 
                    # use a particular field to search for the grib record, "None" is also acceptable.
                    if var != 'wind':
                         field=ggf.get_ua_field(grib,level,coord,shortname=var)
                    else: 
                         field=u
    
                    
                    mymap=maps.make_basemap(field,date,var,level,
                                          winds=winds, fhr=fhr) 
                    mymap.set_bm()
                    mymap.run()
                    mymap.save_figure(outdir)
        else:
            def_maps=set_def_maps(preset_flag)
            for fig in def_maps:  
             # If statement here is to plot a single figure from the full list of presets
             #if fig == '10m_u': 
              try: 
                level = def_maps[fig].get('lev')
          
                sname   = def_maps[fig].get('sname', None)
                pname   = def_maps[fig].get('pname', None)
                step    = def_maps[fig].get('step',None)         
                hgt   = def_maps[fig].get('hgt')
                plot_wind = def_maps[fig].get('barbs',False)
                coord     = def_maps[fig].get('vc')


                # var controls the figure title and file output name. Use a descriptive one 
                # by choosing either the shortName from grib, or the label in the dictionary (fig)
                if sname is not None: 
                   var = sname
                else: 
                   var = fig
                print level,var, hgt,plot_wind, hgt
    
    
                # Grab winds from file if plotting the barbs
                if plot_wind or var == 'wind': 
                    u = ggf.get_ua_field(grib,level,coord,shortName='u')
                    v = ggf.get_ua_field(grib,level,coord,shortName='v')
                    winds=[u,v]
                else:
                    winds=None
    
                # Get the variable from file by passing key,value pairs from the grib file. If you do not want to 
                # use a particular field to search for the grib record, "None" is also acceptable.
                if var != 'wind':
                     field=ggf.get_ua_field(grib,level,coord,shortName=sname,parameterName=pname,stepType=step)
                else: 
                     field=u
    
                height = None
                if hgt: 
                    height = ggf.get_ua_field(grib,'gh',level,coord)
                print "Made it here" 
    
                mymap=maps.make_basemap(field,date,var,level,
                                  winds=winds, plot_height=height,def_maps=def_maps,
                                  fhr=fhr) 
                mymap.set_bm()
                mymap.run()
                mymap.save_figure(outdir)
              except(ValueError):
                print 'Skipping figure'
                pass
    
main()    
