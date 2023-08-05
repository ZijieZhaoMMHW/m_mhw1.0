%% An example providing some initial analysis of MHW category (Hobday et al., 2018)

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

%% 2. Detecting MHWs and corresponding categories

% Here we detect marine heatwaves off eastern Tasmania based on the
% traditional definition of MHWs (Hobday et al. 2016). We detected MHWs
% during 1993 to 2016 for climatologies and thresholds in 1982 to 2005.
tic
[MHW,mclim,m90,mhw_ts,category_ts]=detect(sst_full,datenum(1982,1,1):datenum(2016,12,31),datenum(1982,1,1),datenum(2005,12,31),datenum(1993,1,1),datenum(2016,12,31)); %take about 30 seconds.
toc

% The last column in the table `MHW` is just the category of corresponding
% MHW event
MHW(1:5,end)
% Here we can see the first 5 MHW events are all assigned to category 1,
% which is 'moderate' MHW based on Hobday's definition (Hobday et al.,
% 2018).

% The output category_ts is the time series representation of MHW category.
category_ts(1,1,datenum(1993,4,20)-datenum(1993,1,1)+1)
% Here we can see there is a category-1 MHW at Apr/20/1993 in x1 y1
% location

%% 3. Frequency of MHWs for each category
% Here we do some initial analysis to get frequency of MHWs for each category
MHW_loc=unique(MHW{:,8:9},'rows');
freq_category=NaN(32,32,4); %lon - lat - category
for x=1:size(MHW_loc,1)
    ts_here=squeeze(category_ts(MHW_loc(x,1),MHW_loc(x,2),:));
    for c=1:4
        bw=bwlabel(ts_here==c);
        % calculating annual frequency
        freq_category(MHW_loc(x,1),MHW_loc(x,2),c)=nanmax(bw)./(2016-1993+1);
    end
end

%% 4. Annual MHW days for each category
% Here we do some initial analysis to get annual MHW days for each category
MHW_loc=unique(MHW{:,8:9},'rows');
mhwday_category=NaN(32,32,4); %lon - lat - category
ocean_index=~isnan(nanmean(category_ts,3));
for c=1:4
    % calculating annual MHW days
    mhwday_here=nansum(category_ts==c,3);
    mhwday_here(~ocean_index)=nan;
    mhwday_category(:,:,c)=mhwday_here./(2016-1993+1);
end

%% 5. Visualization
% Running this part requires cmocean toolbox (Thyng et al., 2016)
load('lon_and_lat');
m_proj('miller','lon',[nanmin(lon_used) nanmax(lon_used)],'lat',[nanmin(lat_used) nanmax(lat_used)]);
color_name={'deep','algae','matter','amp'};
title_name={'Moderate','Strong','Severe','Extreme'};
for i=1:4
    subplot(2,4,i)
    m_pcolor(lon_used,lat_used,(freq_category(:,:,i))');
    shading interp
    cmocean(color_name{i});
    m_coast('patch',[0.7 0.7 0.7],'linewidth',2);
    m_grid('fontname','consolas','fontsize',8);
    s=colorbar('fontsize',8,'fontname','consolas');
    s.Label.String='/year';
    title(['MHW frequency - ' title_name{i}],'fontname','consolas','fontsize',12);
    
    subplot(2,4,i+4)
    m_pcolor(lon_used,lat_used,(mhwday_category(:,:,i))');
    shading interp
    cmocean(color_name{i});
    m_coast('patch',[0.7 0.7 0.7],'linewidth',2);
    m_grid('fontname','consolas','fontsize',8);
    s=colorbar('fontsize',8,'fontname','consolas');
    s.Label.String='days/year';
    title(['MHW days - ' title_name{i}],'fontname','consolas','fontsize',12);
end
