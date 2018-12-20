%% An example about how to apply m_mhw to real-world data
% Here we provide an example about how to apply m_mhw to real-world data.

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
size(sst_full); %size of data
datenum(2016,12,31)-datenum(1982,1,1)+1 % The temporal length is 35 years.

%% 2. Detecting MHWs and MCSs

% Here we detect marine heatwaves off eastern Tasmania based on the
% traditional definition of MHWs (Hobday et al. 2016). We detected MHWs
% during 1993 to 2016 for climatologies and thresholds in 1982 to 2005.

[MHW,mclim,m90,mhw_ts]=detect(sst_full,datenum(1982,1,1):datenum(2016,12,31),datenum(1982,1,1),datenum(2005,12,31),datenum(1993,1,1),datenum(2016,12,31));; %take about 30 seconds.

% Additionally, we also detect MCSs during 1982 to 2005 based on the same
% climatologies. 

[MCS,~,m10,mcs_ts]=detect(sst_full,datenum(1982,1,1):datenum(2016,12,31),datenum(1982,1,1),datenum(2005,12,31),datenum(1993,1,1),datenum(2016,12,31),'Event','MCS','Threshold',0.1);

% Have a look of these two data.
MHW(1:5,:);
MCS(1:5,:);

% You could see that the properties `mhw_onset` and `mhw_end` are in a
% strange format. This is due to the fact that they are originally
% constructed in numeric format. We could change it to date format by
% following steps.

datevec(num2str(MHW{1:5,:}),'yyyymmdd') % vector
datestr(datevec(num2str(MHW{1:5,:}),'yyyymmdd')) % string
datenum(num2str(MHW{1:5,:}),'yyyymmdd') % number

%% 3. Visualizing MHW/MCS time series

% Have a look of MHW events in grid (1,2) from Sep 2015 to Apr 2016
figure('pos',[10 10 1000 1000]);
event_line(sst_full,MHW,mclim,m90,[1 2],1982,[2015 9 1],[2016 5 1]);

% Have a look of MCS events in grid (1,2) during 1994
figure('pos',[10 10 1000 1000]);
event_line(sst_full,MCS,mclim,m10,[1 2],1982,[1994 1 1],[1994 12 31],'Event','MCS','Color',[0.5 0.5 1]);

%% 4. Mean states and trends

% Please note that this section requires the toolbox m_map

% Now we would like to know the mean states and annual trends of MHW
% frequency, i.e. how many MHW events would be detected per year and how it
% changes with time.

[mean_freq,annual_freq,trend_freq,p_freq]=mean_and_trend(MHW,mhw_ts,1982,'Metric','Frequency');

% These four outputs separately represent the total mean, annual mean,
% annual trend and associated p value of frequency.

% This function could detect mean states and trends for six different
% variables (Frequency, mean intensity, max intensity, duration and total
% MHW/MCs days). 

metric_used={'Frequency','MeanInt','MaxInt','CumInt','Duration','Days'};

