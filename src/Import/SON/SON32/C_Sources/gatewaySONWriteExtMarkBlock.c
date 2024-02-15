/*function ret=gatewaySONWriteExtMarkBlock(fh, chan, buffer, extra, count)
% SONWRITEEXTMARKBLOCK writes data to a marker channel
%
% Implemented through gatewaySONWriteMarkBlock.dll
% The SONWriteExtMarkBlock.m file transposes the extra data before calling
% this routine to provide C compatible array indexing.
% 
% RET=SONWRITEEXTMARKBLOCK(FH, CHAN, TIMESTAMPS, MARKERS, EXTRA, COUNT)
% INPUTS: FH the SON file handle
%         CHAN the target channel
%         TIMESTAMPS a vector of int32 timestamps for the markers
%                   which should be at least COUNT in length
%         MARKERS the 4xCOUNT array of uint8 marker values, one set of
%                   4 for each timestamp
%         EXTRA the array of extra data, int16, single or text
%         COUNT the number of marker items to write to the buffer
%
% Returns zero or a negative error code.
%
% For efficient use of disc space, COUNT should be  a multiple of
% (BUFSIZE bytes - 20)/4 , where BUFSIZE is supplied in a prior call to
% SONSETWAVECHAN, SONSETREALMARKCHAN or SONSETTEXTMARKCHAN (20 is the size of the block header on disc)
%
% see CED documentation
%
% See also SONSETSETWAVECHAN, SONSETREALMARKCHAN, SONSETTEXTMARKCHAN,
% SONWRITEMARKBLOCK
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
short _SONWriteExtMarkBlock(short    fh,
                        WORD    chan,
                        TpMarker   pMark,
                        long    count)
{
    short i;
    FARPROC SONWriteExtMarkBlock;
    SONWriteExtMarkBlock = GetProcAddress(hinstLib,"SONWriteExtMarkBlock");
    if (SONWriteExtMarkBlock != NULL){
        i=(*SONWriteExtMarkBlock)(fh, chan, pMark, count);
        return i;
    }
    mexErrMsgTxt("SONWriteExtMarkBlock not found in SON32.DLL\n");
}

WORD _SONItemSize(short fh, WORD chan)
{
    FARPROC SONItemSize;
    WORD i;
    SONItemSize=GetProcAddress(hinstLib,"SONItemSize");
    i=(*SONItemSize)(fh, chan);
    return i;
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
    char *pM, *pM2;
    char *pExtra;
    WORD sz;
    if (nrhs<6)
       mexErrMsgTxt("SONWriteExtMarkBlock: Too few  arguments\n");
    
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
    pMarkers=(char *)mxGetPr(prhs[3]); 
    pExtra=(char *)mxGetPr(prhs[4]);
    count=mxGetScalar(prhs[5]);                //Number to write

    /*Load and get pointer to the library SON32.DLL*/
    hinstLib = LoadLibrary(SON32);
    if (hinstLib == NULL){
        mexPrintf("%s not found",SON32);
        plhs[0]=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
        p=mxGetData(plhs[0]);
        p[0]=SON_BAD_PARAM;
        return;
    }
    sz=_SONItemSize(fh, chan);
    pM=(char *)mxMalloc(count*sz);
    pM2=pM;
    for (n=0; n<count; n++){
        memcpy(pM, pTimes++, 4);
        pM+=4;
        for (i=0; i<4; i++){
            *pM++=*pMarkers++;
        }
       memcpy(pM, pExtra, sz-8);
       pExtra+=(sz-8);
       pM+=(sz-8);
       mexPrintf("%d\n",pM);
}
    
    //Call DLL
    ret=_SONWriteExtMarkBlock(fh, chan, pM2, count);
    fFreeResult = FreeLibrary(hinstLib);
    mxFree(pM);
    
    //Return value - goes in ans if no arguments
    plhs[0]=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
    p=mxGetData(plhs[0]);
    *p=ret;
  
}




