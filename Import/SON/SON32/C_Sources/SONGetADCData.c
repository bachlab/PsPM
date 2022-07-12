/*% SONGETADCDATA returns data for Adc, AdcMark, RealWave ( and RealMark?)
% data channels
%
% Implemented through SONGetADCData.dll
%
% [npoints, bTime, data]=SONGETADCDATA(fh, chan,...
%               maxpoints, sTime, eTime{, FilterMask})
%
%            INPUTS: FH = file handle
%                    CHAN = channel number 0 to SONMAXCHANS-1
%                    MAXPOINTS = Maximum number of data points to return
%                                   The routine will calculate MAXPOINTS
%                                   if this is passed as zero or less.
%                    STIME  = the start time for the data search
%                                   (in clock ticks)
%                    ETIME = the end time for the search
%                                    (in clock ticks)
%                    FILTERMASK  if present is  a filter mask structure
%                                   There will be no filtering if this is
%                                   absent.
%           OUTPUTS: NPOINTS= number of data points returned
%                               or a negative error
%                    BTIME = the time for the first sample returned in
%                               data (in clock ticks)
%                    DATA = the output data array
%
% Alternative call:
% [npoints, bTime]=SONGETADCDATA(fh, chan,...
%               data, sTime, eTime{, FilterMask})
% Here, DATA must be a pre-allocated int16 column vector. SON32.DLL will
% place data directly into this array in the matlab workspace. For repeated
% calls, this can be faster but it breaks normal matlab conventions.
%
% For error codes returned in NPOINTS see the CED documentation
%
% ML 03/05*/



#include <string.h>
#include <stdio.h>
#include <windows.h>
#include <matrix.h>
#include <mex.h>

#include "son.h"
#include "machine.h"
#include "SONDef.h"

HINSTANCE hinstLib=NULL;
BOOL fFreeResult;


// Calls the SON32.DLL read routine
long _SONGetADCData(short    fh,
WORD    chan,
TpAdc   psData,
long    maxpoints,
TSTime  sTime,
TSTime  eTime,
TpSTime pbTime,
TpFilterMask    pFltMask)
{
    long i;
    FARPROC SONGetADCData;
    SONGetADCData =GetProcAddress(hinstLib,"SONGetADCData");
    if (SONGetADCData != NULL){
        i=(*SONGetADCData)(fh, chan, psData, maxpoints, sTime, eTime,
                                                        pbTime, pFltMask);
        return i;
    }
    return -1000;
}

//  Returns the number of clock ticks per sampling interval for channel
//  chan
int ChanInterval(short fh, WORD chan)
{
    FARPROC SONGetTimePerADC,SONChanDivide;
    WORD a;
    TSTime b;
    
    SONGetTimePerADC=GetProcAddress(hinstLib,"SONGetTimePerADC");
    SONChanDivide=GetProcAddress(hinstLib,"SONChanDivide");
    if ((SONGetTimePerADC==NULL) || (SONChanDivide==NULL)) {
        mexErrMsgTxt("Required routines not found in SON32.DLL");
    }
    a=(*SONGetTimePerADC)(fh, 0);
    b=(*SONChanDivide)(fh, chan);
    return a*b ;
}


void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
    
    short   fh;
    WORD    chan;
    TpAdc   psData;
    long    maxpoints;
    TSTime  sTime;
    TSTime  eTime;
    TSTime  StartTime;
    TpSTime pbTime=&StartTime;
    TpFilterMask    pFltMask=NULL;
    TFilterMask FilterMask;
    double *p;
    long npoints;
    int dim[2]={1,1};
    long * ret;
    
    //Used for filter
    int mode;
    int m,n;
    const int empty[2]={0,0};

    
    if (nrhs<5)
        mexErrMsgTxt("SONGetADCData: Too few input arguments\n");
    
    //Get input arguments
    fh=mxGetScalar(prhs[0]);                   //File handle
    chan=mxGetScalar(prhs[1]);                 //Channel number
    //maxpoints - see below
    sTime=mxGetScalar(prhs[3]);                //Start time for data search
    eTime=mxGetScalar(prhs[4]);                //End Time for data search
    
    //prhs[2] can be maxpoints (a scalar; =mode 1)or a pointer to a
    //pre-allocated array in the matlab calling space (mode 2).
    if (mxGetM(prhs[2])==1 && mxGetN(prhs[2])==1) {// scalar so mode 1
        if (nlhs<3) {
            mexPrintf("SONGetRealData:Too few LHS arguments \n");
            plhs[0]=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
            ret=mxGetData(plhs[0]);
            *ret=SON_BAD_PARAM;
            for (m=1; m<nlhs; m++)
                plhs[m]=mxCreateNumericArray(2, empty, mxINT32_CLASS, mxREAL);
            return;
        }
        else {
            mode=1;
            maxpoints=mxGetScalar(prhs[2]);
        }
    }
    else {// non-scalar so mode 2....
        //.....but first check it is a valid data array
        if ((mxGetM(prhs[2])>1)||(mxGetClassID(prhs[2])!= mxINT16_CLASS)) {
            mexPrintf("SONGetADCData:"
            "Data array must be an int16 column vector\n");
            plhs[0]=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
            ret=mxGetData(plhs[0]);
            *ret=SON_BAD_PARAM;
            for (m=1; m<nlhs; m++)
                plhs[m]=mxCreateNumericArray(2, empty, mxINT32_CLASS, mxREAL);
            return;
        }
        else {          // Input OK so use pointer to pre-allocated array
            mode=2;
            psData=mxGetData(prhs[2]);
            maxpoints=mxGetN(prhs[2]);
        }
    }
    
    //Get and set up the filter mask
    if (nrhs==6 && mxIsStruct(prhs[5])==1){
        GetFilterMask(prhs[5], &FilterMask);
        pFltMask=&FilterMask;
    }
    else
        pFltMask=NULL;

    
    //Load and get pointer to the library SON32.DLL//
    hinstLib = LoadLibrary(SON32);
    if (hinstLib == NULL){
        mexPrintf("%s not found",SON32);
        plhs[0]=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
        p=mxGetData(plhs[0]);
        p[0]=SON_BAD_PARAM;
        return;
    }
    
    // If maxpoints was zero on call, calculate maxpoints from
    // sample interval
    if (maxpoints<=0)
        maxpoints=(eTime-sTime)/ChanInterval(fh, chan);
    // In mode 1 we need to create the return array in the matlab
    // workspace
    if (mode==1 && nlhs>=3) {
        dim[1]=maxpoints;
        plhs[2]=mxCreateNumericArray(2, dim, mxINT16_CLASS, mxREAL);
        psData=mxGetData(plhs[2]);
    }
    
    if(psData != NULL){
        
        //Call DLL
        npoints=_SONGetADCData(fh, chan, psData, maxpoints, sTime, eTime,
                                            pbTime, pFltMask);
        fFreeResult = FreeLibrary(hinstLib);
        
        //return results. This one goes in ans if no arguments
        dim[1]=1;
        plhs[0]=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
        ret=mxGetData(plhs[0]);
        *ret=npoints;
        
        if (nlhs>=2){
            plhs[1]=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
            ret=mxGetData(plhs[1]);
            *ret=*pbTime;
        }
        
        
    }
    
}


