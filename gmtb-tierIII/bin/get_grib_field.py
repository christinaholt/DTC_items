import pygrib 


def get_ua_field(fn,level,typeOfLevel,**kwargs):
    # Get the required grib field given a file name
    # fn: filename, var: variable to plot, lev: level
    # to plot in hPa, levtype: type of level in grib file
    # anlTime: optional analysis time 
    # for a sanity check, fcstHr: option forecast hour
    # in case a file contains multiples and not in fn. 

    # Set up args
    print "GET ARGS: ", locals()
    tmp    = locals()
    alist  = {}
    for i in tmp:
      if tmp[i] is not None and i != 'fn':
        print i , tmp[i]
        if i == 'level':
           alist[i] = int(tmp[i])
        elif i == 'kwargs':
           for j in tmp['kwargs']:
             if tmp['kwargs'][j] is not None and j != 'fn':
               alist[j]=tmp['kwargs'][j]
        else:
           alist[i] = tmp[i]
    print "ALIST ", alist
    grbs=pygrib.open(fn)
    grb = grbs.select(**alist)[0]
    print "PRINTING GRB: ", grb

    return grb


