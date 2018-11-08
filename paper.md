A MATLAB toolbox to detect and analyze marine heatwaves
==================================================================

As a result of the increase in global temperature (Hansen et al., 2006; New et al., 2011; IPCC, 2014), frequent oceanic thermal extremes have been observed in various regions (Garrabou et al., 2009; Oliver et al., 2017, 2018b). With increased frequency and implication (Oliver et al., 2018a), marine heatwaves (MHWs), which have been defined as discrete prolonged anomalously warm water events (Hobday et al., 2016), have received increasing scientific attention and focus. MHWs have been shown to have a significant impact in multiple areas, including the redistribution of marine species, mass mortality and marine life disease (Perry et al., 2005; Garrabou et al., 2009; Mills et al., 2013; Wernberg et al., 2013). In some frontlines of climate change (e.g. the oceanic region of eastern Tasmania; Hobday and Pecl, 2014), MHW is an important contributor toward the regional change of the climate system (Wernberg et al., 2013), as well as water properties (Oliver et al., 2018b). 

The framework for the definition of MHWs (Hobday et al., 2016) is based on the approach to determining atmospheric heatwaves (Perkins and Alexander, 2013). This approach defines a heatwave event in the atmosphere using percentile thresholds and a minimum duration of three days. Considering the fact that oceanic events have a larger temporal scale than atmospheric events, an MHW event is categorized as a thermal event when its associated temperature is larger than the 90th percentile threshold for at least 5 days, and two events with a temporal gap of less than 2 days are to be treated as a single joint event. The definition of a marine cold spell (MCS) is effectively the reverse of the definition of an MHW event, where an MCS event is defined as a period in which the associated temperature is lower than the 10th percentile (Schlegel et al., 2017). 

The code implementation of MHW has been done in Python (https://github.com/ecjoliver/marineHeatWaves) and R (Schlegel and Smit, 2018). In this paper, we provide a MATLAB toolbox for use in detecting and analyzing MHW/MCS. This toolbox includes functions for detecting, visualizing and calculating mean states and annual trends for MHW metrics. Compared to modules in Python and R, this toolbox could be used to detect spatial MHW/MCS, i.e. events in each grid of the dataset. This process is achieved using simple loops instead of parallel computation. Parallel computation is not suitable here as the size of the resultant MHW/MCS dataset would change with loops, which is against the rule that each loop should be independent of others in a parallel computation. It should be noted that parallel computation could be used if each detected event is stored independently. However, this would mean that another loop should be included to all events into one composite. We have tested this approach and found that it would not be faster than the version using simple loops. Additionally, this toolbox has been developed into a relatively simple version, with basic inputs and concisely formatted outputs to accommodate MATLAB users of all levels.







Reference
-------------
Garrabou, J., Coma, R., Bensoussan, N., Bally, M., Chevaldonné, P., Cigliano, M., Díaz, D., Harmelin, J.G., Gambi, M.C., Kersting, D.K. and Ledoux, J.B., 2009. Mass mortality in Northwestern Mediterranean rocky benthic communities: effects of the 2003 heat wave. Global change biology, 15(5), pp.1090-1103.

Hansen, J., Sato, M., Ruedy, R., Lo, K., Lea, D.W. and Medina-Elizade, M., 2006. Global temperature change. Proceedings of the National Academy of Sciences, 103(39), pp.14288-14293.

Hobday, A.J. and Pecl, G.T., 2014. Identification of global marine hotspots: sentinels for change and vanguards for adaptation action. Reviews in Fish Biology and Fisheries, 24(2), pp.415-425.

Hobday, A.J., Alexander, L.V., Perkins, S.E., Smale, D.A., Straub, S.C., Oliver, E.C., Benthuysen, J.A., Burrows, M.T., Donat, M.G., Feng, M. and Holbrook, N.J., 2016. A hierarchical approach to defining marine heatwaves. Progress in Oceanography, 141, pp.227-238.

IPCC. 2014. Climate change 2014: synthesis report. Contribution of Working Groups I, II and III to the fifth assessment report of the Intergovernmental Panel on Climate Change. Edited by L.A. Meyer and R.K. Pachauri. Geneva: IPCC.

Mills, K.E., Pershing, A.J., Brown, C.J., Chen, Y., Chiang, F.S., Holland, D.S., Lehuta, S., Nye, J.A., Sun, J.C., Thomas, A.C. and Wahle, R.A., 2013. Fisheries management in a changing climate: lessons from the 2012 ocean heat wave in the Northwest Atlantic. Oceanography, 26(2), pp.191-195.

New, M., Liverman, D., Schroder, H. and Anderson, K., 2011. Four degrees and beyond: the potential for a global temperature increase of four degrees and its implications.

Oliver, E.C., Benthuysen, J.A., Bindoff, N.L., Hobday, A.J., Holbrook, N.J., Mundy, C.N. and Perkins-Kirkpatrick, S.E., 2017. The unprecedented 2015/16 Tasman Sea marine heatwave. Nature communications, 8, p.16101.

Oliver, E.C., Donat, M.G., Burrows, M.T., Moore, P.J., Smale, D.A., Alexander, L.V., Benthuysen, J.A., Feng, M., Gupta, A.S., Hobday, A.J. and Holbrook, N.J., 2018. Longer and more frequent marine heatwaves over the past century. Nature communications, 9(1), p.1324.

Oliver, E.C., Lago, V., Hobday, A.J., Holbrook, N.J., Ling, S.D. and Mundy, C.N., 2018. Marine heatwaves off eastern Tasmania: Trends, interannual variability, and predictability. Progress in Oceanography, 161, pp.116-130.

Perkins, S.E. and Alexander, L.V., 2013. On the measurement of heat waves. Journal of Climate, 26(13), pp.4500-4517.

Perry, A.L., Low, P.J., Ellis, J.R. and Reynolds, J.D., 2005. Climate change and distribution shifts in marine fishes. science, 308(5730), pp.1912-1915.

Schlegel, R.W. and Smit, A.J., 2018. heatwaveR: A central algorithm for the detection of heatwaves and cold-spells. The Journal of Open Source Software, 3, p.821.

Schlegel, R.W., Oliver, E.C., Wernberg, T. and Smit, A.J., 2017. Nearshore and offshore co-occurrence of marine heatwaves and cold-spells. Progress in oceanography, 151, pp.189-205.

Wernberg, T., Smale, D.A., Tuya, F., Thomsen, M.S., Langlois, T.J., De Bettignies, T., Bennett, S. and Rousseaux, C.S., 2013. An extreme climatic event alters marine ecosystem structure in a global biodiversity hotspot. Nature Climate Change, 3(1), p.78.


