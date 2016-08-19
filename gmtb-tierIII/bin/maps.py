import os,sys,shutil,math
import matplotlib as mpl
mpl.use('Agg')
from mpl_toolkits.basemap import Basemap, cm
import numpy as np
import matplotlib.pyplot as plt


def polar_stere(bounds, **kwargs):
#def polar_stere(lon_w, lon_e, lat_s, lat_n, **kwargs):
    '''Returns a Basemap object (NPS/SPS) focused in a region.

    lon_w, lon_e, lat_s, lat_n -- Graphic limits in geographical coordinates.
                                  W and S directions are negative.
    **kwargs -- Aditional arguments for Basemap object.

    '''
    lon_w,lon_e,lat_s,lat_n = bounds
    lon_0 = lon_w + (lon_e - lon_w) / 2.
    ref = lat_s if abs(lat_s) > abs(lat_n) else lat_n
    lat_0 = math.copysign(90., ref)
    proj = 'npstere' if lat_0 > 0 else 'spstere'
    prj = Basemap(projection=proj, lon_0=lon_0, lat_0=lat_0,
                          boundinglat=0, resolution='c')
    #prj = pyproj.Proj(proj='stere', lon_0=lon_0, lat_0=lat_0)
    lons = [lon_w, lon_e, lon_w, lon_e, lon_0, lon_0]
    lats = [lat_s, lat_s, lat_n, lat_n, lat_s, lat_n]
    x, y = prj(lons, lats)
    ll_lon, ll_lat = prj(min(x), min(y), inverse=True)
    ur_lon, ur_lat = prj(max(x), max(y), inverse=True)
    return Basemap(projection='stere', lat_0=lat_0, lon_0=lon_0,
                           llcrnrlon=ll_lon, llcrnrlat=ll_lat,
                           urcrnrlon=ur_lon, urcrnrlat=ur_lat, **kwargs)

