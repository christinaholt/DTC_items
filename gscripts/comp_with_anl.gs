'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/HDRF/six06l.2014091118.hwrfprs_p.ctl'
'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/HDRF/edouard06l.2014091306.hwrfprs_p.ctl'
'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/HDRF/daniel04e.2012070406.hwrfprs_p.ctl'
'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/HDGF/six06l.2014091118.hwrfprs_p.ctl'
'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/HDGF/edouard06l.2014091306.hwrfprs_p.ctl'
'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/HDGF/daniel04e.2012070406.hwrfprs_p.ctl'
'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/HDRF/six06l.2014091118.hwrfprs_p_anl.ctl'
'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/HDRF/edouard06l.2014091306.hwrfprs_p_anl.ctl'
'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/HDRF/daniel04e.2012070406.hwrfprs_p_anl.ctl'
'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/HDGF/six06l.2014091118.hwrfprs_p_anl.ctl'
'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/HDGF/edouard06l.2014091306.hwrfprs_p_anl.ctl'
'open /pan2/projects/dtc-hurr/Christina.Holt/TNE_RRTMG_PCl/case_studies/ctl_files/HDGF/daniel04e.2012070406.hwrfprs_p_anl.ctl'

* Draws 5 day errors in red/blue color shades for several levels
* Panels are different levels: SFC, 1000, 850, 700, 500, 250
* New figs for new vars: TMP, Height, SPFH


levs.2=1000
levs.3=850
levs.4=700
levs.5=500
levs.6=250

storms.1='06L'
storms.2='06L'
storms.3='04E'

vars.1='TMPprs'
vars.2='HGTprs'
vars.3='SPFHprs'

varnm.1='TMP'
varnm.2='HGT'
varnm.3='SPFH'

expt.1='HDRF'
expt.2='HDGF'
panels('3 2')

scale.1='-20 20 2.5'
scale.2='-400 400 50'

scale='-21 30 3'
levels='set clevs -3 -2.5 -2 -1.5 -1 -.5 0 .5 1.0 1.5 2.0 2.5 3.0'
lats='-30 60'



*Loop over experiments (HDRF HDGF)
e=1
while e <= 1
*Loop over cases (storms)
   s=3
   while s <= 3
     if (s < 3); lons='265 355'; else ; lons='205 295' ; endif
*Loop over variables (TMP, HGT, SPFH). Each Gets a new fig
     v=1
    'set dfile 'e*s
    'set t 1'
     while v <=3
*Loop over levels (Each in a new panel)
       'enable print maps.gm'
       ofn = expt.e'_'storms.s'_'s'_'vars.v
       
       i=1
       while i <= 6 
          _vpg.i
          'set grads off'
          'set lon 'lons
          'set lat 'lats
*          'colormaps -map b2r -l ' scale.v
          fnum=e*s
          anum=fnum+6
         
          if (i = 1)
           'set z 1'
           
           if (v=1) ; var='tmp2m'; endif
           if (v=2) ; var='hgtsfc'; endif
           if (v=3) ; var='spfh2m'; endif
 

          say 'VAR 'var
          scale=makescale(var,v)
          'colormaps -map spectral -l ' scale


          'set gxout shaded'
          'd 'var'.'fnum'(t=121)'
          say result
          'q shades'
          say result
          'run cbarn'
          if v<3
             'set gxout contour'
             'set cint 'subwrd(scale,3)*2 ; 'set cmax 'subwrd(scale,2) ; 'set cmin 'subwrd(scale,1)
             'd 'var'.'anum'(t=1)'
          endif
          'draw title 'expt.e' Surface 'varnm.v' - 5 day'
         else 

          'set lev 'levs.i
          scale=makescale(vars.v,v)
          'colormaps -map spectral -l ' scale

          'set gxout shaded'
          'd 'vars.v'.'fnum'(t=121)'
          say result
          'q shades'
          say result
          'run cbarn'
          if v<3
             'set gxout contour'
             'set cint 'subwrd(scale,3)*2 ; 'set cmax 'subwrd(scale,2) ; 'set cmin 'subwrd(scale,1)
             'd 'vars.v'.'anum'(t=1)'
          endif
          'draw title 'expt.e' 'levs.i' hPa 'varnm.v' - 5 day'
         endif
       i=i+1
       endwhile 
*       exit
       'print'
       'disable print maps.gm'
       '!gxps -c -i maps.gm -o 'ofn'.ps'
       'clear'
     v=v+1
     endwhile 
   s=s+1
   endwhile 
e=e+1
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
          'd max(max('var'(t=121),x=1,x=441),y=1,y=361)'
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
          'd min(min('var'(t=121),x=1,x=441),y=1,y=361)'
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
