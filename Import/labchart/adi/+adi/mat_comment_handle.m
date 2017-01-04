classdef (Hidden) mat_comment_handle < handle
    %
    %   Class:
    %   adi.mat_comment_handle
    %
    %   NOTE: This class is a quick hack to get the mat file sdk working
    %
    %   This contains a handle that is needed by the SDK to get comments
    %   for a particular record. Methods in this class can be used to
    %   extract actual comments from a record.
    %
    %   See Also:
    %   adi.comment
    
    
    properties
        is_valid = false %A handle may not be valid if there are no comments
        %for a given record
        record
        tick_dt
        
        current_index = 1
        trigger_minus_record_start_s
    end
    
    properties (Hidden)
        comment_data
        n_comments
    end
    
    methods
        function obj = mat_comment_handle(comment_data,is_valid,record_id,tick_dt,trigger_minus_record_start_s)
            %
            %   adi.mat_comment_handle(comment_data,is_valid,record_id,tick_dt)
            
            %NOTE: Only comments for the record are passed in ...
            
            obj.comment_data  = comment_data;
            obj.is_valid      = is_valid;
            obj.record        = record_id;
            obj.tick_dt       = tick_dt;
            obj.n_comments    = length(comment_data);
            obj.trigger_minus_record_start_s = trigger_minus_record_start_s;
        end
        function delete(~)
        end
        function has_another_comment = advanceCommentPointer(obj)
            obj.current_index = obj.current_index + 1;
            has_another_comment = obj.current_index <= obj.n_comments;
        end
        function cur_comment = getCurrentComment(obj)
            if obj.n_comments == 0
                cur_comment = [];
            else
                cur_comment = adi.mat_file_sdk.getCommentInfo(obj,obj.comment_data(obj.current_index));
            end
        end
        function close(~)
        end
    end
    
    
end

