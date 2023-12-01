%% 1. Loading data

% Load NOAA OI SST V2 data
sst_full=NaN(32,32,datenum(2016,12,31)-datenum(1982,1,1)+1);
for i=1982:2016;
    file_here=['sst_' num2str(i)];
    load(file_here);
    eval(['data_here=sst_' num2str(i) ';'])
    sst_full(:,:,(datenum(i,1,1):datenum(i,12,31))-datenum(1982,1,1)+1)=data_here;
end

%% 2. Compare detect() and detectc()
tic
[MHW,mclim,m90,mhw_ts]=detect(sst_full,datenum(1982,1,1):datenum(2016,12,31),datenum(1982,1,1),datenum(2005,12,31),datenum(1993,1,1),datenum(2016,12,31));; %take about 30 seconds.
toc

tic
[MHWc,mclimc,m90c,mhw_tsc]=detectc(sst_full,datenum(1982,1,1):datenum(2016,12,31),datenum(1982,1,1),datenum(2005,12,31),datenum(1993,1,1),datenum(2016,12,31));; %take about 30 seconds.
toc

num_mhw=cellfun(@(x)size(x,1),MHWc);
num_mhw=nansum(num_mhw(:))