# Multi-variate Analysis for FLIM 

Determination of Coefficient of Variation in complex FLIM datasets under different imaging conditions
Main code is run through "streamlinedversion.m." Requries text file input with headers:
ImageFile,	KIValue,	KIConcen,	ManualCFDClass,	FluorescentDye,	Day,	ROI,	LaserPower,	BinNumber, CollectionTime.
Not all columns must contain information.

## Results

- **Large Cov is associated with long-lifetime FLIM data**

## Goals

- Compare two  distinct lifetime distributions over time/ days
- Compare many distinct lifetimes over singleday/ time-lapse
- Compare live changes using a quencher
  - Translate result into biexponential dataset and biological samples
  - Examine acqusition parameters / Test pile-up correction
  - Examine solutions both hardware and software  
