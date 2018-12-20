An example about applying **`m_mhw`** to real-world data
==================================================================

We provide an example about applying **`m_mhw`** to real-world data. In this example, we use **`m_mhw`** to detect and analyze MHWs off eastern Tasmania during 1982 - 2016.

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

Detecting MHWs and MCSs
-------------

In this section we detect MHWs and MCSs off eastern Tasmania based on definition give by Hobday et al. (2016) and Schlegel et al. (2017). The climatology and thresholds (90th and 10th percentile) are calculated for SST during 1982 - 2005.

```
% Here we detect marine heatwaves off eastern Tasmania based on the
% traditional definition of MHWs (Hobday et al. 2016). We detected MHWs
% during 1993 to 2016 for climatologies and thresholds in 1982 to 2005.

[MHW,mclim,m90,mhw_ts]=detect(sst_full,datenum(1982,1,1):datenum(2016,12,31),datenum(1982,1,1),datenum(2005,12,31),datenum(1993,1,1),datenum(2016,12,31)); %take about 30 seconds.

% Additionally, we also detect MCSs during 1982 to 2005 based on the same
% climatologies. 

[MCS,~,m10,mcs_ts]=detect(sst_full,datenum(1982,1,1):datenum(2016,12,31),datenum(1982,1,1),datenum(2005,12,31),datenum(1993,1,1),datenum(2016,12,31),'Event','MCS','Threshold',0.1);

```

Let’s have a look at these two resultant data (`MHW` and `MCS`).

```
MHW(1:5,:)
MCS(1:5,:)
```

The properties `mhw_onset` and `mhw_end` are in a strange format. This is due to the fact that they are originally constructed in numeric format. We could change it to date format by following steps.

```
datevec(num2str(MHW{1:5,:}),'yyyymmdd') % vector
datestr(datevec(num2str(MHW{1:5,:}),'yyyymmdd')) % string
datenum(num2str(MHW{1:5,:}),'yyyymmdd') % number
```

Visualizing MHW/MCS time series
-------------

In this section we use `event_line` to visualize MHW/MCS events in grid (1,2). Firstly, let’s have a look at MHW time series during Sep 2015 to Apr 2016 in this loc.

