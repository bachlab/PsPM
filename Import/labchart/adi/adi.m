classdef adi
    %
    %   Class:
    %   adi
    %
    %   This class is meant to hold simple helpers for the package.
    
    methods (Static)
        function view()
            %
            %   adi.view(*file_path)
            %
            %   This is 
           %TODO: Run the viewer
           file_path = adi.uiGetChartFile();
           adi.file_viewer(file_path);
        end
    end
    
    methods (Hidden,Static)
        function createBlankFileAtPath(file_path)
            %
            %   adi.createBlankFileAtPath(file_path)
            %
            %   This function was written to try and test out the
            %   importance of creating a new file, from scratch, versus 
            %   just copying a new file that I had previously created using
            %   LabChart 8. 
            %
            %   I was having trouble with the writing aspect of the SDK. It
            %   turns out there were bugs in the code that had yet to be
            %   finished. 
            %
            %   I'm not sure if this function is necessary anymore, but
            %   I'll leave it here for now.
            
           repo_path = adi.sl.stack.getPackageRoot();
           blank_file_path = fullfile(repo_path,'files','blank_labchart_8_file.adicht');
           copyfile(blank_file_path,file_path)
        end
    end
    methods (Static)
        function [file_path, file_root] = uiGetChartFile(varargin)
            %x Show user selection window to select Labchart files
            %
            %   [file_path, file_root] = adi.uiGetChartFile(varargin)
            %
            %   This function can be used to select a particular LabChart
            %   file.
            %
            %   Optional Inputs:
            %   ----------------
            %   multi_select : logical (default: false)
            %       If true multiple files can be selected.
            %   prompt : string (default: 'Pick a file to read'
            %   start_path : string (default: '')
            %       If not empty the selection will start in the specified
            %       folder. If empty AND the function was previously used 
            %       the previously selected path will be used.
            %
            %   Output:
            %   -------
            %   file_path : str, 0, or cellstr
            %       If the user cancels the output is 0. Otherwise this is
            %       the full path to the file.
            %   file_root : str or 0
            %       Path to the folder that contains the file.
            
            persistent last_file_root
            
            in.multi_select = false;
            in.prompt = 'Pick a file to read';
            in.start_path = '';
            in = adi.sl.in.processVarargin(in,varargin);
            
            filter_specifications = ...
                {'*.adicht','Labchart Files (*.adicht)'; ...
                '*.h5','HDF5 Files (*.h5)';...
                '*.mat','Matlab Files (*.mat)'};
            
            if in.multi_select
                multi_select_value = 'on';
            else
                multi_select_value = 'off';
            end
            
            if isempty(in.start_path) && ~isempty(last_file_root)
               in.start_path = last_file_root;
            end
            
            if isempty(in.start_path)
                [file_name_or_names,file_root] = uigetfile(filter_specifications,in.prompt,'MultiSelect',multi_select_value);
            else
                [file_name_or_names,file_root] = uigetfile(filter_specifications,in.prompt,in.start_path,'MultiSelect',multi_select_value);
            end
            
            if isnumeric(file_name_or_names)
                file_path = 0;
                file_root = 0;
            else
                last_file_root = file_root;
                if ischar(file_name_or_names)
                    file_path = fullfile(file_root,file_name_or_names);
                    if in.multi_select
                        file_path = {file_path};
                    end
                else
                    n_files = length(file_name_or_names);
                    file_path = cell(1,n_files);
                    for iFile = 1:n_files
                       file_path{iFile} = fullfile(file_root,file_name_or_names{iFile}); 
                    end
                end
            end
        end
    end
    
end

