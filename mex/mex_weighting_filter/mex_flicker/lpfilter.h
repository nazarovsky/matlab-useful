// lowpass Butterworth filter for block 4 for 230v50hz
const FloatType a_lp[]={ 1.00000000000000000e+00,  -9.97399218298034240e-01}; 
const FloatType b_lp[]={ 1.30039085098287990e-03,  1.30039085098287990e-03}; 
FloatType z_lp; 

FloatType lp_filter(FloatType x) { 
 // returns one filtered value and updates internal "delayed" values 
   FloatType y;
   y	   =  b_lp[0] * x + z_lp;
   z_lp   =  b_lp[1] * x - a_lp[1]*y;
   return y; 
} 

