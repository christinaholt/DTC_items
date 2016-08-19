;************************************************
; load required libraries, envars, and begin
;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"


; infile
if (.not. isvar("infile")) then
  print("ERROR: 'infile' not set.")
  exit
end if

; season
if (.not. isvar("season")) then
  print("ERROR: 'season' not set.")
  exit
end if

; init hr
if (.not. isvar("inithr")) then
  print("ERROR: 'inithr' not set.")
  exit
end if

; forecast hr
if (.not. isvar("fcsthr")) then
  print("ERROR: 'fcsthr' not set.")
  exit
end if

; png file
if (.not. isvar("png_file")) then
  print("ERROR: 'png_file' not set.")
  exit
end if

; config
if (.not. isvar("config")) then
  print("ERROR: 'config' not set.")
  exit
end if

; config
if (.not. isvar("grid")) then
  print("ERROR: 'grid' not set.")
  exit
end if

begin

;************************************************
; read in netcdf file
;************************************************
nc_file   = addfile("/d4/projects/NEMS/AOP2013/scripts/met_config/nmbpcp_d02_03_03.nc","r")

file_atts = getvaratts(nc_file)

series_file  = addfile(""+infile+"","r")

series_atts  = getvaratts(series_file)
printVarSummary(series_atts)

fcst_var   = series_file@$series_atts(6)$
fcst_lev   = series_file@$series_atts(7)$
latin1     = series_file@$series_atts(13)$
latin2     = series_file@$series_atts(14)$
lov        = series_file@$series_atts(19)$

; OBAR used for ThompsonMP since both NAMOC (FBAR) and ThompsonMP (OBAR) all in same nc file (NAMOCThompsonMP)
if (config .eq. "NAMOC") then  
   metric            = series_file->series_cnt_FBAR(:,:)
else if (config .eq. "ThompsonMP") then
   metric            = series_file->series_cnt_OBAR(:,:)
else if (config .eq. "NAMOCThompsonMP") then
   metric            = series_file->series_cnt_ME(:,:)
end if
end if
end if
metric@_FillValue = -9999

lon2d             = series_file->lon(:,:)
lat2d             = series_file->lat(:,:)

metric@lat2d  = lat2d
metric@lon2d  = lon2d

min_met    = min(metric)
max_met    = max(metric)

nlat       = dimsizes(lat2d(:,0))
nlon       = dimsizes(lon2d(0,:))

xdim       = nlat - 1
ydim       = nlon - 1

;************************************************
; set corner points
;************************************************
x_ll                  = 0
y_ll                  = 0
x_ur                  = nlat-1
y_ur                  = nlon-1

; set the lat/lons of the corner points
lat_ll                = lat2d(x_ll,y_ll)
lon_ll                = lon2d(x_ll,y_ll)
lat_ur                = lat2d(x_ur,y_ur)
lon_ur                = lon2d(x_ur,y_ur)

;************************************************
; create plot
;************************************************
wks = gsn_open_wks("png",""+png_file+"")

gsn_define_colormap(wks,"WhViBlGrYeOrRe")

res                            = True

res@gsnFrame                   = False
res@gsnMaximize                = True
res@gsnPaperOrientation        = "landscape"

; map transformation
res@mpLimitMode = "Corners"
res@mpLeftCornerLatF  = lat_ll
res@mpLeftCornerLonF  = lon_ll
res@mpRightCornerLatF = lat_ur
res@mpRightCornerLonF = lon_ur

; map projection
res@mpProjection               = "LambertConformal"
res@mpLambertParallel1F        = latin1
res@mpLambertParallel2F        = latin1
res@mpLambertMeridianF         = lov

; map resources
res@mpPerimOn                  = True
res@mpPerimLineThicknessF      = 4.0
res@gsnDraw                    = False
res@mpDataBaseVersion = "Ncarg4_1"
res@mpDataSetName = "Earth..4"
res@mpOutlineDrawOrder         = "PostDraw"
res@mpOutlineBoundarySets      = "GeophysicalAndUSStates"
res@mpUSStateLineThicknessF    = 1.6
res@mpGeophysicalLineThicknessF = 2.0
res@mpFillOn                   = True
res@mpGridAndLimbOn            = False

