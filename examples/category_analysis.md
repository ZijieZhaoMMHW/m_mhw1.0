MHW Category Analysis
==================================================================

In this template, we provide an example about some initial analysis of MHW category. 

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
tic
[MHW,mclim,m90,mhw_ts,category_ts]=detect(sst_full,datenum(1982,1,1):datenum(2016,12,31),datenum(1982,1,1),datenum(2005,12,31),datenum(1993,1,1),datenum(2016,12,31)); %take about 30 seconds.
toc
```
The last column in the table `MHW` is just the category of the corresponding MHW event.
```
>> MHW(1:5,end)

ans =

  5×1 table

    category
    ________

       1    
       1    
       1    
       1    
       1    
```
Here we can see the first 5 MHW events are all assigned to category 1, which is 'moderate' MHW based on Hobday's definition ([Hobday et al., 2018](https://www.jstor.org/stable/26542662)).

The output category_ts is the time series representation of MHW category.
```
>> category_ts(1,1,datenum(1993,4,20)-datenum(1993,1,1)+1)

ans =

     1
```
Here we can see there is a category-1 MHW at Apr/20/1993 in x1 y1 location.

Frequency of MHWs for each category
-------------
Here we do some initial analysis to get frequency of MHWs for each category. 
```
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
```

Mean annual MHW days for each category
-------------
Here we do some initial analysis to get mean annual MHW days for each category.
```
MHW_loc=unique(MHW{:,8:9},'rows');
mhwday_category=NaN(32,32,4); %lon - lat - category
ocean_index=~isnan(nanmean(category_ts,3));
for c=1:4
    % calculating annual MHW days
    mhwday_here=nansum(category_ts==c,3);
    mhwday_here(~ocean_index)=nan;
    mhwday_category(:,:,c)=mhwday_here./(2016-1993+1);
end
```

Visualization
-------------
Running this part requires cmocean toolbox ([Thyng et al., 2016](https://www.jstor.org/stable/24862699))
```
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
```
![Image text](https://github.com/ZijieZhaoMMHW/m_mhw1.0/blob/master/store_figure/mhw_category.png)

