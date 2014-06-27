/*==========================================================
 * mex_delta_fast_spline_interp.cpp 
 * 27.06.2014 16:05 Nazarovsky A.E.
 *		
 * Compilation: mex mex_delta_fast_spline_interp.cpp  tested in Microsoft Visual Studio 2010
 * don't forget to setup compiler in MATLAB using mex - setup
 *
 * This is a MEX-file for MATLAB.
 * Copyright 1984-2009 The MathWorks, Inc.
 *
 * 
 * USAGE:
 * fast spline resampling of 1d equally spaced data points
 * 
 * y1=mex_delta_fast_spline_interp(x_beg, x_end, x1_beg, x1_end, y, N , M);
 *
 *  input data - N equally spaced points from "x_beg" to "x_end" with corresponding values in "y" array
 *  output data - M equally spaced points from "x1_beg" to "x1_end" with corresponding values in "y1" array
 *
 *  x_beg	N points			  x_end                   
 *   *-----*-----*-----*-----* .........  *-----*
 *
 *    x1_beg         M points                 x1_end          (x1_beg>=x_beg , x1_end<=x_end)
 *     *----*----*----*----*----* .......*----*
 * Input:
 *        x_beg, x_end  - first and last points of the input x grid 
 *        N - number of points in the input grid
 *        y - values in the points of the input grid (should be sorted to correspond with x grid)
 *        x1_beg, x1_end - first and last points of the output x1 grid 
 *        M - number of points in the output grid
 * Output: 
 *        y1 - interpolated values         

 *========================================================*/
/* $Revision: 1.5.4.4 $ */

#include <math.h>
#include "mex.h"
#define MIN(X,Y) ((X) < (Y) ? (X) : (Y))
#define M_MAGIC 0.2679492f

extern void _main();
/* The computational routine */

static float c_pre[7]; // pre initialized coefficients for solve_tridiagonal
float *C; //  array of spline coefficients

float spline_phi(float t)
{
	float abs_t=fabs(t);
	if (abs_t <=1){
		return  4.0 + (-6.0 + 3.0 * abs_t)*abs_t*abs_t ;
	} else {
		if (abs_t <=2){
			return (2.0-abs_t)*(2.0-abs_t)*(2.0-abs_t);
		} else {
			return  0.0;
		}
	};
}

// void delta_fast_spline_interp(double *y1,  double x_beg, double x_end, double x1_beg, double x1_end, double *y, int M , int N)
//
//  x_beg			N points				   x_end                   
//   *-----*-----*-----*-----* .........  *-----*
//
//    x1_beg         M points                 x1_end          (x1_beg>=x_beg , x1_end<=x_end)
//     *----*----*----*----*----* .......*----*
// Input:
//        x_beg, x_end  - first and last points of the input x grid 
//        N - number of points in the input grid
//        y - values in the points of the input grid (should be sorted to correspond with x grid)
//        x1_beg, x1_end - first and last points of the output x1 grid 
//        M - number of points in the output grid
// Output: 
//        y1 - interpolated values         

/* ********************************************************************** */


