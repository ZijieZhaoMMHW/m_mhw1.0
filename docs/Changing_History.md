Changing History
==================================================================

2018-12-14
-------------
Updating the algorithm to calculate the climatologies and thresholds with help from Maxime Marin (<Maxime.Marin@csiro.au>).

2023-6-16
-------------
Rewrite the `detect` function, enabling the category of MHW (Hobday et al., 2018) and adding a new output `category_ts`, which is the category of MHW on each day.
Rewrite the `mean_and_trend` function, making it much faster.
Rewrite the example for better interpretation. 

Ongoing changes:
Enabling different algorithms to detect MHWs.
Writing more examples, including seasonality of MHWs, analysis of MHW category, and more advanced MHW analysis such as EOF and basic machine learning methods.
Writing the algorithm to detect spatiotemporal MHWs, such as results in Sun et al. (2023) and Bonino et al. (2023).

2023-6-23
-------------
Adding a new example about analysis of seasonality and monthly variability of MHWs.

2023-6-27
-------------
Adding a new example about EOF analysis on MHW metrics.

2023-8-5
-------------
Adding a new example about MHW category analysis.

2023-9-20
-------------
Adding a new example about EOF analysis on MHW cumulative intensity.

2023-12-1
-------------
Fixing a small error in the function `detect`

2024-10-17
-------------
Fixing a small error in the function `mean_and_trend`
