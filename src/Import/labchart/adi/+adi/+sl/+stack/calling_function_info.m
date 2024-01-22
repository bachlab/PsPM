classdef calling_function_info < handle
    %
    %   Class:
    %   sl.stack.calling_function_info
    %
    %   See Also:
    %   sl.warning.deprecated
    %
    %   IMPROVEMENTS:
    %   ===================================================================
    %   1) We might eventually add on a workspace grab of the level
    %   requested
    %   2) Multiple levels???
    %   3) Add on an option for a fully resolved name (make a separate
    %   property) -> i.e. for when things are in packages
    
    properties
       line_number = NaN
       file_path   = ''
       name     %file_name or 'CommandWindow' when called from command window
       %Notes about name:
       %
       %    1) The file name lacks an extension
       %    2) For classes, a function will contain the class name (at
       %    least for static methods ...)
       %    3) The name lacks the package
       is_cmd_window = false
    end
    
    methods
        function obj = calling_function_info(level)
            %calling_function_info  Returns the caller of the calling function.
            %
            %   obj = sl.stack.calling_function_info(*level)
            %
            %
            %   INPUTS
            %   ============================================================
            %   level : (scalar, default: 2) which caller to retrieve,
            %       where 1 denotes caller of this function, 2 caller of
            %       the function calling this function, etc
            %
            %   Known Users:
            %   sl.warning.deprecated
            %
            %   tags: utility, display
            
            if nargin < 1
                level = 2;
            end
            
            s = dbstack('-completenames');
            assert(level > 0,'The input ''level'' must be > 0, %d observed',level);

            %NOTE: Stack has most recent on top
            %this   - index 1
            %caller - index 2
            %etc
            
            if length(s) == 1
                obj.name = 'CommandWindow';
                obj.is_cmd_window = true;
            else
                idx = level + 1;
                obj.name        = s(idx).name;
                obj.file_path   = s(idx).file;
                obj.line_number = s(idx).line;
            end
        end
    end
end