for i=1:6;
    eval(['[mean_' metric_used{i} ',annual_' metric_used{i} ',trend_' metric_used{i} ',p_' metric_used{i} ']=mean_and_trend(MHW,mhw_ts,1993,' '''' 'Metric' '''' ',' 'metric_used{i}' ');'])
end

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

%% 5. Applying cluster algoirthm to MHW - A kmeans example.

% We get so many MHWs now.... Could we distinguish them into different
% gropus based on their metrics?

% Change it to matrix;
MHW_m=MHW{:,:};

% Extract mean, max, cumulative intensity and duration.
MHW_m=MHW_m(:,[3 4 5 7]); 

[data_for_k,mu,sd]=zscore(MHW_m);

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



% Use 9 groups.

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

loc_x=[1.5 1.5 1.5 2.5 2.5 2.5 3.5 3.5 3.5];
loc_y=[1.5 2.5 3.5 1.5 2.5 3.5 1.5 2.5 3.5];
text_used={['1: ' num2str(round(prop_9(1)*100)) '%'],['2: ' num2str(round(prop_9(2)*100)) '%'],['3: ' num2str(round(prop_9(3)*100)) '%'],...
    ['4: ' num2str(round(prop_9(4)*100)) '%'],['5: ' num2str(round(prop_9(5)*100)) '%'],['6: ' num2str(round(prop_9(6)*100)) '%'],...
    ['7: ' num2str(round(prop_9(7)*100)) '%'],['8: ' num2str(round(prop_9(8)*100)) '%'],['9: ' num2str(round(prop_9(9)*100)) '%']};



figure('pos',[10 10 1500 1500]);

h=subplot(2,2,1);
data_here=k_9(:,1);
data_here=reshape(data_here,3,3);
data_here(:,end+1)=data_here(:,end);
data_here(end+1,:)=data_here(end,:);
pcolor(1:4,1:4,data_here);
set(h,'ydir','reverse');
axis off
colormap(jet);
text(loc_x,loc_y,text_used,'fontsize',16,'horiz','center','fontweight','bold');
colorbar;
title('Durations','fontsize',16,'fontweight','bold');

h=subplot(2,2,2);
data_here=k_9(:,2);
data_here=reshape(data_here,3,3);
data_here(:,end+1)=data_here(:,end);
data_here(end+1,:)=data_here(end,:);
pcolor(1:4,1:4,data_here);
axis off
set(h,'ydir','reverse');
colormap(jet);
text(loc_x,loc_y,text_used,'fontsize',16,'horiz','center','fontweight','bold');
colorbar
title('MaxInt','fontsize',16,'fontweight','bold');

h=subplot(2,2,3);
data_here=k_9(:,3);
data_here=reshape(data_here,3,3);
data_here(:,end+1)=data_here(:,end);
data_here(end+1,:)=data_here(end,:);
pcolor(1:4,1:4,data_here);
axis off
set(h,'ydir','reverse');
colormap(jet);
text(loc_x,loc_y,text_used,'fontsize',16,'horiz','center','fontweight','bold');
colorbar
title('MeanInt','fontsize',16,'fontweight','bold');

h=subplot(2,2,4);
data_here=k_9(:,4);
data_here=reshape(data_here,3,3);
data_here(:,end+1)=data_here(:,end);
data_here(end+1,:)=data_here(end,:);
[x,y]=meshgrid(1:4,1:4);
pcolor(1:4,1:4,data_here);
set(h,'ydir','reverse');
axis off
colormap(jet);
text(loc_x,loc_y,text_used,'fontsize',16,'horiz','center','fontweight','bold');
colorbar
title('CumInt','fontsize',16,'fontweight','bold');

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

sst_1993_2016=ssta_full(:,:,(datenum(1993,1,1):datenum(2016,12,31))-datenum(1982,1,1)+1);
time_used=MHW{:,:};
time_used=time_used(:,1:2);
start_full=datenum(num2str(time_used(:,1)),'yyyymmdd')-datenum(1993,1,1)+1;
end_full=datenum(num2str(time_used(:,2)),'yyyymmdd')-datenum(1993,1,1)+1;


for i=1:9;
    start_here=start_full(k==i);
    end_here=end_full(k==i);
    
    index_here=[];
    
    for j=1:length(start_here);
        period_here=start_here(j):end_here(j);
        index_here=[index_here;period_here(:)];
    end
    
    eval(['sst_' num2str(i) '=nanmean(sst_1993_2016(:,:,index_here),3);'])
    
end

color_used=hot;
color_used=color_used(end:-1:1,:);
figure('pos',[10 10 1500 1500]);

plot_index=[1 4 7 2 5 8 3 6 9];

for i=1:9;
    eval(['plot_here=sst_' num2str(i) ';']);
    subplot(3,3,plot_index(i));
    eval(['data_here=sst_' num2str(i) ';'])
    
    m_contourf(lon_used,lat_used,data_here',-3:0.1:3,'linestyle','none');
    
    
    if i~=3;
    m_grid('xtick',[],'ytick',[]);
    else;
        m_grid('linestyle','none');
    end
    m_gshhs_h('patch',[0 0 0]);
    colormap(color_used);
    caxis([0 2]);
    
    title(['Group (' num2str(i) '):' num2str(round(prop_9(i)*100)) '%'],'fontsize',16);
    
end

hp4=get(subplot(3,3,9),'Position');   
s=colorbar('Position', [hp4(1)+hp4(3)+0.025  hp4(2)  0.025  0.85],'fontsize',14);
s.Label.String='^{o}C';
    








    







h1=gca;
data_1=magic(20);
data_1(11:20,:)=nan;
contour(data_1,'parent',h1);
colormap(h1,'jet');
h2=axes('position',get(h1,'position'),'color','none');
hold on
data_2=rand(20,20);
data_2(1:10,:)=nan;
contour(data_2,'parent',h2);
colormap(h2,'winter');

