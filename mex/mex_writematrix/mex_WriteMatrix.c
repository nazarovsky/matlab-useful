/*==========================================================
 * writes contents of matrix Z to csv delimited file 
 * mex_writematrix (Z, filename)
 * Nazarovsky Alexander	22.08.2014 13:52
 *========================================================*/
/* $Revision: 1.1.10.4 $ */
//  Usage:
//     mex_WriteMatrix(filename,matrix,format,delimiter);
//  Parameters:
//     filename  - full path for CSV file to export 
//     matrix    - matrix of double values to be exported
//     format    - format of export (sprintf) , e.g. '%10.6f'
//     delimiter - delimiter, for example can be ',' or ';'

#include "mex.h"
#define _WIN32

/* for ctrl-c detection http://www.caam.rice.edu/~wy1/links/mex_ctrl_c_trick/ */
#if defined (_WIN32)
    #include <windows.h>
#elif defined (__linux__)
    #include <unistd.h>
#endif

#ifdef __cplusplus 
    extern "C" bool utIsInterruptPending();
#else
    extern bool utIsInterruptPending();
#endif



#define FUNCNAME "MATLAB:mex_WriteMatrix:error"

FILE* fd=NULL;


/* write to file routine */
void writemat(double *z, size_t n, size_t m, char *fname, char *fmt, char *dlm)
{
   int i;
   int j;

   fd = fopen(fname,"w+");
   if(fd == NULL)
   {
         mexErrMsgIdAndTxt(FUNCNAME,"fopen() Error!");
         exit;
   }

   for (i=0; i<m; i++) {
      for (j=0; j<n; j++) {
         if (j<n-1) {
           fprintf(fd, fmt, z[i+j*m]);
           fprintf(fd, dlm, z[i+j*m]);	
         } else {
           fprintf(fd,fmt,z[i+j*m]);	
         } 
 
          if (utIsInterruptPending()) {        /* check for a Ctrl-C event */
            mexPrintf("Ctrl-C Detected.\n\n");
            return;  
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
    size_t m;                    /* M = number of rows of matrix */
    size_t n;                    /* N = number of cols of matrix */
    int    status;
    size_t fnamelen; /* filename string buffer length     */
    char  *fname;                    /* filename string   */

    size_t fmtlen;   /* value format string buffer length */
    char  *fmt;                    /* value format string */

    size_t dlmlen;   /* delimiter string buffer length    */
    char  *dlm;                    /* value format string */

    /* check for proper number of arguments */
    if(nrhs!=4) {
        mexErrMsgIdAndTxt(FUNCNAME,"Four input parameters required (filename, matrix, value format and separator).");
    }

    if(!mxIsChar(prhs[0])) {    
        mexErrMsgIdAndTxt(FUNCNAME,"Filename must be a string.");
    }
    
    if( !mxIsDouble(prhs[1]) || 
         mxIsComplex(prhs[1])) {
        mexErrMsgIdAndTxt(FUNCNAME,"Input matrix Z must be type double.");
    }

    if(!mxIsChar(prhs[2])) {    
        mexErrMsgIdAndTxt(FUNCNAME,"Value format must be a string (e.g. %%10.6f)");
    }

//    if (!mxIsChar(prhs[3]) || mxGetN(prhs[3])>1) {    
    if (!mxIsChar(prhs[3])) {    
        mexErrMsgIdAndTxt(FUNCNAME,"Separator must be a char");
    }


    /* process first input = filename */
    fnamelen=mxGetN(prhs[0])+1;
    fname=(char *)mxCalloc(fnamelen,sizeof(char));
    status=mxGetString(prhs[0],fname,(mwSize)fnamelen);

    /* process second input = matrix */
    inMatrix = mxGetPr(prhs[1]);
    n = mxGetN(prhs[1]);
    m = mxGetM(prhs[1]);

    /* process third input = value format */
    fmtlen=mxGetN(prhs[2])+1;
    fmt=(char *)mxCalloc(fmtlen,sizeof(char));
    status=mxGetString(prhs[2],fmt,(mwSize)fmtlen);

    /* process fourth input = delimiter */
    dlmlen=mxGetN(prhs[3])+1;
    dlm=(char *)mxCalloc(dlmlen,sizeof(char));
    status=mxGetString(prhs[3],dlm,(mwSize)dlmlen);

    writemat(inMatrix,n,m,fname, fmt, dlm);

    mxFree(fname);
    mxFree(fmt);
    mxFree(dlm);

    if (fd!=NULL) {
       fclose(fd);
    }

}