res@cnFillOn            = True         ; turn on contour fill
res@cnFillMode          = "RasterFill"
res@gsnSpreadColors     = True
res@gsnSpreadColorStart = 0

res@cnLinesOn          = False        ; turn off contour lines
res@cnLineLabelsOn     = False        ; turn off line labels
res@cnInfoLabelOn      = False        ; turn off info label
res@lbBoxLinesOn       = False        ; turn off labelbar box lines

res@lbLabelAutoStride          = True              ; nice lb labels
res@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour levels
res@lbTitlePosition            = "Bottom"
res@lbAutoManage               = False
res@pmTickMarkDisplayMode      = "NoCreate"
res@pmLabelBarDisplayMode      = "ALWAYS"
res@pmLabelBarHeightF          = .08
res@pmLabelBarSide             = "bottom"
res@pmLabelBarOrthogonalPosF   = 0.027
res@lbTitleFontHeightF         = .01          ; make title smaller

if (fcst_var .eq. "SHTFL") then
;  gsn_define_colormap(wks,"WhViBlGrYeOrRe")
  if (season .eq. "summer" .or. season .eq. "spring") then
    res@cnFillColors               = (/ 2,3,6,9,12,15,18,22,28,32,39,42,45,50,53,57,60,64,67,69,72,75,78,81,84,87,89,92,94,97,102,102 /)
    res@cnMinLevelValF             =  -50             ; set min contour level
    res@cnMaxLevelValF             =  500              ; set max contour level
    res@cnLevelSpacingF            =  25               ; set contour spacing
    res@lbTitleString              = "Wm~S~-2~N~"
    res@cnLabelBarEndStyle         = "ExcludeOuterBoxes"
  else if (season .eq. "annual") then
    res@cnFillColors               = (/ 2,3,6,9,12,15,18,22,28,32,39,42,45,50,53,57,60,64,67,69,72,75,78,81,84,87,89,92,94,97,102,102 /)
    res@cnMinLevelValF             =  -100             ; set min contour level
    res@cnMaxLevelValF             =  420              ; set max contour level
    res@cnLevelSpacingF            =  20               ; set contour spacing
    res@lbTitleString              = "Wm~S~-2~N~"
    res@cnLabelBarEndStyle         = "ExcludeOuterBoxes"
  else if (season .eq. "fall" .or. season .eq. "winter") then
;    res@cnFillColors               = (/ 2,3,6,9,12,15,18,22,28,32,39,42,45,50,53,57,60,64,67,69,72,75,78,81,84,87,89,92,94,97,102,102 /)
;    res@cnMinLevelValF             =  -100             ; set min contour level
;    res@cnMaxLevelValF             =  340              ; set max contour level
;    res@cnLevelSpacingF            =  20               ; set contour spacing
;    res@lbTitleString              = "Wm~S~-2~N~"
;    res@cnLabelBarEndStyle         = "ExcludeOuterBoxes"
    gsn_define_colormap(wks,"testcmap")
    res@cnFillColors               = (/ 91,98,105,112,118,129,138,145,150,156,162,168,173,178,184,193,200,200 /)
    res@cnMinLevelValF             =  -25             ; set min contour level
    res@cnMaxLevelValF             =  350              ; set max contour level
    res@cnLevelSpacingF            =  25               ; set contour spacing
    res@lbTitleString              = "Wm~S~-2~N~"
    res@cnLabelBarEndStyle         = "ExcludeOuterBoxes"
  end if
  end if
  end if
