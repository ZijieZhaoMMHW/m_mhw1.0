%% An example performing EOF analysis on MHW
% Here we provide an example performing EOF analysis on MHW

%% 1. Loading data

% Load NOAA OI SST V2 data
sst_full=NaN(32,32,datenum(2016,12,31)-datenum(1982,1,1)+1);
for i=1982:2016;
    file_here=['sst_' num2str(i)];
    load(file_here);
    eval(['data_here=sst_' num2str(i) ';'])
    sst_full(:,:,(datenum(i,1,1):datenum(i,12,31))-datenum(1982,1,1)+1)=data_here;
end

% This data includes SST in [147-155E, 45-37S] in resolution of 0.25 from
% 1982 to 2016.

load('lon_and_lat');

%% 2. Detecting MHWs

% Here we detect marine heatwaves off eastern Tasmania based on the
% traditional definition of MHWs (Hobday et al. 2016). We detected MHWs
% during 1993 to 2016 for climatologies and thresholds in 1982 to 2005.
tic
[MHW,mclim,m90,mhw_ts]=detect(sst_full,datenum(1982,1,1):datenum(2016,12,31),datenum(1982,1,1),datenum(2005,12,31),datenum(1993,1,1),datenum(2016,12,31)); %take about 30 seconds.
toc
%% 3. Preparing EOF data
% Inspired by Oliver et al. (2018), we aim to perform an EOF analysis on
% annual MHW days 

% Generating date matrix
date_used=datevec(datenum(1993,1,1):datenum(2016,12,31));

% Determining land index
land_index=isnan(nanmean(mhw_ts,3));

% Annual MHW days
mhwdays=NaN(32,32,2016-1993+1);
for i=1993:2016
    idx_here=date_used(:,1)==i;
    d_here=sum(~isnan(mhw_ts(:,:,idx_here)),3,'omitnan');
    d_here(land_index)=nan;
    mhwdays(:,:,i-1993+1)=d_here;
end
%% 4. EOF analysis
% EOF - manual
[lat2,~]=meshgrid(lat_used,lon_used);
% weighted by spatial grid
data=mhwdays.*cosd(repmat(lat2,1,1,24));
% reshape from 3d to 2d
data=(reshape(data,size(mhw_ts,1)*size(mhw_ts,2),24))';
% get rid of land data
data=data(:,~land_index);
% remove linear trend
F=detrend(data,1);
% remove mean
F=detrend(F,0);
% calculating cov matrix
C=F'*F;
% performing EOF analysis
[EOFs,D]=eig(C);
PCs=EOFs'*F';

D=diag(D);
D=D./nansum(D);
% EOFs is the spatial EOF patterns, PCs is the corresponding principal
% component time series, and D is the corresponding explained variance.

% find the first EOF pattern
[Ds,i]=sort(D,'descend');
EOF1=EOFs(:,i(1));
PC1=PCs(i(1),:);
Ds(1:2)
% Here we can see the first EOF pattern explains 56.38% of total variance,
% while the second EOF pattern only explains 8.69%. Therefore, we only
% focus on the first EOF pattern here.

% reshape EOF1 from 2d to 3d
sEOF1=NaN(size(mhw_ts,1)*size(mhw_ts,2),1);
sEOF1(~land_index)=EOF1;
sEOF1=reshape(sEOF1,size(mhw_ts,1),size(mhw_ts,2));

sEOF1=sEOF1.*nanstd(PC1);
PC1=PC1./nanstd(PC1);

%% 5. EOF visualization
figure
subplot(2,1,1);
m_proj('miller','lon',[nanmin(lon_used) nanmax(lon_used)],'lat',[nanmin(lat_used) nanmax(lat_used)]);
m_pcolor(lon_used,lat_used,sEOF1');
shading interp
m_coast('patch',[0.7 0.7 0.7],'linewidth',2);
m_grid('linewidth',2,'fontname','consolas');
colormap(m_colmap('jet'));
caxis([0 40]);
s=colorbar('fontname','consolas','fontsize',12);
title(s,'days/year','fontname','consolas');
set(gca,'fontsize',12)
title('EOF1: 56.38%','fontsize',16,'fontname','consolas');

subplot(2,1,2);
plot(1:24,PC1,'r','linewidth',2);
set(gca,'xtick',1:24,'xticklabels',1993:2016,'fontname','consolas','fontsize',12);
xlabel('Year','fontname','consolas');
ylabel('PC1','fontname','consolas');
xlim([1 24]);
set(gca,'fontsize',12,'linewidth',2)
xtickangle(90);
title('PC1: 56.38%','fontsize',16,'fontname','consolas');