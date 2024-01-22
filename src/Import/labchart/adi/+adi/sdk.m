classdef (Hidden) sdk
    %
    %   Class:
    %   adi.sdk
    %
    %   This class is meant to be the singular access point for getting
    %   data from a LabChart file. Methods in this class call a mex
    %   interface which makes calls to the C API provided by ADInstruments.
    %
    %   Function Definitions:
    %   ---------------------
    %   Function definitions for the SDK can be found in the header file.
    %
    %   See:
    %   /private/ADIDatCAPI_mex.h
    %
    %   They are also defined in the calling function.
    %
    %
    %   Some definitions:
    %   -----------------
    %   tick   : sampling rate of fastest channel
    %   record : Records can be somewhat equivalent to trials or blocks
    %       in other experimental setups. Each file can consist of 1 or
    %       more records. Each time the start/stop button is pressed a new
    %       record is created. Additionally, changes to the channel setup
    %       warrant creation of a new record (such as a change in the
    %       sampling rate)
    %
    %   Usage Notes:
    %   ------------
    %   NOTE: For the typical user, this SDK doesn't need to be called
    %   directly. You can access most of the needed functionality by using
    %   adi.readFile
    %
    %   NOTE:
    %   Since Matlab's importing is subpar, but since it allows calling
    %   static methods from an instance of a class, one can instiate this
    %   class to allow shorter calling of the static methods of the class.
    %
    %   e.g.
    %   sdk = adi.sdk
    %   sdk.getNumberOfChannels(file_h)
    %
    %   See Also:
    %   adi.readFile
    
    methods (Static)
        %adi.sdk.makeMex
        %This should only be called with everything closed and cleared to
        %avoid crashing Matlab
        %{
        %TODO: Can we move all of this into the function itself ...
        clear all
        close all
        adi.sdk.unlockMex
        clear all
        %}

        function unlockMex()
           sdk_mex(100); 
        end
        %adi.sdk.makeMex
        function makeMex()
            %
            %   adi.sdk.makeMex
            %
            %   This function compiles the necessary mex code.
            
            %TODO: allow unlocking - this would require reference counting.
            %
            %Currently we lock the mex file when it is run. If we didn't
            %and we were to clear the mex file and then try to delete a
            %file handle Matlab would crash. Reference counting would
            %involve incrementing for every opened handle, then
            %decrementing every time handles are destroyed. If this count
            %is zero, then we could safely clear the mex dll from memory.
            
            base_path = adi.sl.stack.getMyBasePath;
            mex_path  = fullfile(base_path,'private');
            
            wd = cd; %wd - working directory
            cd(mex_path)
            try
                
                if strcmp(computer,'PCWIN64')
                    mex('sdk_mex.cpp','-v','ADIDatIOWin64.lib')
                else
                    mex('sdk_mex.cpp','ADIDatIOWin.lib')
                end
                
                %Extra files:
                %------------------------
                
                file_names = cell(1,3);
                file_names{1} = 'ADIDatIOWin_thunk_pcwin64.exp';
                file_names{2} = 'ADIDatIOWin_thunk_pcwin64.lib';
                file_names{3} = 'ADIDatIOWin_thunk_pcwin64.obj';
                
                for iFile = 1:3
                    cur_file_path = fullfile(base_path,file_names{iFile});
                    %Let's avoid a warning by checking first (delete throws
                    %a warning when the file is not present)
                    if exist(cur_file_path,'file')
                        delete(cur_file_path)
                    end
                end
                
                %Go back to where we started.
                cd(wd)
            catch ME
                cd(wd)
                fprintf(2,'%s',ME.message);
            end
            
        end
    end
    
    %NOTE: In Matlab the functions can be easily visualized by folding all
    %the code and then expanding this methods block
    methods (Static)
        %File specific functions
        %------------------------------------------------------------------
        function file_h = openFile(file_path,varargin)
            %
            %   file = adi.sdk.openFile(file_path)
            %
            %   NOTE: This function allows for reading or writing but
            %   I've only implemented reading.
            %
            %   Inputs:
            %   -------
            %   file_path : char
            %       Full path to the file.
            %
            %   Outputs:
            %   --------
            %   file : adi.file_handle
            
            in.read_and_write = false;
            in = adi.sl.in.processVarargin(in,varargin);
            
            %If the pointer value is already valid - i.e. already open -
            %then we just use the current pointer value rather than
            %requesting a second
            pointer_value = adi.handle_manager.checkFilePointer(file_path);
            
            if (pointer_value == 0)            
                adi.handle_logger.logOperation(file_path,'openFile',-1)
                %fprintf(2,'ADI SDK - Opening: %s\n',file_path);
                %TODO: Change this so we can call the same function but with
                %an additional input that specifies reading or writing
                if in.read_and_write
                    [result_code,pointer_value] = sdk_mex(0.5,h__toWChar(file_path));
                else
                    [result_code,pointer_value] = sdk_mex(0,h__toWChar(file_path));
                end

                adi.sdk.handleErrorCode(result_code)

                adi.handle_manager.openFile(file_path,pointer_value)

                adi.handle_logger.logOperation(file_path,'openFile',pointer_value)
            end
            
            file_h = adi.file_handle(pointer_value,file_path);
            
            
            
        end
        function file_h = createFile(file_path)
            
            pointer_value = adi.handle_manager.checkFilePointer(file_path);
            if pointer_value == 0
                [result_code,pointer_value] = sdk_mex(17,h__toWChar(file_path));
                adi.sdk.handleErrorCode(result_code)
                adi.handle_manager.openFile(file_path,pointer_value)
                adi.handle_logger.logOperation(file_path,'createFile',pointer_value)
            end
            
            file_h = adi.file_handle(pointer_value,file_path);
        end
        function closeFile(pointer_value)
            %
            %   adi.sdk.closeFile(pointer_value)
            %
            %   Since this method should only be called by:
            %    adi.file_handle.delete()
            %
            %   and since that is the deconstructor method of that object
            %   it seemed weird to pass in that object ot this method, so
            %   instead the pointer value is passed in directly.
            
            adi.handle_manager.closeFile(pointer_value)
            
        end
        function n_records  = getNumberOfRecords(file_h)
            %getNumberOfRecords  Get the number of records for a file.
            %
            %   n_records = adi.sdk.getNumberOfRecords(file_h)
            %
            %   See definition of the "records" in the definition section.
            
            [result_code,n_records] = sdk_mex(1,file_h.pointer_value);
            adi.sdk.handleErrorCode(result_code)
            n_records = double(n_records);
        end
        function n_channels = getNumberOfChannels(file_h)
            %getNumberOfChannels  Get # of channels for a file.
            %
            %   n_channels = adi.sdk.getNumberOfChannels(file_h)
            %
            %   Outputs:
            %   ===========================================================
            %   n_channels : The # of physical channels of recorded data
            %   across all records. For some records some channels may not
            %   have any data. A channel is identified by (??? name ??,
            %   hardware id????, i.e. what makes channel unique?)
            %
            %   Status: DONE
            
            [result_code,n_channels] = sdk_mex(2,file_h.pointer_value);
            adi.sdk.handleErrorCode(result_code)
            n_channels = double(n_channels);
        end
        function writer_h = createDataWriter(file_h)
           %
           %Creates a new writer session for writing new data and
           %returns a handle to that open writer for use in other
           %related functions.
            
            [result_code,writer_pointer] = sdk_mex(19,file_h.pointer_value);
            writer_h = adi.data_writer_handle(writer_pointer);
            adi.sdk.handleErrorCode(result_code) 
        end
        function commitFile(writer_h)
            %
            %   adi.sdk.commitFile(writer_h)
            
           result_code = sdk_mex(24,writer_h.pointer_value);
           adi.sdk.handleErrorCode(result_code)
        end
        function closeWriter(pointer_value)
            %
            %   adi.sdk.closeWriter(pointer_value)
            
            result_code = sdk_mex(25,pointer_value);
            adi.sdk.handleErrorCode(result_code) 
        end
        %Record specific functions
        %------------------------------------------------------------------
        function n_ticks_in_record = getNTicksInRecord(file_h,record)
            %
            %
            %   n_ticks_in_record = adi.sdk.getNTicksInRecord(file_h,record)
            %
            %   Returns the # of samples of channels with the highest data
            %   rate.
            %
            %   Inputs:
            %   =====================================
            %   record : double
            %       Record #, 1 based.
            %
            %   Outputs:
            %   ===========================================================
            %   n_ticks_in_record : This is equivalent to asking how many
            %       samples were obtained from the channels with the highest
            %       sampling rate
            %
            %   Status: DONE
            
            [result_code,n_ticks_in_record] = sdk_mex(3,file_h.pointer_value,c0(record));
            adi.sdk.handleErrorCode(result_code)
            n_ticks_in_record = double(n_ticks_in_record);
            
        end
        function dt_tick = getTickPeriod(file_h,record,channel)
            %
            %
            %   dt_tick = adi.sdk.getTickPeriod(file_handle,record,channel)
            %
            %   Outputs:
            %   ===========================================================
            %   dt_tick :
            %
            %   STATUS: DONE
            
            [result_code,dt_tick] = sdk_mex(4,file_h.pointer_value,c0(record),c0(channel));
            adi.sdk.handleErrorCode(result_code)
        end
        function [record_start,data_start,trigger_minus_rec_start_samples] = getRecordStartTime(file_h,record,tick_dt)
            %
            %   [record_start,data_start] = getRecordStartTime(file_h,record,tick_dt)
            %
            %   Outputs:
            %   ------------
            %   record_start : Matlab datenum
            %       Time of record start. If triggered, this is the time of
            %       the trigger.
            %   data_start   : Matlab datenum
            %       Time at which the first data point was collected. If a
            %       trigger was used this may be before of after the trigger.
            %
            %   For easier viewing you can use datestr(record_start) or
            %   datestr(data_start).
            
            [result_code,trigger_time,fractional_seconds,trigger_minus_rec_start_samples] = sdk_mex(16,file_h.pointer_value,c0(record));
            
            trigger_minus_rec_start_samples = double(trigger_minus_rec_start_samples);
            
            adi.sdk.handleErrorCode(result_code);
            
            record_start_unix = trigger_time + fractional_seconds;
            
            %+ trigger_minus_rec_start => data starts before trigger
            %- trigger_minus_rec_start => data starts after trigger
            %
            %Units are in ticks and needs to be converted to seconds
            data_start_unix = record_start_unix - trigger_minus_rec_start_samples*tick_dt;
            
            %NOTE: Times are local, not in GMT
            record_start = adi.sl.datetime.unixToMatlab(record_start_unix,0);
            data_start   = adi.sl.datetime.unixToMatlab(data_start_unix,0);
            
        end
        function startRecord(writer_h,varargin)
           %
           %
           %    Optional Inputs:
           %    ----------------
           %    trigger_time:
           %    fractional_seconds:
           %    trigger_minus_rec_start:
            
           %JAH TODO: At this point 
           in.trigger_time = now;
           in.fractional_seconds = 0;
           in.trigger_minus_rec_start = 0;
           in = adi.sl.in.processVarargin(in,varargin);    
           
           result_code = sdk_mex(21, writer_h.pointer_value, ...
               double(in.trigger_time), ...
               double(in.fractional_seconds), ...
               clong(in.trigger_minus_rec_start));
           adi.sdk.handleErrorCode(result_code)
        end
        function finishRecord(writer_h)
            %
            %   adi.sdk.finishRecord(writer_h)
            
           result_code = sdk_mex(23, writer_h.pointer_value); 
           adi.sdk.handleErrorCode(result_code) 
        end
        %Comment specific functions
        %------------------------------------------------------------------
        function comments_h = getCommentAccessor(file_h,record,tick_dt,trigger_minus_record_start_s)
            %
            %
            %   comments_h = adi.sdk.getCommentAccessor(file_handle,record_idx_0b)
            %
            %   comments_h :adi.comment_handle
            
            [result_code,comment_pointer] = sdk_mex(6,file_h.pointer_value,c0(record));
            if adi.sdk.isMissingCommentError(result_code)
                comments_h  = adi.comment_handle(file_h.file_path,0,false,record,tick_dt,trigger_minus_record_start_s);
            else
                adi.sdk.handleErrorCode(result_code)
                comments_h  = adi.comment_handle(file_h.file_path,comment_pointer,true,record,tick_dt,trigger_minus_record_start_s);
            end
        end
        function closeCommentAccessor(pointer_value)
            %
            %
            %   adi.sdk.closeCommentAccessor(pointer_value);
            %
            %   This should only be called by:
            %   adi.comment_handle
            
            result_code = sdk_mex(7,pointer_value);
            adi.sdk.handleErrorCode(result_code);
        end
        function has_another_comment  = advanceComments(comments_h)
            %
            %
            %   has_another_comment = adi.sdk.advanceComments(comments_h);
            
            result_code = sdk_mex(9,comments_h.pointer_value);
            
            if adi.sdk.isMissingCommentError(result_code)
                has_another_comment = false;
            else
                adi.sdk.handleErrorCode(result_code);
                has_another_comment = true;
            end
            
        end
        function comment_info = getCommentInfo(comments_h)
            %
            %
            %   comment_info = adi.sdk.getCommentInfo(comments_h)
            %
            %   Inputs:
            %   -------
            %   adi.comment_handle
            
            [result_code,comment_string_data,comment_length,tick_pos,channel,comment_num] = sdk_mex(8,comments_h.pointer_value);
            
            d = @double;
            
            if result_code == 0
                comment_string = adi.sdk.getStringFromOutput(comment_string_data,comment_length);
                comment_info   = adi.comment(comment_string,d(tick_pos),...
                    d(channel),d(comment_num),comments_h.record,...
                    comments_h.tick_dt,comments_h.trigger_minus_rec_start);
            else
                adi.sdk.handleErrorCode(result_code);
                comment_info = [];
            end
        end
        function comment_number = addComment(file_h,channel,record,tick_position,comment_string)
            %
            %   comment_number = adi.sdk.addComment(channel,record,tick_position,comment_string)
            
            [result_code,comment_number] = sdk_mex(26,file_h.pointer_value,...
                clong(channel), c0(record), clong(tick_position), h__toWChar(comment_string));
            adi.sdk.handleErrorCode(result_code);
        end
        function deleteComment(file_h,comment_number)
            %
            %   adi.sdk.deleteComment(file_h,comment_number)
            
            result_code = sdk_mex(27,file_h.pointer_value,clong(comment_number));
            adi.sdk.handleErrorCode(result_code);
        end
        %Channel specific functions
        %------------------------------------------------------------------
        function n_samples    = getNSamplesInRecord(file_h,record,channel)
            %
            %
            %   n_samples  = adi.sdk.getNSamplesInRecord(file_h,record,channel)
            %
            %   INPUTS
            %   ===========================================
            %   record  : (0 based)
            %   channel : (0 based)
            %
            %   Status: DONE
            
            [result_code,n_samples] = sdk_mex(5,file_h.pointer_value,c0(record),c0(channel));
            adi.sdk.handleErrorCode(result_code)
            n_samples = double(n_samples);
        end
        function output_data  = getChannelData(file_h,record,channel,start_sample,n_samples_get,get_samples,varargin)
            %
            %
            %   output_data  = adi.sdk.getChannelData(...
            %                       file_h,record,channel,start_sample,n_samples_get,get_samples)
            %
            %   Inputs:
            %   -------
            %   channel:
            %       Channel to get the data from, 1 based.
            %   record:
            %       Record to get the data from, 1 based.
            %   start_sample: first sample to get
            %   n_samples:
            %   get_samples: 
            %       If true data is returned as samples, if false, the data 
            %       are upsampled (sample & hold) to the highest rate ...
            %
            %   Optional Inputs:
            %   ----------------
            %   leave_raw: (default false)
            %       If false, the output is cast to a double. If true, the
            %       cast does not occur and the output is of type 'single'
            %
            %   See Also:
            %   adi.channel.getAllData
            
            in.leave_raw = false;
            in = adi.sl.in.processVarargin(in,varargin);
            
            data_type = c(0);
            if ~get_samples
                %get in tick units
                data_type = bitset(data_type,32);
            end
            
            [result_code,data,n_returned] = sdk_mex(10,...
                file_h.pointer_value,c0(channel),...
                c0(record),c0(start_sample),...
                c(n_samples_get),data_type);
            
            adi.sdk.handleErrorCode(result_code)
            
            if n_returned ~= n_samples_get
                error('Why was this truncated???')
            end
            
            if in.leave_raw
                output_data = data;
            else
                output_data = double(data); %Matlab can get finicky working with singles
            end
        end
        function units = getUnits(file_h,record,channel)
            %getUnits
            %
            %   units = adi.sdk.getUnits(file_h,record,channel)
            
            
            [result_code,str_data,str_length] = sdk_mex(11,...
                file_h.pointer_value,c0(record),c0(channel));
            
            %TODO: Replace with function call to isGoodResultCode
            if result_code == 0 || result_code == 1
                units = adi.sdk.getStringFromOutput(str_data,str_length);
            else
                adi.sdk.handleErrorCode(result_code);
                units = '';
            end
            
        end
        function channel_name = getChannelName(file_h,channel)
            %
            %
            %   channel_name = adi.sdk.getChannelName(file_h,channel)
            %
            %   Status: DONE
            
            [result_code,str_data,str_length] = sdk_mex(12,...
                file_h.pointer_value,c0(channel));
            
            if result_code == 0
                channel_name = adi.sdk.getStringFromOutput(str_data,str_length);
            else
                adi.sdk.handleErrorCode(result_code);
                channel_name = '';
            end
            
        end
        function dt_channel   = getSamplePeriod(file_h,record,channel)
            %
            %
            %   dt_channel   = getSamplePeriod(file_h,channel,record)
            %
            %   This should return the sample period, the inverse of the
            %   sampling rate, for a single channel.
            %
            %   For channels with NO SAMPLES, the dt returned is NaN
            %
            %   Alternatively, I can ask:
            %   A) # of ticks in record
            %   B) tick period
            %   C) # of samples in record
            %
            %   sample period =
            
            n_samples_in_record = adi.sdk.getNSamplesInRecord(file_h,record,channel);
            if n_samples_in_record == 0
                dt_channel = NaN;
                return
            end
            
            %             n_ticks_in_record   = adi.sdk.getNTicksInRecord(file_h,record);
            %             tick_dt             = adi.sdk.getTickPeriod(file_h,record,channel);
            %             dt_channel_temp = tick_dt * n_ticks_in_record/n_samples_in_record;
            
            [result_code,dt_channel] = sdk_mex(15,...
                file_h.pointer_value,c0(record),c0(channel));
            
            adi.sdk.handleErrorCode(result_code)
        end
        function setChannelName(file_h,channel,channel_name)
            %
            %   adi.sdk.setChannelName(file_h,channel,channel_name)
            %
            %   Inputs:
            %   -------
            %   file_h: adi.file_handle   
            %   channel: channel index, starting from zero
            %   channel_name: 
            
            %??? - Does this create a new channel if it doesn't exist yet?
            
            result_code = sdk_mex(18,file_h.pointer_value,....
                c0(channel),h__toWChar(channel_name));
            
            adi.sdk.handleErrorCode(result_code)
            
        end
        function setChannelInfo(writer_h,channel,seconds_per_sample,units,varargin)
           %
           %    Sets channel information for the specific record.
           %
           %    TODO: Make it so that we can have everything be optional
           %    ...
           %
           %    Inputs:
           %    -------
           %    channel :
           %    seconds_per_sample : 
           %
           %    Optional Inputs:
           %    ----------------
           %    enabled_for_record : (default true)
           %    limits :
           %        ???? Why do we care what the limits are????
           %
           %    ??? - when is this done relative to a new record? Does
           %    this need to be done every time or does a default carry
           %    over? Does setting this create a new record or only get
           %    updated when a new record is started?
           
           in.enabled_for_record = true;
           in.limits = [-Inf Inf];
           in = adi.sl.in.processVarargin(in,varargin);
           
           result_code = sdk_mex(20,...
               writer_h.pointer_value,...
               c0(channel),...
               h__toInt(in.enabled_for_record),...
               double(seconds_per_sample),...
               h__toWChar(units),...
               single(in.limits));
           adi.sdk.handleErrorCode(result_code)
        end
        function addChannelSamples(writer_h,channel,data)
            %
            %   adi.sdk.addChannelSamples(writer_h,channel,data)
            %   
            %   Inputs:
            %   -------
            %   writer_h:
            %   channel:
            %   data:
            %
            %   DLLEXPORT ADIResultCode ADI_AddChannelSamples(ADI_WriterHandle writerH, long channel, 
            %         float* data, long nSamples, long *newTicksAdded);
            
            [result_code,new_ticks_added] = sdk_mex(22,writer_h.pointer_value,c0(channel),single(data));
            adi.sdk.handleErrorCode(result_code)
        end
        %Helper functions
        %------------------------------------------------------------------
        function is_ok = checkNullChannelErrorCodes(result_code)
            %
            %
            %    is_ok = adi.sdk.checkNullChannelErrorCodes(result_code)
            %
            %    For some reason there is a non-zero error code when
            %    retrieving information about a channel during a record in
            %    which there is no data for that channel. The error message
            %    is: "the operation completed successfully"
            
            is_ok = result_code == 0 || result_code == 1;
            %result_code == 1
            %"the operation completed successfully"
        end
        function hex_value = resultCodeToHex(result_code)
            %
            %   hex_value = adi.sdk.handleErrorCode(result_code)
            %
            %   Returns the hex_value of the result code for comparision
            %   with the values in the C header.
            
            temp      = typecast(result_code,'uint32');
            hex_value = dec2hex(temp);
        end
        function is_missing_comment_code = isMissingCommentError(result_code)
            %
            %
            %   is_missing_comment_code = adi.sdk.isMissingCommentError(result_code)
            
            
            %TODO: Do I want to do the literal error check here instead
            %of the mod????
            
            %Relevant Link:
            %http://forum.adi.com/viewtopic.php?f=7&t=551
            
            %If there are no comments, the result_code is:
            %-1610313723 - data requested not present => xA0049005
            
            is_missing_comment_code = mod(result_code,16) == 5;
            
        end
        function handleErrorCode(result_code)
            %
            %
            %   adi.sdk.handleErrorCode(result_code)
            %
            %   If there is an error this function will throw an error
            %   and display the relevant error string given the error code
            
            %Relevant forum post:
            %http://forum.adi.com/viewtopic.php?f=7&t=551
            
            if ~adi.sdk.checkNullChannelErrorCodes(result_code)
                %if result_code ~= 0
                temp      = adi.sl.stack.calling_function_info;
                errorID   = sprintf('ADINSTRUMENTS:SDK:%s',temp.name);
                error_msg = adi.sdk.getErrorMessage(result_code);
                
                
                %TODO: Create a clean id - move to a function
                %The ID is not allowed to have periods in it
                %Also, the calling function info isn't a clean name
                %(I think it includes SDK, but what if I only wanted the
                %name, not the full path ...???)
                %
                errorID = regexprep(errorID,'\.',':');
                
                error(errorID,[errorID '  ' error_msg]);
            end
            
            %Copied from ADIDatCAPI_mex.h 5/6/2014
            % % %                typedef enum ADIResultCode
            % % %       {
            % % %       //Win32 error codes (HRESULTs)
            % % %       kResultSuccess = 0,                             // operation succeeded
            % % %       kResultErrorFlagBit        = 0x80000000L,       // high bit set if operation failed
            % % %       kResultInvalidArg          = 0x80070057L,       // invalid argument. One (or more) of the arguments is invalid
            % % %       kResultFail                = 0x80004005L,       // Unspecified error
            % % %       kResultFileNotFound        = 0x80030002L,       // failure to find the specified file (check the path)
            % % %
            % % %
            % % %       //Start of error codes specific to this API
            % % %       kResultADICAPIMsgBase        = 0xA0049000L,
            % % %
            % % %       kResultFileIOError  = kResultADICAPIMsgBase,    // file IO error - could not read/write file
            % % %       kResultFileOpenFail,                            // file failed to open
            % % %       kResultInvalidFileHandle,                       // file handle is invalid
            % % %       kResultInvalidPosition,                         // pos specified is outside the bounds of the record or file
            % % %       kResultInvalidCommentNum,                       // invalid commentNum. Comment could not be found
            % % %       kResultNoData,                                  // the data requested was not present (e.g. no more comments in the record).
            % % %       kResultBufferTooSmall                          // the buffer passed to a function to receive data (e.g. comment text) was not big enough to receive all the data.
            % % %
            % % %                                                       // new result codes must be added at the end
            % % %       } ADIResultCode;
            
        end
        function error_msg = getErrorMessage(result_code)
            %
            %
            %   error_msg = adi.sdk.getErrorMessage(result_code)
            
            [~,err_msg_data,err_msg_len] = sdk_mex(14,int32(result_code));
            error_msg = adi.sdk.getStringFromOutput(err_msg_data,err_msg_len);
        end
        function str = getStringFromOutput(int16_data,str_length)
            %
            %   This is a helper function for whenever we get a string out.
            %
            %   str = adi.sdk.getStringFromOutput(int16_data,str_length)
            %
            %   TODO: Make hidden
            %
            
            %str_length - apparently contains the null character, we'll
            %ignore the null character here ...
            str = char(int16_data(1:str_length-1));
        end
    end
    
    %Wrapper methods ------------------------------------------------------
    methods (Static)
        function comments = getAllCommentsForRecord(file_h,record_id,tick_dt,trigger_minus_record_start_s,sdk)
            %
            %
            %   DOCUMENTATION: Out of date
            %
            %   comments = adi.sdk.getAllCommentsForRecord(file_handle,record_obj)
            %
            %   Parameters
            %   ----------
            %   file_handle : adi.file_handle
            %
            %   record_id   : double
            %
            %   tick_dt     : double
            %
            %   See Also:
            %   adi.record
            
            %NOTE: These comments seem to be returned ordered by time, not
            %by ID.
            
            MAX_NUMBER_COMMENTS = 1000; %NOTE: Overflow of this value
            %just causes things to slow down, it is not a critical error.
            
            if ~exist('sdk','var')
                sdk = adi.sdk;
            end
            
            temp_comments_ca = cell(1,MAX_NUMBER_COMMENTS);
            comments_h = sdk.getCommentAccessor(file_h,record_id,tick_dt,trigger_minus_record_start_s);
            
            if ~comments_h.is_valid
                comments = [];
                return
            end
            
            %Once the accessor is retrieved, the first comment can be accessed.
            temp_comments_ca{1} = comments_h.getCurrentComment();
            
            cur_comment_index = 1;
            while comments_h.advanceCommentPointer()
                cur_comment_index = cur_comment_index + 1;
                temp_comments_ca{cur_comment_index} = comments_h.getCurrentComment();
            end
            
            comments = [temp_comments_ca{1:cur_comment_index}];
            
            comments_h.close();
        end
    end
    
    
end

function int_out = h__toInt(value_in)
    int_out = int32(value_in);
end

function str_out = h__toWChar(str_in)
%NOTE: I had trouble with the unicode string conversion so per
%some Mathworks forum post I am just using a null terminated
%array of int16s
str_out = [int16(str_in) 0];
end

