m_mhw
==================================================================
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/bcdba7f2a9ab428bbdc28629bf5bce22)](https://www.codacy.com/app/ZijieZhaoMMHW/m_mhw1.0?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=ZijieZhaoMMHW/m_mhw1.0&amp;utm_campaign=Badge_Grade)
[![DOI](http://joss.theoj.org/papers/10.21105/joss.01124/status.svg)](https://doi.org/10.21105/joss.01124)

The **`m_mhw`** toolbox is an matlab - based tool designed to detect and analyse spatial marine heatwaves (MHWs). Previously, approaches to detecting and analysing MHW time series have been applied in python (https://github.com/ecjoliver/marineHeatWaves, written by Eric C. J. Oliver) and R (Schlegel and Smit, 2018). 

The **`m_mhw`** toolbox is designed 1) to determine spatial MHWs according to the definition provided in Hobday et al. (2016) and marine cold spells (MCSs) introduced in Schlegel et al. (2017); 2) to visualize MHW/MCS event in a particular location during a period; 3) to explore the mean states and trends of MHW metrics, such as what have done in Oliver et al. (2018). 

The detection of MHW/MCS in each grid of data is done by simple loops instead of parallel computation. This is due to the fact that the size of detected MHW/MCS events (i.e. the number of events) is absolutely unknown, hence the resultant output MHW matrix has to be changed in each step. This is against the principle of parallel computation, which requires the independence of each step of calculation. Although we could still achieve parallel computation by detecting and storing each MHW independently, it means that we need to add another loop to combine them into a new matrix. If we do so, the resultant codes would only be a little bit faster than original codes using simple loops. Additionally, introducing parallel computation could also increase the complexity of this toolbox, which could be hard to handle by new users to matlab.

Installation
-------------

The installation of this toolbox could be directly achieved by downloading this repositories and add its path in your MATLAB.

Requirements
-------------

The MATLAB Statistics and Machine Learning Toolbox. [m_map](https://www.eoas.ubc.ca/~rich/map.html) is recommended for running example.

Functions
-------------

<table>
<colgroup>
<col width="17%" />
<col width="82%" />
</colgroup>
<thead>
<tr class="header">
<th>Function</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><code>detect()</code></td>
<td>The main function, aiming to detect spatial MHW/MCS events following definition given by Hobday et al. (2016). </td>
</tr>
<tr class="even">
<td><code>event_line()</code></td>
<td>The function to create a line plot of MHW/MCS in a particular grid during a particular period.</td>
</tr>
<tr class="odd">
<td><code>mean_and_trend()</code></td>
<td>The function to calculate spatial mean states and annual trends of MHW/MCS properties. </td>
</tr>
<tr class="even">
<td><code>composites()</code></td>
<td>The function to calculate composites for a particular dataset across a particular index. </td>
</tr>
</tbody>
</table>

Additionally, this toolbox also provides sea surface temperature off eastern Tasmania [147-155E, 45-37S] during 1982-2015, extracted from NOAA OI SST V2 (Reynolds et al., 2007).

Inputs and outputs
--------------------

The core function `detect` need some inputs:

<table>
<colgroup>
<col width="17%" />
<col width="82%" />
</colgroup>
<thead>
<tr class="header">
<th>Variable</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><code>temp</code></td>
<td>A 3D matrix containing temperature data. </td>
</tr>
<tr class="even">
<td><code>time</code></td>
<td>A numeric vector indicating the time corresponding to temp in the format of <code>datenum()<code>. </td>
</tr>
<tr class="odd">
<td><code>cli_start</code></td>
<td>A numeric value indicating the starting date for calculating climatology in the format of <code>datenum()<code>. </td>
</tr>
<tr class=“even”>
<td><code>cli_end</code></td>
<td>A numeric value indicating the ending date for calculating climatology in the format of <code>datenum()<code>.</td>
</tr>
<tr class=“odd”>
<td><code>mhw_start</code></td>
<td>A numeric value indicating the starting date for detection of MHW in the format of <code>datenum()<code>.</td>
</tr>
<tr class=“even”>
<td><code>mhw_end</code></td>
<td>A numeric value indicating the ending date for detection of MHW in the format of <code>datenum()<code>.</td>
</tr>
</tbody>
</table>

The core function `detect` would return four outputs, which are `MHW`, `mclim`, `m90` and `mhw_ts`. Their descriptions are summarized in following table. 

<table>
<colgroup>
<col width="17%" />
<col width="82%" />
</colgroup>
<thead>
<tr class="header">
<th>Variable</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><code>MHW</code></td>
<td>A table containing all detected MHW/MCS events, where every row corresponds to a particular event and every column indicates a metric or property. </td>
</tr>
<tr class="even">
<td><code>mclim</code></td>
<td>A 3D numeric matrix in size of (x,y,366), containing climatologies in each grid for every Julian day. </td>
</tr>
<tr class="odd">
<td><code>m90</code></td>
<td>A 3D numeric matrix in size of (x,y,366), containing thresholds in each grid for every Julian day. </td>
</tr>
<tr class=“even”>
<td><code>mhw_ts</code></td>
<td>A 3D numeric matrix in size of (x,y,(datenum(MHW_end)-datenum(MHW_start)+1)), containing daily MHW/MCS intensity. 0 in this variable indicates that corresponding day is not in a MHW/MCS event and NaN indicates missing value or lands. </td>
</tr>
</tbody>
</table>

The major output `MHW` contains all detected MHW/MCS events, characterized by 9 different properties, including:

<table>
<colgroup>
<col width="17%" />
<col width="82%" />
</colgroup>
<thead>
<tr class="header">
<th>Property</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><code>mhw_onset</code></td>
<td>A numeric vector indicating the onset date (YYYYMMDD) of each event. </td>
</tr>
<tr class="even">
<td><code>mhw_end</code></td>
<td>Similar to <code>mhw_onset</code>, but indicating the end date (YYYYMMDD). </td>
</tr>
<tr class="odd">
<td><code>mhw_dur</code></td>
<td>A numeric vector indicating the duration (days) of each event. </td>
</tr>
<tr class=“even”>
<td><code>int_max</code></td>
<td>A numeric vector indicating the maximum intensity of each event in unit of deg. C. </td>
</tr>
<tr class=“odd”>
<td><code>int_mean</code></td>
<td>A numeric vector indicating the mean intensity of each event in unit of deg. C. </td>
</tr>
<tr class=“even”>
<td><code>int_var</code></td>
<td>A numeric vector indicating the variance of intensity of each event. </td>
</tr>
<tr class=“odd”>
<td><code>int_cum</code></td>
<td>A numeric vector indicating the cumulative intensity of each event in unit of deg. C x days. </td>
</tr>
<tr class=“even”>
<td><code>xloc</code></td>
<td>A numeric vector indicating the location of each event in the x-dimension of temperature data. </td>
</tr>
<tr class=“odd”>
<td><code>yloc</code></td>
<td>A numeric vector indicating the location of each event in the y-dimension of temperature data. </td>
</tr>
</tbody>
</table>

For information of other functions, please see `help` text via MATLAB. For practical tutorial and example, please see following contents.

Example
----------

We provide an [example](https://github.com/ZijieZhaoMMHW/m_mhw1.0/blob/master/testing/an_example.md) about how to use functions in **`m_mhw`** and how to apply them to real-world data. Its associated code could be found [here](https://github.com/ZijieZhaoMMHW/m_mhw1.0/blob/master/testing/an_example.m).

Issues
--------------------

The results from this toolbox would be slightly different from outputs from Python and R modules. This is due to the fact that MATLAB follows different rules to calculate percentile thresholds. The number of detected events from this toolbox would be slightly less than that from Python and R. Please see a [comparison](https://github.com/ZijieZhaoMMHW/m_mhw1.0/blob/master/testing/compare_M_R.md). If you would like to get the same outputs as python, please set the optional input `'percentile'` as `'python'` (default is `'matlab'`).

Contributing to **`m_mhw`**
----------

To contribute to the package please follow the guidelines [here](https://github.com/ZijieZhaoMMHW/m_mhw1.0/blob/master/docs/Contributing_to_mmhw.md).

Please use this [link](https://github.com/ZijieZhaoMMHW/m_mhw1.0/issues) to report any bugs found.

References
----------

Hobday, A.J. et al. (2016). A hierarchical approach to defining marine heatwaves, Progress in Oceanography, 141, pp. 227-238.

Schlegel, R. W., Oliver, E. C. J., Wernberg, T. W., Smit, A. J., 2017. Nearshore and offshore co-occurrences of marine heatwaves and cold-spells. Progress in Oceanography, 151, pp. 189-205.

Schlegel, R. W. and Smit, A. J, 2018. heatwaveR: A central algorithm for the detection of heatwaves and cold-spells. The Journal of Open Source Software, 3, p.821.

Oliver, E.C., Lago, V., Hobday, A.J., Holbrook, N.J., Ling, S.D. and Mundy, C.N., 2018. Marine heatwaves off eastern Tasmania: Trends, interannual variability, and predictability. Progress in Oceanography, 161, pp.116-130.

Reynolds, Richard W., Thomas M. Smith, Chunying Liu, Dudley B. Chelton, Kenneth S. Casey, Michael G. Schlax, 2007: Daily High-Resolution-Blended Analyses for Sea Surface Temperature. J. Climate, 20, 5473-5496. 

Contact
-------

Zijie Zhao

School of Earth Science, The University of Melbourne

Parkville VIC 3010, Melbourne, Australia

E-mail: <zijiezhaomj@gmail.com> 

Maxime Marin

CSIRO Oceans & Atmosphere, Indian Ocean Marine Research Centre

Crawley 6009, Western Australia, Australia

E-mail: <Maxime.Marin@csiro.au> 

