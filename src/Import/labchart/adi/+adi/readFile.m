function file_obj = readFile(file_path,varargin)
%x Opens up a LabChart file and extracts meta data.
%
%   file_obj = adi.readFile(*file_path,varargin)
%
%   file_obj = adi.readFile(*file_path,options)
%
%   This function reads some preliminary data from the specified LabChart
%   or simple data file and exposes access to further commands for reading
%   data.
%
%   **********************************************************
%   This is THE gateway function for working with these files.
%   **********************************************************
%
%   Optional Inputs:
%   ----------------
%   file_path : str
%       Path of the file to read. An empty or missing input prompts the
%       user.
%
%   See   adi.file_read_options   for additional option details. 
%   You can pass in specific properties to this function to change:
%
%       e.g. adi.readFile(file_path,'remove_empty_channels',false) 
%
%       OR you can pass in the options object:
%
%       options = adi.file_read_options;
%       %Change some options ...
%
%       adi.readFile(file_path,options)
%
%   Outputs:
%   --------
%   file_obj : adi.file
%
%   See Also:
%   adi.file
%   adi.convert

if length(varargin) == 1 && strcmp(class(varargin{1}),adi.file_read_options)
    in = varargin{1};
else
    in = adi.file_read_options;
    in = adi.sl.in.processVarargin(in,varargin);
end

if nargin == 0 || isempty(file_path)
    file_path = adi.uiGetChartFile();
    if isnumeric(file_path)
        return
    end
end

[~,~,file_extension] = fileparts(file_path);

%Choose SDK based on file extension
%----------------------------------
if strcmp(file_extension,'.mat')
    sdk = adi.mat_file_sdk;
elseif strcmp(file_extension,'.h5')
    sdk = adi.h5_file_sdk;
else
    sdk = adi.sdk;
end

file_h   = sdk.openFile(file_path);
file_obj = adi.file(file_path,file_h,sdk,in);
end