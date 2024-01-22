function file_writer = editFile(file_path,varargin)
%x  Open a file for editing
%
%   file_writer = adi.editFile(file_path)
%
%

if ~exist(file_path,'file')
    error('File to edit doesn''t exist:\n%s',file_path)
end

file_h = adi.sdk.openFile(file_path,'read_and_write',true);    
    
data_writer_h = adi.sdk.createDataWriter(file_h);

file_writer = adi.file_writer(file_path, file_h, data_writer_h, false);

end