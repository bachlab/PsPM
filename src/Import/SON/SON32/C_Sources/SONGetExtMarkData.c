/*% SONGetExtMarkData returns the timings, marker values and extra data
% for an AdcMark, RealMark or TextMark channel
%
% Implemented through SONGetExtMarkData.dll
%
% [npoints, times, markers, extra]=
%        SONGETEXTMARKDATA(fh, chan, maxpoints, stime, etime{, filtermask})
%
%            INPUTS: FH = file handle
%                    CHAN = channel number 0 to SONMAXCHANS-1
%                    MAXPOINTS = Maximum number of data values to return
%                                (up to 32767, if zero this will be set to
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
%                    EXTRA= An X x NPOINT array. The NPOINT columns contain
%                            the extra data for each marker. The length of 
%                            the columns varies between channels.
%                            EXTRA is int16 for ADCMark channels, single 
%                               for RealMark and uint8 for TextMark
%
% Note: If required, cast TextMark EXTRA data to type char in MATLAB 
%       If you do not need the EXTRA data, use SONGetMarkData instead
%
% For error codes, see the CED documentation
%
%ML 04/05

 */



#include <string.h>
#include <stdio.h>
#include <windows.h>
#include <matrix.h>
#include "mex.h"

#include "son.h"
#include "machine.h"
#include "SONDef.h"

HINSTANCE hinstLib;
BOOL fFreeResult;


// Calls the SON32.DLL read routine
long _SONGetExtMarkData(short    fh,
WORD    chan,
TpMarker   pMark,
long    maxpoints,
TSTime  sTime,
TSTime  eTime,
TpFilterMask    pFltMask)
{
    long i;
    FARPROC SONGetExtMarkData;
    SONGetExtMarkData = GetProcAddress(hinstLib,"SONGetExtMarkData");
    i=(*SONGetExtMarkData)(fh, chan, pMark, maxpoints, sTime, eTime,pFltMask);
    return i;
}

WORD _SONItemSize(short fh, WORD chan)
{
    FARPROC SONItemSize;
    WORD i;
    SONItemSize=GetProcAddress(hinstLib,"SONItemSize");
    i=(*SONItemSize)(fh, chan);
    return i;
}

TDataKind _SONChanKind(short fh, WORD chan)
{
    FARPROC SONChanKind;
    TDataKind i;
    SONChanKind=GetProcAddress(hinstLib, "SONChanKind");
    i=(*SONChanKind)(fh, chan);
    return i;
}


void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
    
    short   fh;
    WORD    chan;
    TpMarker pMark;
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
    int markbytes;
    long *MarkPtr1;
    long *ptr1;
    char *MarkPtr2;
    char *ptr2;
    int n;
    TpRealMark RealPtr, ptr4;
    TpAdc AdcPtr, ptr3;
    
    //Used for filter
    int m;
    const int *empty[2]={0,0};
    
    if (nrhs<5)
        mexErrMsgTxt("SONGetExtMarkData: Too few  arguments\n");
    
    //Get input arguments
    fh=mxGetScalar(prhs[0]);                   //File handle
    chan=mxGetScalar(prhs[1]);                 //Channel number
    maxpoints=mxGetScalar(prhs[2]);            //maxpoints - see below
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
        p=mxGetPr(plhs[0]);
        p[0]=SON_BAD_PARAM;
        return;
    }
    
    markbytes=max(1,_SONItemSize(fh, chan));
    pMark=mxCalloc(maxpoints,markbytes);
    
    
    //Call DLL
    npoints=_SONGetExtMarkData(fh, chan, pMark, maxpoints, sTime, eTime, pFltMask);
    fFreeResult = FreeLibrary(hinstLib);
    
    //return results. This one goes in ans if no arguments
    plhs[0]=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
    ret=mxGetData(plhs[0]);
    *ret=npoints;
    
    if (npoints<0) npoints=0;
    
    if (nlhs>=2){
        dim[0]=max(0,npoints);
        dim[1]=1;
        plhs[1]=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
        ptr1=mxGetData(plhs[1]);
        MarkPtr1=(long *)pMark;
        for (m=0; m<npoints; m++) {
            *ptr1++=*MarkPtr1;
            MarkPtr1=(long *)((char *)MarkPtr1+markbytes);
        }
    }
    
    if (nlhs>=3) {
        dim[0]=max(0,npoints);
        dim[1]=4;
        plhs[2]=mxCreateNumericArray(2, dim, mxUINT8_CLASS, mxREAL);
        ptr2=mxGetData(plhs[2]);
        MarkPtr2=(char *)pMark+sizeof(long);
        for (n=0; n<4; n++) {
            for (m=0; m<npoints; m++){
                *ptr2++=*((char *)MarkPtr2+n);
            }
            MarkPtr2=(char *)MarkPtr2+markbytes;
        }
    }
    
    if (nlhs==4){
        switch(_SONChanKind(fh, chan)) {
            case AdcMark:
                dim[0]=(markbytes-sizeof(TMarker))/2;
                dim[1]=max(0,npoints);
                plhs[3]=mxCreateNumericArray(2, dim, mxINT16_CLASS, mxREAL);
                ptr3=mxGetData(plhs[3]);
                AdcPtr=(TpAdc)((char *)pMark+sizeof(TMarker));
                for (m=0; m<dim[1]; m++){
                    for (n=0; n<dim[0]; n++) {
                        *ptr3++ = *AdcPtr++;
                    }
                    AdcPtr=(TpAdc)((char *)AdcPtr+sizeof(TMarker));
                }
                break;
            case RealMark:
                dim[0]=(markbytes-sizeof(TMarker))/2;
                dim[1]=max(0,npoints);
                plhs[3]=mxCreateNumericArray(2, dim, mxSINGLE_CLASS, mxREAL);
                ptr4=mxGetData(plhs[3]);
                RealPtr=(TpRealMark)((char *)pMark+sizeof(TMarker));
                for (m=0; m<dim[1]; m++){
                    for (n=0; n<dim[0]; n++) {
                        *ptr4++ = *RealPtr++;
                    }
                    RealPtr=(TpRealMark)((char *)RealPtr+sizeof(TMarker));
                }
                break;
            case TextMark:
                dim[1]=max(0,npoints);
                dim[0]=(markbytes-sizeof(TMarker));
                plhs[3]=mxCreateNumericArray(2, dim, mxUINT8_CLASS, mxREAL);
                ptr2=mxGetData(plhs[3]);
                MarkPtr2=(char *)pMark+sizeof(TMarker);
                for (m=0; m<dim[1]; m++){
                    for (n=0; n<dim[0]; n++) {
                        *ptr2++=*MarkPtr2++;
                    }
                    MarkPtr2=(char *)MarkPtr2+sizeof(TMarker);
                }
                break;
                default:
                    dim[0]=0;
                    dim[1]=0;
                    plhs[3]=mxCreateNumericArray(2, dim, mxDOUBLE_CLASS, mxREAL);
        }
    }
    
    mxFree(pMark);
}




