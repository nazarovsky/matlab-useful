/*==========================================================
 * mex_filter.cpp 
 * 24.06.2014 15:45 Nazarovsky A.E.
 *		
 * don't forget to setup compiler in MATLAB using mex - setup
 * This is a MEX-file for MATLAB.
 * Copyright 1984-2009 The MathWorks, Inc.
 *
 *========================================================*/
/* $Revision: 1.5.4.4 $ */

#include "mex.h"
extern void _main();
/* The computational routine */
#include "filter.h"

void call_filter(double *Y,  double *X, int N )
{
    int k;
    float x;
    float y;
    for (k=0;k<N;k++){
                x=X[k];
		y=filter(x);
		Y[k]=y;
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
    mexErrMsgIdAndTxt("MATLAB:mex_filter:nargin", 
            " requires three input arguments.");
  } else if (nlhs > 1) {
    mexErrMsgIdAndTxt("MATLAB:mex_filter:nargout",
            " requires 1 output argument.");
  }

    /* make sure the first input argument is type double */
    if( !mxIsDouble(prhs[0]) || 
         mxIsComplex(prhs[0])) {
        mexErrMsgIdAndTxt("MATLAB:mex_filter:notDouble","input vector must be type double.");
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