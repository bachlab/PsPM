/*% SONLASTTIME returns information about the last entry on a channel
% before a specified time
%
% Implemented through SONLastTime.dll
%
%[time, data, markers, markerflag]=...
%                       SONGETADCDATA(fh, chan, eTime, sTime{, FilterMask})
%
%   INPUTS: FH SON File Handle
%           CHAN Channel number (1 to SONMaxChannels)
%           STIME Searches back from this time
%           ETIME stops search at this time (eTime must be less than sTime)
%           FILTERMASK, if present, a filter mask
%
%   OUTPUTS: TIME The time of the last data point between ETIME and STIME
%                   or a negative error code
%            DATA Value at TIME for an ADC or Real channel.
%                   For an EventBoth channel the InitLow value
%            MARKERS the marker codes for the event at TIME for
%                   a marker channel
%            MARKERFLAG Set to 1 if CHAN is a marker channel, 0 otherwise
% 
% ML 04/05
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


// Calls the SON32.DLL  routine

TSTime _SONLastTime(short fh,
                    WORD chan,
                    TSTime sTime,
                    TSTime eTime,
                    TpVoid pvVal,
                    TpMarkBytes pMB,
                    TpBOOL pbMark,
                    TpFilterMask pFltMask)
{
    FARPROC SONLastTime;
    TSTime ret;
    
    SONLastTime=GetProcAddress(hinstLib, "SONLastTime");
    if (SONLastTime!=NULL){
        ret=(*SONLastTime)(fh, chan, sTime, eTime, pvVal, pMB, pbMark, pFltMask);
        return ret;
    }
    else {
        mexErrMsgTxt("SONLastTime not found in DLL");
        return -99;
    }
}



void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
    
    short   fh;
    WORD    chan;
    TSTime sTime, eTime, ResTime;
    TpSTime peTime;
    TMarkBytes  MB={0,0,0,0};
    unsigned char *ptr;
    BOOLEAN bMark=0;
    TpFilterMask    pFltMask=NULL;
    TFilterMask FilterMask;
    TAdc p=0;
    TpAdc pdata;
    int dim[2]={1,1};
    int m;
    
    int GetFilterMask();
    
    
    if (nrhs<3)
        mexErrMsgTxt("SONGetADCData: Too few input arguments\n");
    
    //Get input arguments
    fh=mxGetScalar(prhs[0]);                   //File handle
    chan=mxGetScalar(prhs[1]);                 //Channel number
    sTime=mxGetScalar(prhs[2]);                //Start time for data search
    eTime=mxGetScalar(prhs[3]);                //End Time
    
    //Get and set up the filter mask
    if (nrhs==5 && mxIsStruct(prhs[4])==1){
        GetFilterMask(prhs[4], FilterMask);
        pFltMask=&FilterMask;
    }
    else
        pFltMask=NULL;
    
    
    //Load and get pointer to the library SON32.DLL//
    hinstLib = LoadLibrary(SON32);
    if (hinstLib == NULL){
        mexPrintf("%s not found",SON32);
        plhs[0]=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
        *mxGetPr(plhs[0])=SON_BAD_PARAM;
        return;
    }
    
    
ResTime=_SONLastTime(fh, chan, sTime, eTime, &p, MB, &bMark, pFltMask);
fFreeResult = FreeLibrary(hinstLib);
    
    plhs[0]=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
    peTime=mxGetData(plhs[0]);
    *peTime=ResTime;

    if(nlhs>=2){
        plhs[1]=mxCreateNumericArray(2, dim, mxINT16_CLASS, mxREAL);
        pdata=mxGetData(plhs[1]);
        *pdata=p;
    }
    
    if (nlhs>=3){
        dim[1]=4;
        plhs[2]=mxCreateNumericArray(2,dim,mxUINT8_CLASS,mxREAL);
        ptr=mxGetData(plhs[2]);
        for (m=0; m<=3; m++)
            *ptr++=MB[m];
    }
   
    if (nlhs==4){
        dim[1]=1;
        plhs[3]=mxCreateNumericArray(2,dim,mxDOUBLE_CLASS,mxREAL);
        *mxGetPr(plhs[3])=bMark;
    }
}








