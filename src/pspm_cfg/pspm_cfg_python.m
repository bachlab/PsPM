function out = pspm_cfg_python(varargin)
% ● Description
%   pspm_cfg_python is a function that provides UI controls for
%   python definition.
% ● Format
%   out = pspm_cfg_python
%   out = pspm_cfg_python(python_package)
% ● Arguments
%   python_package: [string] the python package PsPM wants to use.
%   out:            [struct] The UI struct variable for python detection.
% ● History
%   Written on 08-04-2024 by Teddy

%% Input checking
switch length(varargin)
  case 0
    python_package    = 'Python';
  case 1
    python_package    = varargin{1};
  otherwise
    warning('ID:invalid_input', 'Up to one input variable is allowed');
end
%% Structs
% manually detect python
pspm_py_path          = cfg_files;
pspm_py_path.name     = 'Manually define Python';
pspm_py_path.tag      = 'pypath';
pspm_py_path.num      = [1 1];
pspm_py_path.help     = {'Please specify python executable file on the computer.'};
% the struct of python detection
pspm_py_detect        = cfg_choice;
pspm_py_detect.val    = {pspm_py_path};
pspm_py_detect.values = {pspm_py_path};
pspm_py_detect.name   = python_package;
pspm_py_detect.tag    = python_package;
pspm_py_detect.help   = {['Use ',python_package,' to analyse the input data. ',...
                          'Please select how to detect Python in the following.']};
%% Output
out = pspm_py_detect;
