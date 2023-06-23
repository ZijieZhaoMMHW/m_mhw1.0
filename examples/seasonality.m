%% An example analysing seasonality of MHWs
% Here we provide an example about seasonality of MHWs

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

%% 2. Detecting MHWs and MCSs

% Here we detect marine heatwaves off eastern Tasmania based on the
% traditional definition of MHWs (Hobday et al. 2016). We detected MHWs
% during 1993 to 2016 for climatologies and thresholds in 1982 to 2005.
tic
[MHW,mclim,m90,mhw_ts]=detect(sst_full,datenum(1982,1,1):datenum(2016,12,31),datenum(1982,1,1),datenum(2005,12,31),datenum(1993,1,1),datenum(2016,12,31)); %take about 30 seconds.
toc

%% 3. Generating monthly and seasonal MHW metrics
% Here we calculate monthly and seasonal MHW metrics including numbers of
% MHW days and mean MHW intensity

% Generating date matrix
date_used=datevec(datenum(1993,1,1):datenum(2016,12,31));

% Determining land index
land_index=isnan(nanmean(mhw_ts,3));

% Monthly
mhwday_month=NaN(size(mhw_ts,1),size(mhw_ts,2),12); % lon-lat-month
mhwint_month=NaN(size(mhw_ts,1),size(mhw_ts,2),12); % lon-lat-month
for i=1:12
    index_used=date_used(:,2)==i;
    mhwday_month(:,:,i)=nansum(~isnan(mhw_ts(:,:,index_used)),3)./(2016-1993+1);
    mhwint_month(:,:,i)=nanmean(mhw_ts(:,:,index_used),3);
end
mhwday_month(repmat(land_index,1,1,12))=nan;
% mhwday_month is the average number of MHW days in each month during
% 1993-2016
% mhwint_month is the average intensity of MHW days in each month during
% 1993-2016

% Seasonal
% Determining austral seasons
% SPR-SON SUM-DJF AUT-MAM WIN-JJA
seas=[9 10 11;...
    12 1 2;...
    3 4 5;...
    6 7 8];
mhwday_seas=NaN(size(mhw_ts,1),size(mhw_ts,2),4); % lon-lat-seasons
mhwint_seas=NaN(size(mhw_ts,1),size(mhw_ts,2),4); % lon-lat-seasons
for i=1:4
    index_used=ismember(date_used(:,2),seas(i,:));
    mhwday_seas(:,:,i)=nansum(~isnan(mhw_ts(:,:,index_used)),3)./(3*(2016-1993+1));
    mhwint_seas(:,:,i)=nanmean(mhw_ts(:,:,index_used),3);
end
mhwday_seas(repmat(land_index,1,1,4))=nan;
% mhwday_seas (days/month) is the average number of MHW days in each season during
% 1993-2016
% mhwint_seas (^{o}C) is the average intensity of MHW days in each season during
% 1993-2016

%% 4. Visualizing seasonal MHW metrics
m_proj('miller','lon',[nanmin(lon_used(:)) nanmax(lon_used(:))],'lat',[nanmin(lat_used(:)) nanmax(lat_used(:))]);
name_used={'SPR','SUM','AUT','WIN'};
for i=1:4
    subplot(2,4,i);
    m_pcolor(lon_used,lat_used,(mhwday_seas(:,:,i))');
    shading interp
    m_coast('patch',[0.7 0.7 0.7]);
    m_grid;
    caxis([0 10]);
    colormap('jet');
    s=colorbar('location','southoutside');
    title(['MHW days/month-' name_used{i}]);
end

for i=1:4
    subplot(2,4,i+4);
    m_pcolor(lon_used,lat_used,(mhwint_seas(:,:,i))');
    shading interp
    m_coast('patch',[0.7 0.7 0.7]);
    m_grid;
    caxis([0 3]);
    colormap('jet');
    s=colorbar('location','southoutside');
    title(['MHW intensity (^{o}C)-' name_used{i}]);
end
