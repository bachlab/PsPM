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

int _SONAppID(short fh, TSONCreator *p1, TSONCreator *p2)
{
    FARPROC SONAppID;
    int i;
    SONAppID=GetProcAddress(hinstLib,"SONAppID");
    if (SONAppID != NULL){
        i=(*SONAppID)(fh, p1, p2);
        return i;
    }
    mexErrMsgTxt("SONAppID not found in library\n");
}


void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
    short fh, i;
    TSONCreator creator={""};
    char buf [9];
    double *p;
    const int dim[2]={1,8};
    
    if (nrhs>=1)
        fh=mxGetScalar(prhs[0]);
    
    if (nrhs==2){
        if (mxGetClassID(prhs[1])==mxCHAR_CLASS) {
            mxGetString(prhs[1], &buf, 9);
            memcpy(creator.acID, buf, 8);
        }
        else
            mexErrMsgTxt("SONAppID: String required on input (arg 2)");
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

if (nrhs==1)
    i=_SONAppID(fh, &creator, NULL); //read
else {
    i=_SONAppID(fh, NULL, &creator); //write
    _SONAppID(fh, &creator, NULL); //and read back
}

fFreeResult = FreeLibrary(hinstLib);

memcpy(&buf, creator.acID, 8);
buf[8]=0;
plhs[0]=mxCreateString(&buf);
return;
}
