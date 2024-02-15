classdef (Hidden) file_handle < handle
    %
    %   Class:
    %   adi.file_handle
    %
    %   This class is simply meant to hold the reference to an open file.
    %   When no one holds it the file will be closed.
    
    properties
        pointer_value %Pointer to the file object in the mex code. This gets
        %cast to ADI_FileHandle in the mex code.
        file_path
    end
    
    methods
        function obj = file_handle(pointer_value,file_path)
            %
            %   Inputs:
            %   -------
            %   pointer_value:
            %   file_path: 
            
            obj.pointer_value = pointer_value;
            obj.file_path = file_path;
        end
        function delete(obj)
            %
            %
            %   fprintf(2,'ADI SDK - Deleting file ref: %s\n',obj.file_name);
                        
            adi.handle_logger.logOperation(obj.file_path,'closeFile',obj.pointer_value)
            adi.sdk.closeFile(obj.pointer_value);
        end
    end
    
end

