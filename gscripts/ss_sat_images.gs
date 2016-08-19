'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/HDGF/daniel04e.2012070406.hwrfsat_m.ctl'
'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/HDGF/six06l.2014091118.hwrfsat_m.ctl'
'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/HDGF/edouard06l.2014091306.hwrfsat_m.ctl'
'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/HDRF/daniel04e.2012070406.hwrfsat_m.ctl'
'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/HDRF/six06l.2014091118.hwrfsat_m.ctl'
'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/HDRF/edouard06l.2014091306.hwrfsat_m.ctl'


* Stormscale satellite plots

panels('1 2')


storm.1='Daniel 04E'
storm.2='Edouard 06L'
storm.3='Edouard 06L'

sat.1=IR
sat.2=Vis
 
v=1
while v <= 1
  f=1
  while f <= 3 
   
     if v = 1
        if f <2 ;  var='SBT114toa' ; else; var = 'SBT124toa'; endif
        cset='IR2'
     else
        if f <2 ;  var='SBT112toa' ; else; var = 'SBT122toa'; endif
        cset='vis'
     endif
     'enable print maps.gm'
     
     i=1
     while i <= 21
        fhr=i*6-6
         
        ofn=sat.v'_ss_sat_'f'_'i'.gif'
        _vpg.1
        'set parea .5 4.5 2 6.5' 
        'set dfile 'f
        'set t 'i 
        'set x 1 501'
        'set y 1 401'
        'set z 1'
        'q time'
        stime=subwrd(result,3)
        
        'set gxout shaded'
        'set grads off'
        'colorset 'cset
        'q dims'
        say result
        'd 'var'-273.15'
        say result
        'run cbarn 0.7 1 4.9 4.25'
        'draw title HDGF 'sat.v
        'set strsiz 0.15'
        'draw string 0.5 1.5 'fhr' hr Forecast'
  
        _vpg.2
        say result
        'set parea .5 4.5 2 6.5' 
        'set dfile 'f+3
        'set t 'i
        'set z 1'
        'set x 1 501'
        'set y 1 401'
        'q time'
        stime=subwrd(result,3)
        
        'set gxout shaded'
        'set grads off'
        'colorset 'cset
        'q dims'
        say result
        'd 'var'-273.15'
        say result
        'run cbarn 0.7 1 4.9 4.25'
        'draw title HDRF 'sat.v
        'set strsiz 0.15'
        'draw string 0.5 1.5 'stime ' for 'storm.f
        'printim  'ofn' white gif  x1100 y850'
*exit
        'clear'
        i=i+2
     endwhile
*        'disable print maps.gm'
*        '!gxps -c -i maps.gm -o 'ofn'.ps' 
     f=f+1
  endwhile
v=v+1
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