class general_map(object):
    ''' Class that generates all of the generic parts of a map figure.'''
    def __init__(self):
        # Load the parameters dictionary that defines plotting parameters for various variables.
        if self.diff: 
          self.params = self.set_diff_params()
        else:
          self.params = self.set_fig_params()

    def set_diff_params(self):
        '''Definition of parameters for plotting difference maps. 
           The top level variable name must match the "shortName" used in the grib file.
           Each variable has a 
           subdictionary for various height levels to define either int/min/max values, 
           or contour values directly. Other options that the scripts use: 
               cbar: user-specified color tables
              scale: a scale factor (should start with an operator (*,/,+,-)
               unit: a string for unit if the one in the grib file is inappropriate
            varname: option for using a variable name different than that in the grib file
        ''' 
        params = {

                 'gh': {'250': {'int':   2, 'min': -24, 'max':  24},
                        '500': {'int':   2, 'min': -24, 'max':  24},
                        '700': {'int':   2, 'min': -24, 'max':  24},
                        '850': {'int':   2, 'min': -24, 'max':  24},
                        'cbar': 'seismic',
                        'unit': 'dam',
                        'scale': '/10'},

                 't': {'250': {'int':   1, 'min': -10, 'max':  10},
                       '500': {'int':   1, 'min': -10, 'max':  10},
                       '700': {'int':   1, 'min': -10, 'max':  10},
                       '850': {'int':   1, 'min': -10, 'max':  10},
                       '2m' : {'int':   1, 'min': -10, 'max':  10},
                       'any': {'int':   1, 'min': -10, 'max':  10},
                       'cbar': 'seismic',
                       'unit': 'C'},

                 '2t':  {'2': {'int':   1, 'min': -10, 'max':  10},
                       'cbar': 'seismic',
                       'unit': 'C',
                       'varname': 'temperature'},

                 '2d':  {'2': {'int':   1, 'min': -10, 'max':  10},
                       'cbar': 'seismic',
                       'unit': 'C',
                       'varname': 'dewpoint temperature'},

                 'r'  :{'850': {'int':  1, 'min':   -40, 'max': 40},
                        'cbar': plt.cm.terrain_r},

                 'ncpcp':{'0': {'default': True},
                        'cbar':cm.s3pcpn},

                 'acpcp':{'0': {'default': True},
                        'cbar':cm.s3pcpn},

                 'ncpcp':{'0': {'default': True},
                        'cbar':cm.s3pcpn},

                 'tp':{'0': {'default':   True},
                        'cbar':cm.s3pcpn},

                 'q': {'any': {'int': 0.5, 'min': -5 , 'max': 5},
                        'scale': '*1000',
                        'unit': 'g/kg',
                        'cbar':'terrain_r'},

                 'pwat':{'0': {'int': 0.5 ,'min':-5 ,'max': 5},
                        'scale': '*1000',
                        'unit': 'g m**-2',
                        'cbar':'terrain_r'},

                 'prate': {'0': {'int': 0.5, 'min': -5, 'max': 5},
                        'scale': '*1000',
                        'unit': 'g m**-2 s**-1',
                        'cbar':'terrain_r'},

                  'ULWRF': {'0': {'default': True},
                        'varname': 'ULWRF'}

                 }
        return params

    def set_fig_params(self):
        '''Definition of parameters for plotting standard maps. 
           The top level variable name must match the "shortName" used in the grib file.
           Each variable has a 
           subdictionary for various height levels to define either int/min/max values, 
           or contour values directly. Other options that the scripts use: 
               cbar: user-specified color tables
              scale: a scale factor (should start with an operator (*,/,+,-)
               unit: a string for unit if the one in the grib file is inappropriate
            varname: option for using a variable name different than that in the grib file
        ''' 
        params = {
                 'gh': {'250': {'int':  12, 'min': 888, 'max': 1122}, 
                        '500': {'int':   6, 'min': 462, 'max':  600},
                        '700': {'int':   3, 'min': 252, 'max':  324},
                        '850': {'int':   3, 'min':  90, 'max':  178},
                        'cbar': 'rainbow',
                        'unit': 'dam',
                        'scale': '/10'},

                 't': {'250': {'int':   5, 'min': -75, 'max': -10},
                       '500': {'int':   5, 'min': -50, 'max':  25},
                       '700': {'int':   5, 'min': -45, 'max':  45},
                       '850': {'int':   5, 'min': -45, 'max':  45},
                       '2m' : {'int':   5, 'min': -20, 'max':  60},
                       'any': {'int':   5, 'min': -75, 'max':  75},
                       'unit': 'C', 
                       'scale': '-273.15'},

                 '2t':  {'2': {'int':   2, 'min': -40, 'max':  60},
                       'unit': 'C',
                       'scale': '-273.15',
                       'varname': 'temperature'},

                 '2d':  {'2': {'int':   2, 'min': -40, 'max':  40},
                       'unit': 'C',
                       'scale': '-273.15',
                       'varname': 'dewpoint temperature',
                       'cbar': 'terrain_r'},

                 'absv':{'500': {'int':   1e-5, 'min': -20e-5, 'max':  20e-5},
                         'scale':'-7.292e-5*2*np.sin(self.lat*np.pi/160.)', 
                         'varname': 'Relative Vorticity',
                         'cbar': plt.cm.RdBu_r},

                 'w':{'700': {'int':   500, 'min': -10000, 'max': 10000}},

                 'wind':{'250': {'int':  20, 'min':  30, 'max': 220},
                         'any': {'int':   5, 'min':   5, 'max': 250}}, 
                 '10wind':{'10': {'int':  2, 'min': -50, 'max': 50}}, 
                 '10u':{'10': {'int':  2, 'min': -50, 'max': 50}}, 
                 '10v':{'10': {'int':  2, 'min': -50, 'max': 50}}, 

                 'r'  :{'850': {'int':  2, 'min':   0, 'max': 105},
                        'cbar': plt.cm.terrain_r},
                 'ncpcp':{'0': {'contours': [0,1,2.5,5,7.5,10,15,20,30,40,50,70,100,150,200,250,300,400,500,600,750]},
                        'cbar':cm.s3pcpn},
                 'acpcp':{'0': {'contours': [0,1,2.5,5,7.5,10,15,20,30,40,50,70,100,150,200,250,300,400,500,600,750]},
                        'cbar':cm.s3pcpn},
                 'ncpcp':{'0': {'contours': [0,1,2.5,5,7.5,10,15,20,30,40,50,70,100,150,200,250,300,400,500,600,750]},
                        'cbar':cm.s3pcpn},
                 'tp':{'0': {'contours': [0,1,2.5,5,7.5,10,15,20,30,40,50,70,100,150,200,250,300,400,500,600,750]},
                        'cbar':cm.s3pcpn},
                 'q': {'any': {'int': 2, 'min': 0 , 'max': 24 },
                        'scale': '*1000',
                        'unit': 'g/kg',
                        'cbar':'terrain_r'},
                 'pwat':{'0': {'int': 2 ,'min':0 ,'max': 24},
                        'scale': '*1000',
                        'unit': 'g m**-2',
                        'cbar':'terrain_r'},
                 'prate': {'0': {'int': 0.5, 'min': 0, 'max': 10},
                        'scale': '*1000',
                        'unit': 'g m**-2 s**-1',
                        'cbar':'terrain_r'},
                  'ULWRF': {'0': {'default': True},
                        'varname': 'ULWRF'}
                 }
        return params


    def draw_map(self):
        # Make figure
        lon=self.lon
        lat=self.lat
        fp=self.params 
        m=self.m
        plt.figure(figsize=(15,12))

        # Draw political boundaries
        m.drawcoastlines()
        m.drawstates()
        m.drawcountries()
        m.drawmapboundary()
        m.drawlsmask(ocean_color='0.8',land_color='white')

        # Draw lat/lon grid
        parallels = np.arange(-90.,90,10.)
        m.drawparallels(parallels,labels=[1,0,0,0],fontsize=10)
        meridians = np.arange(0.,360.,20.)
        m.drawmeridians(meridians,labels=[0,0,0,1],fontsize=10)

    def save_figure(self,outdir):
        fp=self.params 
        if not self.diff:
            field=self.field
        else:
            field=self.field[0]

        fp_field=fp.get(self.myvar, None)
       
        var = self.myvar
        lev   = str(field['level'])
        atime = field.analDate.strftime('%Y%m%d%H')
        grid  = self.area_flag

        if self.fhr is None: 
            fcsthr=field['forecastTime']
        else: 
            fcsthr=self.fhr

        vert_unit = self.coord_str(str(field['typeOfLevel']),title=False)
 
        # Output file name definition
        filename=''.join([var,lev,vert_unit,'_',grid,'_',atime,'_f','{:02d}'.format(fcsthr),'.png'])
          
        # Check to see if output location exists, if not, make it.
        if not os.path.exists(outdir):
             os.makedirs(outdir)

        plt.savefig('/'.join([outdir, filename]))
        plt.close()


    def fill_field(self):
        '''Color-fill the field of the figure being plotted'''
        field=self.field
        m=self.m
        fp=self.params
        x, y = m(self.lon,self.lat)
        
        # Choose either a specific level definition from the dictionary for contour info, or 
        # a generic set of parameters used for "any" level.
        check_lev = fp[self.myvar].get(str(self.level),None)
        if check_lev is not None: 
           var_lev = str(self.level)
        else: 
           var_lev = 'any' 

        # Get contour information from the dictionary. Should supply either min/max/int values, or 
        # a specific set of contour levels.
        min   =  fp[self.myvar][var_lev].get('min',None)
        max   =  fp[self.myvar][var_lev].get('max',None)
        int   =  fp[self.myvar][var_lev].get('int',None)
 
        # If min is not defined, try to get contours
        if min is None: levs = fp[self.myvar][var_lev].get('contours',None) 


        # Use "jet" colormap by default for full fields, or "bwr" for diff fields
        if not self.diff:
          colormap = fp[self.myvar].get('cbar',plt.cm.jet)
        else:
          colormap = fp[self.myvar].get('cbar',plt.cm.bwr)

        data = None
        if self.myvar == 'winds': 
            u=self.winds[0].values
            v=self.winds[1].values
            data=np.sqrt(u.dot(v))
            if self.diff: 
              u=self.winds[2].values
              v=self.winds[3].values
              data=data-np.sqrt(u.dot(v)) 
        else:
          # Determine how to apply the scaling factor based on the first item in the string
          scale =  fp[self.myvar].get('scale',None)
          data = self.scale_field(scale)

        if min is not None:
            clevs = np.arange(min,max,int)
        elif levs is not None:
            clevs = levs
        else: 
            clevs = None 

        # Plot on default levels if none are specified in fp. 
        if clevs == None: 
           cs = m.contourf(x,y,data,cmap=colormap)
        else: 
           cs = m.contourf(x,y,data,clevs,cmap=colormap)
        cbar=plt.colorbar(cs,orientation='vertical',shrink=0.8)

    def scale_field(self,scale=None): 
        field=self.field
 
        if self.diff:
           plotme=field[0].values-field[1].values
        else:
           plotme=field.values


        if scale is not None:
            if scale[0] == '/':   
               data=np.true_divide(plotme,float(scale[1:]))
            elif scale[0] == '-':
               data=np.subtract(plotme,eval(scale[1:]))
            elif scale[0] == '*':
               data=np.multiply(plotme,float(scale[1:]))
        else:
            data=plotme
        return data

    def contour_field(self,var,field):
        '''Draw field contours. Does not have to be the main field being processed. Mostly plotting height.'''
        m    = self.m
        fp   = self.params

        x, y = m(self.lon,self.lat)

        check_lev = fp[self.myvar].get(str(self.level),None)
        if check_lev is not None: 
           var_lev = str(self.level)
        else: 
           var_lev = 'any' 

        # Get contour information from the dictionary. Should supply either min/max/int values, or 
        # a specific set of contour levels.
        min   =  fp[self.myvar][var_lev].get('min',None)
        max   =  fp[self.myvar][var_lev].get('max',None)
        int   =  fp[self.myvar][var_lev].get('int',None)

        # If min is not defined, try to get contours
        if min is None: levs = fp[self.myvar][var_lev].get('contours',None)

        scale =  fp[var].get('scale',None)
        data = self.scale_field(scale)
           
        if min is not None:
            clevs = np.arange(min,max,int)
        elif levs is not None:
            clevs = levs
        else:
            clevs = None
        # Plot on default levels if none are specified in fp. 
        if clevs == None:
           cc = m.contour(x,y,data,colors='k')
        else:
           cc = m.contour(x,y,data,clevs,colors='k')

        plt.clabel(cc, fontsize=10, inline=1, fmt= '%4.0f')


    def wind_field(self):
        '''Plot the wind field in barbs. Masks are applied here to thin 
           the quantity of barbs plotted for clarity'''

        m=self.m
        fp=self.params
        u=self.winds[0].values
        v=self.winds[1].values
       
        if self.diff: 
          u=u-self.winds[2].values
          v=v=self.winds[3].values
 
        # Mask for winds. Different grids require slightly different masking
        maskarray = np.ones(u.shape)
        if self.area_flag != 'G104':
             maskarray[1::20,1::40] = 0
        else:
             maskarray[1::4,1::8] = 0
            
       
        mu = np.ma.masked_array(u, mask=maskarray) 
        mv = np.ma.masked_array(v, mask=maskarray) 
        x, y = m(self.lon,self.lat)
        barb_control = dict(height=0.6, width=0.3, emptybarb=0.07)
        self.barbs = m.barbs(x, y, mu, mv, barbcolor='k',pivot='middle',sizes=barb_control, linewidth=0.4, length=5)

    def coord_str(self,coord,title=True):
        '''Determine how to label the vertical coordinate based on the contents of the grib file, or other
           information.'''
        if not self.diff:
            field=self.field
        else:
            field=self.field[0]

        if coord == 'isobaricInhPa':
             vert_unit = str(field['pressureUnits'])
        elif coord == 'hybrid':
            if title: 
              vert_unit = "$\sigma$"
            else:
              vert_unit = "sigma"
        elif coord == 'surface': 
              vert_unit = 'm'
        else:
            # vert_unit = str(field.get('unitsOfFirstFixedSurface',False))
            vert_unit ='m'
        return vert_unit

    def plot_title(self):
         if not self.diff:
            field=self.field
         else:
            field=self.field[0]
         fp=self.params
         date = str(field['dataDate'])
         myvar = fp[self.myvar].get('varname',str(field['name']))
         atime = field.analDate.strftime('Analysis: %Y%m%d %H UTC')
         if field.validDate: 
            vtime = field.validDate.strftime('Valid: %Y%m%d %H UTC')
         else: 
            vtime = ''

         level = str(self.level)
         coord = str(field['typeOfLevel'])
         vert_unit = self.coord_str(coord)

         var_unit = fp[self.myvar].get('unit',field['units'])

         maptype = 'shaded'
         if self.fhr is not None: 
            fcsthr= self.fhr
         else: 
            try: 
               fcsthr=str(field['forecastTime'])
            except: 
               fcsthr=''

         if self.myvar == 'wind':
            title_str=str('wind magnitude (%s, %s)'%(var_unit,maptype))
         else:
            title_str=str('%s (%s, %s)'%(myvar,var_unit,maptype))
         #cycle=str(field['analysisTime'])
         plt.title('%s \nFcst Hr: %s' % (atime, fcsthr) , loc='left')
         plt.title('%s %s' % (level,vert_unit), position=(0.5, 1.04), fontsize=18)
         if self.height: 
             plt.title('%s \n Height (dam), contoured' % (title_str)
                   , loc = 'right')
         else:
             plt.title('%s' % title_str, loc = 'right')
         plt.xlabel('%s' % (vtime), fontsize=18, labelpad=40)

    def display_map(self):
        plt.show()

    def run(self):
        self.draw_map()
        self.fill_field()
        if self.height is not None: self.contour_field('gh',self.height)
        if self.winds is not None: self.wind_field()
        self.plot_title()


