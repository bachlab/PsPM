/*
 *
 *      Old compiling notes:
 *      --------------------
 *      mex sdk_mex.cpp ADIDatIOWin.lib
 *      mex -v sdk_mex.cpp LoadADIDatDll.cpp ADIDatIOWin64.lib
 *
 *      Compiling should be done via:
 *      adi.sdk.makeMex()
 *
 *      http://www.mathworks.com/help/matlab/matlab_external/passing-arguments-to-shared-library-functions.html
 *
 */

#define MAX_STRING_LENGTH 500 //I decided to avoid trying to deal with any
//sort of dynamic allocation. Since strings aren't that long, I'm fine
//hardcoding this value for now, assuming that this value is plenty large

#include <stdint.h>
#include <stdio.h>
#include <malloc.h>
#include <time.h>
#include <float.h>
#include "mex.h"
#include "ADIDatCAPI_mex.h"
#include <ctime>
//#include "LoadADIDatDll.h"

int ref_count = 0; //NYI
int locked = 0;

void setDoubleOutput(mxArray *plhs[],int index, double value)
{
    
    //Sets a single scalar value at the output location specified
    //
    //  Inputs:
    //  ------------------------------------
    //  plhs  : The output data
    //  index : which index to set the data for (0 based)
    //  value : The value to assign to that particular output
    //
    //  Example: (In Matlab)
    // [a,b] = testFunction()
    //
    //  Let's say we are trying to set b to 5
    //
    //  setLongOutput(plhs,1,5)
    
    //NOTE: We've hardcoded the output to be a scalar
    plhs[index] = mxCreateNumericMatrix(1,1,mxDOUBLE_CLASS,mxREAL);
    double *p_value;
    p_value    = (double *)mxGetData(plhs[index]);
    p_value[0] = value;
}

void setInt64Output(mxArray *plhs[],int index, int64_t value)
{
	plhs[index] = mxCreateNumericMatrix(1,1,mxINT64_CLASS,mxREAL);
    
    
    int64_t *p_value;
    p_value    = (int64_t *)mxGetData(plhs[index]);
    p_value[0] = value;
}

//TODO: It would be nice to template these ...
void setLongOutput(mxArray *plhs[],int index, long value)
{
    
    //Sets a single scalar value at the output location specified
    //
    //  Inputs:
    //  -------
    //  plhs  : The output data
    //  index : which index to set the data for (0 based)
    //  value : The value to assign to that particular output
    //
    //  Example: (In Matlab)
    // [a,b] = testFunction()
    //
    //  Let's say we are trying to set b to 5
    //
    //  setLongOutput(plhs,1,5)
    
    //NOTE: We've hardcoded the output to be a scalar
    
    //TODO: Is this correct with a 64 bit system ?????
    plhs[index] = mxCreateNumericMatrix(1,1,mxINT32_CLASS,mxREAL);
    
    
    long *p_value;
    p_value    = (long *)mxGetData(plhs[index]);
    p_value[0] = value;
}

double getDoubleInput(const mxArray *prhs[], int index){
    
    double *p_value;
    p_value = (double *)mxGetData(prhs[index]);
    
    //Compare start time
    
    //Return only first value (assume only 1 value)
    return p_value[0];
    
}

int getIntInput(const mxArray *prhs[], int index){
    
    int *p_value;
    p_value = (int *)mxGetData(prhs[index]);
    return p_value[0];
    
}

long getLongInput(const mxArray *prhs[], int index){
    
    long *p_value;
    p_value = (long *)mxGetData(prhs[index]);
    return p_value[0];
}

int64_t getInt64Input(const mxArray *prhs[], int index){
    
    int64_t *p_value;
    p_value = (int64_t *)mxGetData(prhs[index]);
    return p_value[0];
}

//===================================================================

ADI_FileHandle getFileHandle(const mxArray *prhs[])
{
    
    //ASSUMPTION: We currently assume the file handle will be the second
    //input to the function, after the function option (i.e. index 1)
    
    return ADI_FileHandle(getInt64Input(prhs,1));
}

ADI_CommentsHandle getCommentsHandle(const mxArray *prhs[])
{
    
    //TODO: I can replace this now with a call to getLongInput ...
//     int *input_file_handle;
//     input_file_handle = (int *)mxGetData(prhs[1]);
//     return ADI_CommentsHandle(input_file_handle[0]);
//     
    return ADI_CommentsHandle(getInt64Input(prhs,1));
}

