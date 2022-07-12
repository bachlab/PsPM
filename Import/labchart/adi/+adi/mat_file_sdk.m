classdef (Hidden) mat_file_sdk < handle
    %
    %   Class:
    %   adi.mat_file_sdk
    %
    %   This should expose the SDK in a similar manner as the regular SDK
    %   but it should do it from a mat file.
    %
    %   The h5_file_sdk borrows implementations from this class and then
    %   changes some of the methods. I think I would rather they both 
    %   inherit from a file sdk.
    %
    %   JAH 2014-6-15: This code layout will likely change although the 
    %   interface will most likely not. I just don't like the non-obvious
    %   code layout.

    %NOTE: In Matlab the functions can be easily visualized by folding all
    %the code and then expanding this methods block
    methods (Static)
        %File specific functions
        %------------------------------------------------------------------
        function file_h = openFile(file_path)
            %
            %   file = adi.mat_file_sdk.openFile(file_path)
            %
            %   NOTE: Only reading is supported.
            %
            %   Inputs:
            %   -------
            %   file_path : char
            %       Full path to the file.
            %
            %   Outputs:
            %   --------
            %   file : adi.mat_file_h
            
            file_h = adi.mat_file_h(file_path);
            
        end
        function n_records  = getNumberOfRecords(file_h)
            %getNumberOfRecords  Get the number of records for a file.
            %
            %   n_records = adi.mat_file_sdk.getNumberOfRecords(file_h)
            %
            %   See definition of the "records" in the definition section.
            
            file_meta = file_h.m.file_meta;    
            n_records = file_meta.n_records;
        end
        function n_channels = getNumberOfChannels(file_h)
            %getNumberOfChannels  Get # of channels for a file.
            %
            %   n_channels = adi.mat_file_sdk.getNumberOfChannels(file_h)

            
            file_meta  = file_h.m.file_meta;    
            n_channels = file_meta.n_channels;
        end
        %Record specific functions
        %------------------------------------------------------------------
        function n_ticks_in_record = getNTicksInRecord(file_h,record)
            %
            
            record_meta = file_h.m.record_meta(1,record);
            n_ticks_in_record = record_meta.n_ticks;

        end
        function dt_tick = getTickPeriod(file_h,record,~)
            %
            
            record_meta = file_h.m.record_meta(1,record);
            dt_tick = record_meta.tick_dt;
        end
        function [record_start,data_start,trigger_minus_rec_start_samples] = getRecordStartTime(file_h,record,tick_dt)
            %
            record_meta  = file_h.m.record_meta(1,record);
            record_start = record_meta.record_start;
            data_start   = record_meta.data_start;
            trigger_minus_rec_start_samples = record_meta.trigger_minus_rec_start_samples;
        end
        %Comment specific functions
        %------------------------------------------------------------------
        function comments_h = getCommentAccessor(file_h,record,tick_dt,trigger_minus_record_start_s)
            %
            
            comments = file_h.m.comments;
            comments_for_record = comments([comments.record] == record);
            comments_h = adi.mat_comment_handle(comments_for_record,...
                ~isempty(comments_for_record),record,tick_dt,trigger_minus_record_start_s);
        end
%         function closeCommentAccessor(pointer_value)
%         end
%         function has_another_comment  = advanceComments(comments_h)
%         end
        function comment_info = getCommentInfo(comments_h,data)
            %
            %
            %   comment_info = adi.sdk.getCommentInfo(comments_h)
            
            comment_info   = adi.comment(data.str,...
                data.tick_position,...
                data.channel,...
                data.id,...
                comments_h.record,...
                comments_h.tick_dt,...
                comments_h.trigger_minus_record_start_s);
        end
        %Channel specific functions
        %------------------------------------------------------------------
        function n_samples    = getNSamplesInRecord(file_h,record,channel)
            %
            cm = file_h.m.channel_meta;
            n_samples = cm(channel).n_samples(record);
            
        end
        function output_data  = getChannelData(file_h,record,channel,start_sample,n_samples_get,get_samples,varargin)
            %
            %(file_h,record,channel,start_sample,n_samples_get,get_samples,varargin)
            
            in.leave_raw = false;
            in = adi.sl.in.processVarargin(in,varargin);
            
            if get_samples == false
                %JAH: NYI
                error('Sorry, I can''t let you do that ...')
            end
            
            chan_name   = sprintf('data__chan_%d_rec_%d',channel,record);    
            output_data = file_h.m.(chan_name)(start_sample:(start_sample+n_samples_get-1),1);
            
            if in.leave_raw
                %output_data = output_data;
            else
                output_data = double(output_data); %Matlab can get finicky working with singles
            end
            
        end
        function units        = getUnits(file_h,record,channel)
            %getUnits
            cm = file_h.m.channel_meta(1,channel);
            units = cm.units{record};
        end
        function channel_name = getChannelName(file_h,channel)
            %
            cm = file_h.m.channel_meta(1,channel);
            channel_name = cm.name;
        end
        function dt_channel   = getSamplePeriod(file_h,record,channel)
            %
            cm = file_h.m.channel_meta(1,channel);
            dt_channel = cm.dt(record);
        end
    end
    
    %Wrapper methods
    methods (Static)
        function comments = getAllCommentsForRecord(file_h,record_id,tick_dt,trigger_minus_rec_start_samples)
            %
            %TODO: This isn't right
            
            comments = adi.sdk.getAllCommentsForRecord(file_h,record_id,tick_dt,trigger_minus_rec_start_samples,adi.mat_file_sdk);
        end
    end
    
end

