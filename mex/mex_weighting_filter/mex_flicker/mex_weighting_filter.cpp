/*==========================================================
 * mex_weighting_filter.cpp 
 * 01.08.2014 16:58 Nazarovsky A.E.
 * Input agruments: input_values - array [0..1279] of float values (1 sec with fd=1280 )
 *
 *		output_values = mex_weighting_filter ( input_values )
 *		
 * don't forget to setup compiler in MATLAB using mex - setup
 * This is a MEX-file for MATLAB.
 * Copyright 1984-2009 The MathWorks, Inc.
 *
 *========================================================*/
/* $Revision: 1.5.4.4 $ */

// #include <math.h>
#include "mex.h"
extern void _main();
/* The computational routine */

#define SCALING_FACTOR  1238354 // SCALING CONSTANT found according to 50 Hz signal with sine modulation , mod.depth=0.25% and mod.freq=8.8 Hz - result should be = 1
#define M_PI 3.14159265358979323


#include "filter.h"
#include "lpfilter.h"

void call_filter(double *Y,  double *X, int N )
{
    int k;
    double y;
    for (k=0;k<N;k++){
		y = X[k];
		y = y*y ;         // squaring [block 2]
		y = filter(y); // high pass 1 order [block 3]
		y = y*y;          // squaring [block 4]
		y = lp_filter(y); // low pass 1 order [block 4]
		Y[k]=y*SCALING_FACTOR; // scaling and output [block 4]
	}
}


void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])

{

  double *input_values;          /* 1xN input matrix */
  double *output_values;         /* 1xN output matrix */

  size_t n;                   /* size of matrix */
  /* Check for proper number of arguments */

  if (nrhs != 1) {
    mexErrMsgIdAndTxt("MATLAB:mex_weighting_filter2:nargin", 
            "mex_weighting_filter2 requires three input arguments.");
  } else if (nlhs > 1) {
    mexErrMsgIdAndTxt("MATLAB:mex_weighting_filter2:nargout",
            "mex_weighting_filter2 requires 1 output argument.");
  }

    /* make sure the first input argument is type double */
    if( !mxIsDouble(prhs[0]) || 
         mxIsComplex(prhs[0])) {
        mexErrMsgIdAndTxt("MATLAB:mex_weighting_filter2:notDouble","mex_weighting_filter2 input vector must be type double.");
    }

    /* create a pointer to the real data in the input matrix 1 */
    input_values = mxGetPr(prhs[0]);

    /* get dimensions of the input matrices */
    n = mxGetN(prhs[0]);

    /* create the output matrix */
    plhs[0] = mxCreateDoubleMatrix(1,(mwSize)n,mxREAL);

    /* get a pointer to the real data in the output matrix */
    output_values = mxGetPr(plhs[0]);

    /* call the computational routine */
    call_filter(output_values,input_values,n);

  return;
}