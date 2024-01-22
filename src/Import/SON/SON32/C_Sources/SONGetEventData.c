/*% SONGETEVENTDATA returns the timings for an Event or marker channel
% 
% Implemented through SONGetEventData.dll
% 
% [npoints, times, levlow]=
%             SONGETEVENTDATA(fh, chan, maxpoints, stime, etime{, filtermask})
%             
%            INPUTS: FH = file handle
%                    CHAN = channel number 0 to SONMAXCHANS-1
%                    MAXPOINTS = Maximum number of data values to return
%                    STIME  = the start time for the data search
%                                   (in clock ticks)
%                    ETIME = the end time for teh search
%                                    (in clock ticks)
%                    FILTERMASK  if present is  a filter mask structure
%                                   There will be no filtering if this is
%                                   absent.
%           OUTPUTS: NPOINTS= number of data points returned
%                               or a negative error
%                    TIMES = an NPOINT column vector containing the
%                               timestamps (in clock ticks)
%                    LEVLOW = For a EventBoth (level) channel, 
%                               this is set to 1 if the first event
%                               is a high to low transition, 0 otherwise
% 
%
% For error codes, see the CED documentation
%
%ML 05/05
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
long _SONGetEventData(short    fh,
                        WORD    chan,
                        TpSTime   plTimes,
                        long    maxpoints,
                        TSTime  sTime,
                        TSTime  eTime,
                        TpBOOL plevLow,
                        TpFilterMask    pFltMask)
{
    long i;
    FARPROC SONGetEventData;
    SONGetEventData = GetProcAddress(hinstLib,"SONGetEventData");
    if (SONGetEventData != NULL){
    i=(*SONGetEventData)(fh, chan, plTimes, maxpoints, sTime, eTime, plevLow, pFltMask);
    return i;
    }
    mexErrMsgTxt("SONGetMarkData not found in SON32.DLL\n");
}


void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
    
    short   fh;
    WORD    chan;
    long    maxpoints;
    TSTime  sTime;
    TSTime  eTime;
    TpFilterMask    pFltMask=NULL;
    TFilterMask FilterMask;
    long npoints=0, *ret;
    TpSTime plTimes;
    int levLow=0;
    int *ptr;
    int dim[2]={1,1};
    double *p;



        
    //Used for filter
    int m,n;
    const int *empty[2]={0,0};
    
    
    if (nrhs<5)
        mexErrMsgTxt("SONGetEventData: Too few  arguments\n");

    //Get input arguments
    fh=mxGetScalar(prhs[0]);                   //File handle
    chan=mxGetScalar(prhs[1]);                 //Channel number
    maxpoints=mxGetScalar(prhs[2]);            //maxpoints
    sTime=mxGetScalar(prhs[3]);                //Start time for data search
    eTime=mxGetScalar(prhs[4]);                //End Time for data search
           
mexPrintf("%d\n",eTime);
   
    //Get and set up the filter mask
    if (nrhs==5 && mxIsStruct(prhs[5])==1){
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
    
// allocate array for return of event data
       if (nlhs>=2){
        dim[0]=1;
        dim[1]=maxpoints;
        plhs[1]= mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
        plTimes=mxGetData(plhs[1]);
       }
    
    //Call DLL
    npoints=_SONGetEventData(fh, chan, plTimes, maxpoints, sTime, eTime, &levLow, pFltMask);
    fFreeResult = FreeLibrary(hinstLib);
    
    
    //return results. This one goes in ans if no arguments
    dim[0]=1;
    dim[1]=1;
    plhs[0]=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
    ret=mxGetData(plhs[0]);
    *ret=npoints;
    
    
    if (nlhs==3) {
        plhs[2]=mxCreateNumericArray(2, dim, mxINT16_CLASS, mxREAL);
        ptr=mxGetData(plhs[2]);
        *ptr=levLow;

    }
}



