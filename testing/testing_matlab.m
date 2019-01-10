%% This file is MATLAB source code for Comparing Outputs from mhw and python modules.


sst_full=NaN(32,32,datenum(2016,12,31)-datenum(1982,1,1)+1);
for i=1982:2016;
    file_here=['sst_' num2str(i)];
    load(file_here);
    eval(['data_here=sst_' num2str(i) ';'])
    sst_full(:,:,(datenum(i,1,1):datenum(i,12,31))-datenum(1982,1,1)+1)=data_here;
end
% choose data in grid (1,2)
sst_1_2=sst_full(1,2,:);
% write it into csv file
csvwrite('sst_1_2.csv',[1;round(sst_1_2(:),2)]);
% read it again to make sure MATLAB and Python get data from the same file
sst_1_2=csvread('sst_1_2.csv');
% detecting MHW using MATLAB
[MHW,mclim,m90,mhw_ts]=detect(reshape(sst_1_2,1,1,length(sst_1_2)),datenum(1982,1,1):datenum(2016,12,31),datenum(1982,1,1),datenum(2005,12,31),datenum(1982,1,1),datenum(2016,12,31));

% reading the climatology and threshold from python
mclim_p=ncread('threshold_climatology','climatology');
m90_p=ncread('threshold_climatology','threshold');
mclim_p=mclim_p((datenum(2000,1,1):datenum(2000,12,31))-datenum(1982,1,1)+1);
m90_p=m90_p((datenum(2000,1,1):datenum(2000,12,31))-datenum(1982,1,1)+1);

% comparing the difference
% we need to round it into 8 decimal point to avoid the difference caused by
% different programming language's way to store data
nansum(round(mclim_p(:),8)==round(mclim(:),8))
% get 366, climatology is absolutely the same

% what about threshold
nansum(round(m90_p(:),8)==round(m90(:),8))
% get 0, absolutely not the same

% Is the way to detetc MHW different?
% To answer this, we use the threshold from python to determine MHWs
[MHW_p,mclim,m90,mhw_ts]=detect_justfortest(reshape(sst_1_2,1,1,length(sst_1_2)),datenum(1982,1,1):datenum(2016,12,31),datenum(1982,1,1),datenum(2005,12,31),datenum(1982,1,1),datenum(2016,12,31),reshape(m90_p,1,1,366));


