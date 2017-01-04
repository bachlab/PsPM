classdef (Hidden) file_writer < handle
    %
    %   Class:
    %   adi.file_writer
    %
    %   See Also:
    %   ---------
    %   adi.channel_writer
    %
    %
    %   SDK Calls:
    %   ----------
    %   adi.sdk.commitFile
    %   adi.sdk.closeWriter
    %   adi.sdk.addComment
    %   adi.sdk.deleteComment
    %   adi.createFile
    %
    %   ADI write operations
    %   --------------------
    %   ADI_SetChannelName
    %   ADI_CreateWriter
    %   ADI_SetChannelInfo
    %   ADI_StartRecord - Starts the writer recording a new record, setting the trigger time.
    %   ADI_AddChannelSamples - Writes new data samples into the specified channel record.
    %   ADI_FinishRecord - Ends the current record being written by the writer.
    %   ADI_CommitFile - Ensures all changes to the file made via the writer session are written to the file.
    %   ADI_CloseWriter - Terminates the writer session and releases resources used by the session.
    %   ADI_AddComment - 
    
    %{
    Comment editing setup
    ---------------------
    We'll have an array of comments but we'll need to access the delete and
    add comment methods
    
    %}
    
    %{
    TODO: I need to determine how this interface should be organized.
    I'd like to generate a set of commands that the user would execute then
    implement those commands.
    
    1) create file
    2) initialize channels
    3) start record
    4) add comments
    5) stop record
    6) repeat steps 2 - 5
    7) commit and close file - ??? does it help to commit more frequently?
    
    %}
    properties
        file_path %Where we are writing to
        current_record = NaN  %NaN when not recording
        last_record = 0  %will always point to last record completed
        %0 indicates that no records have been recorded
        record_durations %???? We can get this for
        record_dts %We'll log this for every record
        record_trigger_times %Unix time values (Units: s)
        channels = {} %{adi.channel_writer}
        
        comments
    end
    
    properties (Dependent)
        current_channel_names
        in_record_mode
    end
    
    methods
        function value = get.current_channel_names(obj)
           temp = obj.channels;
           n_chans = length(temp);
           value = cell(1,n_chans);
           for iChan = 1:n_chans
              cur_chan = temp{iChan};
              if ~isempty(cur_chan)
                 value{iChan} = cur_chan.name; 
              end
           end
        end
        function value = get.in_record_mode(obj)
            value = ~isnan(obj.current_record);
        end
    end
        
    properties (Hidden)
        is_new %Whether or not the file existed when created
        file_h %
        data_writer_h %
    end
    
    methods
        function obj = file_writer(file_path,file_h,data_writer_h,is_new)
            %
            %   Call these to initialize this object:
            %       - adi.createFile() OR 
            %       - adi.editFile
            %
            %   obj = adi.file_writer(file_path,file_h)
            %
            %   Inputs:
            %   -------
            %   file_path :
            %   file_h : adi.file_handle
            %   data_writer_h : adi.data_writer_handle
            %   is_new : logical
            %   
            %
            %   See Also:
            %   ---------
            %   adi.createFile
            %   adi.editFile
            
            obj.file_path = file_path;
            obj.file_h = file_h;
            obj.data_writer_h = data_writer_h;
            
            %TODO: If the file is not new, read in the channel and record
            %specs from the file ...
            obj.is_new = is_new;
            if ~is_new
               temp_file = adi.file(file_path,file_h,adi.sdk,adi.file_read_options);
               obj.last_record = temp_file.n_records;
               %TODO: Do we want to instantiate writers for all the
               %channels ???? - Yes
               %
               
               recorded_chan_specs = temp_file.channel_specs;
               if ~isempty(recorded_chan_specs)
                   max_id = max([recorded_chan_specs.id]);

                   chan_ca = cell(1,max_id);
                   for iChan = 1:length(recorded_chan_specs)

                      cur_obj = recorded_chan_specs(iChan);
                      cur_id = cur_obj.id;
                      %* fs and units are on a record by record basis so we
                      %use the last ones
                      %
                      %TODO: If a channel was not used, we shouldn't add it
                      chan_ca{cur_id} = obj.addChannel(cur_id,cur_obj.name,cur_obj.fs(end),cur_obj.units{end});
                   end
                   obj.channels = chan_ca;
               end
               
               records = temp_file.records;
               if ~isempty(records)
               
               obj.comments = [records.comments];               obj.record_durations = [records.duration];
               obj.record_dts = [records.tick_dt];
               %
               %Need to add the record times
               error('Not yet implemented')
               end
            end
        end
        function comment_number = addComment(obj,record,comment_time,comment_string,varargin)
            %x Adds a comment to the specified record
            %
            %   comment_number = addComment(obj,tick_position,comment_string,varargin)
            %
            %   Inputs:
            %   -------
            %   record : 
            %       -1 means current record
            %   comment_time : 
            %       Time is in seconds ...
            %       TODO: Clarify how this relates to the trigger
            %       and data start
            %   comment_string : string
            %       The actual text of the comment to add
            %
            %   Optional Inputs:
            %   ----------------
            %   channel : 
            %       -1 indicates to add to all channels
            %       1 - add to channel 1
            %       2 - add to channel 2
            %
            %   Outputs:
            %   --------
            %   comment_number : numeric
            %       The resulting id of the comment.
            %
            %   TODO: We could build in support to adding to channels
            %   by name
            %   TODO: Build check on the channel if it is out of range
            
            in.channel = -1;
            in = adi.sl.in.processVarargin(in,varargin);
            
            %TODO: Check that record makes sense
            %If -1, check that we are in a record
            %otherwise, make sure record is between 1 and n records
            if record == -1
                record = obj.current_record;
            end
            tick_position = round(comment_time/obj.record_dts(record));
            
            comment_number = adi.sdk.addComment(obj.file_h,in.channel,record,tick_position,comment_string);
        end
        function deleteComment(obj,comment_number)
            adi.sdk.deleteComment(obj.file_h,comment_number)
        end
        function new_chan = addChannel(obj,id,name,fs,units)
            %x Add a channel that can be written to
            %
            %   Inputs:
            %   -------
            %   id :
            %       Channel number, starting at 1. These do not need to be
            %       continuous.
            %   name : string
            %       Name of the channel
            %   fs : numeric
            %       Sampling rate
            %   units : string
            %       Units of the measurement
            %
            %   Outputs:
            %   --------
            %   new_chan : 
            %
            new_chan = adi.channel_writer(obj,id,name,fs,units);
            
            %TODO: Do I want to make an explicit delete call to an object
            %if it is there
            %temp = obj.channels{id};
            %if ~isempty(temp)
            %   temp.delete()
            %end
            obj.channels{id} = new_chan;
        end
        function startRecord(obj,varargin)
            %
            %   Optional Inputs:
            %   ----------------
            %
            %   I think 'old_record' was meant to allow instantiating
            %   things based on the previous record
            
            in.record_to_copy = [];
            %What are the units on trigger time???
            %This should probably be afer the last record, rather than now
            in.trigger_time = [];
            in.fractional_seconds = 0;
            in.trigger_minus_rec_start = 0;
            in = adi.sl.in.processVarargin(in,varargin);
            
            if obj.in_record_mode
                error('Unable to start a record when in record mode already')
            end
            
            obj.current_record = obj.last_record + 1;
            
            if ~isempty(in.record_to_copy)
               %TODO: Populate in based on these properties ... 
            end
            in = rmfield(in,'record_to_copy');
            
            if isempty(in.trigger_time)
                %If record 2, add duration of record 1 to this value
                if obj.current_record > 1
                    %trigger_times are in Unix time (seconds)
                    %Do we need to add a slight offset ????
                    in.trigger_time = obj.record_trigger_times(end) + obj.record_durations(end)+30;
                    %Add duration of last record to last record start time
                else
                    in.trigger_time = sl.datetime.matlabToUnix(now);
                end
            end

            all_chans = [obj.channels{:}];
            
            all_chans.initializeRecord(obj.current_record);
            
            adi.sdk.startRecord(obj.data_writer_h,in);
            
            %in.trigger_time
            
            
            %TODO: Check if the channel is enabled or not for determining
            %which has the highest fs
            highest_fs = max([all_chans.fs]);
            obj.record_dts = [obj.record_dts 1/highest_fs];
            obj.record_trigger_times = [obj.record_trigger_times in.trigger_time];
        end
        function stopRecord(obj)
            obj.last_record = obj.current_record;
            obj.current_record = NaN;
            adi.sdk.finishRecord(obj.data_writer_h)
            
            channel_objects = [obj.channels{:}];            
            channel_durations = [channel_objects.last_record_duration];
            obj.record_durations = [obj.record_durations max(channel_durations)];
        end
        function save(obj)
           adi.sdk.commitFile(obj.data_writer_h) 
        end
        function delete(obj)
           delete(obj.file_h)
           %Why is this not working ????
           %Did I not implement it correctly?
            %
            %I think I might want this as a delete method in
            %adi.data_writer_handle
           %adi.sdk.closeWriter(obj.data_writer_h.pointer_value) 
           
           %MOVED TO DELETE
        end
        %addChannel
    end
    
    methods (Hidden)
        function updateSampleCount(obj,channel_obj,n_samples)
           %We may not need this ...  
        end
    end
    
end

