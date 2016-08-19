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
    # Graphics output data root -- include expt names here
    moad_dataroot=os.getenv('MOAD_DATAROOT')

    # ROTDIR should be a list of input directories

    date=os.getenv('START_TIME')     # @Y@m@d@H
    fhr=os.getenv('FCST_TIME') # 3 digit fcst hour
    grid_list=os.getenv('GRID_VX_LIST')
    vx_grid=grid_list.split(" ")

    grib1 = os.getenv("GRIBONE")
    grib2 = os.getenv("GRIBTWO")

    gribin=[grib1, grib2]


    user_def = os.getenv('USER_MAPS',False)

    # Set the output file location (template set in maps.py).
    outdir='/'.join([moad_dataroot, 'diffprd'])


    # Change projection if needed.
    for grid in vx_grid: 
        outmap = grid
        print grid
        
        # Wind rotation is a user choice, not necessarily a predefined choice, so is included here.
        wind_rot = {'G104': 'grid', 'G218': 'grid', 'G3': 'grid'}

        grib = []
        # Assumes that NCEP pre-defined grids will be defined with a leading "G"  
        if grid[0] == 'G':
           for exp in range(1,len(gribin)+1):
             newgrib = ''.join(['pgrbq', fhr, '.gfs.', date,'_', grid,'_',str(exp), '.grib2'])
             newgrib = '/'.join([outdir,newgrib])
             if not os.path.exists(outdir):
               os.makedirs(outdir)
             vx = regrib.new_grid(grid,gribin,newgrib,wind_rot.get(grid,None))
             vx.regrid()
             grib.append(newgrib)
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
                    u1=ggf.get_ua_field(grib[0],level,coord,shortName='u')
                    v1=ggf.get_ua_field(grib[0],level,coord,shortName='v')
                    u2=ggf.get_ua_field(grib[1],level,coord,shortName='u')
                    v2=ggf.get_ua_field(grib[1],level,coord,shortName='v')
                     
                    winds=[u1,v1,u2,v2]
                else:
                  winds=None
    
                # Get the variable from file
                if var != 'wind':
                     field1=ggf.get_ua_field(grib[0],level,coord,shortName=var)
                     field2=ggf.get_ua_field(grib[1],level,coord,shortName=var)
                     field = [field1, field2]
                else: 
                     field=winds
    
                height = None
                if hgt: 
                    height1 = ggf.get_ua_field(grib[0],level,coord,shortName='gh')
                    height2 = ggf.get_ua_field(grib[1],level,coord,shortName='gh')
                    height=[height1,height2]

                mymap=maps.make_basemap(field,date,var,level,area_flag=outmap,
                                  winds=winds, plot_height=height,def_maps=def_maps,diff=True) 
                mymap.set_bm()
                mymap.run()
                mymap.save_figure(outdir)
    
main()    
