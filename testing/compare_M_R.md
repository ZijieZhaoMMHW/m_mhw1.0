Comparing Outputs from **`m_mhw`** and Python module.
==================================================================

Here we provide a comparison between outputs from **`m_mhw`** and [**`marineHeatwaves.py`**](https://github.com/ecjoliver/marineHeatWaves/blob/master/marineHeatWaves.py).Its associated code could be found in the same folder. 
To simplify the testing process, we choose the `sst_full(1,2)` as the input dataset. 

```
sst_full=NaN(32,32,datenum(2016,12,31)-datenum(1982,1,1)+1);
for i=1982:2016;
    file_here=['sst_' num2str(i)];
    load(file_here);
    eval(['data_here=sst_' num2str(i) ';'])
    sst_full(:,:,(datenum(i,1,1):datenum(i,12,31))-datenum(1982,1,1)+1)=data_here;
end
% choose data in grid (1,2)
sst_1_2=sst_full(1,2,:);
```

We firstly write `sst_1_2` into a csv file. This is to make sure that MATLAB and python get data from the same file. We store the outputs as `MHW`,`mclim`,`m90`.

```
% write it into csv file
csvwrite('sst_1_2.csv',[1;round(sst_1_2(:),2)]);
% read it again to make sure MATLAB and Python get data from the same file
sst_1_2=csvread('sst_1_2.csv');
sst_1_2=sst_1_2(2:end);
% detecting MHW using MATLAB
[MHW,mclim,m90,mhw_ts]=detect(reshape(sst_1_2,1,1,length(sst_1_2)),datenum(1982,1,1):datenum(2016,12,31),datenum(1982,1,1),datenum(2005,12,31),datenum(1982,1,1),datenum(2016,12,31));

```

Then, we read it in python and use the marineHeatwaves.py module to analyse it. We store this result as `mhws` and `mclim`.

```
import os
import numpy as np
from datetime import date
import marineHeatWaves as mhw
t = np.arange(date(1982,1,1).toordinal(),date(2016,12,31).toordinal()+1)
import pandas as pd
data = pd.read_csv('sst_1_2.csv')
sst=[]
for i in range(0,12784):
    sst.append(float(np.array(data)[i]))
sst=np.array(sst)
mhws, clim=mhw.detect(t,sst,climatologyPeriod=[1982, 2005])
```

Then, we store the climatology and threshold for coming comparsion.

```
import netCDF4 as nc
da=nc.Dataset("threshold_climatology","w",format="NETCDF4")
da.createDimension("time",12784)
da.createVariable("threshold","f8",("time"))
da.createVariable("climatology","f8",("time"))
da.variables["threshold"][:]=clim['thresh']
da.variables['climatology'][:]=clim['seas']
da.close()
```

We could find slight differences. Fistly, MHW (via MATLAB) contains 93 events while mhws (via python) contains 94 events. Additionally, if you carefully look at these two variables, you could find small differences in events corresponding to the same period.

Based on the definition from Oliver et al. (2016), the detection of marine heatwaves is to find periods when temperature is larger than cliamtology-based threshold for at least 5 days while two events with <2 days' gap would be treated as one signle event. So, three factors could potentially cause the differences.

Climatology
-------------
The difference of calculated climatology could cause the differences between detected MHWs. Here we compare the calculated climatologies.

```
% reading the climatology and threshold from python
mclim_p=ncread('threshold_climatology','climatology');
m90_p=ncread('threshold_climatology','threshold');
mclim_p=mclim_p((datenum(2000,1,1):datenum(2000,12,31))-datenum(1982,1,1)+1);
m90_p=m90_p((datenum(2000,1,1):datenum(2000,12,31))-datenum(1982,1,1)+1);
```

Now we have `mclim_p` (from python) `mclim` (from matlab). Before comparing them, we need to firstly round them into 8 decimal point to avoid the difference caused by different programming language's way to store data.

```
nansum(round(mclim_p(:),8)==round(mclim(:),8))
ans =
   366
```

We get 366, so climatologies from MATLAB and python are absolutely the same.

Threshold
-------------
What about threshold?

```
nansum(round(m90_p(:),8)==round(m90(:),8))
ans =
     0
```

Threshold are absolutely not the same. So it could be caused by the fact that these two programming language use two different functions to calculate the percentile threshold.

Way to detect MHWs
-------------
Although thresholds are different, the difference between results could also be due to different ways to detect MHW period. So we write another function called `detect_justfortest`. This function is absolutely the same as `detect` except its threshold is one of inputs. Now, we use the `m90_p` as designed threshold, to see if MATLAB could get the same results from python. This output is stored as `MHW_p`.

```
[MHW_p,mclim,m90,mhw_ts]=detect_justfortest(reshape(sst_1_2,1,1,length(sst_1_2)),datenum(1982,1,1):datenum(2016,12,31),datenum(1982,1,1),datenum(2005,12,31),datenum(1982,1,1),datenum(2016,12,31),reshape(m90_p,1,1,366));
```

Now we get 94 events. Detailed comparsion has not been shown here but if you do it you could find its presented information is absolutely the same as output from python module.

Different way to calculate the percentile
-------------
The function `prctile` in MATLAB Statistics and Machine Learning Toolbox calculates the percentile based on a particular linear regression (see [details](https://au.mathworks.com/help/stats/prctile.html?searchHighlight=prctile&s_tid=doc_srchtitle)), while Python Numpy uses another algorithm. In R's [`stats` toolbox](https://www.rdocumentation.org/packages/stats/versions/3.5.2/topics/quantile), 9 types of percentile is recorded. Numpy's is the same as Type 7 while MATLAB's is similar to Type 5. Compared to Type 7, Type 5 is more popular in the study about hydrology (Hyndman and Fan, 1996), which is just the heatwave's condition. Additionally, the original paper (Oliver et al., 2016) has not mentioned the way to calculate the percentile, and we also want to make the result consistent with other MATLAB outputs (which are mostly based on Statistics and Machine Learning Toolbox). So, after carefull discussion, we decide to keep the difference and not change it. We also strongly suggest scientists to describe their way to calculate percentile in their future research especially when it is associated with methodology.