```
% Have a look of MHW events in grid (1,2) from Sep 2015 to Apr 2016
figure('pos',[10 10 1000 1000]);
event_line(sst_full,MHW,mclim,m90,[1 2],1982,[2015 9 1],[2016 5 1]);
```
![Image text](https://github.com/ZijieZhao/see/blob/master/store_figure/event_mhw.png)

From this plot, we could see that oceanic region off eastern Tasmania in austral summer during 2015/2016 is dominated by intense MHWs, which has been already well discussed in Oliver et al. (2016).

Let's also have a look at MCS time series during 1994.

```
% Have a look of MCS events in grid (1,2) during 1994
figure('pos',[10 10 1000 1000]);
event_line(sst_full,MCS,mclim,m10,[1 2],1982,[1994 1 1],[1994 12 31],'Event','MCS','Color',[0.5 0.5 1]);
```
![Image text](https://github.com/ZijieZhao/see/blob/master/store_figure/event_mcs.png)

We could see that this year is dominated by four different MCS events, majorly in Jul to Sep.

Mean states and trends
-------------

In this section, we would like to see the mean states and trends of MHW properties (frequency, duration, maximum intensity, mean intensity. Similar approach has been done by Oliver et al. (2018). In this section, we use **`m_map`** toolbox (https://www.eoas.ubc.ca/~rich/map.html) to visualize resultant outputs.

```
% This function could detect mean states and trends for six different
% variables (Frequency, mean intensity, max intensity, duration and total
% MHW/MCs days). 

metric_used={'Frequency','MeanInt','MaxInt','CumInt','Duration','Days'};

for i=1:6;
    eval(['[mean_' metric_used{i} ',annual_' metric_used{i} ',trend_' metric_used{i} ',p_' metric_used{i} ']=mean_and_trend(MHW,mhw_ts,1993,' '''' 'Metric' '''' ',' 'metric_used{i}' ');'])
end
```

For each metric, we get four outputs, which are `mean_?`, `annual_?`, `trend_?`, `p_?`, separately indicating the total mean, annual mean, annual trend and associated p-value of specified metric. 

See if we could plot them. Note that here we actually show the decadal trend instead of annual trend to avoid too small values.

```
% plot mean and trend

% It could be detected that, as a global hotspot, the oceanic region off
% eastern Tasmania exhibits significant positive trends of MHW metrics. 

figure('pos',[10 10 1500 1500]);


subplot(2,6,1);
m_contourf(lon_used,lat_used,mean_Frequency',2:0.1:5,'linestyle','none');
m_gshhs_h('patch',[1 1 1]);
m_grid;
colormap(jet);
s=colorbar('location','southoutside');
m_text(148,-44,'a) Frequency','fontweight','bold','fontsize',14);

subplot(2,6,2);
m_contourf(lon_used,lat_used,mean_MeanInt',1:0.1:2.5,'linestyle','none');
m_gshhs_h('patch',[1 1 1]);
m_grid;
colormap(jet);
m_text(148,-44,'b) MeanInt','fontweight','bold','fontsize',14);
s=colorbar('location','southoutside');

subplot(2,6,3);
m_contourf(lon_used,lat_used,mean_MaxInt',1:0.1:3,'linestyle','none');
m_gshhs_h('patch',[1 1 1]);
m_grid;
colormap(jet);
m_text(148,-44,'c) MaxInt','fontweight','bold','fontsize',14);
s=colorbar('location','southoutside');

subplot(2,6,4);
m_contourf(lon_used,lat_used,mean_CumInt',15:0.1:50,'linestyle','none');
m_gshhs_h('patch',[1 1 1]);
m_grid;
colormap(jet);
m_text(148,-44,'d) CumInt','fontweight','bold','fontsize',14);
s=colorbar('location','southoutside');

subplot(2,6,5);
m_contourf(lon_used,lat_used,mean_Duration',9:0.1:27,'linestyle','none');
m_gshhs_h('patch',[1 1 1]);
m_grid;
colormap(jet);
m_text(148,-44,'e) Duration','fontweight','bold','fontsize',14);
s=colorbar('location','southoutside');

subplot(2,6,6);
m_contourf(lon_used,lat_used,mean_Days',26:0.1:72,'linestyle','none');
m_gshhs_h('patch',[1 1 1]);
m_grid;
colormap(jet);
m_text(148,-44,'f) Days','fontweight','bold','fontsize',14);
s=colorbar('location','southoutside');

subplot(2,6,7);
m_contourf(lon_used,lat_used,(trend_Frequency')*10,0.5:0.05:3.5,'linestyle','none');
s=colorbar('location','southoutside');
m_gshhs_h('patch',[1 1 1]);
m_grid;
[lon,lat]=meshgrid(lon_used,lat_used);
lon=lon';
lat=lat';
hold on
m_scatter(lon(p_Frequency<0.05),lat(p_Frequency<0.05),1.5,'k');
colormap(jet);
m_text(148,-44,'g) t-Frequency','fontweight','bold','fontsize',14);

subplot(2,6,8);
m_contourf(lon_used,lat_used,(trend_MeanInt')*10,-0.4:0.05:0.4,'linestyle','none');
m_gshhs_h('patch',[1 1 1]);
m_grid;
s=colorbar('location','southoutside');
[lon,lat]=meshgrid(lon_used,lat_used);
lon=lon';
lat=lat';
hold on
m_scatter(lon(p_MeanInt<0.05),lat(p_MeanInt<0.05),1.5,'k');
colormap(jet);
caxis([-0.4 0.4]);
m_text(148,-44,'h) t-MeanInt','fontweight','bold','fontsize',14);

subplot(2,6,9);
m_contourf(lon_used,lat_used,(trend_MaxInt')*10,-0.4:0.05:0.4,'linestyle','none');
s=colorbar('location','southoutside');
m_gshhs_h('patch',[1 1 1]);
m_grid;
[lon,lat]=meshgrid(lon_used,lat_used);
lon=lon';
lat=lat';
hold on
m_scatter(lon(p_MaxInt<0.05),lat(p_MaxInt<0.05),1.5,'k');
colormap(jet);
caxis([-0.4 0.4]);
m_text(148,-44,'i) t-MaxInt','fontweight','bold','fontsize',14);

subplot(2,6,10);
m_contourf(lon_used,lat_used,(trend_CumInt')*10,-0.4:0.1:110,'linestyle','none');
s=colorbar('location','southoutside');
m_gshhs_h('patch',[1 1 1]);
m_grid;
[lon,lat]=meshgrid(lon_used,lat_used);
lon=lon';
lat=lat';
hold on
m_scatter(lon(p_CumInt<0.05),lat(p_CumInt<0.05),1.5,'k');
colormap(jet);
caxis([0 110]);
m_text(148,-44,'j) t-CumInt','fontweight','bold','fontsize',14);


subplot(2,6,11);
m_contourf(lon_used,lat_used,(trend_Duration')*10,-3:0.1:42,'linestyle','none');
s=colorbar('location','southoutside');
m_gshhs_h('patch',[1 1 1]);
m_grid;
[lon,lat]=meshgrid(lon_used,lat_used);
lon=lon';
lat=lat';
hold on
m_scatter(lon(p_Duration<0.05),lat(p_Duration<0.05),1.5,'k');
colormap(jet);
caxis([0 40]);
m_text(148,-44,'k) t-Duration','fontweight','bold','fontsize',14);

subplot(2,6,12);
m_contourf(lon_used,lat_used,(trend_Days')*10,0:0.1:75,'linestyle','none');
s=colorbar('location','southoutside');
m_gshhs_h('patch',[1 1 1]);
m_grid;
[lon,lat]=meshgrid(lon_used,lat_used);
lon=lon';
lat=lat';
hold on
m_scatter(lon(p_Days<0.05),lat(p_Days<0.05),1.5,'k');
colormap(jet);
caxis([0 74]);
m_text(148,-44,'l) t-Days','fontweight','bold','fontsize',14);

```
![Image text](https://github.com/ZijieZhao/see/blob/master/store_figure/mean_and_trend.png)

We could see that, as a globally recongized hotspot, oceanic region in eastern Tasmania exhibits significantly increasing MHW metrics in most regions.

Applying cluster algoirthm to MHW - A kmeans example.
-------------

We get so many MHW events. Could we use some cluster algorithms to divide them into different groups based on their properties? Let's try kmeans. We use mean, maximum, cumulative intensity and duration as variable for cluster algorithm.

```
% Change it to matrix;
MHW_m=MHW{:,:};

% Extract mean, max, cumulative intensity and duration.
MHW_m=MHW_m(:,[3 4 5 7]); 

[data_for_k,mu,sd]=zscore(MHW_m);

```

Determination of suitable groups of kmeans is an important step. Here we use a correlation - based method to determine a suitable number of clusters. As more nodes were included, the generated patterns were reconstructed into a dataset with the same size as the original data by duplicating each pattern based on its allocated temporal data; the correlations between these two datasets were then calculated. The final map size of the kmeans was determined as that size at which the correlation tended to a constant.

```

% Determine suitable groups of kmeans cluster.
index_full=[];
cor_full=[];
for i=2:20;
    k=kmeans(data_for_k,i,'Distance','cityblock','maxiter',200);
    k_full=[];
    for j=1:i;
        k_full=[k_full;nanmean(data_for_k(k==j,:))];
    end
    
    k_cor=k_full(k,:);
    k_cor=k_cor(:);
    
    [c,p]=corr([data_for_k(:) k_cor]);
    
    index_full=[index_full;2];
    cor_full=[cor_full;c(1,2)];
        
        
end

% Plot correlations and their first difference

figure('pos',[10 10 1500 1500]);
subplot(1,2,1);
plot(2:20,cor_full,'linewidth',2);
hold on
plot(9*ones(1000,1),linspace(0.6,1,1000),'r--');
xlabel('Number of Groups','fontsize',16,'fontweight','bold');
ylabel('Correlation','fontsize',16,'fontweight','bold');
title('Correlation','fontsize',16);
set(gca,'xtick',[5 9 10 15 20],'fontsize',16);

subplot(1,2,2);
plot(3:20,diff(cor_full),'linewidth',2);
hold on
plot(9*ones(1000,1),linspace(-0.02,0.14,1000),'r--');
xlabel('Number of Groups','fontsize',16,'fontweight','bold');
ylabel('First difference of Correlation','fontsize',16,'fontweight','bold');
title('First Difference of Correlation','fontsize',16);
set(gca,'fontsize',16);

```
![Image text](https://github.com/ZijieZhao/see/blob/master/store_figure/determine_k.png)

From this plot, it could be detected that, when number of groups reaches 9, the correlation increases to a relatively high value (~0.9) and its associated first difference tends to be stationary. Therefore, we choose 9 groups for kmeans analysis.

Using 9 groups' kmeans, means and proportion of elements in each group are determined.

```
k=kmeans(data_for_k,9,'Distance','cityblock','maxiter',200);

k_9=[];
prop_9=[];
for i=1:9;
    data_here=data_for_k(k==i,:);
    data_here=nanmean(data_here);
    data_here=data_here.*sd+mu;
    k_9=[k_9;data_here];
    prop_9=[prop_9;nansum(k==i)./size(data_for_k,1)];
end
```

Then plot them using colormap. The proportions of events in each group are labelled.

![Image text](https://github.com/ZijieZhao/see/blob/master/store_figure/codebook.png)

From this plot, we could see that more than 70000 MHW events are classified into 9 groups by their associated metric. Each group exhibits distinct MHW metrics, e.g. few (2%) intense (large MaxInt and MeanInt) and long (large Duration and CumInt) MHWs tend to happen in Group 5.

Let's see their associated SST anomaly patterns.

Firstly we need to calculate the SST anomaly (SSTA). The SSTA in each group is calculated by averaging SSTA across all detected MHWs in their associated group.

```
% Their associated SSTA patterns

% Calculate SSTA

time_used=datevec(datenum(1982,1,1):datenum(2016,12,31));
m_d_unique=unique(time_used(:,2:3),'rows');

ssta_full=NaN(size(sst_full));

for i=1:size(m_d_unique);
    date_here=m_d_unique(i,:);
    index_here=find(time_used(:,2)==date_here(1) & time_used(:,3)==date_here(2));
    ssta_full(:,:,index_here)=sst_full(:,:,index_here)-nanmean(sst_full(:,:,index_here),3);
end
```
![Image text](https://github.com/ZijieZhao/see/blob/master/store_figure/sst_9.png)

It could be detected that the existence of MHWs in this region is always companied by significant oceanic characteristics. Firstly, MHWs tend to happen in the period when oceanic region off eastern Tasmania is anomalously warm. Additionally, distinct surface conditions exist during specified MHW groups, e.g. sea surface is extremely hot during MHWs in Group 5.

More things....
-------------

For more examples and tutorial please contact zijiezhaomj@gmail.com.

Reference
-------------

Hobday, A.J. et al. (2016). A hierarchical approach to defining marine heatwaves, Progress in Oceanography, 141, pp. 227-238.

Schlegel, R. W., Oliver, E. C. J., Wernberg, T. W., Smit, A. J. (2017). Nearshore and offshore co-occurrences of marine heatwaves and cold-spells. Progress in Oceanography, 151, pp. 189-205.

Oliver, E.C., Benthuysen, J.A., Bindoff, N.L., Hobday, A.J., Holbrook, N.J., Mundy, C.N. and Perkins-Kirkpatrick, S.E., 2017. The unprecedented 2015/16 Tasman Sea marine heatwave. Nature communications, 8, p.16101.

Oliver, E.C., Lago, V., Hobday, A.J., Holbrook, N.J., Ling, S.D. and Mundy, C.N., 2018. Marine heatwaves off eastern Tasmania: Trends, interannual variability, and predictability. Progress in Oceanography, 161, pp.116-130.

Reynolds, Richard W., Thomas M. Smith, Chunying Liu, Dudley B. Chelton, Kenneth S. Casey, Michael G. Schlax, 2007: Daily High-Resolution-Blended Analyses for Sea Surface Temperature. J. Climate, 20, 5473-5496. 







