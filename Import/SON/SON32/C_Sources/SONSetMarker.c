/*% SONSETMARKER replaces the data associated with a marker on disc
% 
% Implemented through SONSetMarker.dll
% 
% RET=SONSETMARKER(FH, CHAN, TIME, NEWTIME, {NEWMARKERS, {NEWEXTRA}})
%   FH = the SON file handle
%   CHAN = the target marker channel
%   TIME = the current timestamp of the target marker entry (clock ticks)
%   NEWTIME = a new time that will replace the timestamp in TIME
%   NEWMARKERS = if present, a set of 4 uint8 marker values that will replace
%               those on disc
%   NEWEXTRA = if present, the extra data to replace all or some of the 
%               existing extra data
%                These may be:  int16 (for AdcMark)
%                               single (for RealMark)
%                               or uint8 (for TextMark)
%                               (N.B. not char which is 16bit in matlab)
%
% The data type for NEWEXTRA must match that of the target channel (the function
% returns SON_NO_EXTRA if it does not. 
%
% e.g SONSetMarker(fh, 2, 140100, 140200)
%     replaces the timestamp only
%     SONSetMarker (fh, 2, 140100, 14020, uint8([22 33 44 55]))
%     replaces the markers also
%     SONSetMarker (fh, 2, 140100, 14020, uint8([22 33 44 55]), int16([0 0]))
%     also replaces the first two extra data entries with zero on an AdcMark channel
%     
% Returns: 1 if the replacement occured.    
%          0 if not e.g. NEWEXTRA is longer than the existing entry or the 
%              new timestamp would break the temporal sequence of successive
%              entries
%          or an negative error code
%          
%     
%     ML 05/05
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
short _SONSetMarker(short    fh,
WORD    chan,
TSTime  time,
TpMarker pMark,
WORD size)
{
    short i;
    FARPROC SONSetMarker;
    SONSetMarker = GetProcAddress(hinstLib,"SONSetMarker");
    if (SONSetMarker != NULL){
        i=(*SONSetMarker)(fh, chan, time, pMark, size);
        return i;
    }
    mexErrMsgTxt("SONSetMarker not found in SON32.DLL\n");
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
    long npoints=0;
    unsigned char *ptr;
    int dim[2]={1,1};
    long *p;
    int err=0;
    WORD size=0;
    TSTime time;
    TMarker Marker;
    TAdcMark adcmark;
    TRealMark realmark;
    TTextMark textmark;
    TpMarker temp=&Marker;
       
    
    if (nrhs<4)
        mexErrMsgTxt("SONSetMarker: Too few  arguments\n");
    
    
    //Get input arguments
    fh=mxGetScalar(prhs[0]);                   //File handle
    chan=mxGetScalar(prhs[1]);                 //Channel number
    time=mxGetScalar(prhs[2]);                // time of marker
    
        
    Marker.mark=mxGetScalar(prhs[3]);           //New timestamp value
    size=sizeof(TSTime);
  
    //New marker values if present
    if(nrhs>=5) {
        ptr=mxGetData(prhs[4]);
        memcpy(&Marker.mvals, ptr, sizeof(TMarkBytes));
        size=sizeof(TMarker);
    }

    //Load and get pointer to the library SON32.DLL//
    hinstLib = LoadLibrary(SON32);
    if (hinstLib == NULL){
        mexPrintf("%s not found",SON32);
        plhs[0]=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
        p=mxGetData(plhs[0]);
        p[0]=SON_BAD_PARAM;
        return;
    }
 
    //Extra data if present
    if (nrhs==6) {
        switch (mxGetClassID(prhs[5])){
            case mxUINT8_CLASS:
                if (_SONChanKind(fh, chan)== 8) {
                    size=mxGetN(prhs[5])*mxGetM(prhs[5]);
                    memcpy(&textmark.t, mxGetData(prhs[5]), size);
                    textmark.m=Marker;
                    temp=(TpMarker)&textmark;
                }
                else
                    err=SON_NO_EXTRA;
                break;
            case mxINT16_CLASS:
                if (_SONChanKind(fh, chan)== 6) {
                    size=2*mxGetN(prhs[5])*mxGetM(prhs[5]);
                    memcpy(&adcmark.a, mxGetData(prhs[5]), size);
                    adcmark.m=Marker;
                    temp=(TpMarker)&adcmark;
                }
                else
                    err=SON_NO_EXTRA;
                break;
            case mxSINGLE_CLASS:
                if (_SONChanKind(fh, chan)== 7) {
                    size=4*mxGetN(prhs[5])*mxGetM(prhs[5]);
                    memcpy(&realmark.r, mxGetData(prhs[5]), size);
                    realmark.m=Marker;
                    temp=(TpMarker)&realmark;
                }
                else
                    err=SON_NO_EXTRA;
                break;
        }
        size=size+sizeof(TMarker);
    }
    else
        err=SON_BAD_PARAM;
    
    
    
    if (err != 0) {
        plhs[0]=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
        p=mxGetData(plhs[0]);
        p[0]=err;
        return;
    }
    
 
    //Call DLL
    npoints=_SONSetMarker(fh, chan, time, temp, size);
    fFreeResult = FreeLibrary(hinstLib);
    
    
    //return results. This one goes in ans if no arguments
    plhs[0]=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
    p=mxGetData(plhs[0]);
    p[0]=npoints;
    
    
}



