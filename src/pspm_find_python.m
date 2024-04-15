function pyinfo = pspm_find_python()
% ● Description
%   pspm_find_python detects python environment in the system and return
%   the path and version of python
% ● Description

pyrunfile("py_find_location.py")
pyinfo_text   = fileread('py_loc.txt');
disp(pyinfo_text);
pyinfo_struct = regexp(pyinfo_text, '\n', 'split');
pyinfo        = pyinfo_struct(1:2);

% Adjustments
if isunix
  % for macOS, this needs to be something like ".../python3.11"
  pyinfo{1} = [pyinfo{1}, '/python', pyinfo{2}];
else
  % for windows
end

end