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

int _SONTimeDate(short fh, TSONTimeDate *p1, TSONTimeDate *p2)
{
    FARPROC SONTimeDate;
    int i;
    SONTimeDate=GetProcAddress(hinstLib,"SONTimeDate");
    if (SONTimeDate != NULL){
        i=(*SONTimeDate)(fh, p1, p2);
        return i;
    }
    mexErrMsgTxt("SONTimeDate not found in library\n");
}


void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
    short fh, i, *ret;
    TSONTimeDate Date={0,0,0,0,0,0};
    TSONTimeDate *pDate=&Date;
    double *ptr, *p;
    const int dim[2]={1,6};
    
    if (nrhs>=1)
        fh=mxGetScalar(prhs[0]);
    
    if (nrhs==2){
        ptr=mxGetPr(prhs[1]);
        if ( (mxGetM(prhs[1])==1) && (mxGetN(prhs[1])==6) ) {
            Date.wYear=*ptr++;
            Date.ucMon=*ptr++;
            Date.ucDay=*ptr++;
            Date.ucHour=*ptr++;
            Date.ucMin=*ptr++;
            Date.ucSec=*ptr;
            Date.ucHun=(*ptr-Date.ucSec+0.05)*10.0;
            mexPrintf("%d\n",Date.ucHun);
        }
        else
            mexErrMsgTxt("SONTimeDate: matlab clock style input required");
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
        i=_SONTimeDate(fh, pDate, NULL); //read
    else {
        i=_SONTimeDate(fh, NULL, pDate); //write
        _SONTimeDate(fh, pDate, NULL); //and read back
    }

    fFreeResult = FreeLibrary(hinstLib);
    
    
    plhs[0]=mxCreateNumericArray(2, dim, mxDOUBLE_CLASS, mxREAL);
    if (i>=0) {
        ptr=mxGetData(plhs[0]);
        *ptr++=Date.wYear;
        *ptr++=Date.ucMon;
        *ptr++=Date.ucDay;
        *ptr++=Date.ucHour;
        *ptr++=Date.ucMin;
        *ptr=Date.ucSec+(Date.ucHun*0.1);
    }
    return;
}
