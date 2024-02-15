/*% SONGETMARKDATA returns the timings and marker values for a Marker, AdcMark,
% RealMark or TextMark channel
% 
% Implemented through SONGetMarkData.dll
% 
% [npoints, times, markers]=
%             SONGETMARKDATA(fh, chan, maxpoints, stime, etime{, filtermask})
%             
%            INPUTS: FH = file handle
%                    CHAN = channel number 0 to SONMAXCHANS-1
%                    MAXPOINTS = Maximum number of data values to return
%                                (up to 32767, if zero will be set to
%                                   32767)
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
%                    MARKERS = an NPOINT x 4 byte array, with 4 markers
%                           for each of the timestamps in TIMES.
% 
% Note: For easier compatability with version 1.0 of the library use a
% structure for the outputs e.g.
% [npoints, data.timings, data.markers]=
%                         SONGETMARKDATA(fh, chan, maxpoints, stime, etime)
%
% For error codes, see the CED documentation
%
%ML 04/05
 **/



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
long _SONGetMarkData(short    fh,
WORD    chan,
TpMarker   pMark,
long    maxpoints,
TSTime  sTime,
TSTime  eTime,
TpFilterMask    pFltMask)
{
    long i;
    FARPROC SONGetMarkData;
    SONGetMarkData = GetProcAddress(hinstLib,"SONGetMarkData");
    if (SONGetMarkData != NULL){
        i=(*SONGetMarkData)(fh, chan, pMark, maxpoints, sTime, eTime, pFltMask);
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
    long npoints=0;
    TMarker Markers[32767];
    short levLow;
    unsigned char *ptr;
    int dim[2]={1,1};
    double *p;
    long *ret;
    int i,j;
    
    
    
    //Used for filter
    int m,n;
    const int *empty[2]={0,0};
    
    
    if (nrhs<5)
        mexErrMsgTxt("SONGetMarkData: Too few  arguments\n");
    
    //Get input arguments
    fh=mxGetScalar(prhs[0]);                   //File handle
    chan=mxGetScalar(prhs[1]);                 //Channel number
    maxpoints=mxGetScalar(prhs[2]);            //maxpoints
    if ((maxpoints>32767) || (maxpoints<=0))
        maxpoints=32767;
    sTime=mxGetScalar(prhs[3]);                //Start time for data search
    eTime=mxGetScalar(prhs[4]);                //End Time for data search
    
    
    
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
    
    
    
    //Call DLL
    npoints=_SONGetMarkData(fh, chan, &Markers, maxpoints, sTime, eTime, pFltMask);
    fFreeResult = FreeLibrary(hinstLib);
    
    
    //return results. This one goes in ans if no arguments
    dim[0]=1;
    dim[1]=1;
    plhs[0]=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
    ret=mxGetData(plhs[0]);
    *ret=npoints;
    
    
    if (nlhs>=2) {
        dim[0]=max(0,npoints);
        plhs[1]=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
        ret=mxGetData(plhs[1]);
        for (i=0; i<npoints; i++)
            *ret++=Markers[i].mark;
        
    }
    
    if (nlhs==3) {
        dim[1]=4;
        dim[0]=max(0,npoints);
        plhs[2]=mxCreateNumericArray(2, dim, mxUINT8_CLASS, mxREAL);
        ptr=mxGetData(plhs[2]);
            for (j=0; j<4; j++)
                for(i=0; i<npoints; i++)
                *ptr++=Markers[i].mvals[j];

        
        
    }
}
    
    
    
    