ADI_WriterHandle getWriterHandle(const mxArray *prhs[]){
    return ADI_WriterHandle(getLongInput(prhs,1));
}

wchar_t *getStringOutputPointer(mxArray *plhs[],int index)
{
    plhs[index] = mxCreateNumericMatrix(1,MAX_STRING_LENGTH,mxINT16_CLASS,mxREAL);
    return (wchar_t *)mxGetData(plhs[index]);
}

void setFileHandle(mxArray *plhs[], ADIResultCode result, ADI_FileHandle fileH){
    
    //Used by openFile and createFile
    
    int64_t *fh_pointer;
    //Assign to 2nd value, first is the status code ...
    plhs[1]    = mxCreateNumericMatrix(1,1,mxINT64_CLASS,mxREAL);
    fh_pointer = (int64_t *) mxGetData(plhs[1]);
    if (result == 0)
    {
        fh_pointer[0] = (int64_t)fileH;
    }
    else
    {
        fh_pointer[0] = 0;
    }
}

void setWriterHandle(mxArray *plhs[], ADIResultCode result, ADI_WriterHandle writerH){
    
    int64_t *wh_pointer;
    //Assign to 2nd value, first is the status code ...
    plhs[1]    = mxCreateNumericMatrix(1,1,mxINT64_CLASS,mxREAL);
    wh_pointer = (int64_t *) mxGetData(plhs[1]);
    if (result == 0)
    {
        wh_pointer[0] = (int64_t)writerH;
    }
    else
    {
        wh_pointer[0] = 0;
    }
}


