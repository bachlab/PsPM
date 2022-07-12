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

long _SONFMode(TpFilterMask pMask, int mode)
{
    FARPROC SONFMode;
    long i;
    SONFMode=GetProcAddress(hinstLib,"SONFMode");
    if (SONFMode != NULL){
        i=(*SONFMode)(pMask, mode);
        return i;
    }
    mexErrMsgTxt("SONFMode not found in library\n");
}


void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
    TFilterMask FilterMask={0,0};
    int index, lmode, len;
    int dim[2]={1,1};
    double *p;
    long retmode;
    char mode[4];
    const char fieldnames[2][7]={"lFlags","aMask"};
    const char  *f[2];
    const char  **fnames=&f[0];
    long *tmpPtr;
    char *ptr;    
    
    f[0]=&fieldnames[0][0];
    f[1]=&fieldnames[1][0];
    
    if (nrhs<1)
        mode[0]='a';
    else {
        index=0;
        if (mxIsStruct(prhs[0])==1){
            GetFilterMask(prhs[0], &FilterMask);
            index=1;
        }
        
        len=mxGetN(prhs[index])*mxGetM(prhs[index])+1;
        if(len>7)
            len=7;
        mxGetString(prhs[index], mode, len);
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
    
    switch (mode[0]) {
        case 'o':
        case 'O':  lmode=SON_FMASK_ORMODE;
        break;
        case 'a':
        case 'A': lmode=SON_FMASK_ANDMODE;
        break;
        case 'n':
        case 'N':
            default: lmode=-1;
    }
    
    retmode=_SONFMode(&FilterMask, lmode);
    fFreeResult = FreeLibrary(hinstLib);
    
    
    plhs[0]=mxCreateStructMatrix(1, 1, 2, fnames);
    if (plhs[0] != NULL) {
        mxSetField(plhs[0], 0, "lFlags",
        mxCreateNumericArray(2, dim, mxINT32_CLASS, mxREAL));
        tmpPtr=mxGetData(mxGetField(plhs[0], 0, "lFlags"));
        *tmpPtr=FilterMask.lFlags;
        dim[0]=32;
        dim[1]=4;
        mxSetField(plhs[0], 0, "aMask",
        mxCreateNumericArray(2, dim, mxUINT8_CLASS, mxREAL));
        ptr=mxGetData(mxGetField(plhs[0], 0, "aMask"));
        memcpy(ptr, &FilterMask.aMask, sizeof(FilterMask.aMask));
    }
    
    
    
    
}
