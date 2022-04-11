function ow_final = pspm_overwrite(fn, ow)

% DESCRIPTION
% pspm_overwrite generalises the overwriting operation as following
% 1. detect whether a dialog is necessary to confirm overwritting
% 2. detect if a file exist in the current folder
% 3. automatically return whether to overwrite or not
% 4. never select to overwrite in develop mode

% ARGUMENTS
% fn        the name of the file to possibly overwrite
%           can be a link if necessary
% ow        option of overwrite if this option is presented
%           can be 0 (not to overwrite) or 1 (to overwrite)

% OUTPUTS
% ow_final  option of overwriting determined by pspm_overwrite

global settings;
pspm_init;

ow_final = 1; % default to overwrite

switch settings.developmode
  case 1
  otherwise
end

if exist(fn, 'file') && ow == 0
  
  if feature('ShowFigureWindows')
    msg = ['Model file already exists. Overwrite?', ...
    newline, 'Existing file: ', fn];
    overwrite=questdlg(msg, 'File already exists', 'Yes', 'No', 'Yes');
    % default as Yes (to overwrite)
  else
    overwrite = 'Yes'; % default as Yes (to overwrite)
  end
  if strcmp(overwrite, 'No'), return; end
end

end