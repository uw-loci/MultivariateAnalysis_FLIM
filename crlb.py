# -*- coding: utf-8 -*-
# crlb.py
#
# @author: Christoph Thiele, 2021
# See Mathematica file for details on derviation
'''
Functions to calculate the CRLB (minimum variance of an unbiased estimater) of
the lifetime tau and the background b based on a mono-exponential decay with
single photon detection.
'''
#import numpy as np
#import matplotlib.pyplot as plt

def tau(tau, n=1, b=0, T=float('inf'), b_fixed = False):
    '''
    def tau(tau, n=1, b=0, T=float('inf'), b_fixed=False):
      Calculates the CRLB (minimum variance of an unbiased estimater) of the 
      lifetime tau determined from a mono-expontial decay. Assumes by default 
      lifetime tau and background b need to be estimated. 
      tau: lifetime
      n: number of photons in decay
      b: fraction of background photons: (b=0) no BG, (b=1) only BG
      T: measurement window in the same units as tau. Eg: repetion period-cutoff
      b_fixed: b needs to estimated (=False), or is precisely known (=True)
      
      Scales inversely propotional to n: crlb.tau(2)/100 == crlb.tau(2,n=100)
    '''
    from mpmath import mpf,exp,log,polylog,cosh,sinh,isinf,isnan
    if isnan(tau) or isnan(n) or isnan(b) or isnan(T):
        # for nan input return nan
        return float('nan')
        
    assert tau>=0,         'lifetime tau needs to be positive'
    assert b>=0 and b<=1,  'background fraction needs to be between 0 and 1'
    assert n>=0,           'number of photons n needs to be positive'
    assert T>=0,           'measurement periode needs to be positive'
    
    assert type(b_fixed) == bool, 'b_fixed needs to be bool'
    #%%
    
    tau = mpf(tau)
    n = mpf(n)
    b = mpf(b)
    T = mpf(T)

    if tau == 0 or n == 0 or T == 0:
        # In these cases, we have no information about tau
        crlb_tau = mpf('inf')
        return float(crlb_tau)        
    
    # switch to relative measurement periode chi
    chi = T/tau
    if chi > 1e8:
        # set extremly large chi to inf to avoid numeric instabilities
        chi = mpf('inf')
    
        
    # replace b values that are close to the limits by the limit to avoid numeric instabilities
    if b < 1e-16:
        b = 0
    elif b > 1.0-1e-8:
        # for only background the lifetime cannot be determined
        b = 1
        crlb_tau = mpf('inf')
        return float(crlb_tau)
    
    # Case 1: infinite T
    if isinf(chi):
        crlb_tau = tau**2/(n-b*n)
        
    # Case 2: no bg (known), but finite T
    elif b_fixed and b==0:
            crlb_tau = (2*tau**2)/(2*n + chi**2*n - 2*n*cosh(chi)) - (2*tau**2*cosh(chi))/(2*n + chi**2*n - 2*n*cosh(chi))

    # Case 3: fixed bg (known), finite T
    elif b_fixed:
        crlb_tau = (chi*tau**2*(-1 + exp(chi))**2)/(n*(chi - 2*b*chi - 2*b*chi**2 - b*chi**3 - 2*chi*exp(chi) + 4*b*chi*exp(chi) + 2*b*chi**2*exp(chi) - chi**3*exp(chi) + b*chi**3*exp(chi) + chi*exp(2*chi) - 2*b*chi*exp(2*chi) - b*chi*(-1 + exp(chi))*(2 + chi + (-2 + chi)*exp(chi))*(log(b*(-1 + exp(chi))) - log(chi + b*(-1 - chi + exp(chi)))) + b*(1 + chi - exp(chi))**2*log((exp(chi)*(chi + b*(-1 - chi + exp(chi))))/(-b + (b + chi - b*chi)*exp(chi))) - 2*b*(-1 + exp(chi))*(1 + (-1 + chi)*exp(chi))*polylog(2,((-1 + b)*chi)/(b*(-1 + exp(chi)))) - 2*b*(-1 + exp(chi))*(-1 - chi + exp(chi))*polylog(2,((-1 + b)*chi*exp(chi))/(b*(-1 + exp(chi)))) - 2*b*(-1 + exp(chi))**2*polylog(3,((-1 + b)*chi)/(b*(-1 + exp(chi)))) + 2*b*(-1 + exp(chi))**2*polylog(3,((-1 + b)*chi*exp(chi))/(b*(-1 + exp(chi))))))
    
    # Case 4: no bg (unknown), finite T
    elif b==0:
        crlb_tau = (4*tau**2*(2 + chi**2 - 2*cosh(chi))*sinh(chi/2.))/(n*(-4*chi**3*cosh(chi/2.) + (12 + 12*chi**2 + chi**4)*sinh(chi/2.) - 4*sinh((3*chi)/2.)))
    
    # Case 5: unknown bg, finite T
    else:
        crlb_tau = (4*chi*tau**2*(-1 + exp(chi))**2*((-1 + b)*chi + log(-b + (b + chi - b*chi)*exp(chi)) - log(chi + b*(-1 - chi + exp(chi)))))/(n*(b*(2*chi + 2*chi**2 - b*chi**2 - 2*chi*exp(chi) + b*chi**2*exp(chi) - 2*b*chi*(-1 + exp(chi))*log(1 - (b*(-1 + exp(chi)))/((-1 + b)*chi)) - 2*(-1 + b)*chi*(-1 + exp(chi))*(log(b*(-1 + exp(chi))) - log(chi + b*(-1 - chi + exp(chi)))) + 2*(-1 - chi + exp(chi))*log((exp(chi)*(chi + b*(-1 - chi + exp(chi))))/(-b + (b + chi - b*chi)*exp(chi))) + 2*b*(-1 + exp(chi))*polylog(2,-((b - b*exp(-chi))/(chi - b*chi))) - 2*(-1 + b)*(-1 + exp(chi))*polylog(2,((-1 + b)*chi)/(b*(-1 + exp(chi)))) - 2*b*(-1 + exp(chi))*polylog(2,(b*(-1 + exp(chi)))/((-1 + b)*chi)) + 2*(-1 + b)*(-1 + exp(chi))*polylog(2,((-1 + b)*chi*exp(chi))/(b*(-1 + exp(chi)))))**2 + 4*((-1 + b)*chi + log(-b + (b + chi - b*chi)*exp(chi)) - log(chi + b*(-1 - chi + exp(chi))))*(chi - 2*b*chi - 2*b*chi**2 - b*chi**3 - 2*chi*exp(chi) + 4*b*chi*exp(chi) + 2*b*chi**2*exp(chi) - chi**3*exp(chi) + b*chi**3*exp(chi) + chi*exp(2*chi) - 2*b*chi*exp(2*chi) - b*chi*(-1 + exp(chi))*(2 + chi + (-2 + chi)*exp(chi))*(log(b*(-1 + exp(chi))) - log(chi + b*(-1 - chi + exp(chi)))) + b*(1 + chi - exp(chi))**2*log((exp(chi)*(chi + b*(-1 - chi + exp(chi))))/(-b + (b + chi - b*chi)*exp(chi))) - 2*b*(-1 + exp(chi))*(1 + (-1 + chi)*exp(chi))*polylog(2,((-1 + b)*chi)/(b*(-1 + exp(chi)))) - 2*b*(-1 + exp(chi))*(-1 - chi + exp(chi))*polylog(2,((-1 + b)*chi*exp(chi))/(b*(-1 + exp(chi)))) - 2*b*(-1 + exp(chi))**2*polylog(3,((-1 + b)*chi)/(b*(-1 + exp(chi)))) + 2*b*(-1 + exp(chi))**2*polylog(3,((-1 + b)*chi*exp(chi))/(b*(-1 + exp(chi)))))))
    
    return float(crlb_tau)

