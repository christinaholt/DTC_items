'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/GFS/2012070406.mega_025.ctl'
'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/GFS/2014091118.mega_025.ctl'
'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/GFS/2014091306.mega_025.ctl'
'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/HDGF/daniel04e.2012070406.mega_025.ctl'
'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/HDGF/six06l.2014091118.mega_025.ctl'
'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/HDGF/edouard06l.2014091306.mega_025.ctl'
'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/HDRF/daniel04e.2012070406.mega_025.ctl'
'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/HDRF/six06l.2014091118.mega_025.ctl'
'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/HDRF/edouard06l.2014091306.mega_025.ctl'

panels('1 2')


storm.1='Daniel 04E'
storm.2='Edouard 06L'
storm.3='Edouard 06L'

lons.1='-150 -60'
lons.2='-95 10'
lons.3='-105 5'

lats.1='-25 60'
lats.2='-28 62'
lats.3='-25 65'
 
  f=1
  while f <= 3 
   
*     'enable print maps.gm'
     
     i=1
     while i <=21
        fhr=i*6-6
        _vpg.1
        ofn='HGT_MSLP_'f'_'i'.gif'
        'set parea .5 4.5 2 6.5' 
        'set dfile 'f
        'set lon 'lons.f
        'set lat 'lats.f
        'set lev 500'
        'set t 'i 
        'q time'
        stime=subwrd(result,3)
        
        'set gxout contour'
        'set grads off'

        cont='546 552 558 564 570 576 582 584 586 588 594 600 606 612 618'
        'q dims'
        say result
        'set cthick 8'
        'set ccolor 1'
        'set clevs 'cont
        'd HGTprs.'f'/10.'
        say result
        'set cthick 10'
        'set clevs 'cont
        'set ccolor 4'
        'd HGTprs.'f+3'/10.'
        'set cthick 10'
        'set ccolor 2'
        'set clevs 'cont
        'd HGTprs.'f+6'/10.'
        'draw title 500 hPa Height'
        'set strsiz 0.15'
        'draw string 0.5 1.5 'fhr' hr forecast'
  
        _vpg.2
        say result
        'set parea .5 4.5 2 6.5' 
        'set lon 'lons.f
        'set lat 'lats.f
        'set lev 500'
        'set t 'i
        'q time'
        stime=subwrd(result,3)
        
        'set grads off'

        cont='976 980 984 988 992 996 1000 1004 1008 1012 1016'
        'set cthick 8'
        'set ccolor 1'
        'set clevs 'cont
        'd PRMSLmsl.'f'/100.'
        say result
        'set cthick 10'
        'set ccolor 4'
        'set clevs 'cont
        'd PRMSLmsl.'f+3'/100.'
        'set ccolor 2'
        'set cthick 10'
        'set clevs 'cont
        'd PRMSLmsl.'f+6'/100.'

        'draw title MSLP'
        'set strsiz 0.15'
        'draw string 0.5 1.5 'stime ' for 'storm.f
*exit
        'printim  'ofn' white gif  x1100 y850'
        'clear'
        i=i+1
     endwhile
*        'disable print maps.gm'
*        '!gxps -c -i maps.gm -o 'ofn'.ps' 
     f=f+1
  endwhile


















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


