function ow_final = pspm_overwrite(varargin)

% DESCRIPTION
% pspm_overwrite generalises the overwriting operation
% pspm_overwrite considers the following situations
% - whether options.overwrite is defined
% - whether PsPM is in develop mode
% - whether the file exist
% - whether GUI can be used
% Only the following situation will stop PsPM to overwrite files
% 1. if overwrite is defined as not to overwrite
% 2. if overwrite is not defined, and users use the GUI to stop overwriting

% ARGUMENTS
% fn        the name of the file to possibly overwrite
%           can be a link if necessary
% ow        option of overwrite if this option is presented
%           can be a value or a struct
%           if a value, can be 0 (not to overwrite) or 1 (to overwrite)
%           if a struct, check if the field "overwrite" exist

% OUTPUTS
% ow_final  option of overwriting determined by pspm_overwrite

global settings;

%% start to define ow
switch numel(varargin)
  case 0
    warning('ID:invalid_input', 'at least one argument is required');
    return;
  case 1 % ow is not defined
    fn = varargin{1};
    if iscell(fn)
      fn = fn{1};
    end
    switch settings.developmode
      case 1
        ow_final = 1; % In develop mode, always overwrite
      otherwise
        if ~exist(fn, 'file')
          % if file does not exist, always "overwrite"
          ow_final = 1;
        else
          if feature('ShowFigureWindows') % if in gui
            msg = ['Model file already exists. Overwrite?', ...
              newline, 'Existing file: ', fn];
            overwrite = questdlg(msg, ...
              'File already exists', 'Yes', 'No', 'Yes');
            % default as Yes (to overwrite)
            ow_final = strcmp(overwrite, 'Yes');
          else
            ow_final = 1; % if GUI is not available, always overwrite
          end
        end
    end
  case 2
    fn = varargin{1};
    if iscell(fn)
      fn = fn{1};
    end
    ow = varargin{2};
    if ~exist(fn, 'file')
      % if file does not exist, always "overwrite"
      ow_final = 1;
      return
    end
    switch class(ow)
      case 'double'
        ow_final = ow;
      case 'struct'
        ow_struct = ow;
        if isfield(ow_struct, 'overwrite')
          ow_final = ow_struct.overwrite;
        else
          ow_final = 0;
        end
    end
end

%% validate ow_final
if ow_final ~= 0 && ow_final ~= 1
  warning('ID:invalid_input', 'overwrite can be only 0 or 1');
  return;
end