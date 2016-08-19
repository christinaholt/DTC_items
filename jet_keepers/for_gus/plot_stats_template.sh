#!/bin/ksh

set -x

outloc=/pan2/projects/dtc-hurr/Christina.Holt/H215/figures
inloc=/pan2/projects/dtc-hurr/Christina.Holt/H215/MET_output
vx=hwrf_vx

#for ATCF in H215 H15Z; do
for ATCF in H215; do
#for ATCF in HDGF HDRF; do
tag='only_2'
text_fn=singles_stats_${ATCF}${tag}.txt
rm ${text_fn}

for stat in RMSE ME; do
  if [[ ${stat} = 'ME' ]] ; then
    colormaps=BlWhRe
  else 
    colormaps=gui_default
  fi


#for var in SPFH HGT RH TMP VGRD UGRD ; do
for var in SPFH TMP; do
#for var in VGRD UGRD ; do
#for var in PRMSL; do
  case $var in 
	HGT)
          unit='(gpm)'
          if [[ ${stat} = 'ME' ]]; then
              colorlevs='(/-35.0, -30.0,-25.0,-20.0,-15.0,-10.0,-5.0,-3.0,-1.0,0,1.0,3.0,5.0,10.0,15,20.0,25.0,30.0,35.0/)'
          else
              colorlevs='(/2.0,4.0,6.0,8.0,10.0,14.0,18.0,22.0,26.0,30.0,34.0,38.0,42.0,46.0/)'
          fi
	  ;;
	RH)
    	  unit='(%)'
    	  if [[ ${stat} = 'ME' ]] ; then
    	      colorlevs='(/-50.0,-40.0,-30.0,-20.0,-10.0,-5,-3,-1,0,1,3,5,10.0,20.0,30.0,40.0,50.0/)'
    	  else
    	      colorlevs='(/4.0,8.0,12.0,16.0,20,24.0,28.0,32.0,34.0,40.0,45.0,50.0/)'
    	  fi
	  ;;
	TMP)
    	  unit='(K)'
    	  if [[ ${stat} = 'ME' ]] ; then
    	      colorlevs='(/-2.0,-1.60,-1.20,-0.80,-.4,0,0.4,0.80,1.2,1.6,2.0/)'
    	  else
    	      colorlevs='(/0.0,0.5,1.0,2.0,2.5,3.0,3.5,4.0,5.0,8.0/)'
    	  fi
	  ;;
	VGRD|UGRD)
    	  unit='(m/s)'
    	  if [[ ${stat} = 'ME' ]] ; then
    	      colorlevs='(/-15.0,-12.0,-9.0,-6.0,-3.0,-2,-1,-0.5,0,0.5,1,2,3.0,6.0,9.0,12.0,15.0/)'
    	  else
    	      colorlevs='(/0.0,1.0,2.0,4.0,6.0,8.0,10.0,12.0,14.0,18.0,20.0/)'
    	  fi
	  ;;
	WIND)
    	  unit='(m/s)'
    	  if [[ ${stat} = 'ME' ]] ; then
    	      colorlevs='(/-4.0,-3.6,-3.2,-2.8,-2.4,-2.0,-1.6,-1.2,-0.8,-0.4,0,0.4,0.8,1.2,1.6,2.0,2.4,2.8,3.2,3.6,4.0/)'
    	  else
    	      colorlevs='(/0.0,0.4,0.8,1.2,1.6,2.0,2.4,2.8,3.2,3.6,4.0,4.4,4.8,5.2,5.6/)'
    	  fi
	  ;;
	SPFH)
          unit='(kg/kg)'
    	  if [[ ${stat} = 'ME' ]] ; then
    	      colorlevs='(/-0.005,-.003,-0.001,-.0008,-0.0006,-0.0004,-0.0002,-0.0001,0.00, 0.0001,0.0002,0.0004,0.0006,.0008,.001,.003,0.005/)'
    	  else
    	      colorlevs='(/0.0, 0.001,0.002,0.003,0.004,0.005,0.006,0.007,0.008,0.009,0.01/)'
    	  fi
	  ;;
	PRMSL)
	  unit='(hPa)'
    	  if [[ ${stat} = 'ME' ]] ; then
    	      colorlevs='(/-2.0,-1.60,-1.20,-0.80,-.4,0,0.4,0.80,1.2,1.6,2.0/)'
    	  else
    	      colorlevs='(/0.0,0.5,1.0,2.0,2.5,3.0,3.5,4.0,5.0,8.0/)'
    	  fi
   esac

     
#for lev in 250 300 400 500 600 700 850 900 1000; do
for lev in 2 ; do 



cat << EOF > ${ATCF}_${var}${lev}.ncl
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 

begin
fhr=24
do while(fhr.le.126)
  if (fhr.lt.100) then
      fhrs=sprinti("%0.2i",fhr)
  else
      fhrs=sprinti("%0.3i",fhr)
  end if
   fhr3=sprinti("%0.3i",fhr)
      print ( fhr)
      print ( fhrs)
  wks = gsn_open_wks("png","${var}${lev}_"+fhr3+"_${ATCF}_${stat}") ; open a ps file
;
 FileName = "${inloc}/${ATCF}only/${var}_"+fhrs+"_${lev}.nc"

  ff = addfile(FileName,"r")

  cnt1= ff->series_cnt_TOTAL(:,:)
  rms1= ff->series_cnt_${stat}(:,:)
  xlat= ff->lat(:,:)
  xlon= ff->lon(:,:)
  dims = dimsizes(xlat)

  nlat = dims(0)                                ; assign # lat/lon points
  nlon = dims(1)


