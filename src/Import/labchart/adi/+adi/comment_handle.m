classdef (Hidden) comment_handle < handle
    %
    %   Class:
    %   adi.comment_handle
    %
    %   This contains a handle that is needed by the SDK to get comments
    %   for a particular record. Methods in this class can be used to
    %   extract actual comments from a record.
    %
    %   See Also:
    %   adi.comment
    
    
    properties
       pointer_value %Pointer to the a commenct accessor object in the mex 
       %code. This gets cast to ADI_CommentsHandle in the mex code. This
       %shouldn't be changed ...
       
       is_valid = false %A handle may not be valid if there are no comments
       %for a given record
       record
       tick_dt
       file_name
       trigger_minus_rec_start
    end
    
    methods
        function obj = comment_handle(file_name,pointer_value,is_valid,record_id,tick_dt,trigger_minus_rec_start)
            %
            %   obj = adi.comment_handle(pointer_value,is_valid)
            
           obj.file_name = file_name;
           obj.pointer_value = pointer_value;
           obj.is_valid      = is_valid;
           obj.record        = record_id;
           obj.tick_dt       = tick_dt;
           obj.trigger_minus_rec_start = trigger_minus_rec_start;
        end
        function delete(obj)
            if ~obj.is_valid
                return
            end 
            %fprintf(2,'ADI SDK: Deleting comment: %s\n',obj.file_name);
           adi.sdk.closeCommentAccessor(obj.pointer_value);
        end
        function has_another_comment = advanceCommentPointer(obj)
           has_another_comment = adi.sdk.advanceComments(obj); 
        end
        function cur_comment = getCurrentComment(obj)
           cur_comment = adi.sdk.getCommentInfo(obj);
        end
        function close(obj)
           %fprintf(2,'ADI SDK: Closing comment: %s\n',obj.file_name);
           adi.sdk.closeCommentAccessor(obj.pointer_value);
           obj.is_valid = false;
        end
    end
    
    
end

