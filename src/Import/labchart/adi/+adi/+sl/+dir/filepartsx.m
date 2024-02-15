function path_out = filepartsx(file_or_folder_path,N)
%filepartsx   Applies fileparts() function numerous times
%
%   path_out = sl.dir.filepartsx(file_or_folder_path,N)
%
%   Small function to help clean up stripping of the path.
%
%   INPUTS:
%   -------
%   file_or_folder_path : path to file or folder
%   N                   : # of times to apply fileparts() function
%
%   Example:
%   --------
%   file_path = 'C:\my_dir1\my_dir2\my_file.txt';
%   path_out  = sl.dir.filepartsx(file_path,2);
%
%   path_out  => 'C:\my_dir1'

path_out = file_or_folder_path;
for iN = 1:N
   path_out = fileparts(path_out); 
end

end