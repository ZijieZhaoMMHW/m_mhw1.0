Analysing monthly and seasonal variability of MHWs
==================================================================

In this template, we provide an example containing simple analysis of monthly and seasonal variability of MHWs

Loading data
-------------

Firstly, let’s load NOAA OI SST data (Reynolds et al., 2007). Due to the limitation of file size in Github, these data are stored in folder [data](https://github.com/ZijieZhaoMMHW/m_mhw1.0/tree/master/data) for one year per file. We need to reconstruct these data into one combined dataset.

```
sst_full=NaN(32,32,datenum(2016,12,31)-datenum(1982,1,1)+1);
for i=1982:2016;
    file_here=['sst_' num2str(i)];
    load(file_here);
    eval(['data_here=sst_' num2str(i) ‘;’])
    sst_full(:,:,(datenum(i,1,1):datenum(i,12,31))-datenum(1982,1,1)+1)=data_here;
end
```

The `sst_full` contains SST in [147-155E, 45-37S] in resolution of 0.25 from 1982 to 2016.

```
size(sst_full); %size of data
load('lon_and_lat');
datenum(2016,12,31)-datenum(1982,1,1)+1 % The temporal length is 35 years.
load(‘sst_loc’);% also load lon location and lat location
```
Detecting MHWs
-------------
Here we detect MHWs during 1993-2016 based on climatologies during 1993-2005.
```
[MHW,mclim,m90,mhw_ts]=detect_full(sst_full,datenum(1982,1,1):datenum(2016,12,31),datenum(1982,1,1),datenum(2005,12,31),datenum(1993,1,1),datenum(2016,12,31)); %take about 30 seconds.
```
Generating monthly and seasonal MHW metrics
-------------
Here we calculate monthly and seasonal MHW metrics, including the average number of MHW days and average MHW intensity.

Firstly, generating date vectors
```
date_used=datevec(datenum(1993,1,1):datenum(2016,12,31));
```
The  matrix `date_used` is a date-vector variable, where each row corresponds to the date (year-month-day-hour) of a particular time point during 1993-2016.

We also need the land index, indicating the location of lands where no MHW found.
```
land_index=isnan(nanmean(mhw_ts,3));
```
Then we calculate the monthly average of MHW days and MHW intensity based on data during 1993-2016. This could be easily achieved by using a loop from 1-12.
```
mhwday_month=NaN(size(mhw_ts,1),size(mhw_ts,2),12); % lon-lat-month
mhwint_month=NaN(size(mhw_ts,1),size(mhw_ts,2),12); % lon-lat-month
for i=1:12
    index_used=date_used(:,2)==i;
    mhwday_month(:,:,i)=nansum(~isnan(mhw_ts(:,:,index_used)),3)./(2016-1993+1);
    mhwint_month(:,:,i)=nanmean(mhw_ts(:,:,index_used),3);
end
mhwday_month(repmat(land_index,1,1,12))=nan;
```
`mhwday_month` is the average number of MHW days in each month during 1993-2016, and `mhwint_month` is the average intensity of MHW days in each month during 1993-2016.

Using a comparable approach, it is possible to estimate the seasonal average of both the number of MHW days and the intensity of MHW, with the exception that the seasons need to be clearly defined. Here we define austral seasons as SPR-SON SUM-DJF AUT-MAM WIN-JJA.
```
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
```
`mhwday_seas` (days/month) is the average number of MHW days in each season during
1993-2016, and `mhwint_seas` (^{o}C) is the average intensity of MHW days in each season during
1993-2016.

Simple visualization
-------------
Here we visualize the seasonal variability of MHW metrics.
```
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
    title(['MHW days/month-' name_used{i}]);
end
```
![Image text](https://github.com/ZijieZhaoMMHW/m_mhw1.0/blob/master/store_figure/mhwseas.png)

The first row of the figure corresponds to the average number of MHW days in each season, and the second row is the average intensity of MHW days in each seasons.
