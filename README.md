[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1044368.svg)](https://doi.org/10.5281/zenodo.1044368)

This repository contains code to accompany the manuscript titled

### Symbiont shuffling linked to differential photochemical dynamics of *Symbiodinium* in three Caribbean reef corals

by **Ross Cunning, Rachel N. Silverstein, and Andrew C. Baker**  
in *Coral Reefs* (doi: [10.1007/s00338-017-1640-3](http://dx.doi.org/10.1007/s00338-017-1640-3))

In this manuscript, we describe changes in *Symbiodinium* community structure ('symbiont shuffling') in three corals during experimental thermal bleaching and recovery. We demonstrate that the magnitude of shuffling can be predicted by the relative difference in photochemical efficiency of co-occurring symbionts under stress, and the duration of thermal stress applied.


#### Repository contents:

* **data/master.csv:** Contains photophysiological data and symbiont community structure data used in this study. Column headers are as follows:
    + *Species*: Coral host species (Ss=*S. siderea*, Mc=*M. cavernosa*, Of=*O. faveolata*)
    + *Colony*: ID of coral host colony
    + *Core*: ID of individual core (fragment of colony)
    + *BleachLvl*: Duration of heat stress treatment (Low=7 days, Med=10 days, High=14 days)
    + *Total.init*: Total symbiont to host cell ratio before heat stress
    + *PropD.init*: Proportion of symbionts in clade D before heat stress
    + *MaxY.init*: Fv/Fm measured before heat stress
    + *Total.bleach*: Total symbiont to host cell ratio at end of heat stress
    + *PropD.bleach*: Proportion of symbionts in clade D at end of heat stress
    + *MaxY.bleach*: Fv/Fm measured at end of heat stress
    + *Total.recov*: Total symbiont to host cell ratio after 3 months recovery
    + *PropD.recov*: Proportion of symbionts in clade D after 3 months recovery
    + *MaxY.recov*: Fv/Fm measured after 3 months recovery
    + *\*2*: As above, but for repeated bleaching and recovery (only for *M. cavernosa*).
For additional details on experimental design and data collection, see [Cunning et al. 2015](dx.doi.org/10.1098/rspb.2014.1725) and [Silverstein et al. 2015](dx.doi.org/10.1111/gcb.12706).
    
* **analysis/:** Contains an R Markdown document (analysis.Rmd) with commented code to reproduce all data analysis and figures presented in the manuscript. Knitting this document produces the HTML output (analysis.html) and saves the R environment as an RData file (analysis.RData).

* **figures/:** Contains png files for each figure included in the manuscript. Code to generate these figures can be found in **analysis/analysis.Rmd**.
