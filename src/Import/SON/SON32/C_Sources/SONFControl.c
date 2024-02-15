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

int _SONFControl(TpFilterMask pMask, int layer, int item, int set)
{
    FARPROC SONFControl;
    int i;
    SONFControl=GetProcAddress(hinstLib,"SONFControl");
    if (SONFControl != NULL){
        i=(*SONFControl)(pMask, layer, item, set);
        return i;
    }
    mexErrMsgTxt("SONFControl not found in library\n");
}


void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
    TFilterMask FilterMask={0,0};
    int layer, item, set;
    int i, *ret;
    int dim[2]={1,1};
    double *p;
    char fieldnames[2][7]={"lFlags","aMask"};
    const char  *f[2];
    const char  **fnames=&f[0];
    long *tmpPtr;
    int len;
    char *ptr;
    char mode[8];
    
    f[0]=&fieldnames[0][0];
    f[1]=&fieldnames[1][1];
        
    if (nrhs<4) {
        mexPrintf("SONFControl:Too few LHS arguments \n");
        plhs[0]=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
        ret=mxGetData(plhs[0]);
        *ret=SON_BAD_PARAM;
        return;
    }

    if (mxIsStruct(prhs[0])==1)
        GetFilterMask(prhs[0], &FilterMask);
    else {
        mexPrintf("SONFControl:No valid filter mask on  input \n");
        plhs[0]=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
        ret=mxGetData(plhs[0]);
        *ret=SON_BAD_PARAM;
        return;
        
    }
        
        
    
    if (mxIsNumeric(prhs[1]))
        layer=mxGetScalar(prhs[1]);
    else
        layer=SON_FALLLAYERS;
        
    if (mxIsNumeric(prhs[2]))
        item=mxGetScalar(prhs[2]);
    else
        item=SON_FALLITEMS;
  
    len=mxGetN(prhs[3])*mxGetM(prhs[3])+1;
    if(len>7)
        len=7;
    mxGetString(prhs[3], mode, len);
        
switch (mode[0]) {
    case 'C':
    case 'c':
            set=SON_FCLEAR;
            break;
    case 'S':
    case 's':
            set=SON_FSET;
            break;
    case 'I':
    case 'i':
            set=SON_FINVERT;
            break;
    case 'R':
    case 'r':
    default:
            set=SON_FREAD;
            break;
}
                                        
    
    //Load and get pointer to the library SON32.DLL//
    hinstLib = LoadLibrary(SON32);
    if (hinstLib == NULL){
        mexPrintf("%s not found",SON32);
        plhs[0]=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
        p=mxGetPr(plhs[0]);
        p[0]=SON_BAD_PARAM;
        return;
    }
    
    
    i=_SONFControl(&FilterMask, layer, item, set);
    fFreeResult = FreeLibrary(hinstLib);
    
    plhs[0]=mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL);
    ret=mxGetData(plhs[0]);
    *ret=i;
    
    if (nrhs==2) {
      
        plhs[1]=mxCreateStructMatrix(1, 1, 2, fnames);
        if (plhs[1] != NULL) {
            mxSetField(plhs[1], 0, "lFlags",
            mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL));
            tmpPtr=mxGetData(mxGetField(plhs[1], 0, "lFlags"));
            *tmpPtr=FilterMask.lFlags;
            dim[0]=32;
            dim[1]=4;
            mxSetField(plhs[1], 0, "aMask",
            mxCreateNumericArray(2, dim, mxUINT8_CLASS, mxREAL));
            ptr=mxGetData(mxGetField(plhs[1], 0, "aMask"));
            memcpy(ptr, &FilterMask.aMask, sizeof(FilterMask.aMask));
        }
    }

}
