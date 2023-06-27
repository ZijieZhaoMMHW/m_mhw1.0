EOF analysis on MHW data
==================================================================

In this template, we provide an example performing EOF analysis on MHW data, focusing on annual MHW days. This example is inspired by results in [Oliver et al. (2018)](https://doi.org/10.1016/j.pocean.2018.02.007).

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
Preparing EOF data
-------------
Here we calculate annual MHW days. 

Firstly, generating date vectors
```
date_used=datevec(datenum(1993,1,1):datenum(2016,12,31));
```
The  matrix `date_used` is a date-vector variable, where each row corresponds to the date (year-month-day-hour) of a particular time point during 1993-2016.

We also need the land index, indicating the location of lands where no MHW found.
```
land_index=isnan(nanmean(mhw_ts,3));
```
Then we calculate the annual MHW days.
```
mhwdays=NaN(32,32,2016-1993+1);
for i=1993:2016
    idx_here=date_used(:,1)==i;
    d_here=sum(~isnan(mhw_ts(:,:,idx_here)),3,'omitnan');
    d_here(land_index)=nan;
    mhwdays(:,:,i-1993+1)=d_here;
end
```
`mhwdays` is a 3D data, where each layer indicates spatial MHW days in a particular year during 1993-2016.

Performing EOF analysis
-------------
Here we manually perform EOF analysis on annual MHW days.

Firstly, we need to spatially weighted the data.
```
[lat2,~]=meshgrid(lat_used,lon_used);
data=mhwdays.*cosd(repmat(lat2,1,1,24));
```
Then, we need to reshape the data from 3d to 2d and get rid of the land data.
```
data=(reshape(data,size(mhw_ts,1)*size(mhw_ts,2),24))';
data=data(:,~land_index);
```
Remove the linear trend and mean from the data.
```
F=detrend(data,1);
F=detrend(F,0);
```
Calculate the covariance matrix
```
C=F'*F;
```
Perform the eigenvalue analysis
```
[EOFs,D]=eig(C);
PCs=EOFs'*F';
D=diag(D);
D=D./nansum(D);
```
`EOFs` is the spatial EOF patterns, `PCs` is the corresponding principal component time series, and `D` is the corresponding explained variance.

Have a look at the first and second EOF mode
```
[Ds,i]=sort(D,'descend');
EOF1=EOFs(:,i(1));
PC1=PCs(i(1),:);
Ds(1:2)
ans =

    0.5638
    0.0869
```
Here we can see the first EOF mode explains 56.38% of total variance, while the second EOF mode explains only 8.69%. Therefore, we only focus on the first EOF mode here. 

For visualization, we need to reshape the EOF from 3d back to 2d.
```
sEOF1=NaN(size(mhw_ts,1)*size(mhw_ts,2),1);
sEOF1(~land_index)=EOF1;
sEOF1=reshape(sEOF1,size(mhw_ts,1),size(mhw_ts,2));

sEOF1=sEOF1.*nanstd(PC1);
PC1=PC1./nanstd(PC1);
```
Simple Visualization
-------------
Here we visualize the first EOF mode. 
```
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
```
![Image text](https://github.com/ZijieZhaoMMHW/m_mhw1.0/blob/master/store_figure/mhweof.png)

