# Multi-variate Analysis for FLIM 

Determination of coefficient of variation in complex FLIM datasets with various lifetimes.
Main code for getting lifetime statistics is run through "MAIN_streamlinedversion.m." Requries text file input with headers:
ImageFile,	KIConcen,	FluorescentDye,	Day,	ROI,	LaserPower,	BinNumber, CollectionTime. Not all columns must contain information.
The associated image files should have .asc or .tif files of mean lifetime (or colorcodedvalue from SPCImage analysis), 
photon count, and/or chi-squared values. 

The gramm data visualization toolbox is used for figure creation. 

## Results

- **Large CV is associated with long-lifetime FLIM data**
  
![image](https://github.com/uw-loci/MultivariateAnalysis_FLIM/assets/111527077/6bfc9655-d9c9-485f-924f-8459dc3978d9)

## To Run CRLB Code (20240320)
 - _Download python code "crlb.py" written by Christoph Thiele (2021)_
 - 	has been edited from the original repository (https://github.com/thielec/CRLB_FL-SMLM/blob/main/crlb.py)
   	to include a call to the tau function
 - _Download  and run matlab code "plot_dye_crlb_cv.m" to generate plot_
 - 	specify any folders or python environments - mpmath is required to run the python code
 - 	specify parameters to evaluate crlb (see python code for details)
 - 	load experimental data (mean lifetime and CV of values)
