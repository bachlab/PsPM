function out = pspm_cfg_python(varargin)
% ● Description
%   pspm_cfg_python is a GUI function that provides UI controls for
%   python definition
% ● Format
%   out = pspm_cfg_python
%   out = pspm_cfg_python(default_auto)

switch length(varargin)
  case 0
    default_auto = 1;
  case 1
    default_auto = varargin{1};
  otherwise
    warning('ID:invalid_input', 'Up to one input variable is allowed');
end

ppg2hb_py_auto          = cfg_const;
ppg2hb_py_auto.name     = 'Automatically detect Python';
ppg2hb_py_auto.tag      = 'pspm_py_auto';
ppg2hb_py_auto.val      = {0};
ppg2hb_py_auto.help     = {['This only works if a Python environment ',...
                            'already exists in Matlab, created by ',...
                            'previous PsPM function calls or manually.']};

ppg2hb_py_path          = cfg_files;
ppg2hb_py_path.name     = 'Manually define Python';
ppg2hb_py_path.tag      = 'pspm_py_path';
ppg2hb_py_path.num      = [1 1];
ppg2hb_py_path.help     = {'Please specify python executable file on the computer.'};

ppg2hb_py_detect        = cfg_choice;
if default_auto
  ppg2hb_py_detect.val    = {ppg2hb_py_auto};
else
  ppg2hb_py_detect.val    = {ppg2hb_py_path};
end
ppg2hb_py_detect.values = {ppg2hb_py_auto, ppg2hb_py_path};
ppg2hb_py_detect.help   = {'Mode of detecting python path in the operating system.'};

out = ppg2hb_py_detect;