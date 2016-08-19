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

def set_def_maps():

    map_confs = {
        '250_wind':   {'lev': '250', 'pvar':  'wind', 'pfill': 's', 'barbs':  True,  'hgt':  True, 'vc': 'isobaricInhPa'},
        '250_temp':   {'lev': '250', 'pvar':     't', 'pfill': 's', 'barbs':  True,  'hgt':  True, 'vc': 'isobaricInhPa'},
        '500_hgt':    {'lev': '500', 'pvar':    'gh', 'pfill': 's', 'barbs':  True,  'hgt':  True, 'vc': 'isobaricInhPa'},
        '500_temp':   {'lev': '500', 'pvar':     't', 'pfill': 's', 'barbs':  True,  'hgt':  True, 'vc': 'isobaricInhPa'},
        '500_vort':   {'lev': '500', 'pvar':  'absv', 'pfill': 's', 'barbs': False,  'hgt':  True, 'vc': 'isobaricInhPa'},
        '700_temp':   {'lev': '700', 'pvar':     't', 'pfill': 's', 'barbs':  True,  'hgt':  True, 'vc': 'isobaricInhPa'},
        '700_vvel':   {'lev': '700', 'pvar':     'w', 'pfill': 's', 'barbs': False,  'hgt':  True, 'vc': 'isobaricInhPa'},
        '850_hgt':    {'lev': '850', 'pvar':    'gh', 'pfill': 's', 'barbs':  True,  'hgt': False, 'vc': 'isobaricInhPa'},
        '850_temp':   {'lev': '850', 'pvar':     't', 'pfill': 's', 'barbs':  True,  'hgt':  True, 'vc': 'isobaricInhPa'},
        '850_rh':     {'lev': '850', 'pvar':     'r', 'pfill': 's', 'barbs':  True,  'hgt':  True, 'vc': 'isobaricInhPa'},
        '2m_tmp':     {'lev':   '2', 'pvar':    '2t', 'pfill': 's', 'barbs': False,  'hgt': False, 'vc': 'heightAboveGround'},
        '2m_dpt':     {'lev':   '2', 'pvar':    '2d', 'pfill': 's', 'barbs': False,  'hgt': False, 'vc': 'heightAboveGround'},
        '6h_acpcp':   {'lev':   '0', 'pvar': 'acpcp', 'pfill': 's', 'barbs': False,  'hgt': False, 'vc': 'surface', 'acc_field': True},
        '6h_apcp':    {'lev':   '0', 'pvar':    'tp', 'pfill': 's', 'barbs': False,  'hgt': False, 'vc': 'surface', 'acc_field': True}
#        '6h_ncpcp':   {'lev':   '0', 'pvar': 'ncpcp', 'pfill': 's', 'barbs': False,  'hgt': False, 'vc': 'surface'}
                }

    return map_confs


def main():
 
    # Get the cycle information from env vars
    moad_dataroot=os.getenv('MOAD_DATAROOT')
    rotdir=os.getenv('ROTDIR')
    date=os.getenv('START_TIME')     # @Y@m@d@H
    fhr=os.getenv('FCST_TIME') # 3 digit fcst hour
    grid_list=os.getenv('GRID_VX_LIST')
    vx_grid=grid_list.split(" ")
    filename=''.join(['pgrbq', fhr, '.gfs.', date, '.grib2'])
    gribin='/'.join([rotdir, filename])
    user_def = os.getenv('USER_MAPS',False)

    # Set the output file location (template set in maps.py).
    outdir='/'.join([moad_dataroot, 'figprd'])


    # Change projection if needed.
    for grid in vx_grid: 
        outmap = grid
        print grid
        
        # Wind rotation is a user choice, not necessarily a predefined choice, so is included here.
        wind_rot = {'G104': 'grid', 'G218': 'grid', 'G3': 'grid'}

        # Assumes that NCEP pre-defined grids will be defined with a leading "G"  
        if grid[0] == 'G':
           newgrib = ''.join(['pgrbq', fhr, '.gfs.', date,'_', grid, '.grib2'])
           newgrib = '/'.join([outdir,newgrib])
           if not os.path.exists(outdir):
             os.makedirs(outdir)
           vx = regrib.new_grid(grid,gribin,newgrib,wind_rot.get(grid,None))
           vx.regrid()
           grib = newgrib
        else:
           grib = gribin

        plot_wind=True
        print gribin, outdir
    
    
        # Set forecast hour
        pvars=['gh', 't']
        plevels=[ 850, 700, 500, 250 ]
        coord = [ "isobaricInhPa", "isobaricInhPa", "isobaricInhPa", "isobaricInhPa"]
        # Variables include: t, r, u, v, w, gh, absv, clwmr,soilw, 2t, 2d, pwat,
        # cwat,press,q,pt,tp, acpcp
        if user_def:  
            for var in pvars:
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
            def_maps=set_def_maps()
            for fig in def_maps:
              # Optional if statement here can control evaluating one type of figure at a time.
              #if fig == '6h_apcp' or fig == '6h_acpcp':
              acc_field=def_maps[fig].get('acc_field',False)
              if (acc_field and fhr != '000') or (not acc_field): 
                level = def_maps[fig].get('lev')
                var   = def_maps[fig].get('pvar')
                hgt   = def_maps[fig].get('hgt')
                plot_wind = def_maps[fig].get('barbs',False)
                coord     = def_maps[fig].get('vc')
                print level,var, hgt,plot_wind, hgt
    
    
                # Grab winds from file if plotting the barbs
                if plot_wind or var == 'wind': 
                    u = ggf.get_ua_field(grib,level,coord,shortName='u')
                    v = ggf.get_ua_field(grib,level,coord,shortName='v')
                    winds=[u,v]
                else:
                    winds=None
    
                # Get the variable from file
                if var != 'wind':
                     field=ggf.get_ua_field(grib,level,coord,shortName=var)
                else: 
                     field=u
    
                height = None
                if hgt: 
                    height = ggf.get_ua_field(grib,level,coord,shortName='gh')
                print "Made it here" 

                mymap=maps.make_basemap(field,date,var,level,area_flag=outmap,
                                  winds=winds, plot_height=height,def_maps=def_maps) 
                mymap.set_bm()
                mymap.run()
                mymap.save_figure(outdir)
    
main()    
