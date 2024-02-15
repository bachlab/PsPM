#include <string.h>
#include <stdio.h>
#include <windows.h>
#include <matrix.h>
#include "mex.h"
#include "son.h"
#include "machine.h"

int GetFilterMask(mxArray *rhsptr, TpFilterMask pMask)

{
    mxArray *tmpPtr;
    int error;
    unsigned char *ptr;
    const int *empty[2]={0,0};

    
    tmpPtr=mxGetField(rhsptr,0,"lFlags");
    
    if ((tmpPtr==NULL) || mxGetClassID(tmpPtr) != mxINT32_CLASS){
        mexPrintf("Bad Filter: lFlags missing or not int32 class\n");
        error=1;
    }
    else {
        (*pMask).lFlags=mxGetScalar(tmpPtr);
    }
    
    tmpPtr=mxGetField(rhsptr,0,"aMask");
    if (tmpPtr ==NULL){
        mexPrintf("SONGetRealData Bad Filter: aMask missing\n");
        error=1;
    }
    else {
        if ((mxGetM(tmpPtr)!=32) ||( mxGetN(tmpPtr)!=4)){
            mexPrintf("SONGetRealData Bad Filter:"
            "aMask has wrong dimensions\n");
            error=1;
        }
        if (mxGetClassID(tmpPtr) != mxUINT8_CLASS){
            mexPrintf("SONGetRealData Bad Filter:"
            "aMask must be uint8 class\n");
            error=1;
        }
    }
    if (error==1)
        return SON_BAD_PARAM;
    
    ptr=mxGetData(tmpPtr);// Mask

    memcpy((*pMask).aMask,ptr,sizeof((*pMask).aMask));
   
    return 1;
}
