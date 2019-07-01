function file_writer = createFile(file_path,varargin)
%
%   file_writer = adi.createFile(file_path)
%
%   This is a work in progress
%

in.copy_blank_when_new = false;
in = adi.sl.in.processVarargin(in,varargin);

is_new = ~exist(file_path,'file');

%Possibilities
%1) create new file de novo
%2) create new file using a copy of a blank file as a starting point
%3) edit a file that already exists

if is_new
    if in.copy_blank_when_new
       adi.createBlankFileAtPath(file_path)
       file_h = adi.sdk.openFile(file_path,'read_and_write',true); 
    else
       file_h = adi.sdk.createFile(file_path);  
    end
else
    file_h = adi.sdk.openFile(file_path,'read_and_write',true);
end
%file_h : adi.file_handle

data_writer_h = adi.sdk.createDataWriter(file_h);
%data_writer_h : adi.data_writer_handle

file_writer = adi.file_writer(file_path, file_h, data_writer_h, is_new);

end