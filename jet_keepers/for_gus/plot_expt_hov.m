clear
close all



%stat='RMSE'
stat='ME'
c=1
%expt={'H215' 'H15Z'};
expt={ 'H215'};
for e=1:length(expt)

ifn=['singles_stats_' expt{e} '.txt']

fid = fopen(ifn);

fmtstring = ['%s %u %s %s %u ' repmat('%f ',1,6)];

contents = textscan(fid, fmtstring);


data = cell2mat(contents(:,6:end)); 

fhrs=zeros(size(data,1)+1,1);
fhrs=cell2mat(contents(:,5));
LEV=cell2mat(contents(:,2));

stdlevs= [1000 900 850 700 600 500 400 300 250 0];
colormap(colorcube)
cmap = colormap;
orange=cmap(8,:);
purple=cmap(34,:);
blue=cmap(30,:);


pvars = {'HGT' 'TMP' 'SPFH' 'UGRD' 'VGRD' };
%pvars = {'HGT' 'TMP'};
unitlabs = {'Height (gpm)' 'Temp (K)' 'Speed (m/s)' 'RH (kg/kg)'};

%1. VAR
%2. LEV
%3. FHR
%4. Whole AVE
%5. Whole Std. Dev.
%6. EP ave
%7. EP SD
%8. ATL ave
%9. ATL SD
   for p=1:length(pvars) %Loop through variables
   
        % X is fhr
        % Y is height
        
         fhr=[0 24 48 72 96 120 144];
         for j=1:3 % basin
             figure(c)
             set(figure(c),'Units','inches','Position',[1 3 8.5 11],'PaperPosition',[0 0 11 8.5],'PaperSize',[11 8.5])
             
             area=[3 1 5];
             basin={'EP' 'MEGA' 'ATL'};
              
             HGTLEVS=zeros(length(stdlevs),length(fhr))
             
                for i=2:length(fhr)-1
                   HGTLEVS(1:length(stdlevs)-1,i)=data((fhrs==fhr(i) & strcmp(contents{:,1},pvars{p}) & ...
                               strcmp(contents{:,3},expt{e}) & strcmp(contents{:,4},stat)) ,area(j))
                end
             h = surf(fhr,flipdim(stdlevs,2),HGTLEVS)
             %h = contour(HGTLEVS(:,:))
             %          'EdgeColor', 'flat')
             view([0 90])
             box on
             if strcmp(stat,'ME')
               cm=[ -10, 5; -2,2; -0.001,0.001; -1,1; -1,1];
               colormap(darkb2r(cm(p,1),cm(p,2)))
             elseif strcmp(stat,'RMSE')
               cm=[ 0,25; 0,5;  0,0.003; 0,5; 0,5];
               colormap(p2g(cm(p,1),cm(p,2)))
             end
             colorbar
             %colormap(jet(125))
             %colorbar
             %colorbar('Ylim', [-1 1], ... 
             %'YTickMode', 'manual', ...
             %'Fontsize', 36, 'FontName', 'Times', 'FontWeight', ...
             %'normal', 'FontAngle', 'normal')
             shading flat
             
             %set(h(1), 'FaceColor',blue)
             %set(h(2), 'FaceColor',orange)
             %set(h(3), 'FaceColor',purple)
             %
             set(gca, 'LineWidth', 2)
             set(gca, 'FontSize', 20)
             set(gca, 'XTick',1:24:144)
             set(gca, 'XLim', [1 144])
             set(gca, 'XTickLabel',fhr)
             set(gca, 'YDir','reverse')
             set(gca, 'YTick',flipdim(stdlevs,2))
             set(gca, 'YLim', [0 1000])
             set(gca, 'YTickLabel',flipdim(stdlevs,2))
             xlabel('Forecast Hour')
             ylabel('Pressure Level (hPa)')
             title([expt{e},' ',stat, ' for ',pvars{p},' in ',basin{j}])
             
             fn=[stat '_' expt{e} '_hov_' pvars{p} '_' basin{j} '.pdf']
             print(figure(c),'-dpdf',fn)
             c=c+1
             clear HGTLEVS
         end
   %legend ('MEGA', 'EP', 'ATL','Location','eastoutside')
   %ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 ...
   %1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
   %
   %text(0.5, 1,{'\bf HDGF-HDRF Bias for' pvars{j}},'HorizontalAlignment' ...
   %,'center','VerticalAlignment', 'top')
   
   end
end