void delta_fast_spline_interp(double *y1,  float x_beg, float x_end, float x1_beg, float x1_end, double *y, int N , int M)
{
   int i;
   int kk;

   float h=(x_end-x_beg)/(N-1);
   float h1=(x1_end-x1_beg)/(M-1);
   //////////////////////////////////////////   finding spline coefficients
   C[1]=(float) 1/6*(y[0]);
   C[N]=(float) 1/6*(y[N-1]);

   for (i = 0; i<N-2; i++){ 
	   C[i+2]=y[i+1];
   }
   C[2]=(y[1]-C[1])/4.0;
   C[N-1]=y[N-2]-C[N];
   // solving tridiagonal system
   // C[N+2] - array of spline coefficients (processed part is calculated inplace)
   // C[0] C[1]   ||     C[2] .... C[N-1]  || C[N] C[N+1]
   //              +-- Processed part [n-2]-+     
    for (i = 3; i <= N-2; i++) {
		if (i<8) {
			C[i] = (C[i] - C[i-1]) *c_pre[i-2];
		} else {
			C[i] = (C[i] - C[i-1])*M_MAGIC;
		}
	}
	C[N-1] = (C[N-1] - C[N-2]) *M_MAGIC ;    

    for (i = N-2; i>1 ; i--) {
		if (i<8) {
			C[i] -= c_pre[i-2]*C[i+1];
		} else {
			C[i] -= M_MAGIC*C[i+1];
		}
    }
   //
   C[0]=2*C[1]-C[2];
   C[N+1]=2*C[N]-C[N-1];

	//////////////////////////////////////////   actual resampling part
   
	int p1=0; // pivot for x1 array
	float xx=0.0,yy=0.0;
	int ll=0,mm=0;
	
	float px=x_beg; 
	float px1=x1_beg; 
	int l1=0,m1=0;

    if (M>=N)  //size of x1 >= size of x
	{
		px=(floor((x1_beg-x_beg)/h) +1)*h+x_beg;
		while (p1<M) {

			xx=(px1-x_beg)/h;
                        ll = xx + 1 ;
			mm = MIN(ll+3,N+2);
			yy=0.0;
			for (kk=ll; kk<=mm; kk++){
			   yy+=C[kk-1]*spline_phi(xx-kk+2);
		        }
			y1[p1]=yy;
			p1++;
			px+=h;  px1=x1_beg+p1*h1;
			if (px1<px){
	  		   px-=h;
			};
		};
	} else  //size of x1 < size of x
	{
		px=(floor((x1_beg-x_beg)/h) +1)*h+x_beg;
		while (p1<M) {
			xx=(px1-x_beg)/h;
			ll= xx + 1;
			mm = MIN(ll+3,N+2);
			   yy=0.0;
			   for (kk=ll; kk<=mm; kk++){
			      yy+=C[kk-1]*spline_phi(xx-kk+2);
			   }
			   y1[p1]=yy;
			   p1++;
			   px+=h;
                           px1=x1_beg+p1*h1;
			   if (px1>px){
			      px+=h;
			   };
		}; 
	};
}




void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
  double *y;                  /* 1xN input   */
  double *y1;                  /* 1xN output */
  float x_beg,x_end;
  float x1_beg,x1_end;
  float N;                   /* size of matrix */
  float M;                   /* size of matrix */


  /* Check for proper number of arguments */

  if (nrhs != 7) {
    mexErrMsgIdAndTxt("MATLAB:mex_delta_fast_spline_interp:nargin", 
            "mex_delta_fast_spline_interp_double requires 7 input arguments:\n y1=f(x_beg, x_end, x1_beg, x1_end, y, N, M) \n ");
  } else if (nlhs > 1) {
    mexErrMsgIdAndTxt("MATLAB:mex_delta_fast_spline_interp:nargout",
            "mex_delta_fast_spline_interp requires 1 output argument:\n  y1=f(x_beg, x_end, x1_beg, x1_end, y, N, M) \n   ");
  }

    x_beg = mxGetScalar(prhs[0]);
    x_end = mxGetScalar(prhs[1]);
    x1_beg = mxGetScalar(prhs[2]);
    x1_end = mxGetScalar(prhs[3]);
    y = mxGetPr(prhs[4]);
    N = mxGetScalar(prhs[5]);
    M = mxGetScalar(prhs[6]);

    C = (float *) mxMalloc( (int)(N+3)*sizeof(float) );
    /* create the output matrix */
    plhs[0] = mxCreateDoubleMatrix(1,(mwSize)M,mxREAL);
    /* get a pointer to the real data in the output matrix */
    y1=mxGetPr(plhs[0]);

 	c_pre[0]=1.0/4.0; 
	for (int k=1; k<7; k++)
	{
		c_pre[k] = 1.0/(4.0 - c_pre[k-1]); 		// after 7th iteration they all should become 0.2679492
	}

// void delta_fast_spline_interp(double *y1,  double x_beg, double x_end, double x1_beg, double x1_end, double *y, int N , int M)
    delta_fast_spline_interp(y1, x_beg, x_end, x1_beg, x1_end, y, N, M);
    mxFree(C);
}