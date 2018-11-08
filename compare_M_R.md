Comparing Outputs from **`m_mhw`** and **`RmarineHeatWaves`**
==================================================================

Here we provide a comparison between outputs from **`m_mhw`** and **`RmarineHeatWaves`**

Let's have a look at MHW outputs in grid (1,2) during 1993 to 2016 based on climatologies and thresholds for 1982 to 2005.

```

[MHW,mclim,m90,mhw_ts]=detect(sst_full,1982,2005,1982,1993,2016);

event_comp=MHW{:,:};
event_comp=event_comp(event_comp(:,8)==1 & event_comp(:,9)==2,:);


```

There is an event during 05/10/1999 to 27/10/1999.

```

event_comp(6,1:2)
ans =
    19991005    19991027

```

See the same event in R output

```

try_sst<-read.csv('sst_1_2.csv',header=F)
library(RmarineHeatWaves)
t<-seq(from=as.Date('1982-01-01'), by=1, length.out=12784) 
useddata<-data.frame(t=t,temp=try_sst$V1)
colnames(useddata)<-c('t','temp')
sst<-make_whole(useddata)
mhw <- detect(sst, climatology_start = '1982-01-01', climatology_end = '2005-12-31')
event<-mhw$event
clim<-mhw$clim

event[28,c(5,6)]

# A tibble: 1 x 2
  date_start date_stop 
  <date>     <date>    
1 1999-10-05 1999-10-28

```

The event in R is in 05/10/1999 to 28/10/1999. What happened to 28/10/1999 in MATLAB?

Let's have a look of the raw temperature and 90th percentile threshold in grid (1,2) at 28/10/1999.

```

sst_full(1,2,datenum(1999,10,28)-datenum(1982,1,1)+1)
ans =
   13.1100

m90(1,2,datenum(2000,10,28)-datenum(2000,1,1)+1)
ans =
   13.1106

```

The raw temperature is colder than 90th percentile threshold, so it is not recongized as an MHW day.

What about the 90th percentile threshold in R

```

clim$thresh_clim_year[clim$t==as.Date('1999-10-28')]
[1] 13.10561

```

The thresholds calculated in R and MATLAB are slightly different since they follow different algorithms. It may induce few biaes for resultant MHW/MCS outputs but it does not impact states and trends of MHW/MCS in long temporal scale.
