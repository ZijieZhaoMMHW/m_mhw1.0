EOF analysis on MHW cumulative intensity
==================================================================

In this template, we provide an example about performing EOF analysis on MHW cumulative intensity

Loading data
-------------

```
sst_full=NaN(32,32,datenum(2016,12,31)-datenum(1982,1,1)+1);
for i=1982:2016;
    file_here=['sst_' num2str(i)];
    load(file_here);
    eval(['data_here=sst_' num2str(i) ';'])
    sst_full(:,:,(datenum(i,1,1):datenum(i,12,31))-datenum(1982,1,1)+1)=data_here;
end
```

The `sst_full` contains SST in [147-155E, 45-37S] in resolution of 0.25 from 1982 to 2016.

```
size(sst_full); %size of data
load('lon_and_lat');
datenum(2016,12,31)-datenum(1982,1,1)+1 % The temporal length is 35 years.
```
Detecting MHWs
-------------
Here we detect MHWs during 1982-2016 based on climatologies during 1982-2005.
```
tic
[MHW,mclim,m90,mhw_ts]=detect(sst_full,datenum(1982,1,1):datenum(2016,12,31),datenum(1982,1,1),datenum(2005,12,31),datenum(1982,1,1),datenum(2016,12,31)); %take about 30 seconds.
toc
```

Preparing EOF data
-------------
We first need to get the annual MHW cumulative intensity
```
% Generating date matrix
date_used=datevec(datenum(1982,1,1):datenum(2016,12,31));

% Determining land index
land_index=isnan(nanmean(mhw_ts,3));

% Annual MHW cumulative intensity
mhwint=NaN(32,32,2016-1982+1);
for i=1982:2016
    idx_here=date_used(:,1)==i;
    d_here=sum(mhw_ts(:,:,idx_here),3,'omitnan');
    d_here(land_index)=nan;
    mhwint(:,:,i-1982+1)=d_here;
end
```

Performing EOF manually
-------------
Then we perform EOF analysis on annual cumulative MHW intensity `mhwint`.
```
% EOF - manual
[lat2,~]=meshgrid(lat_used,lon_used);
% weighted by spatial grid
data=mhwint.*sqrt(cosd(repmat(lat2,1,1,35)));
% reshape from 3d to 2d
data=(reshape(data,size(mhw_ts,1)*size(mhw_ts,2),35))';
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
```
`EOFs` is the spatial EOF patterns, `PCs` is the corresponding principal component time series, and `D` is the corresponding explained variance.
Then we identify the first EOF pattern and its corresponding explained variance.
```
[Ds,i]=sort(D,'descend');
EOF1=EOFs(:,i(1));
PC1=PCs(i(1),:);
Ds(1:2)
>> Ds(1:2)

ans =

    0.6138
    0.0872
```
Here we can see the first EOF pattern explains 61.38% of total variance,  while the second EOF pattern only explains 8.72%. Therefore, we only focus on the first EOF pattern here.
Then we reshape the EOF pattern from 2D to 3D and normalize them.
```
sEOF1=NaN(size(mhw_ts,1)*size(mhw_ts,2),1);
sEOF1(~land_index)=EOF1;
sEOF1=reshape(sEOF1,size(mhw_ts,1),size(mhw_ts,2));

sEOF1=sEOF1.*nanstd(PC1);
PC1=PC1./nanstd(PC1);
```

Visualization
-------------
Here we do a simple visualization of the first EOF mode and its corresponding PC time series.
```
figure('pos',[ 198    19   525   786]);
subplot(2,1,1);
m_proj('miller','lon',[nanmin(lon_used) nanmax(lon_used)],'lat',[nanmin(lat_used) nanmax(lat_used)]);
m_pcolor(lon_used,lat_used,sEOF1');
shading interp
m_coast('patch',[0.7 0.7 0.7],'linewidth',2);
m_grid('linewidth',2,'fontname','consolas');
colormap(m_colmap('blue'));
caxis([-90 -10]);
s=colorbar('fontname','consolas','fontsize',12);
title(s,'^{o}C \cdot days','fontname','consolas');
set(gca,'fontsize',12)
title('EOF1: 61.38%','fontsize',16,'fontname','consolas');

subplot(2,1,2);
plot(1:35,PC1,'r','linewidth',2);
set(gca,'xtick',1:35,'xticklabels',1982:2016,'fontname','consolas','fontsize',12);
xlabel('Year','fontname','consolas');
ylabel('PC1','fontname','consolas');
xlim([1 35]);
set(gca,'fontsize',12,'linewidth',2)
xtickangle(90);
title('PC1: 61.38%','fontsize',16,'fontname','consolas');
```
![Image text](https://github.com/ZijieZhaoMMHW/m_mhw1.0/blob/master/store_figure/mhweof_b.png)
 Here we encounter the classical EOF issue, which leads to EOF and PC patterns that are exactly the opposite of what you would normally expect to see. Keep in mind that the original data can be reconstructed as the product of EOF and PC, so changing the sign of EOF and PC at the same time will not bother the reconstruction of the original data. Here we do so.
```
figure('pos',[ 198    19   525   786]);
subplot(2,1,1);
m_proj('miller','lon',[nanmin(lon_used) nanmax(lon_used)],'lat',[nanmin(lat_used) nanmax(lat_used)]);
m_pcolor(lon_used,lat_used,-sEOF1');
shading interp
m_coast('patch',[0.7 0.7 0.7],'linewidth',2);
m_grid('linewidth',2,'fontname','consolas');
colormap(m_colmap('jet'));
caxis([10 90]);
s=colorbar('fontname','consolas','fontsize',12);
title(s,'^{o}C \cdot days','fontname','consolas');
set(gca,'fontsize',12)
title('EOF1: 61.38%','fontsize',16,'fontname','consolas');

subplot(2,1,2);
plot(1:35,-PC1,'r','linewidth',2);
set(gca,'xtick',1:35,'xticklabels',1982:2016,'fontname','consolas','fontsize',12);
xlabel('Year','fontname','consolas');
ylabel('PC1','fontname','consolas');
xlim([1 35]);
set(gca,'fontsize',12,'linewidth',2)
xtickangle(90);
title('PC1: 61.38%','fontsize',16,'fontname','consolas');
```
![Image text](https://github.com/ZijieZhaoMMHW/m_mhw1.0/blob/master/store_figure/mhweof_a.png)

The first EOF mode based on cumulative intensity resembles the output from [annual MHW days](https://github.com/ZijieZhaoMMHW/m_mhw1.0/blob/master/examples/mhweof.md), which is kind of reasonable as suggested by previous literature. 
