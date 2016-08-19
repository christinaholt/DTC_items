'open edouard.ctl'
'open edouard_sat.ctl'

'set grads off'
'set mproj latlon'

'set lat -30 60'
'set lon -100 10'
*'set lat -30 60'
*'set lon -180 10'


'set gxout shaded'
*'enable print map.gm'


*'set clevs 190 200 210 220 230 240 250 260 270 280'
*'set clevs 190 200 210 220 230 240 250 260 270 280 290 300'
*'set ccols 9 14 4 11 5 13 3 12 7 12 0 0 6'
*'set ccols 9 14 4 11 5 13 3 12 7 12 8 2 6'

'set rgb 55 176 226 255'

'set clevs 190'
'set ccols 55 55'


*'d hgtprs'
*'d mag(ugrd10m,vgrd10m)'

* Shade in d01
'd hgtprs.1'

* Draw d02
cenlat = 16.7
cenlon = -37.7

is = 12/2
lat1 = cenlat - is
lat2 = cenlat + is

lon1 = cenlon - is
lon2 = cenlon + is

'q ll2xy 'lon1' 'lat1
x1=subwrd(result,1)
y1=subwrd(result,2)
'q ll2xy 'lon2' 'lat2
x2=subwrd(result,1)
y2=subwrd(result,2)

'set line 4 1 12'
'draw rec 'x1' 'y1' 'x2' 'y2

* Draw d03
is = 7.1/2
lat1 = cenlat - is
lat2 = cenlat + is

lon1 = cenlon - is
lon2 = cenlon + is

'q ll2xy 'lon1' 'lat1
x1=subwrd(result,1)
y1=subwrd(result,2)
'q ll2xy 'lon2' 'lat2
x2=subwrd(result,1)
y2=subwrd(result,2)

'set line 14 1 12'
'draw rec 'x1' 'y1' 'x2' 'y2

* Draw ghost outer domain
is = 20/2
lat1 = cenlat - is
lat2 = cenlat + is

lon1 = cenlon - is
lon2 = cenlon + is

'q ll2xy 'lon1' 'lat1
x1=subwrd(result,1)
y1=subwrd(result,2)
'q ll2xy 'lon2' 'lat2
x2=subwrd(result,1)
y2=subwrd(result,2)

'set line 1 2 12'
'draw rec 'x1' 'y1' 'x2' 'y2

* Draw ghost inner
is = 10/2
lat1 = cenlat - is
lat2 = cenlat + is

lon1 = cenlon - is
lon2 = cenlon + is

'q ll2xy 'lon1' 'lat1
x1=subwrd(result,1)
y1=subwrd(result,2)
'q ll2xy 'lon2' 'lat2
x2=subwrd(result,1)
y2=subwrd(result,2)

'set line 1 2 12'
'draw rec 'x1' 'y1' 'x2' 'y2

* Draw ATL ocean domain
lat1 = 10  
lat2 = 47.5

lon1 = -98.5
lon2 = -15.3

'q ll2xy 'lon1' 'lat1
x1=subwrd(result,1)
y1=subwrd(result,2)
'q ll2xy 'lon2' 'lat2
x2=subwrd(result,1)
y2=subwrd(result,2)

'set line 2 1 12'
'draw rec 'x1' 'y1' 'x2' 'y2

** Draw EP ocean domain
*lat1 = 5.0
*lat2 = 5.0 + 449/12
*
*lon1=-167.5
*lon2=lon1 + 869/12
*
*'q ll2xy 'lon1' 'lat1
*x1=subwrd(result,1)
*y1=subwrd(result,2)
*'q ll2xy 'lon2' 'lat2
*x2=subwrd(result,1)
*y2=subwrd(result,2)

'set line 2 1 12'
'draw rec 'x1' 'y1' 'x2' 'y2

'printim HWRF_doms.jpg white'
*'disable print map.gm'
*'!gxps -c -i map.gm -o HWRFdomains.ps'
*'!ps2pdf HWRFdomains.ps HWRFdomains.pdf'
