function out = pspm_cfg_python(varargin)
% ● Description
%   pspm_cfg_python is a function that provides UI controls for
%   python definition. It may be also used by test functions, only for which
%   automatical python detection mode can be enabled. In default, python 
%   needs to be specified manually.
% ● Format
%   out = pspm_cfg_python
%   out = pspm_cfg_python(auto_detect)
%   out = pspm_cfg_python(python_package)
%   out = pspm_cfg_python(auto_detect, python_package)
% ● Arguments
%   auto_detect:   [logical] The logical value that determines whether the
%                   to automatically detect python. If not determined, it
%                   will be set as 1.
%   python_package: [string] the python package PsPM wants to use.
%   out:            [struct] The UI struct variable for python detection.
% ● History
%   Written on 08-04-2024 by Teddy

%% Input checking
switch length(varargin)
  case 0
    auto_detect       = 0;
    python_package    = 'Python';
  case 1
    switch class(varargin{1})
      case 'double'
        auto_detect   = varargin{1};
        python_package= 'Python';
      case 'char'
        auto_detect   = 0;
        python_package= varargin{1};
    end
  case 2
    auto_detect       = varargin{1};
    python_package    = varargin{2};
  otherwise
    warning('ID:invalid_input', 'Up to two input variables are allowed');
end
%% Structs
% automatically detect python
% this will be used for testing environment only
pspm_py_auto          = cfg_const;
pspm_py_auto.name     = 'Automatically detect Python';
pspm_py_auto.tag      = 'pypath_auto';
pspm_py_auto.val      = {0};
pspm_py_auto.help     = {['This only works if a Python environment ',...
                          'already exists in Matlab.']};
% manually detect python
pspm_py_path          = cfg_files;
pspm_py_path.name     = 'Manually define Python';
pspm_py_path.tag      = 'pypath';
pspm_py_path.num      = [1 1];
pspm_py_path.help     = {'Please specify python executable file on the computer.'};
% the struct of python detection
pspm_py_detect        = cfg_choice;
if auto_detect
  pspm_py_detect.val  = {pspm_py_auto};
else
  pspm_py_detect.val  = {pspm_py_path};
end
pspm_py_detect.values = {pspm_py_path};
pspm_py_detect.name   = python_package;
pspm_py_detect.tag    = python_package;
pspm_py_detect.help   = {['Use ',python_package,' to analyse the input data. ',...
                          'Please select how to detect Python in the following.']};

%% Output
out = pspm_py_detect;
