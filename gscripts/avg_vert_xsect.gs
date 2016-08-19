'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/HDGF/six06l.2014091118.mega_025.ctl'
'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/HDGF/edouard06l.2014091306.mega_025.ctl'
'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/HDGF/daniel04e.2012070406.mega_025.ctl'
'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/HDRF/six06l.2014091118.mega_025.ctl'
'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/HDRF/edouard06l.2014091306.mega_025.ctl'
'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/HDRF/daniel04e.2012070406.mega_025.ctl'
'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/GFS/2012070406.mega_025.ctl'
'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/GFS/2014091118.mega_025.ctl'
'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/GFS/2014091306.mega_025.ctl'

* Draw a vertical cross section of the latitudinal average of several different variables

panels('2 2')



scale='-35 30 5'
colors='set ccols 16 17 18 19 22 23 25 26 27 28 29 30 31 32'
levels='set clevs -3 -2.5 -2 -1.5 -1 -.5 0 .5 1.0 1.5 2.0 2.5 3.0'

_vpg.1

'set gxout shaded'
'set grads off'
'set lon -95 5'
'set z 1 26'
'set lat 15'
'colormaps -map b2r -l ' scale
say 'RH 'result
colors
levels
'd (-mean(spfhprs.1(t=1), lat=-25, lat=60) + mean(spfhprs.1(t=21), lat=-25, lat=60)) * 1e-4'
say result
'q shades'
say result
'run cbarn'
'draw title HDGF RH Ave'


_vpg.2

'set gxout shaded'
'set grads off'
'set lon -95 5'
'set z 1 26'
'set lat 15'
'colormaps -map b2r -l ' scale
colors
levels
'd (-mean(spfhprs.4(t=1), lat=-25, lat=60) + mean(spfhprs.4(t=21), lat=-25, lat=60)) * 1e-4'
'run cbarn'
'd title HDRF RH Ave'

exit
scale='-3 3 .4'
colors='set ccols 0 17 19 20 21 22 23 24 25 26 27 28 29 30 31 32'
levels='set clevs -3 -2.6 -2.2 -1.8 -1.4 -1 -.6 -.2 0 .2 .6 1 1.4 1.8 2.2 2.6 3'

_vpg.3

'set gxout shaded'
'set grads off'
'set lon -95 5'
'set z 1 26'
'set lat 15'
'colormaps -map b2r -l ' scale
say  'TMP COLORS: 'result
colors
levels
'd -mean(tmpprs.1(t=1), lat=-25, lat=60) + mean(tmpprs.1(t=21), lat=-25, lat=60)'
'run cbarn'
'd title HDGF Temp Ave'

_vpg.4

'set gxout shaded'
'set grads off'
'set lon -95 5'
'set z 1 26'
'set lat 15'
'colormaps -map b2r -l ' levels
colors
levels
'd -mean(tmpprs.4(t=1), lat=-25, lat=60) + mean(tmpprs.4(t=21), lat=-25, lat=60)'
'run cbarn'
'd title HDRF Temp Ave'

* o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ 
* o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ o~ 
function panels(args)
* panels.gsf
* 
* This function evenly divides the real page into a given number of rows
* and columns then creates global variables that contain the 'set vpage' 
* commands for each panel in the multi-panel plot. 
*
* Usage: panels(rows cols)
*
* Written by JMA March 2001
*

* Get arguments
  if (args='')
    say 'panels requires two arguments: the # of rows and # of columns'
    return
  else
    nrows = subwrd(args,1)
    ncols = subwrd(args,2)
  endif

* Get dimensions of the real page
  'query gxinfo'
  rec2  = sublin(result,2)
  xsize = subwrd(rec2,4)
  ysize = subwrd(rec2,6)

* Calculate coordinates of each vpage
  width  = xsize/ncols
  height = ysize/nrows
  row = 1
  col = 1
  panel = 1
  while (row <= nrows)
    yhi = ysize - (height * (row - 1))
    if (row = nrows)
      ylo = 0
    else
      ylo = yhi - height
    endif
    while (col <= ncols)
      xlo = width * (col - 1)
      xhi = xlo + width
      _vpg.panel = 'set vpage 'xlo'  'xhi'  'ylo'  'yhi
      panel = panel + 1
      col = col + 1
    endwhile
    col = 1
    row = row + 1
  endwhile
  return

* THE END *

