---
title: 'A MATLAB toolbox to detect and analyze marine heatwaves'
tags:
- MATLAB
- heatwaves
- extremes
- ocean
authors:
- affiliation: "1, 2, 3, 4"
  name: Zijie Zhao
  orcid: 0000-0003-3403-878X
- affiliation: "2, 3, 5"
  name: Maxime Marin
  orcid: 0000-0001-7209-4454
date: "8 November 2018"
output: pdf_document
bibliography: paper.bib
affiliations:
- index: 1
  name: School of Earth Sciences, The University of Melbourne, Melbourne, Victoria, Australia
- index: 2
  name: Institute for Marine and Antarctic Studies, University of Tasmania, Hobart, Tasmania, Australia
- index: 3
  name: Australian Research Council Centre of Excellence for Climate System Science, Hobart, Tasmania, Australia
- index: 4
  name: College of Oceanic and Atmospheric Sciences, Ocean University of China, Qingdao, China
- index: 5
  name: CSIRO Oceans & Atmosphere, Indian Ocean Marine Research Centre, Crawley 6009, Western Australia, Australia

---

As a result of the increase in global temperature [@hansen2006global;@new2011four;@pachauri2014climate], frequent oceanic thermal extremes have been observed in various regions [@garrabou2009mass;@oliver2017unprecedented;@oliver2018marine]. With increased frequency and implication [@oliver2018longer], marine heatwaves (MHWs), which have been defined as discrete prolonged anomalously warm water events [@hobday2016hierarchical], have received increasing scientific attention and focus. MHWs have been shown to have a significant impact in multiple areas, including the redistribution of marine species, mass mortality and marine life disease [@perry2005climate;@garrabou2009mass;@mills2013fisheries;@wernberg2013extreme]. In some frontlines of climate change, e.g. oceanic regions off eastern Tasmania [@hobday2014identification], MHW is an important contributor toward the regional change of the climate system [@wernberg2013extreme], as well as water properties [@oliver2018marine]. 

The framework for the definition of MHWs [@hobday2016hierarchical] is based on the approach to determining atmospheric heatwaves [@perkins2013measurement]. This approach defines a heatwave event in the atmosphere using percentile thresholds and a minimum duration of three days. Considering the fact that oceanic events have a larger temporal scale than atmospheric events, an MHW event is categorized as a thermal event when its associated temperature is larger than the 90th percentile threshold for at least 5 days, and two events with a temporal gap of less than 2 days are to be treated as a single joint event. The definition of a marine cold spell (MCS) is effectively the reverse of the definition of an MHW event, where an MCS event is defined as a period in which the associated temperature is lower than the 10th percentile [@schlegel2017nearshore]. 

The code implementation of MHW has been done in Python (https://github.com/ecjoliver/marineHeatWaves) and R [@w2018heatwaver]. In this paper, we provide a MATLAB toolbox for use in detecting and analyzing MHW/MCS. This toolbox includes functions for detecting, visualizing and calculating mean states and annual trends for MHW metrics. Compared to modules in Python and R, this toolbox could be used to detect spatial MHW/MCS, i.e. events in each grid of the dataset. This process is achieved using simple loops instead of parallel computation. Parallel computation is not suitable here as the size of the resultant MHW/MCS dataset would change with loops, which is against the rule that each loop should be independent of others in a parallel computation. It should be noted that parallel computation could be used if each detected event is stored independently. However, this would mean that another loop should be included to all events into one composite. We have tested this approach and found that it would not be faster than the version using simple loops. Additionally, this toolbox has been developed into a relatively simple version, with basic inputs and concisely formatted outputs to accommodate MATLAB users of all levels.







Reference
-------------