class make_basemap(general_map):
    ''' Class that defines the map projection for the data based on verification grids provided.'''
    def __init__(self,field,date,myvar,level,area_flag='glob',ncep_grid=None,
                 resolution=None, winds=None, plot_height=None, def_maps=None, fhr=None, diff=False):

        self.diff          = diff
        self.field         = field
        self.lat, self.lon = field[0].latlons()
        self.myvar         = myvar
        self.level         = level
        self.def_maps      = def_maps
        self.winds         = winds
        self.height        = plot_height
        self.area_flag     = area_flag
        self.fhr           = fhr
        super(make_basemap,self).__init__()

    def def_bm(self): 
        ''' Defines several common maps used for verification in a Python dict'''
        basemaps = { 
            'glob':      {'resolution': 'c','projection':'mill','lat_ts':10,'llcrnrlon':0,'urcrnrlon':357.5,'llcrnrlat':-90,'urcrnrlat':90},
            'G3':        {'resolution': 'c','projection':'mill','lat_ts':10,'llcrnrlon':0,'urcrnrlon':357.5,'llcrnrlat':-90,'urcrnrlat':90},
            'nh_mill':   {'resolution': 'c','projection':'mill','lat_ts':10,'llcrnrlon':0,'urcrnrlon':357.5,'llcrnrlat':  0,'urcrnrlat':90},
            'sh_mill':   {'resolution': 'c','projection':'mill','lat_ts':10,'llcrnrlon':0,'urcrnrlon':357.5,'llcrnrlat':-90,'urcrnrlat': 0},
            'trop_mill': {'resolution': 'c','projection':'mill','lat_ts':10,'llcrnrlon':0,'urcrnrlon':357.5,'llcrnrlat':-23,'urcrnrlat':23},
            'nps':       {'resolution': 'c','projection':'npstere','boundinglat':-0.268,'lon_0':-105},
            'sps':       {'resolution': 'c','projection':'spstere','boundinglat':   -60,'lon_0': 105},
            'G218':      {'resolution': 'c','projection':'lcc', 'lat_1':25, 'lat_2':25, 'lon_0':265,'rsphere':6371200,'llcrnrlon':226.514, 'llcrnrlat':12.190,'urcrnrlon':-49.420 , 'urcrnrlat':57.328},
            'G104':    [-147, -64, 10.8, 89.9],

        }
        return basemaps

    def set_bm(self):
        ''' Sets the Basemap object for creating the figure.'''
        base_map=self.def_bm()
        map_def=base_map.get(self.area_flag,None)
        print map_def
        if map_def is None: map_def=base_map.get('glob')
 
        if self.area_flag != 'G104': 
            self.m=Basemap(**map_def)
        else: 
            self.m=polar_stere(map_def,resolution='c')


