function new_file_path = changeFileExtension(file_path,new_extension)
%
%   new_file_path = sl.dir.changeFileExtension(file_path,new_extension)
%
%   This is a simple helper function that makes it obvious what is being
%   done (i.e. changing the file extension).
%
%   Inputs:
%   -------
%   file_path: str
%       Path to the file. It may be absolute or relative.
%   new_extension: str
%       The extension that the file_path should have when returned from
%       this function. This may or may not contain a leading period.
%
%   Example:
%   --------
%   file_path = 'C:\a\b.mat'
%   new_file_path = sl.dir.changeFileExtension(file_path,'txt')
%   new_file_path => 'C:\a\b.txt'


%Ensure dot is present as first character
if new_extension(1) ~= '.'
   new_extension = ['.' new_extension]; 
end

[a,b] = fileparts(file_path);

new_file_path = fullfile(a,[b new_extension]);


end