//=========================================================================
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    //Documentation of the calling forms is given within each if clause

    if (!locked)
    {
        

        
        //NOTE: If we run clear all this will clear the definition of
        //this file and depending on whether or not we had open references
        //could cause Matlab to crash. By locking this file we prevent
        //clearing the file (which means we can't recompile it unless we
        //close Matlab) but we also prevent Matlab from crashing.
        //
        //TODO: Implement allowing unlock by reference counting
        //TODO: Alternatively we could pass in a command to unlock
        mexLock();
        locked = 1;
    }
    
    
    ADI_FileHandle fileH(0);
    
    
    //Setup output result code
    //-----------------------------------------------
    //Each function returns a result code, indicating if the function call
    //worked or not.
    ADIResultCode result;
    int *out_result; //Each function will return a result code as well as
    //possibly other values ..
    plhs[0]    = mxCreateNumericMatrix(1,1,mxINT32_CLASS,mxREAL);
    out_result = (int *) mxGetData(plhs[0]);
    
    
    //Which function to call
    double function_option = mxGetScalar(prhs[0]);
    
    //Function list
    //--------------------------------------
    // 0  ADI_OpenFile
    // 1  ADI_GetNumberOfRecords
    // 2  ADI_GetNumberOfChannels
    // 3  ADI_GetNumTicksInRecord
    // 4  ADI_GetRecordTickPeriod
    // 5  ADI_GetNumSamplesInRecord
    // 6  ADI_CreateCommentsAccessor
    // 7  ADI_CloseCommentsAccessor
    // 8  ADI_GetCommentInfo
    // 9  ADI_NextComment
    // 10 ADI_GetSamples
    // 11 ADI_GetUnitsName
    // 12 ADI_GetChannelName
    // 13 ADI_CloseFile
    // 14 ADI_GetErrorMessage
    // 15 ADI_GetRecordSamplePeriod
    // 16 ADI_GetRecordTime
    // 17 ADI_CreateFile
    
    
    if (function_option == 0)
    {
        //  ADI_OpenFile   <>   openFile
        //  ===================================================
        //  [result_code,file_h] = sdk_mex(0,file_path)
        
        wchar_t *w_file_path = (wchar_t *)mxGetData(prhs[1]);

        //long openMode  = getLongInput(prhs,2);
        
        result        = ADI_OpenFile(w_file_path, &fileH, kOpenFileForReadOnly);
        out_result[0] = result;

        setFileHandle(plhs,result,fileH);
    }
    else if (function_option == 0.5)
    {
		//This is a call to open the file for reading and writing
		//
        //TODO: Replace this with an input to function 0
        
        wchar_t *w_file_path = (wchar_t *)mxGetData(prhs[1]);

        result        = ADI_OpenFile(w_file_path, &fileH, kOpenFileForReadAndWrite);
        out_result[0] = result;

        setFileHandle(plhs,result,fileH);
    }
    else if (function_option == 1)
    {
        //  ADI_GetNumberOfRecords   <>   getNumberOfRecords
        //  ======================================================
        //  [result_code,n_records] = sdk_mex(1,file_handle)
        
        long nRecords = 0;
        fileH         = getFileHandle(prhs);
        
        //ADIResultCode ADI_GetNumberOfRecords(ADI_FileHandle fileH, long* nRecords);
        result        = ADI_GetNumberOfRecords(fileH,&nRecords);
        out_result[0] = result;
        setLongOutput(plhs,1,nRecords);
        
    }
    else if (function_option == 2)
    {
        //  ADI_GetNumberOfChannels   <>   getNumberOfChannels
        //  ========================================================
        //  [result_code,n_channels] = sdk_mex(2,file_handle)
        
        long nChannels = 0;
        fileH = getFileHandle(prhs);
        
        //ADIResultCode ADI_GetNumberOfChannels(ADI_FileHandle fileH, long* nChannels);
        result         = ADI_GetNumberOfChannels(fileH,&nChannels);
        out_result[0]  = result;
        setLongOutput(plhs,1,nChannels);
    }
    else if (function_option == 3)
    {
        //  ADI_GetNumTicksInRecord   <>   getNTicksInRecord
        //  ======================================================
        //  [result,n_ticks] = sdk_mex(3,file_handle,record_idx_0b)
        
        fileH = getFileHandle(prhs);
        
        //0 or 1 based ...
        long record = getLongInput(prhs,2);
        long nTicks = 0;
        
        //ADIResultCode ADI_GetNumTicksInRecord(ADI_FileHandle fileH, long record, long* nTicks);
        result         = ADI_GetNumTicksInRecord(fileH,record,&nTicks);
        out_result[0]  = result;
        setLongOutput(plhs,1,nTicks);
    }
    else if (function_option == 4)
    {
        //  ADI_GetRecordTickPeriod  <>  getTickPeriod
        //  =========================================================
        //  [result,s_per_tick] = sdk_mex(4,file_handle,record_idx_0b,channel_idx_0b)
        
        fileH          = getFileHandle(prhs);
        
        long record  = getLongInput(prhs,2);
        long channel = getLongInput(prhs,3);
        double secsPerTick = 0;
        
        //ADIResultCode ADI_GetRecordTickPeriod(ADI_FileHandle fileH, long channel, long record, double* secsPerTick);
        out_result[0] = ADI_GetRecordTickPeriod(fileH,channel,record,&secsPerTick);
        setDoubleOutput(plhs,1,secsPerTick);
        
    }
    else if (function_option == 5)
    {
        //  ADI_GetNumSamplesInRecord  <>  getNSamplesInRecord
        //  ========================================================
        //  [result_code,n_samples] = sdk_mex(5,file_handle,record_idx_0b,channel_idx_0b);
        
        fileH          = getFileHandle(prhs);
        
        long record   = getLongInput(prhs,2);
        long channel  = getLongInput(prhs,3);
        long nSamples = 0;
        
        //ADIResultCode ADI_GetNumSamplesInRecord(ADI_FileHandle fileH, long channel, long record, long* nSamples);
        out_result[0] = ADI_GetNumSamplesInRecord(fileH,channel,record,&nSamples);
        setLongOutput(plhs,1,nSamples);
    }
    else if (function_option == 6)
    {
        //  ADI_CreateCommentsAccessor  <>  getCommentAccessor
        //  ========================================================
        //  [result_code,comments_h] = sdk_mex(6,file_handle,record_idx_0b);
        
        ADI_CommentsHandle commentsH(0);
        fileH         = getFileHandle(prhs);
        long record   = getLongInput(prhs,2);
        
        //ADIResultCode ADI_CreateCommentsAccessor(ADI_FileHandle fileH, long record, ADI_CommentsHandle* commentsH);
        result = ADI_CreateCommentsAccessor(fileH,record,&commentsH);
        out_result[0] = result;
        
        int64_t *p_c;
        plhs[1]    = mxCreateNumericMatrix(1,1,mxINT64_CLASS,mxREAL);
        p_c = (int64_t *) mxGetData(plhs[1]);
        if (result == 0)
            p_c[0] = (int64_t)commentsH;
        else
            p_c[0] = 0;
    }
    else if (function_option == 7)
    {
        //  ADI_CloseCommentsAccessor   <>   closeCommentAccessor
        //  ========================================================
        //  result_code = sdk_mex(7,comments_h);
        
        ADI_CommentsHandle commentsH = getCommentsHandle(prhs);
        
        //ADIResultCode ADI_CloseCommentsAccessor(ADI_CommentsHandle *commentsH);
        out_result[0] = ADI_CloseCommentsAccessor(&commentsH);
    }
    else if (function_option == 8)
    {
        //  ADI_GetCommentInfo   <>   getCommentInfo
        //  ====================================================
        //  [result_code,comment_string,comment_length,tick_pos,channel,comment_num] = sdk_mex(8,comment_h)
        //
        //  Status: Done
        
        ADI_CommentsHandle commentsH = getCommentsHandle(prhs);
        
        wchar_t *messageOut = getStringOutputPointer(plhs,1);
        long tickPos    = 0;
        long channel    = 0;
        long commentNum = 0;
        long textLen    = 0;
        
        
        //ADIResultCode ADI_GetCommentInfo(ADI_CommentsHandle commentsH, long *tickPos, long *channel, long *commentNum, wchar_t* text,long maxChars, long *textLen);
        //          tickPos                 - receives the tick position of the comment in the record [outparam]
        //          commentNum              - receives the number of the comment [outparam]
        //          channel                 - receives the channel of the comment (-1 for all channel comments) [outparam]
        //          text                    - buffer to receive null terminated text for the comment (optional, may be NULL) [outparam]
        //          maxChars                - the size of the text buffer in wchar_t s. The text will be truncated to fit in this size
        //          textLen                 - receives the number of characters needed to hold the full comment text,
        //                                    even if parameter text is NULL (optional, may be NULL) [outparam]
        
        out_result[0] = ADI_GetCommentInfo(commentsH,&tickPos,&channel,&commentNum,messageOut,MAX_STRING_LENGTH,&textLen);
        
        setLongOutput(plhs,2,textLen);
        setLongOutput(plhs,3,tickPos);
        setLongOutput(plhs,4,channel);
        setLongOutput(plhs,5,commentNum);
        
    }
    else if (function_option == 9)
    {
        
        //  ADI_NextComment  <>  advanceComments
        //  ==================================================
        //  result_code = adi.sdk_mex(9,comments_h);
        //
        //  Returns kResultNoData if there are no more comments ...
        //
        //  Status: Done
        
        ADI_CommentsHandle commentsH = getCommentsHandle(prhs);
        
        //ADIResultCode ADI_NextComment(ADI_CommentsHandle commentsH);
        out_result[0] = ADI_NextComment(commentsH);
    }
    else if (function_option == 10)
    {
        //  ADI_GetSamples   <>   getChannelData
        //  ===========================================================
        //  [result,data,n_returned] = sdk_mex(10,file_h,channel_0b,record_0b,startPos,nLength,dataType)
        
        fileH = getFileHandle(prhs);
        
        long channel  = getLongInput(prhs,2);
        long record   = getLongInput(prhs,3);
        long startPos = getLongInput(prhs,4);
        long nLength  = getLongInput(prhs,5);
        
        ADICDataFlags dataType = static_cast<ADICDataFlags>(getLongInput(prhs,6));

        plhs[1]     = mxCreateNumericMatrix(1,(mwSize)nLength,mxSINGLE_CLASS,mxREAL);
        float *data = (float *)mxGetData(plhs[1]);
        
        long returned = 0;
        // Retrieves a block of sample data from the file into a buffer. Samples are in physical
        // prefixed units.
        //DLLEXPORT ADIResultCode ADI_GetSamples(ADI_FileHandle fileH, long channel, long record, long startPos,
        //  ADICDataFlags dataType, long nLength, float* data, long* returned);
        out_result[0] = ADI_GetSamples(fileH,channel,record,startPos,dataType,nLength,data,&returned);
        //out_result[0] = ADI_GetSamples(fileH,channel,record,startPos,kADICDataAtSampleRate,nLength,data,&returned);
        
        setLongOutput(plhs,2,returned);
        
        //out_result[0] = 4;
    }
    else if (function_option == 11)
    {
        //  ADI_GetUnitsName   <>  getUnits
        //  =======================================
        //  [result_code,str_data,str_length] = sdk_mex(11,file_h,record,channel);
        
        //Inputs
        fileH        = getFileHandle(prhs);
        long record  = getLongInput(prhs,2);
        long channel = getLongInput(prhs,3);
        
        //Outputs
        long textLen      = 0;
        wchar_t *unitsOut = getStringOutputPointer(plhs,1);
        
        
        // Retrieves the prefixed units of a channel, as a string.
        //
        //ADIResultCode ADI_GetUnitsName(ADI_FileHandle fileH, long channel, long record, wchar_t* units, long maxChars, long *textLen);
        out_result[0] = ADI_GetUnitsName(fileH, channel, record, unitsOut, MAX_STRING_LENGTH, &textLen);
        setLongOutput(plhs,2,textLen);
    }
    else if (function_option == 12)
    {
        //  ADI_GetChannelName   <>   getChannelName
        //  =============================================
        //  [result_code,str_data,str_length] = sdk_mex(12,file_h,channel);
        
        
        //Inputs
        fileH        = getFileHandle(prhs);
        long channel = getLongInput(prhs,2);
        
        //Outputs
        long textLen        = 0;
        wchar_t *nameOut    = getStringOutputPointer(plhs,1);
        
        // Retrieves the name of a channel, as a string.
        
        //ADIResultCode ADI_GetChannelName(ADI_FileHandle fileH, long channel, wchar_t* name, long maxChars, long *textLen);
        out_result[0] = ADI_GetChannelName(fileH, channel, nameOut, MAX_STRING_LENGTH, &textLen);
        setLongOutput(plhs,2,textLen);
    }
    else if (function_option == 13)
    {
        //  ADI_CloseFile   <>   closeFile
        //  ==============================================================
        //
        
        fileH          = getFileHandle(prhs);
        result         = ADI_CloseFile(&fileH);
        out_result[0]  = result;
    }
    else if (function_option == 14)
    {
        //  ADI_GetErrorMessage   <>   getErrorMessage
        //  ==============================================================
        //  err_msg = sdk_mex(14,error_code)
        
        long textLen        = 0;
        
        wchar_t *messageOut = getStringOutputPointer(plhs,1);
        
        ADIResultCode code  = (ADIResultCode)getLongInput(prhs,1);
        
        //ADIResultCode ADI_GetErrorMessage(ADIResultCode code, wchar_t* messageOut, long maxChars, long *textLen);
        out_result[0] = ADI_GetErrorMessage(code, messageOut, MAX_STRING_LENGTH, &textLen);
        setLongOutput(plhs,2,textLen);
        
    }
    else if (function_option == 15)
    {
        //   ADI_GetRecordSamplePeriod   <>   getSamplePeriod
        //   ==============================================================
        //   [result_code,dt_channel] = sdk_mex(15,file_h,record,channel)
        
        fileH        = getFileHandle(prhs);
        long record  = getLongInput(prhs,2);
        long channel = getLongInput(prhs,3);
        double secsPerSample = 0;
        
        out_result[0] = ADI_GetRecordSamplePeriod(fileH, channel, record, &secsPerSample);
        setDoubleOutput(plhs,1,secsPerSample);
    }
    else if (function_option == 16)
    {
        //   ADI_GetRecordTime   <>   getRecordStartTime
        //   ==============================================================
        //   [result_code,trigger_time,frac_secs,trigger_minus_rec_start] = sdk_mex(16,file_h,record)
        
        fileH        = getFileHandle(prhs);
        long record  = getLongInput(prhs,2);
        
        time_t triggerTime = 0;
        double fracSecs    = 0;
        long   triggerMinusStartTicks = 0;
        
        //Retrieves time information about the specified record.
        //The trigger time is the time origin of the record and may differ from the start time if
        //there is a pre or post trigger delay, as specified by the trigMinusRecStart parameter.
        // Params: fileH             - ADI_FileHandle for the open file
        //         record            - the record index (starting from 0)
        //         triggerTime       - time_t receives the date and time of the trigger
        //                             position for the new record. Measured as number of
        //                             seconds from 1 Jan 1970
        //         fracSecs          - receives the fractional seconds part of
        //                             the record trigger time ('triggerTime' parameter)
        //         trigMinusRecStart - trigger-time-minus-record-start-ticks. Receives the
        //                             difference between the time of trigger tick and the first
        //                             tick in the record. This +ve for pre-trigger delay and
        //                             -ve for post-trigger delay.
        // Return: a ADIResultCode for result of the operation
        
        //DLLEXPORT ADIResultCode ADI_GetRecordTime(ADI_FileHandle fileH, long record, time_t *triggerTime,
        //double *fracSecs, long *triggerMinusStartTicks);
        
        out_result[0] = ADI_GetRecordTime(fileH, record, &triggerTime, &fracSecs, &triggerMinusStartTicks);
        
        setDoubleOutput(plhs,1,(double)triggerTime);
        setDoubleOutput(plhs,2,fracSecs);
        setLongOutput(plhs,3,triggerMinusStartTicks);
        
    }
    else if (function_option == 17){
        //
        //   ADI_CreateFile   <>   createFile
        //   ==============================================================
        //   [result_code,file_h] = sdk_mex(17,file_path)
        //    
        //   Implemented via sdk.createFile
        
        wchar_t *w_file_path = (wchar_t *)mxGetData(prhs[1]);
        
        result        = ADI_CreateFile(w_file_path, &fileH);
        out_result[0] = result;
        
        setFileHandle(plhs,result,fileH);
    }
    else if (function_option == 18){
        //
        //   ADI_SetChannelName  <>  setChannelName
        //   ==============================================================
        //   [result_code,file_h] = sdk_mex(18,file_h,channel,name)
        //
        //   Implemented via sdk.setChannelName
        
        fileH = getFileHandle(prhs);
        long channel = getLongInput(prhs,2);
        wchar_t *channel_name = (wchar_t *)mxGetData(prhs[3]);
        
        out_result[0] = ADI_SetChannelName(fileH, channel, channel_name);
    }
    else if (function_option == 19){
        //
        //   ADI_CreateWriter  <>  createDataWriter
        //   ===========================================
        //   [result_code,writer_h] = sdk_mex(19,file_h)
        //
        //  Implemented via sdk.createDataWriter
        
        ADI_WriterHandle writerH(0);
        
        fileH = getFileHandle(prhs);
        
        result        = ADI_CreateWriter(fileH,&writerH);
        out_result[0] = result;
        
        setWriterHandle(plhs,result,writerH);
    }
    else if (function_option == 20){
        //
        //   ADI_SetChannelInfo  <>  setChannelInfo
        //   ===========================================
        //   [result_code] = sdk_mex(20,writer_h,channel,enabled,seconds_per_sample,units,limits)
        //
        //   implemented via adi.sdk.setChannelInfo
        
        ADI_WriterHandle writerH = getWriterHandle(prhs);
        
        long channel = getLongInput(prhs,2);
        int enabled  = getIntInput(prhs,3);
        double seconds_per_sample = getDoubleInput(prhs,4);
        wchar_t *units = (wchar_t *)mxGetData(prhs[5]);
        float *temp_limits = (float *)mxGetData(prhs[5]);
        ADIDataLimits limits;
        limits.mMaxLimit = temp_limits[1];
        limits.mMinLimit = temp_limits[0];
        
        out_result[0] = ADI_SetChannelInfo(writerH, channel, enabled, seconds_per_sample, units, &limits);
        
//       DLLEXPORT ADIResultCode ADI_SetChannelInfo(ADI_WriterHandle writerH, long channel, int enabled,
//       double secondsPerSample, const wchar_t* units, const ADIDataLimits *limits);
        
    }
    else if (function_option == 21){
        //
        //   ADI_StartRecord  <>  startRecord
        //   ===========================================
        //   result_code = sdk_mex(21, writerH, trigger_time, fractional_seconds, trigger_minus_rec_start)
        //
        //   implemented via adi.sdk.startRecord
        
        ADI_WriterHandle writerH = getWriterHandle(prhs);
        time_t trigger_time = (time_t)getDoubleInput(prhs,2);
        double fractional_seconds = getDoubleInput(prhs,3);
        long trigger_minus_rec_start = getLongInput(prhs,4);
        
        out_result[0] = ADI_StartRecord(writerH, trigger_time, fractional_seconds, trigger_minus_rec_start);
        
//            DLLEXPORT ADIResultCode ADI_StartRecord(ADI_WriterHandle writerH, time_t triggerTime,
//       double fracSecs, long triggerMinusStartTicks);
    }
    else if (function_option == 22){
        //
        //   ADI_AddChannelSamples  <>  addChannelSamples
        //   ===========================================
        //   [result_code,new_ticks_added] = sdk_mex(22, writerH, channel, data, n_samples)
        //
        //  adi.sdk.addChannelSamples
        
        ADI_WriterHandle writerH = getWriterHandle(prhs);
        long channel = getLongInput(prhs,2);
        float *data  = (float *)mxGetData(prhs[3]);
        long n_samples = (long)mxGetNumberOfElements(prhs[3]);
        long new_ticks_added = 0;
        
        out_result[0] = ADI_AddChannelSamples(writerH, channel, data, n_samples, &new_ticks_added);
        
        setLongOutput(plhs,1,new_ticks_added);
        
//       DLLEXPORT ADIResultCode ADI_AddChannelSamples(ADI_WriterHandle writerH, long channel,
//       float* data, long nSamples, long *newTicksAdded);
    }
    else if (function_option == 23){
        //
        //   ADI_FinishRecord  <>  finishRecord
        //   ===========================================
        //   [result_code] = sdk_mex(23, writerH)
        //
        //  Implemented via adi.sdk.finishRecord
        
        ADI_WriterHandle writerH = getWriterHandle(prhs);
        
        out_result[0] = ADI_FinishRecord(writerH);
        
//        DLLEXPORT ADIResultCode ADI_FinishRecord(ADI_WriterHandle writerH);
    }
    else if (function_option == 24){
        //
        //   ADI_CommitFile  <>  commitFile
        //   ===========================================
        //   [result_code] = sdk_mex(24, writerH, flags)
        //
        //  Implemented via adi.sdk.commitFile
        
        ADI_WriterHandle writerH = getWriterHandle(prhs);
        
        //TODO: What are the flags??????
        
        out_result[0] = ADI_CommitFile(writerH, 0);
        
//         DLLEXPORT ADIResultCode ADI_CommitFile(ADI_WriterHandle writerH, long flags);
    }
    else if (function_option == 25){
        //
        //   ADI_CloseWriter  <>  closeWriter
        //   ===========================================
        //   [result_code] = sdk_mex(25, writerH)
        //
        //  Implemented via adi.sdk.closeWriter
        
        ADI_WriterHandle writerH = getWriterHandle(prhs);
        
        out_result[0] = ADI_CloseWriter(&writerH);
        
//      DLLEXPORT ADIResultCode ADI_CloseWriter(ADI_WriterHandle *writerH);
    }
    else if (function_option == 26){
        //
        //   ADI_AddComment  <>  addComment
        //   ===========================================
        //   [result_code, comment_number] =
        //      sdk_mex(26, file_h, channel, record, tick_position, text)
        //
        //  Implemented via adi.sdk.addComment
        
        fileH = getFileHandle(prhs);
        long channel = getLongInput(prhs,2);
        long record  = getLongInput(prhs,3);
        long tick_position = getLongInput(prhs,4);
        wchar_t *text = (wchar_t *)mxGetData(prhs[5]);
        long comment_number = 0;
        //long comment_number = getLongInput(prhs,6);
        
        out_result[0] = ADI_AddComment(fileH, channel, record, tick_position, text, &comment_number);
        
        setLongOutput(plhs,1,comment_number);
        
//        DLLEXPORT ADIResultCode ADI_AddComment(ADI_FileHandle fileH, long channel, long record, long tickPos,
//       const wchar_t* text, long* commentNum);
    }
    else if (function_option == 27){
        //
        //   ADI_DeleteComment  <>  deleteComment
        //   ===========================================
        //   result_code = sdk_mex(27,file_h,comment_number)
        //
        //  Implemented via adi.sdk.deleteComment
        
        fileH = getFileHandle(prhs);
        long comment_number = getLongInput(prhs,2);
        
        out_result[0] = ADI_DeleteComment(fileH,comment_number);
        
//         DLLEXPORT ADIResultCode ADI_DeleteComment(ADI_FileHandle fileH, long commentNum);
    }
    else if (function_option == 100){
        mexUnlock();
        locked = 0;
    }
    else
    {
        mexErrMsgIdAndTxt("adinstruments:sdk_mex",
                "Invalid function option");
    }

    //ADI_GetRecordSamplePeriod
    //ADI_GetRecordTime
}