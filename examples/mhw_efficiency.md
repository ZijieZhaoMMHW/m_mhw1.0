Comparison for the efficiency biases between `detect` and `detectc`
==================================================================

Here we compare the efficiency biases between `detect` and `detectc`.

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

Comparing `detect` and `detectc`
-------------
Here we detect MHWs during 1982-2016 based on climatologies during 1982-2005.
```
tic
[MHW,mclim,m90,mhw_ts]=detect(sst_full,datenum(1982,1,1):datenum(2016,12,31),datenum(1982,1,1),datenum(2005,12,31),datenum(1993,1,1),datenum(2016,12,31));; %take about 30 seconds.
toc
```
It takes about ~10 seconds on my local machine.
```
tic
[MHWc,mclimc,m90c,mhw_tsc]=detectc(sst_full,datenum(1982,1,1):datenum(2016,12,31),datenum(1982,1,1),datenum(2005,12,31),datenum(1993,1,1),datenum(2016,12,31));; %take about 30 seconds.
toc
```
Using the function `detectc`, it takes only ~7 seconds and the biases will increase as the data size grows.

Examining `detectc` MHW outputs
-------------
Here we take a look at the MHW output from `detectc`. In this output, MHW events are stored in a cell, with each grid cell holding its corresponding MHWs.
```
>> size(MHWc{1,1})

ans =

    62    10
```
Here we can see 62 MHW events are detected in the grid (1,1).

Do we get the same number of events as what we got from `detect`?
```
>> num_mhw=cellfun(@(x)size(x,1),MHWc);
num_mhw=nansum(num_mhw(:))

num_mhw =

       70097
```
The total number of MHW events over the whole domain remains the same as the output from `detect`.