print (ff)
;exit

  res = True
  res@cnLinesOn          = False
  res@cnFillOn           = True               ; color plot desired
  res@cnLineLabelsOn     = False              ; turn off contour lines
  res@cnRasterModeOn     = True
  res@gsnDraw            = False
  res@gsnFrame           = False

  res@tfDoNDCOverlay        = True
  res@mpGeophysicalLineColor = "red" ; color of continental outlines
  res@mpPerimOn              = True ; draw box around map
  res@mpPerimDrawOrder       = "PostDraw"
  res@mpGridLineDashPattern  = 2 ; lat/lon lines as dashed
  res@mpOutlineBoundarySets = "GeophysicalAndUSStates"
  res@mpUSStateLineColor    = "red"

  res@gsnAddCyclic        = False
  res@mpLimitMode        = "Corners" ; choose range of map
  res@mpLeftCornerLatF   = xlat(0,0)
  res@mpLeftCornerLonF   = xlon(0,0)
  res@mpRightCornerLatF  = xlat(nlat-2,nlon-2)
  res@mpRightCornerLonF  = xlon(nlat-2,nlon-2)

;  colors = (/"white","black", "white","PowderBlue","SkyBlue",\
;  "CornflowerBlue","SteelBlue", \
;  "SlateBlue","DarkSlateBlue","BlueViolet","MediumOrchid","Plum", \
;  "LightPink","MistyRose1","Snow"/)

  gsn_define_colormap(wks, "${colormaps}")

do it = 0, 0 

  rms1@lat2d = xlat(:nlat-2,:nlon-2)
  rms1@lon2d = xlon(:nlat-2,:nlon-2)
  cnt1@lat2d = xlat(:nlat-2,:nlon-2)
  cnt1@lon2d = xlon(:nlat-2,:nlon-2)

  if ($lev .lt. 100) then
  res@tiMainString          = "${ATCF} ${var} "+fhrs+" hr ${stat} at ${lev} m" 
  else
  res@tiMainString          = "${ATCF} ${var} "+fhrs+" hr ${stat} at ${lev} hPa"  
  end if

  res@pmLabelBarWidthF = 0.6
  res@lbBoxLinesOn     = False

  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels  = ${colorlevs}



  res@gsnSpreadColors     = True          ; use full range of colormap
  res@cnInfoLabelOn       = False           ; turn off cn info label


  res@gsnRightString       = "${var}${unit}"
  if ("${var}" .eq. "PRMSL") then
  map = gsn_csm_contour_map(wks,rms1(:nlat-2,:nlon-2)/100.,res)
  else
  map = gsn_csm_contour_map(wks,rms1(:nlat-2,:nlon-2),res)
  end if 


  cnt=True
  cnt@cnLinesOn         = True
  cnt@cnFillOn          = False
  cnt@cnLineLabelsOn    = True
  cnt@gsnDraw           = False
  cnt@gsnFrame          = False
  cnt@cnLineLabelPlacementMode  = "constant"
  cnt@tiMainString      = "Constant"
  cnt@cnLineDashSegLenF         = 0.35
  cnt@cnLineLabelInterval       = 1
  cnt@cnLineLabelFontHeightF    =0.008
  cnt@cnInfoLabelOn		= False
  cnt@cnLevelSelectionMode = "ExplicitLevels"
  cnt@cnLevels  = (/20,50,100,150,500,750,1000/)

  map_ov = gsn_csm_contour(wks,cnt1(:nlat-2,:nlon-2),cnt)


; Calculate averages over different regions
  ave_area= wgt_areaave(rms1(20:nlat-20,40:nlon-40), 1.0, 1.0, 0)
  std_area= stddev(rms1(:nlat-2,:nlon-2))
  ave_EP= wgt_areaave(rms1(100:300,80:360), 1.0, 1.0, 0)
  std_EP= stddev(rms1(100:300,80:360))
  ave_AL= wgt_areaave(rms1(100:300,340:600), 1.0, 1.0, 0)
  std_AL= stddev(rms1(100:300,340:600))

  if ("${var}" .eq. "PRMSL") then
   ave_area=ave_area/100. 
   ave_EP=ave_EP/100.
   ave_AL=ave_AL/100.
  end if



; Write to text file
  alist = [/"${var}","${lev}","${ATCF}","${stat}",fhrs,ave_area,std_area,ave_EP,std_EP,ave_AL,std_AL/]

  write_table("${text_fn}", "a", alist, "%s%s%s%s%s%10.3g%10.3g%10.3g%10.3g%10.3g%10.3g")


; Write averages on plot
; EP is defined as 160-90W; 0-50N
; AL is defined as 95-30W; 0-50N
  aves                  = True
  aves@txFontHeightF    = 0.02
  aves@txFontColor      = "black"

  str_all=sprintf("%6.3g",ave_area)
  str_EP=sprintf("%6.3g",ave_EP)
  str_AL=sprintf("%6.3g",ave_AL)

  aves@txJust           = "CenterLeft"
  gsn_text_ndc(wks,"EP AVE: "+str_EP,.1,.18,aves)
  aves@txJust           = "CenterCenter"
  gsn_text_ndc(wks,"Tot. AVE: "+str_all,.5,.18,aves)
  aves@txJust           = "CenterRight"
  gsn_text_ndc(wks,"AL AVE: "+str_AL,.9,.18,aves)




  overlay(map,map_ov)
  draw(map)
  frame(wks)

;
end do

fhr=fhr+24
end do
end

EOF

ncl ${ATCF}_${var}${lev}.ncl

done
done
done
done

