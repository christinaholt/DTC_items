'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/HDGF/daniel04e.2012070406.hwrfprs_m.ctl'
'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/HDGF/six06l.2014091118.hwrfprs_m.ctl'
'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/HDGF/edouard06l.2014091306.hwrfprs_m.ctl'
'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/HDRF/daniel04e.2012070406.hwrfprs_m.ctl'
'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/HDRF/six06l.2014091118.hwrfprs_m.ctl'
'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/HDRF/edouard06l.2014091306.hwrfprs_m.ctl'

* Left Panels are HDGF
* Right Panels are HDRF
* Rows are diff heights 1000, 850, 700
* Shading SPFH, Contouring TMP

levs.1='lev=850,lev=700'
levs.2='lev=700,lev=500'
levs.3='lev=500,lev=300'
*levs.5=500
*levs.6=250

storms.1='04E'
storms.2='06L'
storms.3='06L'

vars.1='(TMPsfc - TMPtrop)/TMPtrop'
*vars.1='TMPtrop-275.15'
vars.2='HPBLsfc'

varnm.1='Efficiency & 1000-950 RH'
varnm.2='PBL Height'
varnm.3='RH 500-300 hPa'

expt.1='HDRF'
expt.2='HDGF'
panels('2 2')

scale.1='-20 20 2.5'
scale.2='-400 400 50'

scale='-21 30 3'
levels='set clevs -3 -2.5 -2 -1.5 -1 -.5 0 .5 1.0 1.5 2.0 2.5 3.0'
lats='-30 60'

'enable print maps.gm'
s=1
* Loop over cases
while s<=3

* Loop over time
  ts=1
  while ts<=127
  fhr=ts-1
  ofn='MPI_'s'_'ts'.gif'
* Loop over rows
      r=1
      while r<=2
         vp=r*2-1
         say vp
         
         _vpg.vp
         say result
         'set parea 0.5 7.0 0.7 10.5'
         'set dfile 's
         'set t 'ts
         'set x 1 501'
         'set y 1 401'
         'set z 1'
         'q time'
         stime=subwrd(result,3)
         
         'set gxout shaded'
         'set grads off'
         scale.1='0.3 0.8 0.02'
*         scale.1='-80 -65 1'
         scale.2='100 1000 50'
         cntlev='80 90 100'
         'colormaps  -map spectral -l ' scale.r

         'd 'vars.r
         say result
         'run cbarn 0.7 1 7.3'
         say result
         if r=1
          'set gxout contour'
          'set clevs 'cntlev
          'd smth9(ave(RHprs , lev=1000 , lev=900))' 
         endif
         
*         'set gxout contour'
*         if r=1; 'set ccolor 1'; else ; 'set ccolor 10' ;endif 
*         'd 'vars.1
         'draw title HDGF 'varnm.r
         'set string 1 c'
         'set strsiz 0.15'
         'draw string 4.25 1.8 'stime' for 'storms.s' - 'fhr' hr fcst'
         
         vp=vp+1 
         _vpg.vp
         'set parea 0.5 7.0 0.7 10.5'
         'set dfile 's+3
         'set t 'ts
         'set x 1 501'
         'set y 1 401'
         'set z 1'
         'q time'
         
         'set gxout shaded'
         'set grads off'
         'colormaps -map spectral -l ' scale.r
         'd 'vars.r
         say result
         'run cbarn 0.7 1 7.3'
         say result
         
         if r=1
          'set gxout contour'
          'set clevs 'cntlev
          'd smth9(ave(RHprs , lev=1000 , lev=900))'
         endif
*         'set gxout contour'
*         if r=1; 'set ccolor 1'; else ; 'set ccolor 10' ;endif 
*         'd 'vars.1
         'draw title HDRF 'varnm.r
         'set string 1 c'
         'draw string 4.25 1.8 'stime' for 'storms.s' - 'fhr' hr fcst'
         
         r=r+1
      endwhile
      'printim  'ofn' white gif  x1100 y850'
*      'print'
*      exit
      'clear'
      ts=ts+12
   endwhile
  
*  'disable print maps.gm'
*  '!gxps -c -i maps.gm -o 'ofn'.ps'
  s=s+1
endwhile





scale='-3 3 .4'
colors='set ccols 0 17 19 20 21 22 23 24 25 26 27 28 29 30 31 32'
levels='set clevs -3 -2.6 -2.2 -1.8 -1.4 -1 -.6 -.2 0 .2 .6 1 1.4 1.8 2.2 2.6 3'


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


function makescale(var,v)
          if v=1 ; rnd=10; endif
          if v=2 ; rnd=100 ; endif
          if v=3 ; rnd=0.0001; endif
          l=1
          fl=1
          'd max(max('var'(t=121),x=1,x=501),y=1,y=401)'
          say result
          while (fl = 1)
              ln=sublin(result,l)
              say ln
              fw=subwrd(ln,1)
              if (fw = 'Result')
                 fl = 0 
                 hi=subwrd(ln,4)
              endif
              l=l+1
              say 'l ' l
          endwhile
          hi=math_int(hi/rnd)*rnd
          
          say 'HI 'hi
          l=1
          fl=1
          'd min(min('var'(t=121),x=1,x=501),y=1,y=401)'
          while (fl = 1)
              ln=sublin(result,l)
              say ln
              fw=subwrd(ln,1)
              if (fw = 'Result')
                 fl = 0 
                 low=subwrd(ln,4)
              endif
              l=l+1
              say 'l ' l
          endwhile
          low=math_int(low/rnd)*rnd
          say 'LOW 'low
          shades=20
          if v<3 
             if hi-low < 20 ; shades = hi-low-1 ; endif
             incr=math_int((hi-low)/shades)
             say 'incr 'incr
          else
             incr=(hi-low)/shades
             say 'incr 'incr
          endif
          say 'HI, LOW, INCR 'hi' 'low' 'incr
          scale=low' 'hi' 'incr
          return scale
