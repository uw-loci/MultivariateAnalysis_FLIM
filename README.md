# Multi-variate Analysis for FLIM 

Determination of Coefficient of Variation in complex FLIM datasets under different imaging conditions

## Results

- **Large CV is associated with long-lifetime FLIM data**
  
![image](https://github.com/uw-loci/MultivariateAnalysis_FLIM/assets/111527077/6bfc9655-d9c9-485f-924f-8459dc3978d9)

## To Run Code (20240320)
 - _Download python code "crlb.py" written by Christoph Thiele (2021)_
 - 	has been edited from the original repository (https://github.com/thielec/CRLB_FL-SMLM/blob/main/crlb.py)
   	to include a call to the tau function
 - _Download  and run matlab code "plot_dye_crlb_cv.m" to generate plot_
 - 	specify any folders or python environments - mpmath is required to run the python code
 - 	specify parameters to evaluate crlb (see python code for details)
 - 	load experimental data (mean lifetime and CV of values)
