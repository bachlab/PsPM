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

BOOLEAN _SONFEqual(TpFilterMask Mask1, TpFilterMask Mask2)
{
    FARPROC SONFEqual;
    int i;
    SONFEqual=GetProcAddress(hinstLib,"SONFEqual");
    if (SONFEqual != NULL){
        i=(*SONFEqual)(Mask1, Mask2);
        return i;
    }
    mexErrMsgTxt("SONFEqual not found in library\n");
}


void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
    TFilterMask FilterMask1, FilterMask2;
    int i, *ret;
    int dim[2]={1,1};
    double *p;

    
    if (nrhs<2)return;
    
    if (mxIsStruct(prhs[0])==1 && mxIsStruct(prhs[1])==1 )
    GetFilterMask(prhs[0], &FilterMask1);
    GetFilterMask(prhs[1], &FilterMask2);
    
    //Load and get pointer to the library SON32.DLL//
    hinstLib = LoadLibrary(SON32);
    if (hinstLib == NULL){
        mexPrintf("%s not found",SON32);
        plhs[0]=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
        p=mxGetPr(plhs[0]);
        p[0]=SON_BAD_PARAM;
        return;
    }
    
    
    i=_SONFEqual(&FilterMask1, &FilterMask2);
    mexPrintf("%d \n",i);
    fFreeResult = FreeLibrary(hinstLib);
    plhs[0]=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
    ret=mxGetData(plhs[0]);
    *ret=i;
    return;
}
