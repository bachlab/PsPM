function varargout = pspm_overwrite(varargin)
% ● Description
%   pspm_overwrite generalises the overwriting operation
%   pspm_overwrite considers the following situations
%   - whether options.overwrite is defined
%   - whether PsPM is in develop mode
%   - whether the file exist
%   - whether GUI can be used
%   PsPM will always try to overwrite files wherever possible except:
%   1. if overwrite is defined as not to overwrite
%   2. if overwrite is not defined
%      a. the file has existed
%      b. users use the GUI to stop overwriting
% ● Arguments
%   fn:         the name of the file to possibly overwrite
%               can be a link if necessary
%   overwrite:  a numerical value or a struct
%               option of overwrite if this option is presented
%               can be a value or a struct
%               if a value, can be 0 (not to overwrite) or 1 (to overwrite)
%               if a struct, check if the field `overwrite` exist
% ● Outputs
%   overwrite_final  option of overwriting determined by pspm_overwrite
%                     0: not to overwrite
%                     1: to overwrite
% ● History
%   Introduced in PsPM 6.0
%   Written in 2022 by Teddy Chao (UCL)
%   Maintained in 2023 by Teddy Chao

%% 1 Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
overwrite_final = 0;
switch nargout
  case 1
    varargout{1} = overwrite_final;
  case 2
    varargout{1} = sts;
    varargout{2} = overwrite_final;
end
%% 2 Check inputs
switch numel(varargin)
  case 0
    warning('ID:invalid_input', 'at least one argument is required');
    return;
  case 1 % overwrite is not defined
    fn = varargin{1};
    if iscell(fn)
      fn = fn{1};
    end
    overwrite_final = 0;
    % the default value of overwrite is initialised here and will be checked later
  case 2
    fn = varargin{1};
    if iscell(fn)
      fn = fn{1};
    end
    switch class(varargin{2})
      case 'double'
        overwrite = varargin{2};
      case 'struct'
        options_struct = varargin{2};
        if isfield(options_struct, 'overwrite')
          overwrite_final = options_struct.overwrite;
        else
          overwrite_final = 0;
        end
      otherwise
        warning('ID:invalid_input', ...
          'the second input argument should be either a double or a struct.');
        return
    end
end
%% 3 Define overwrite
if settings.developmode
  overwrite_final = 1;
else
  if ~exist(fn, 'file')
    % if file does not exist, always overwrite
    overwrite_final = 1;
  else
    if feature('ShoverwriteFigureWindoverwrites') % if in gui
      msg = ['Model file already exists. Overwrite?', ...
        newline, 'Existing file: ', fn];
      overwrite = questdlg(msg, ...
        'File already exists', 'Yes', 'No', 'Yes');
      % default as Yes (to overwrite)
      overwrite_final = strcmp(overwrite, 'Yes');
    end
  end
end
%% 4 Validate overwrite_final
if overwrite_final ~= 0 && overwrite_final ~= 1
  warning('ID:invalid_input', 'overwrite can be only 0 or 1');
  return
end
%% 5 Check outputs
switch nargout
  case 1
    varargout{1} = overwrite_final;
  case 2
    varargout{1} = sts;
    varargout{2} = overwrite_final;
  otherwise
    varargout{1} = overwrite_final;
end
return
