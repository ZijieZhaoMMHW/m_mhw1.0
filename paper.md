A MATLAB toolbox to detect and analyse marine heatwaves
==================================================================

As the increase of global temperature, frequent oceanic thermal extremes have been observed in various regions. With increased frequency and implication, marine heatwaves (MHWs), which have been defined as discrete prolonged anomalously warm water events, have received more and more attention and focus. Previously, MHWs have been determined to have significant impact in multiple, including the redistribution of marine species, mass mortality and marine life disease. In some front lines of climate change (e.g. oceanic region of eastern Tasmania), MHW is an important contributor to regional change of climate system, as well as water properties. 

The frame work for the definition of MHWs was based on the approach to determining atmospheric heatwaves. This approach defined a heatwave event in atmosphere using percentile thresholds and minimum duration of three days. Considering the fact oceanic events have larger temporal scale than atmospheric, a MHW event was definied as a thermal event when its associated temperature is larger than 90th percentile threshold for at least 5 days and two events with temporal gap less than 2 days would be treated as one joint event. A marine cold spell (MCS) is defined following similar definition of MHW, but for period when temperature is smaller than 10th percentile. 

The code implementation of MHW has been done in python and R. In this paper, we provide a MATLAB toolbox to detect and analyze MHW/MCS. This toolbox includes functions for detecting, visualizing and calculating mean states and annual trends for MHW metrics. Compared to modules in python and R, this toolbox could be used to detect spatial MHW/MCS, i.e. events in each grid of dataset. This process is achieved by simple loops instead of parallel computation. Parallel computation is not suitable here due to the size of resultant MHW/MCS dataset would change with loops, which is against the rule that each loop should be independent to others in parallel computation. It should be noted that parallel computation could be used if each detected event is stored independently. However, it means that another loop should be included to all events into one composite. We have tested this approach and found that it would not be faster than the version using simple loops. Additionally, this toolbox has been designed to a simply operated version for MATLAB users in different levels by simplifying the inputs and presenting outputs in concise format.






Reference
-------------
Hansen, J., Sato, M., Ruedy, R., Lo, K., Lea, D.W. and Medina-Elizade, M., 2006. Global temperature change. Proceedings of the National Academy of Sciences, 103(39), pp.14288-14293.

Perkins, S. E., and L. V. Alexander. "On the measurement of heat waves." Journal of Climate 26.13 (2013): 4500-4517.

