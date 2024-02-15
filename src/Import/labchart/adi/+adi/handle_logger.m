classdef (Hidden) handle_logger < handle
    %
    %   Class:
    %   adi.handle_logger
    %
    %   This is hopefully a temporary class that logs open and close
    %   operations.
    
    properties
       fid
    end
    
    methods
        %TODO: Make private
        function obj = handle_logger()
           %Call this via:
           %    
% % % % %            repo_root = adi.sl.stack.getPackageRoot;
% % % % %            file_path = fullfile(repo_root,'temp_logger.txt');
% % % % %            obj.fid = fopen(file_path,'a'); 
        end
        function delete(obj)
% % % %            fclose(obj.fid);
        end
    end
    
    methods (Static)
        function logOperation(file_path,handle_type,handle_value)
            %   
            %   adi.handle_logger.logOperation(file_path,handle_type,handle_value)
            %
            %   Inputs:
            %   -------
            %   file_path : 
            %       Labchart file that is being referenced (not the save
            %       path)
            %   handle_type : string
            %       Who is calling the logger?
            %   handle_value : integer
            
% % % %             persistent obj
% % % %             
% % % %             if isempty(obj)
% % % %                 obj = adi.handle_logger;
% % % %             end
% % % %             
% % % %             %write_str = sprintf('%s %s:\t%s:%ld\n',datestr(now),file_path,handle_type,handle_value);
% % % %             fwrite(obj.fid,write_str);
        end
    end
    
end

