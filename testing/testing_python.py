
import netCDF4 as nc
import numpy as np
from datetime import date
import marineHeatWaves as mhw
t = np.arange(date(1982,1,1).toordinal(),date(2016,12,31).toordinal()+1)
nc_obj=nc.Dataset("sst_1_2.nc")
sst_1_2=nc_obj.variables['sst'][:]
mhws, clim=mhw.detect(t,sst_1_2,climatologyPeriod=[1982, 2005])

da=nc.Dataset("threshold_climatology","w",format="NETCDF4")
da.createDimension("time",12784)
da.createVariable("threshold","f8",("time"))
da.createVariable("climatology","f8",("time"))
da.variables["threshold"][:]=clim['thresh']
da.variables['climatology'][:]=clim['seas']
da.close()