#%%
def B(tau, n=1, b=0, T=float('inf'), b_fixed = False):  
    '''
    def b(tau, n=1, b=0, T=float('inf'), b_fixed=False):
      Calculates the CRLB (minimum variance of an unbiased estimater) of the 
      background b of a mono-expontial decay. Assumes that the 
      lifetime tau and background b need to be estimated. 
    
      tau: lifetime
      n: number of photons in decay
      b: fraction of background photons: (b=0) no BG, (b=1) only BG
      T: measurement window in the same units as tau. Eg: repetion periode-cutoff
      b_fixed: Only included for consitency: b_fixed=True always returns 0.0
    '''
    from mpmath import mpf,exp,log,polylog,cosh,sinh,isnan
    if isnan(tau) or isnan(n) or isnan(b) or isnan(T):
        # for nan input return nan
        return float('nan')
        
    assert tau>=0,         'lifetime tau needs to be positive'
    assert b>=0 and b<=1,  'background fraction needs to be between 0 and 1'
    assert n>=0,           'number of photons n needs to be positive'
    assert T>=0,           'measurement periode needs to be positive'
    
    assert type(b_fixed) == bool, 'b_fixed needs to be bool'
    #%%
    if b_fixed:
        return 0.0
    if n==0:
        return float('inf')
    
    tau = mpf(tau)
    n = mpf(n)
    b = mpf(b)
    T = mpf(T)
        
    # switch to relative measurement periode chi
    chi = T/tau
    if chi > 1e8:
        # set extremly large chi to inf to avoid numeric instabilities
        chi = mpf('inf')
        
    if b < 1e-16:
        b = 0
    elif b > 1.0-1e-8:
        # for only background the lifetime cannot be determined
        tau = 0
    
    # Case 1: infinite T or tau == 0
    if chi > 1e8:
        crlb_b = (b-b**2)/n
        
    # Case 2: no bg (unknown), but finite T
    elif b==0:
        crlb_b = (2*chi**2*(2 + chi**2 - 2*cosh(chi)))/(n*(12 + 12*chi**2 + chi**4 - (16 + 12*chi**2 + chi**4)*cosh(chi) + 4*cosh(2*chi) + 4*chi**3*sinh(chi)))
           
    # Case 3: unknown bg, finite T
    else:
        crlb_b = (-4*(-1 + b)**2*chi*(chi - 2*b*chi - 2*b*chi**2 - b*chi**3 - 2*chi*exp(chi) + 4*b*chi*exp(chi) + 2*b*chi**2*exp(chi) - chi**3*exp(chi) + b*chi**3*exp(chi) + chi*exp(2*chi) - 2*b*chi*exp(2*chi) - b*chi*(-1 + exp(chi))*(2 + chi + (-2 + chi)*exp(chi))*(log(b*(-1 + exp(chi))) - log(chi + b*(-1 - chi + exp(chi)))) + b*(1 + chi - exp(chi))**2*log((exp(chi)*(chi + b*(-1 - chi + exp(chi))))/(-b + (b + chi - b*chi)*exp(chi))) - 2*b*(-1 + exp(chi))*(1 + (-1 + chi)*exp(chi))*polylog(2,((-1 + b)*chi)/(b*(-1 + exp(chi)))) - 2*b*(-1 + exp(chi))*(-1 - chi + exp(chi))*polylog(2,((-1 + b)*chi*exp(chi))/(b*(-1 + exp(chi)))) - 2*b*(-1 + exp(chi))**2*polylog(3,((-1 + b)*chi)/(b*(-1 + exp(chi)))) + 2*b*(-1 + exp(chi))**2*polylog(3,((-1 + b)*chi*exp(chi))/(b*(-1 + exp(chi))))))/(n*((2*chi + 2*chi**2 - b*chi**2 - 2*chi*exp(chi) + b*chi**2*exp(chi) - 2*b*chi*(-1 + exp(chi))*log(1 - (b*(-1 + exp(chi)))/((-1 + b)*chi)) - 2*(-1 + b)*chi*(-1 + exp(chi))*(log(b*(-1 + exp(chi))) - log(chi + b*(-1 - chi + exp(chi)))) + 2*(-1 - chi + exp(chi))*log((exp(chi)*(chi + b*(-1 - chi + exp(chi))))/(-b + (b + chi - b*chi)*exp(chi))) + 2*b*(-1 + exp(chi))*polylog(2,-((b - b*exp(-chi))/(chi - b*chi))) - 2*(-1 + b)*(-1 + exp(chi))*polylog(2,((-1 + b)*chi)/(b*(-1 + exp(chi)))) - 2*b*(-1 + exp(chi))*polylog(2,(b*(-1 + exp(chi)))/((-1 + b)*chi)) + 2*(-1 + b)*(-1 + exp(chi))*polylog(2,((-1 + b)*chi*exp(chi))/(b*(-1 + exp(chi)))))**2 + (4*((-1 + b)*chi + log(-b + (b + chi - b*chi)*exp(chi)) - log(chi + b*(-1 - chi + exp(chi))))*(chi - 2*b*chi - 2*b*chi**2 - b*chi**3 - 2*chi*exp(chi) + 4*b*chi*exp(chi) + 2*b*chi**2*exp(chi) - chi**3*exp(chi) + b*chi**3*exp(chi) + chi*exp(2*chi) - 2*b*chi*exp(2*chi) - b*chi*(-1 + exp(chi))*(2 + chi + (-2 + chi)*exp(chi))*(log(b*(-1 + exp(chi))) - log(chi + b*(-1 - chi + exp(chi)))) + b*(1 + chi - exp(chi))**2*log((exp(chi)*(chi + b*(-1 - chi + exp(chi))))/(-b + (b + chi - b*chi)*exp(chi))) - 2*b*(-1 + exp(chi))*(1 + (-1 + chi)*exp(chi))*polylog(2,((-1 + b)*chi)/(b*(-1 + exp(chi)))) - 2*b*(-1 + exp(chi))*(-1 - chi + exp(chi))*polylog(2,((-1 + b)*chi*exp(chi))/(b*(-1 + exp(chi)))) - 2*b*(-1 + exp(chi))**2*polylog(3,((-1 + b)*chi)/(b*(-1 + exp(chi)))) + 2*b*(-1 + exp(chi))**2*polylog(3,((-1 + b)*chi*exp(chi))/(b*(-1 + exp(chi))))))/b))
    
    return float(crlb_b)


'''
Call to function added by Helen Wilson 2023-03-20
Variables sent in MATLAB code
'''
crlb_return = tau(L,n,b,T)
#print(crlb_return)
#print(n,T,b,L)