/*% SONLASTPOINTSTIME returns the time for which a read will terminate
%
% Implemented through SONLastPointsTime.dll
%
% TIME=SONGETADCDATA(FH, CHAN, ETIME, STIME, LPOINTS, BADC {, FILTERMASK})
%
%   INPUTS: FH SON File Handle
%           CHAN Channel number (1 to SONMaxChannels)
%           STIME Searches back from this time
%           ETIME stops search at this time (eTime must be less than sTime)
%           LPOINTS the number of points it is dsired to read
%           BADC ADCMark data will be treated as Adc if this set
%           FILTERMASK, if present, a filter mask
%
% Returns the time at which the read will end i.e. the time of the final data
% point or a negative error code
% 
% ML 05/05
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

TSTime _SONLastPointsTime(short fh,
                    WORD chan,
                    TSTime sTime,
                    TSTime eTime,
                    long lpoints,
                    BOOL bAdc,
                    TpFilterMask pFltMask)
{
    FARPROC SONLastPointsTime;
    TSTime ret;
    
    SONLastPointsTime=GetProcAddress(hinstLib, "SONLastPointsTime");
    if (SONLastPointsTime!=NULL){
        ret=(*SONLastPointsTime)(fh, chan, sTime, eTime, lpoints, bAdc, pFltMask);
        return ret;
    }
}



void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
    
    short   fh;
    WORD    chan;
    TSTime sTime, eTime, ResTime;
    TpSTime peTime;
    unsigned char *ptr;
    TpFilterMask    pFltMask=NULL;
    TFilterMask FilterMask;
    BOOL bAdc;
    long lpoints;
    
    int const dim[2]={1,1};
    int m;
    
    int GetFilterMask();
    
    
    if (nrhs<6)
        mexErrMsgTxt("SONGetADCData: Too few input arguments\n");
    
    //Get input arguments
    fh=mxGetScalar(prhs[0]);                   //File handle
    chan=mxGetScalar(prhs[1]);                 //Channel number
    sTime=mxGetScalar(prhs[2]);                //Start time for data search
    eTime=mxGetScalar(prhs[3]);                //End Time
    lpoints=mxGetScalar(prhs[4]);              //Number of points
    bAdc=mxGetScalar(prhs[5]);                 // If set, treat ADCMark data
                                               // as adc
    
    //Get and set up the filter mask
    if (nrhs==7 && mxIsStruct(prhs[7])==1){
        GetFilterMask(prhs[7], FilterMask);
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
    
    
    ResTime=_SONLastPointsTime(fh, chan, sTime, eTime, bAdc, lpoints, pFltMask);
    fFreeResult = FreeLibrary(hinstLib);
    
    plhs[0]=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
    peTime=mxGetData(plhs[0]);
    *peTime=ResTime;
    
    
}








