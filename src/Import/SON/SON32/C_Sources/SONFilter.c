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

int _SONFilter(TpMarker pMarks, TpFilterMask pMask)
{
    FARPROC SONFilter;
    long i;
    SONFilter=GetProcAddress(hinstLib,"SONFilter");
    if (SONFilter != NULL){
        i=(*SONFilter)(pMarks, pMask);
        return i;
    }
    mexErrMsgTxt("SONFilter not found in library\n");
}


void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
    TFilterMask FilterMask;
    int i, *ret;
    int dim[2]={1,1};
    double *p;
    TMarker Mark;
    unsigned char *ptr;
    mxArray *ptr2;
    
    if (nrhs<2) {
        mexPrintf("SONFilter:Too few LHS arguments \n");
        plhs[0]=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
        ret=mxGetData(plhs[0]);
        *ret=SON_BAD_PARAM;
        return;
    }
    
    ptr=NULL;
    if (mxIsStruct(prhs[0])){
        ptr2=mxGetField(prhs[0],0,"mvals");
        if (ptr2 != NULL)
            ptr=mxGetData(ptr2);
    }
    else 
        ptr=mxGetData(prhs[0]);

    if (ptr==NULL) {
        mexPrintf("SONFilter:Invalid markers: 4-btye uint8 vector\n"
        " or TMarker structure expected\n");
        plhs[0]=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
        ret=mxGetData(plhs[0]);
        *ret=SON_BAD_PARAM;
        return;
    }
        
    memcpy(&Mark.mvals, ptr, 4);

        
        if (mxIsStruct(prhs[1])==1)
        GetFilterMask(prhs[1], &FilterMask);
    

    

    //Load and get pointer to the library SON32.DLL//
    hinstLib = LoadLibrary(SON32);
    if (hinstLib == NULL){
        mexPrintf("%s not found",SON32);
        plhs[0]=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
        p=mxGetPr(plhs[0]);
        p[0]=SON_BAD_PARAM;
        return;
    }
    
    
    i=_SONFilter(&Mark, &FilterMask);
    fFreeResult = FreeLibrary(hinstLib);
     

    plhs[0]=mxCreateNumericArray(2,dim,mxINT32_CLASS, mxREAL);
    ptr=mxGetData(plhs[0]);
    *ptr=i;

    
    

}
