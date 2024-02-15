/**
* Copyright (c) 2011-2012 ADInstruments. All rights reserved.
*
* \ADIDatFileSDK_license_start
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*
* 1. Redistributions of source code must retain the above copyright notice, this
*    list of conditions and the following disclaimer.
*
* 2. The name of ADInstruments may not be used to endorse or promote products derived
*    from this software without specific prior written permission.
*
* 3. This is an unsupported product which you use at your own risk. For unofficial 
*    technical support, please use http://www.adinstruments.com/forum .
*
* THIS SOFTWARE IS PROVIDED BY ADINSTRUMENTS "AS IS" AND ANY EXPRESS OR IMPLIED
* WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT ARE
* EXPRESSLY AND SPECIFICALLY DISCLAIMED. IN NO EVENT SHALL ADINSTRUMENTS BE LIABLE FOR
* ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*
* \ADIDatFileSDK_license_end
*/

//JAH Modifications
//====================================================
//- removed trailing comma in enumerations
//- made enumerations typedef and added explicit alias


#ifndef ADIDatCAPI_H__
#define ADIDatCAPI_H__


#ifdef ADIDATIOWIN_EXPORTS
#define DLLEXPORT   __declspec(dllexport)
#else
#define DLLEXPORT
#endif


#ifdef __cplusplus
extern "C" {
#endif


   // Result code values 
   typedef enum ADIResultCode
      {
      //Win32 error codes (HRESULTs)
      kResultSuccess = 0,                             // operation succeeded
      kResultErrorFlagBit        = 0x80000000L,       // high bit set if operation failed
      kResultInvalidArg          = 0x80070057L,       // invalid argument. One (or more) of the arguments is invalid
      kResultFail                = 0x80004005L,       // Unspecified error
      kResultFileNotFound        = 0x80030002L,       // failure to find the specified file (check the path)


      //Start of error codes specific to this API      
      kResultADICAPIMsgBase        = 0xA0049000L,

      kResultFileIOError  = kResultADICAPIMsgBase,    // file IO error - could not read/write file
      kResultFileOpenFail,                            // file failed to open
      kResultInvalidFileHandle,                       // file handle is invalid
      kResultInvalidPosition,                         // pos specified is outside the bounds of the record or file
      kResultInvalidCommentNum,                       // invalid commentNum. Comment could not be found
      kResultNoData,                                  // the data requested was not present (e.g. no more comments in the record).
      kResultBufferTooSmall                          // the buffer passed to a function to receive data (e.g. comment text) was not big enough to receive all the data.
      
                                                      // new result codes must be added at the end
      } ADIResultCode;


   // File open modes 
   typedef enum ADIFileOpenMode
      {
      kOpenFileForReadOnly = 0,  // opens the file as read-only, so data cannot be written
      kOpenFileForReadAndWrite  // opens the file as read/write
      } ADIFileOpenMode;


   // Data Types : ADICDataFlags
   typedef enum ADICDataFlags
      {
      kADICDataAtSampleRate = 0,                 // specifies that the function uses samples
      kADICDataAtTickRate = 0x80000000          // specifies that the function uses ticks
      } ADICDataFlags;
    

   //Struct holding maximum and minimum values between which valid 
   //data values in a channel fall.
   typedef struct ADIDataLimits
      {
      float mMaxLimit;
      float mMinLimit;
      } ADIDataLimits;

   // Handles - essentially void* with a little added type safety.
   struct ADI_FileHandle__ { int unused; }; typedef struct ADI_FileHandle__ *ADI_FileHandle;
   struct ADI_WriterHandle__ { int unused; }; typedef struct ADI_WriterHandle__ *ADI_WriterHandle;
   struct ADI_CommentsHandle__ { int unused; }; typedef struct ADI_CommentsHandle__ *ADI_CommentsHandle;

// Define ADI_USELOADIDATDLL to link explicitly to the ADIDatDll. To link implicitly using the
// import library leave this undefined.
#ifndef ADI_USELOADIDATDLL


   //--------------------
   // General Operations:
   //


   // Opens an existing *.adidat file for read and write operations and returns a pointer 
   // to it.
   // If operation is successful, 'fileH' param will be be a handle to the file, else 0.
   // Params: path  - absolute, delimited path to the file, 
   //                 e.g. "C:\\MyData\\TestFile.adidat"
   //         fileH - pointer to an ADI_FileHandle object [outparam]
   //         mode  - ADIFileOpenMode option for controlling the how the file is to be opened
   // Return: a ADIResultCode for result of the operation
   DLLEXPORT ADIResultCode ADI_OpenFile(const wchar_t* path, ADI_FileHandle* fileH, ADIFileOpenMode mode);


   // Creates a new *.adidat file for write operations at the specified location and 
   // returns a pointer to it.
   // If operation is successful, 'file' param will be be a handle to the file, else 0.
   // Params: path  - absolute, delimited path to the file, 
   //                 e.g. "C:\\MyData\\NewFile.adidat"
   //         fileH - pointer to an ADI_FileHandle object [outparam]
   // Return: a ADIResultCode for result of the operation
   DLLEXPORT ADIResultCode ADI_CreateFile(const wchar_t* path, ADI_FileHandle* fileH);


   // Retrieves a text description of a result code returned from an API call.
   // Params: code     - an ADIResultCode value
   //         message  - null-terminated text for the error message [outparam]
   //         maxChars - the size used for the buffer. Must not exceed this when copying 
   //                    text into the buffer
   //         textLen  - receives the number of characters needed to hold the full comment text, 
   //                     even if parameter text is NULL (optional, may be NULL) [outparam]
   // Return: returns kResultBufferTooSmall if maxChars was too small to receive the full title text.
   // Return: a ADIResultCode for result of the operation
   DLLEXPORT ADIResultCode ADI_GetErrorMessage(ADIResultCode code, wchar_t* messageOut, 
      long maxChars, long *textLen);


   // Converts a tick position to a sample position for a given channel.
   // Params: fileH              - ADI_FileHandle for the open file
   //         channel            - the channel index (starting from 0)
   //         record             - the record index (starting from 0)
   //         tickInRecord       - the tick position to be converted
   //         samplePosInRecord  - the converted sample position [outparam]
   // Return: a ADIResultCode for result of the operation
   DLLEXPORT ADIResultCode ADI_TickToSamplePos(ADI_FileHandle fileH, long channel, long record, 
      long tickInRecord, double* samplePosInRecord);


   // Converts a sample position to a tick position for a given channel.
   // Params: fileH              - ADI_FileHandle for the open file
   //         channel            - the channel index (starting from 0)
   //         record             - the record index (starting from 0)
   //         samplePosInRecord  - the tick position to be converted
   //         tickInRecord       - the converted sample position [outparam]
   // Return: a ADIResultCode for result of the operation
   DLLEXPORT ADIResultCode ADI_SamplePosToTick(ADI_FileHandle fileH, long channel, long record, 
      double samplePosInRecord, double* tickInRecord);


   //-----------------
   // Read Operations:
   //


   // Retrieves the number of records in the file.
   // Params: fileH    - ADI_FileHandle for the open file
   //         nRecords - the number of records in the file [outparam]
   // Return: a ADIResultCode for result of the operation 
   DLLEXPORT ADIResultCode ADI_GetNumberOfRecords(ADI_FileHandle fileH, long* nRecords);


   // Retrieves the number of channels in the file.
   // Params: fileH     - ADI_FileHandle for the open file
   //         nChannels - the number of channels in the file [outparam]
   // Return: a ADIResultCode for result of the operation 
   DLLEXPORT ADIResultCode ADI_GetNumberOfChannels(ADI_FileHandle fileH, long* nChannels);


   // Retrieves the number of ticks in the specified record.
   // Params: fileH   - ADI_FileHandle for the open file
   //         record  - the record index (starting from 0)
   //         nTicks  - the number of ticks in the record [outparam]
   // Return: a ADIResultCode for result of the operation 
   DLLEXPORT ADIResultCode ADI_GetNumTicksInRecord(ADI_FileHandle fileH, long record, long* nTicks);


   // Retrieves the tick period for the specified record and channel.
   // Params: fileH       - ADI_FileHandle for the open file
   //         channel     - the channel in the record (starting from 0)
   //         record      - the record index (starting from 0)
   //         secsPerTick - the tick period for the record [outparam]
   // Return: a ADIResultCode for result of the operation 
   DLLEXPORT ADIResultCode ADI_GetRecordTickPeriod(ADI_FileHandle fileH, long channel, long record, 
      double* secsPerTick);


   // Retrieves the number of samples in the specified record.
   // Params: fileH    - ADI_FileHandle for the open file
   //         channel  - the channel in the record (starting from 0)
   //         record   - the record index (starting from 0)
   //         nSamples - the number of samples in the record [outparam]
   // Return: a ADIResultCode for result of the operation 
   DLLEXPORT ADIResultCode ADI_GetNumSamplesInRecord(ADI_FileHandle fileH, long channel, long record, 
      long* nSamples);


   // Retrieves the sample period for the specified record.
   // Params: fileH         - ADI_FileHandle for the open file
   //         channel       - the channel in the record (starting from 0)
   //         record        - the record index (starting from 0)
   //         secsPerSample - the sample period for the record [outparam]
   // Return: a ADIResultCode for result of the operation 
   DLLEXPORT ADIResultCode ADI_GetRecordSamplePeriod(ADI_FileHandle fileH, long channel, long record, 
      double* secsPerSample);


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
   DLLEXPORT ADIResultCode ADI_GetRecordTime(ADI_FileHandle fileH, long record, time_t *triggerTime, 
      double *fracSecs, long *triggerMinusStartTicks);


   // Creates a comments accessor handle for the specified record.
   // Params: fileH         - ADI_FileHandle for the open file
   //         record        - the record index (starting from 0)
   //         commentsH     - handle to the new comments accessor for the record [outparam]
   // Return: a ADIResultCode for result of the operation 
   DLLEXPORT ADIResultCode ADI_CreateCommentsAccessor(ADI_FileHandle fileH, long record, 
      ADI_CommentsHandle* commentsH);


   // Closes the comments accessor, releasing the memory it used.
   // Sets the ADI_CommentsHandle to 0.
   // Params: ADI_CommentsHandle       - handle to a comments accessor
   // Return: a ADIResultCode for result of the operation
   DLLEXPORT ADIResultCode ADI_CloseCommentsAccessor(ADI_CommentsHandle *commentsH);


   // Retrieves information from the comment currently referenced by the comments accessor.
   // Params: ADI_CommentsHandle       - handle to a comments accessor
   //          tickPos                 - receives the tick position of the comment in the record [outparam]
   //          commentNum              - receives the number of the comment [outparam]
   //          channel                 - receives the channel of the comment (-1 for all channel comments) [outparam]
   //          text                    - buffer to receive null terminated text for the comment (optional, may be NULL) [outparam]
   //          maxChars                - the size of the text buffer in wchar_t s. The text will be truncated to fit in this size
   //          textLen                 - receives the number of characters needed to hold the full comment text, 
   //                                    even if parameter text is NULL (optional, may be NULL) [outparam]
   // Return: returns kResultBufferTooSmall if maxChars was too small to receive the full comment text.
   // Returns kResultNoData if this accessor has reached the end of the comments in the record.
   DLLEXPORT ADIResultCode ADI_GetCommentInfo(ADI_CommentsHandle commentsH, long *tickPos, long *channel, long *commentNum, wchar_t* text, 
      long maxChars, long *textLen);


   // Advances the comments accessor to the next comment in the record
   // Params: ADI_CommentsHandle       - handle to a comments accessor
   // Returns kResultNoData if this accessor has reached the end of the comments in the record.
   DLLEXPORT ADIResultCode ADI_NextComment(ADI_CommentsHandle commentsH);


   // Retrieves a block of sample data from the file into a buffer. Samples are in physical 
   // prefixed units.
   // Params: fileH    - ADI_FileHandle for the open file
   //         channel  - the channel containing the desired data (starting from 0)
   //         record   - the record containing the start position of the desired data 
   //                    (starting from 0)
   //         startPos - the start position as an offset from the start of the record (0)
   //         nLength  - number of elements (ticks/samples) to retrieve
   //         dataType - specifies the type of data (ticks or samples) to retrieve
   //         data     - pointer to a float array of 'nLength' in size    
   //                    e.g. float* data=(float*)malloc(sizeof(float*kDataSize)); [outparam]
   //         returned - the number of samples actually returned by the function (may be less 
   //                    than the amount requested) [outparam]
   // Return: a ADIResultCode for result of the operation
   DLLEXPORT ADIResultCode ADI_GetSamples(ADI_FileHandle fileH, long channel, long record, long startPos, 
      ADICDataFlags dataType, long nLength, float* data, long* returned);


   // Retrieves the prefixed units of a channel, as a string.
   // Params: fileH     - ADI_FileHandle for the open file
   //         channel   - the unit's channel (starting from 0)
   //         record    - the unit's record (starting from 0)
   //         units     - buffer to receive null terminated text for the units name (optional, may be NULL) [outparam]
   //         maxChars  - the size of the text buffer in wchar_t s. The text will be truncated to fit in this size
   //         textLen   - receives the number of characters needed to hold the full comment text, 
   //                     even if parameter text is NULL (optional, may be NULL) [outparam]
   // Return: returns kResultBufferTooSmall if maxChars was too small to receive the full comment text.
   // Return: a ADIResultCode for result of the operation
   DLLEXPORT ADIResultCode ADI_GetUnitsName(ADI_FileHandle fileH, long channel, long record, wchar_t* units, 
      long maxChars, long *textLen);


   // Retrieves the name of a channel, as a string.
   // Params: fileH    - ADI_FileHandle for the open file
   //         channel  - the channel index (starting from 0)
   //         name    - null-terminated text for the name [outparam]
   //         maxChars - the size used for the buffer. Must not exceed this when copying 
   //                    text into the buffer
   //         textLen   - receives the number of characters needed to hold the full comment text, 
   //                     even if parameter text is NULL (optional, may be NULL) [outparam]
   // Return: returns kResultBufferTooSmall if maxChars was too small to receive the full title text.
   // Return: a ADIResultCode for result of the operation
   DLLEXPORT ADIResultCode ADI_GetChannelName(ADI_FileHandle fileH, long channel, wchar_t* name, 
      long maxChars, long *textLen);


   //------------------
   // Write Operations:
   //

   // Sets the name of the specified channel.
   // Params: file    - ADI_FileHandle for the open file
   //         channel - the channel to set the name (starting from 0)
   //         name   - null-terminated text string with the channel name
   // Return: a ADIResultCode for result of the operation
   DLLEXPORT ADIResultCode ADI_SetChannelName(ADI_FileHandle fileH, long channel, const wchar_t* name);


   // Creates a new writer session for writing new data and returns a handle to that open writer for use in 
   // other related functions.
   // Params: fileH             - ADI_FileHandle for the open file
   //         writerH           - ADI_WriterHandle for the new writing session [outparam]
   // Return: a ADIResultCode for result of the operation
   DLLEXPORT ADIResultCode ADI_CreateWriter(ADI_FileHandle fileH, ADI_WriterHandle* writerH);


   // Sets the channel information for the specified channel in a new record to be written by the writer session.
   // Params: writerH          - ADI_WriterHandle for the writing session
   //         channel          - the channel to receive the new info (starting from 0)
   //         enabled          - boolean value set true (1) if data is to be added to this channel in the new record
   //         secondsPerSample - new sample period for this channel in the new record 
   //         unitsName        - null-terminated text string units for the channel record
   //         limits           - Optional pointer to a struct holding maximum and minimum values between which valid 
   //                            data values in the channel fall.
   //                            If NULL, the limits are +ve and -ve infinity.
   //
   // Return: a ADIResultCode for result of the operation
   DLLEXPORT ADIResultCode ADI_SetChannelInfo(ADI_WriterHandle writerH, long channel, int enabled, 
      double secondsPerSample, const wchar_t* units, const ADIDataLimits *limits);


   //Starts the writer recording a new record, setting the trigger time.
   //The trigger time is the time origin of the record and may differ from the start time if
   //there is a pre or post trigger delay, as specified by the trigMinusRecStart parameter.
   //         writerH           - ADI_WriterHandle for the writing session
   //         triggerTime       - time_t specifying the date and time of the trigger 
   //                             position for the new record. Measured as number of 
   //                             seconds from 1 Jan 1970
   //         fracSecs          - Provides fraction-resolution to the start position of 
   //                             the record ('triggerTime' parameter)
   //         trigMinusRecStart - trigger-time-minus-record-start-ticks.  Specifies the 
   //                             difference between the time of trigger tick and the first 
   //                             tick in the record. This +ve for pre-trigger delay and 
   //                             -ve for post-trigger delay.
   // Return: a ADIResultCode for result of the operation
   DLLEXPORT ADIResultCode ADI_StartRecord(ADI_WriterHandle writerH, time_t triggerTime, 
      double fracSecs, long triggerMinusStartTicks);


   // Writes new data samples into the specified channel record.
   // Params: writerH         - ADI_WriterHandle for the writing session
   //         channel         - the channel to receive the new data (starting from 0)
   //         data            - an array of new float data    
   //                            e.g.  float* data = (float*)malloc(sizeof(float * numSamples));
   //         dataType        - specifies the type of data (ticks or samples) being added
   //         nSamples        - number of samples in the array
   //         newTicksAdded   - number of ticks by which the record increased as a result of adding these samples.
   //                           This will usually be 0 for channels other than the first to which samples are added.
   //                           In the multi-rate case, this can be greater than the number of samples added if
   //                           the channel has a sample rate lower than the tick rate.
   // Return: a ADIResultCode for result of the operation
   DLLEXPORT ADIResultCode ADI_AddChannelSamples(ADI_WriterHandle writerH, long channel, 
      float* data, long nSamples, long *newTicksAdded);


   // Ends the current record being written by the writer.
   // Params: writerH - ADI_WriterHandle for the writer session
   // Return: a ADIResultCode for result of the operation
   DLLEXPORT ADIResultCode ADI_FinishRecord(ADI_WriterHandle writerH);

   // Ensures all changes to the file made via the writer session are written to the file.
   // Params: writerH - ADI_WriterHandle for the writer session
   // Return: a ADIResultCode for result of the operation
   DLLEXPORT ADIResultCode ADI_CommitFile(ADI_WriterHandle writerH, long flags);

   // Terminates the writer session and releases resources used by the session.
   // Sets the ADI_WriterHandle to 0.
   // Also calls ADI_CommitFile() to ensure all changes to the file made via the 
   //writer session are written to the file.
   // Params: writerH - ADI_WriterHandle for the writer session
   // Return: a ADIResultCode for result of the operation
   DLLEXPORT ADIResultCode ADI_CloseWriter(ADI_WriterHandle *writerH);


   // Adds a new comment at the specified position in the existing data.
   // Params: file       - ADI_FileHandle for the open file
   //         channel    - the channel to add the comment into, or -1 for all-channel comment
   //         record     - the record containing the desired position of the new comment
   //                      (starting from 0)
   //         tickPos    - the tick position of the comment as an offset from the start of 
   //                      the record (0)
   //         text       - the null-terminated text string for the new comment
   //         commentNum - the number of the newly added comment (optional, may be NULL) [outparam]
   // Return: a ADIResultCode for result of the operation
   DLLEXPORT ADIResultCode ADI_AddComment(ADI_FileHandle fileH, long channel, long record, long tickPos, 
      const wchar_t* text, long* commentNum);


   // Deletes a comment from the specified position in the existing data.
   // Params: file       - ADI_FileHandle for the open file
   //         commentNum - the number of the comment to delete
   // Return: a ADIResultCode for result of the operation
   DLLEXPORT ADIResultCode ADI_DeleteComment(ADI_FileHandle fileH, long commentNum);


   // Closes the open file and releases memory.
   // If operation is successful, 'fileH' param will be be 0.
   // Params: fileH - pointer to an ADI_FileHandle object [in/outparam]
   // Return: a ADIResultCode for result of the operation 
   DLLEXPORT ADIResultCode ADI_CloseFile(ADI_FileHandle* fileH);

#endif //ADI_USELOADIDATDLL

#ifdef __cplusplus
}
#endif

#endif