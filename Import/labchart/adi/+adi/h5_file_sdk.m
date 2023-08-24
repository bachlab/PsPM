classdef (Hidden) h5_file_sdk < adi.mat_file_sdk
    %
    %   Class:
    %   adi.h5_file_sdk
    %
    %   This should expose the SDK in a similar manner as the regular SDK
    %   but it should do it from a h5 file.
    %
    %   JAH 2014-6-15: This code layout will likely change although the 
    %   interface will most likely not. I just don't like the non-obvious
    %   code layout.
    %
    %   See Also:
    %   adi.mat_file_sdk
    %   adi.sdk
    
    %NOTE: In Matlab the functions can be easily visualized by folding all
    %the code and then expanding this methods block
    methods (Static)
        %File specific functions
        %------------------------------------------------------------------
        function file_h = openFile(file_path)
            %
            %   file = adi.h5_file_sdk.openFile(file_path)
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
            %   file : adi.h5_file_h
            
            file_h = adi.h5_file_h(file_path);
            
        end
        function output_data  = getChannelData(file_h,record,channel,start_sample,n_samples_get,get_samples,varargin)
            %
            %
            %   output_data  = getChannelData(file_h,record,channel,start_sample,n_samples_get,get_samples,varargin)
            %
            %   Inputs:
            %   --------
            %   file_h  : adi.h5_file_h

            in.leave_raw = false;
            in = adi.sl.in.processVarargin(in,varargin);
            
            if get_samples == false
                %JAH: NYI
                error('Sorry, I can''t let you do that ...')
            end
            
            chan_name   = sprintf('/data__chan_%d_rec_%d',channel,record);    
            
            output_data = h5read(file_h.file_path,chan_name,[start_sample 1],[n_samples_get 1]);
            
            if ~in.leave_raw
               output_data = double(output_data); 
            end
        end
    end
    
    %Wrapper methods
    methods (Static)
        function comments = getAllCommentsForRecord(file_h,record_id,tick_dt,trigger_minus_rec_start)
            %
            
            comments = adi.sdk.getAllCommentsForRecord(file_h,record_id,tick_dt,trigger_minus_rec_start,adi.mat_file_sdk);
        end
    end
    
end

