/*function ret=SONWriteMarkBlock(fh, chan, buffer, count)
% SONWRITEMARKBLOCK writes data to a marker channel
% 
% Implemented through SONWriteMarkBlock.dll
%
% RET=SONWRITEMARKBLOCK(FH, CHAN, TIMESTAMPS, MARKERS, COUNT)
% INPUTS: FH the SON file handle
%         CHAN the target channel
%         TIMESTAMPS a vector of int32 timestamps for the markers
%                   which should be at least COUNT in length
%         MARKERS the 4xCOUNT array of uint8 marker values, one set of
%                   4 for each timestamp
%         COUNT the number of marker items to write to the buffer
%         
% Returns zero or a negative error code.
% 
% For efficient use of disc space, COUNT should be  a multiple of 
% (BUFSIZE bytes - 20)/4 , where BUFSIZE is supplied in a prior call to
% SONSETEVENTCHAN (20 is the size of the block header on disc)
% 
% see CED documentation
% 
% See also SONSETEVENTCHAN, SONWRITEEVENTBLOCK, SONWRITEEXTMARKBLOCK
%
% Author:Malcolm Lidierth
% Matlab SON library:
% Copyright 2005 © King’s College London
*/

#include <string.h>
#include <stdio.h>
#include <windows.h>
#include <matrix.h>
#include <mex.h>

#include "son.h"
#include "machine.h"
#include "SONDef.h"

HINSTANCE hinstLib;
BOOL fFreeResult;


// Calls the SON32.DLL read routine
short _SONWriteMarkBlock(short    fh,
                        WORD    chan,
                        TpMarker   pMark,
                        long    count)
{
    short i;
    FARPROC SONWriteMarkBlock;
    SONWriteMarkBlock = GetProcAddress(hinstLib,"SONWriteMarkBlock");
    if (SONWriteMarkBlock != NULL){
        i=(*SONWriteMarkBlock)(fh, chan, pMark, count);
        return i;
    }
    mexErrMsgTxt("SONWriteMarkBlock not found in SON32.DLL\n");
}


void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
    
    short   fh;
    WORD    chan;
    long    count, n;
    long npoints=0;
    TSTime *pTimes; 
    char *pMarkers;
    short ret;
    long *p;
    int dim[2]={1,1},i;
    TpMarker pM;
    
    if (nrhs<5)
       mexErrMsgTxt("SONWriteMarkBlock: Too few  arguments\n");
    
    //Get input arguments
    fh=mxGetScalar(prhs[0]);                   //File handle
    chan=mxGetScalar(prhs[1]);                 //Channel number
    if (mxIsInt32(prhs[2])==0){
        mexPrintf("SONWriteMarkBlock: timestamps must be int32");
        plhs[0]=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
        p=mxGetData(plhs[0]);
        *p=SON_BAD_PARAM;
        return;
    }
    pTimes=(TSTime *)mxGetPr(prhs[2]);         //Pointer to timestamps
    
    pMarkers=(char *)mxGetPr(prhs[3]);         //Pointer to marker values
        if (mxIsInt32(prhs[2])==0){
        mexPrintf("SONWriteMarkBlock: timestamps must be int32");
        plhs[0]=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
        p=mxGetData(plhs[0]);
        *p=SON_BAD_PARAM;
        return;
    }
    pMarkers=(char *)mxGetPr(prhs[3]);         //Pointer to marker values
    
    count=mxGetScalar(prhs[4]);                //Number to write

    pM=mxCalloc(count*8,sizeof(char));
    
    
    for (n=0; n<count; n++){
        pM[n].mark=*pTimes++;
        for (i=0; i<4; i++){
            pM[n].mvals[i]=*pMarkers++;
        }
        mexPrintf("%d\n",n);
}
    
    
/*Load and get pointer to the library SON32.DLL*/
    hinstLib = LoadLibrary(SON32);
    if (hinstLib == NULL){
        mexPrintf("%s not found",SON32);
        plhs[0]=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
        p=mxGetData(plhs[0]);
        p[0]=SON_BAD_PARAM;
        return;
    }
    
    
    
    //Call DLL
    ret=_SONWriteMarkBlock(fh, chan, pM, count);
    fFreeResult = FreeLibrary(hinstLib);
    mxFree(pM);
    
    //Return value - goes in ans if no arguments
    plhs[0]=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
    p=mxGetData(plhs[0]);
    *p=ret;
  
}