else if (fcst_var .eq. "LHTFL") then
  gsn_define_colormap(wks,"testcmap")
  if (season .eq. "summer") then
    res@cnFillColors               = (/ 81,91,98,105,112,118,129,138,145,150,156,162,168,173,178,184,193,200,200 /)
    res@cnMinLevelValF             =  -20              ; set min contour level
    res@cnMaxLevelValF             =  150              ; set max contour level
    res@cnLevelSpacingF            =  10               ; set contour spacing
    res@lbTitleString              = "Wm~S~-2~N~"
    res@cnLabelBarEndStyle         = "ExcludeOuterBoxes"
  else if (season .eq. "winter") then
    res@cnFillColors               = (/ 81,91,98,105,112,118,129,138,145,150,156,162,168,173,178,184,193,200,200 /)
    res@cnMinLevelValF             =  -20              ; set min contour level
    res@cnMaxLevelValF             =  150              ; set max contour level
    res@cnLevelSpacingF            =  10               ; set contour spacing
    res@lbTitleString              = "Wm~S~-2~N~"
    res@cnLabelBarEndStyle         = "ExcludeOuterBoxes"
  end if
  end if
else if (fcst_var .eq. "DSWRF") then
  gsn_define_colormap(wks,"WhViBlGrYeOrRe")
  res@cnLabelBarEndStyle         = "ExcludeOuterBoxes"
;  res@cnFillColors               = (/ 2,3,6,9,12,15,18,22,28,39,42,45,50,53,57,60,64,67,69,72,75,78,81,84,87,89,92,94,97,102 /)
;  res@cnMinLevelValF             = 300           ; set min contour level
;  res@cnMinLevelValF             = 500             ; set max contour level
;  res@cnMaxLevelValF             = 1000             ; set max contour level
;  res@cnLevelSpacingF            = 25               ; set contour spacing
  res@cnMinLevelValF             = 150             ; set min contour level
  res@cnMaxLevelValF             = 650             ; set max contour level
  res@cnLevelSpacingF            = 25              ; set contour spacing
  res@lbTitleString              = "Wm~S~-2~N~"
else if (fcst_var .eq. "DLWRF") then
  gsn_define_colormap(wks,"WhViBlGrYeOrRe")
  res@cnLabelBarEndStyle         = "ExcludeOuterBoxes"
  res@cnFillColors               = (/ 2,4,8,12,21,36,46,50,57,64,71,77,82,87,91,94,102 /)
  res@cnMinLevelValF             = 100           ; set min contour level
  res@cnMaxLevelValF             = 500             ; set max contour level
  res@cnLevelSpacingF            = 25               ; set contour spacing
;  res@cnMinLevelValF             = 160           ; set min contour level
;  res@cnMaxLevelValF             = 400             ; set max contour level
;  res@cnLevelSpacingF            = 15               ; set contour spacing
  res@lbTitleString              = "Wm~S~-2~N~"
else if (fcst_var .eq. "USWRF") then
  gsn_define_colormap(wks,"WhViBlGrYeOrRe")
  res@cnLabelBarEndStyle         = "ExcludeOuterBoxes"
  res@cnFillColors               = (/ 2,3,6,9,12,15,18,22,28,32,39,42,45,50,53,57,60,64,67,69,72,75,78,81,84,87,89,92,94,97,102,102 /)
  res@cnMinLevelValF             = 0           ; set min contour level
  res@cnMaxLevelValF             = 500             ; set max contour level
  res@cnLevelSpacingF            = 20               ; set contour spacing
  res@lbTitleString              = "Wm~S~-2~N~"
else if (fcst_var .eq. "ULWRF") then
  gsn_define_colormap(wks,"WhViBlGrYeOrRe")
  res@cnLabelBarEndStyle         = "ExcludeOuterBoxes"
  res@cnFillColors               = (/ 2,4,8,12,21,36,46,50,57,64,71,77,82,87,91,94,102 /)
;  res@cnMinLevelValF             = 200           ; set min contour level
;  res@cnMaxLevelValF             = 520             ; set max contour level
  res@cnMinLevelValF             = 300           ; set min contour level
  res@cnMaxLevelValF             = 700             ; set max contour level
  res@cnLevelSpacingF            = 25               ; set contour spacing
  res@lbTitleString              = "Wm~S~-2~N~"
