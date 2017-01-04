classdef (Hidden) handle_manager
    %
    %   Class:
    %   adi.handle_manager
    %
    %   This class keeps track of open files and attempts to prevent
    %   closing a file that for some reason is not actually open.
    %
    %   This class is called directly by functions in adi.sdk
    %
    %   It is only used by the ADInstruments SDK since I've had some issues
    %   with getting 
    %
    %
    %   See Also:
    %   adi.sdk
    %   adi.sdk.openFile
    
    properties
        
        %NOTE: This file is locked so to change and rerun this class you
        %need:
        %
        %   adi.handle_manager.unlock
        %   clear classes
        
        DEBUG = false
        %Set this to be true to enable printing of statements in the class
        %methods
        
        USE_FIX = true
        %true - single file only ever gets one pointer
        %false - single file gets multiple pointers
        %
        %   By default this should be true unless we're inspecting how 
        %   the SDK works when this is not true.
    end
    
    properties
        map %containers.Map
        %
        %   key - pointer value of open file
        %   value - file path
        path_key_map
        %
        %   key - file path
        %   value - count of how many are open
    end
    
    methods
        function obj = handle_manager()
            obj.map = containers.Map('KeyType','int64','ValueType','char');
            obj.path_key_map = containers.Map('KeyType','char','ValueType','any');
        end
    end
    
    methods (Static)
        function pointer_value = checkFilePointer(file_path)
            %   pointer_value = adi.handle_manager.checkFilePointer(file_path)
            %
            %   This gets called on opening a file using the ADI sdk. If
            %   a file is already open, we return its pointer, rather
            %   than creating a new pointer for the file.
            %
            %   If a file is not already open, then we return 0, indicating
            %   that a new pointer should be requested from the SDK.
            %
            %   Inputs:
            %   -------
            %   file_path : path to the file to open
            %
            %   Outputs:
            %   --------
            %   pointer_value : numeric value acting as c pointer
            %       If the file is not already open, a value of 0 is
            %       returned
            %
            %   See Also:
            %   adi.sdk.openFile
            
            obj = adi.handle_manager.getReference();
            if obj.USE_FIX
                if obj.path_key_map.isKey(file_path)
                    if obj.DEBUG
                       fprintf(2,'Pointer found for:\n%s\n',file_path); 
                    end
                    temp = obj.path_key_map(file_path);
                    pointer_value = temp(1);
                    temp(2) = temp(2) + 1;
                    obj.path_key_map(file_path) = temp;
                else
                    %fprintf(2,'Pointer not found for:\n%s\n',file_path); 
                    pointer_value = 0;
                end
                
            else
                pointer_value = 0;
            end
        end
        function openFile(file_path,pointer_value)
            %
            %   adi.handle_manager.openFile(file_path,pointer_value)
            %
            %   See Also:
            %   adi.sdk.openFile
            
            obj = adi.handle_manager.getReference();
            %disp(file_path)
            %disp(pointer_value)
            if obj.map.isKey(pointer_value)
                error('Pointer value is redundant, this is not expected')
            end
            obj.map(pointer_value) = file_path;
            
            if obj.USE_FIX
                %                         [pointer_value  count]
                obj.path_key_map(file_path) = [pointer_value 1];
            end
        end
        function closeFile(pointer_value)
            %
            %    adi.handle_manager.closeFile(pointer_value)
            %
            %   See Also:
            %   adi.sdk.closeFile
            %
            %   TODO: The encapsulation is a bit lacking here.
                        
            obj = adi.handle_manager.getReference();
            if obj.map.isKey(pointer_value)
                file_path = obj.map(pointer_value);
                
                if ~obj.USE_FIX
                    %Then just close the file
                    %TODO: We should return the count to the SDK instead
                    %here we would return 0 (or 1, depending on the design)
                    obj.map.remove(pointer_value);
                    result_code = sdk_mex(13,pointer_value);
                    adi.sdk.handleErrorCode(result_code);
                else
                    
                    temp = obj.path_key_map(file_path);
                    if temp(2) == 1
                        %fprintf(2,'Closing reference for:\n%s\n',file_path); 
                        obj.map.remove(pointer_value);
                        obj.path_key_map.remove(file_path);
                        result_code = sdk_mex(13,pointer_value);
                        adi.sdk.handleErrorCode(result_code);
                    else
                        %fprintf(2,'Decrementing reference count for:\n%s\n',file_path); 
                        temp(2) = temp(2) - 1;
                        obj.path_key_map(file_path) = temp;
                    end
                    
                end
            else
                %TODO: Move formatted warning into adi.sl
                warning('Trying to close a file whose pointer is not logged')
            end
        end
        function output_obj = getReference()
            %
            %   adi.handle_manager.getReference
            %
            persistent obj
            if isempty(obj)
                %NOTE: We lock things to try and prevent problems with
                %the mex file. I'm not sure if this is really necessary,
                %but it makes me sleep better at night :)
                mlock();
                obj = adi.handle_manager;
            end
            output_obj = obj;
        end
        function unlock()
            %adi.handle_manager.unlock
            munlock();
        end
    end
    
end

