/*==========================================================
 * writes contents of matrix Z to csv delimited file 
 * mex_writematrix (Z, filename)
 * Nazarovsky Alexander	22.08.2014 13:52
 *========================================================*/
/* $Revision: 1.1.10.4 $ */

#include "mex.h"
#define FUNCNAME "mex_WriteMatrix"

/* write to file routine */
void writemat(double *z, size_t n, size_t m, char *fname )
{
   int i;
   int j;
   FILE* fd=NULL;
//   char  *string_to_write; /* write a row at a time */
//   int row_char_len;


   fd = fopen(fname,"w+");
   if(fd == NULL)
   {
         mexErrMsgIdAndTxt(FUNCNAME,"fopen() Error!");
         exit;
   }

//   string_to_write=(char *)mxCalloc(,sizeof(char));

   for (i=0; i<m; i++) {
      for (j=0; j<n; j++) {
         if (j<n-1) {
           fprintf(fd,"%10.10f,",z[i+j*m]);	
         } else {
           fprintf(fd,"%10.10f",z[i+j*m]);	
         } 
      }
      fprintf(fd,"\n");	       
   }
   fclose(fd);
}

/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    double *inMatrix;                /* MxN input matrix */
    bool out;                    /* output = true // todo: to return false in case of write error */ 
    size_t m;                    /* M = number of rows of matrix */
    size_t n;                    /* N = number of cols of matrix */
    size_t fnamelen; /* filename string buffer length */
    char  *fname;                    /* filename string */
    int    status;

    /* check for proper number of arguments */
    if(nrhs!=2) {
        mexErrMsgIdAndTxt(FUNCNAME,"Two input parameters required.");
    }
    if(nlhs!=1) {
        mexErrMsgIdAndTxt(FUNCNAME,"One output required.");
    }
    
    if( !mxIsDouble(prhs[0]) || 
         mxIsComplex(prhs[0])) {
        mexErrMsgIdAndTxt(FUNCNAME,"Input matrix Z must be type double.");
    }
    if(!mxIsChar(prhs[1])) {    
        mexErrMsgIdAndTxt(FUNCNAME,"Filename must be a string.");
    }
    /* process first input = matrix */
    inMatrix = mxGetPr(prhs[0]);
    n = mxGetN(prhs[0]);
    m = mxGetM(prhs[0]);

    /* process second input = filename */
    fnamelen=mxGetN(prhs[1])+1;
    fname=(char *)mxCalloc(fnamelen,sizeof(char));
    status=mxGetString(prhs[1],fname,(mwSize)fnamelen);

    /* create the output */
    plhs[0] = mxCreateLogicalScalar(true);

    /* get a pointer to the output */
    out = mxGetPr(plhs[0]);

    /* call the writemat routine */
    writemat(inMatrix,n,m,fname);

    mxFree(fname);
}