else if (fcst_var .eq. "HPBL") then
  gsn_define_colormap(wks,"amwg256")
  res@cnLabelBarEndStyle         = "ExcludeOuterBoxes"
  if (season .eq. "summer" .or. season .eq. "spring") then
    res@cnFillColors               = (/ 2,7,14,18,36,42,47,59,70,82,91,101,112,117,122,128,129,145,154,161,168,177,184,193,200,209,220,226,234,241,249,255 /)
    res@cnMaxLevelValF             =  3000             ; set max contour level
    res@cnMinLevelValF             =  0             ; set min contour level
    res@cnLevelSpacingF            =  100               ; set contour spacing
    res@lbTitleString              = "(m)"
  else if (season .eq. "annual" .or. season .eq. "fall") then
    res@cnFillColors               = (/ 2,8,15,31,39,50,68,84,106,121,128,129,145,156,167,179,193,202,211,225,241,255 /)
    res@cnMinLevelValF             =  0             ; set min contour level
    res@cnMaxLevelValF             =  2000             ; set max contour level
    res@cnLevelSpacingF            =  100               ; set contour spacing
    res@lbTitleString              = "(m)"
  else if (season .eq. "winter") then
    res@cnMinLevelValF             =  100             ; set min contour level
    res@cnMaxLevelValF             =  1500             ; set max contour level
    res@cnLevelSpacingF            =  50               ; set contour spacing
    res@lbTitleString              = "(m)"
  end if
  end if
  end if
else
  print("An unrecognized variable was requested.")
end if
end if
end if
end if
end if
end if
end if

; main title
res@tiMainString               = ""+config+": Mean "+fcst_var+" "+fcst_lev+""
res@tiMainFont                 = "helvetica-bold"
res@tiMainFontHeightF          = 0.014
res@tiMainOffsetYF             = -0.01
res@gsnRightString             = ""
res@gsnLeftString              = ""

map = gsn_csm_contour_map(wks,metric,res)

;************************************************
; list and define vx. subregion names
;************************************************
; number of masks/vx. regions
;nmask        = 14
nmask        = 2

region_names = new((/nmask/),"string")
;region_names = (/"APL","GMC","GRB","LMV","MDW","NEC","NMT",\
;                 "NPL","NWC","SEC","SMT","SPL","SWC","SWD"/)
region_names = (/"EAST", "WEST"/)

; set res for masks
poly_res                       = True

; title specs
poly_res@tiMainOn              = False

; poly specs
poly_res@gsFillColor           = (/"transparent"/)
poly_res@gsEdgesOn             = True       ; draw border around polygons
poly_res@gsEdgeColor           = 1
poly_res@gsEdgeThicknessF      = 3

dum = new(nmask,"graphic")
do npoly = 0,nmask-1
  var        = region_names(npoly)
  nrow       = numAsciiRow("/d3/personal/harrold/regions/poly/"+var+".poly")
  ncol       = numAsciiCol("/d3/personal/harrold/regions/poly/"+var+".poly")
  poly       = asciiread("/d3/personal/harrold/regions/poly/"+var+".poly",(/nrow,ncol/),"float")
  poly_lon   = poly(:,1)
  poly_lat   = poly(:,0)
  dum(npoly) = gsn_add_polygon(wks,map,poly_lon,poly_lat,poly_res)

  delete([/var,nrow,ncol,poly,poly_lon,poly_lat/])
end do

; add caption
  txcap               = True                     ; text mods desired
  txcap@txFontHeightF = 0.018                     ; font smaller. default big

  gsn_text_ndc(wks,"Season="+season+"  Grid="+grid+"  Init="+inithr+"  Fcst Hr="+fcsthr+"h",0.29,0.18,txcap)

draw(map)
frame(wks)

end
