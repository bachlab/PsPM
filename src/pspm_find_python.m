function pyinfo = pspm_find_python(varargin)
% ● Description
%   pspm_find_python detects python environment in the system and return
%   the path and version of python
% ● Description
%   pspm_find_python can return the path of python executable file in the
%   system. It supports both auto and defined mode. To automatic find
%   python in the systen, use pyinfo=pspm_find_python(). To load python
%   from previously saved python path file, use
%   pyinfo=pspm_find_python(filepath).
% ● History
%   Written in Apr 2024 by Teddy
switch length(varargin)
  case 0
    pyrunfile("py_find_location.py")
    pyinfo_file = 'py_loc.txt';
  case 1
    pyinfo_file = varargin{1};
end
pyinfo_text   = fileread(pyinfo_file);
disp(pyinfo_text);
if isunix
  pyinfo_struct = regexp(pyinfo_text, '\n', 'split'); % LF for unix
else
  pyinfo_struct = regexp(pyinfo_text, '\r\n', 'split'); % CRLF for windows
end
pyinfo        = pyinfo_struct(1:2);
% Adjustments
if isunix
  % for macOS, this needs to be something like ".../python3.11"
  pyinfo{1} = [pyinfo{1}, '/python', pyinfo{2}];
else
  % for windows
  pyinfo{1} = [pyinfo{1}, '\python.EXE'];
end
end