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

int _SONFActive(TpFilterMask Mask)
{
    FARPROC SONFActive;
    int i;
    SONFActive=GetProcAddress(hinstLib,"SONFActive");
    if (SONFActive != NULL){
        i=(*SONFActive)(Mask);
        return i;
    }
    mexErrMsgTxt("SONFActive not found in library\n");
}


void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
    TFilterMask FilterMask;
    int i, *ret;
    int dim[2]={1,1};
    double *p;

    
    if (nrhs<1)
        mexErrMsgTxt("SONFEqual: Too few input arguments\n");
    
    if (mxIsStruct(prhs[0])==1)
        GetFilterMask(prhs[0], &FilterMask);
    
//Load and get pointer to the library SON32.DLL//
    hinstLib = LoadLibrary(SON32);
    if (hinstLib == NULL){
        mexPrintf("%s not found",SON32);
        plhs[0]=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
        p=mxGetPr(plhs[0]);
        p[0]=SON_BAD_PARAM;
        return;
    }
    
    
    i=_SONFActive(&FilterMask);
    plhs[0]=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
    ret=mxGetData(plhs[0]);
    *ret=i;
    fFreeResult = FreeLibrary(hinstLib);
    return;
}
