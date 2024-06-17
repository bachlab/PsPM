function pspm(varargin)
% ● Description
%   pspm.m handles the main GUI for PsPM
% ● Last Updated in
%   PsPM 7.0
% ● History
%   Written in 12-2023 by Teddy
%   Updared in 06-2024 by Teddy
% ● Developer's notes
%   PsPM will no longer support GUIDE and only use App Designer for UI.
%   App Designer is available for MATLAB that is later than version R2016a (9.0).

release_date_current = datetime(version('-date'));
release_date_win = datetime('01-Jan-2018');
release_date_mac = datetime('01-Jan-2018');
release_date_linux = datetime('01-Jan-2022');
if ispc
  if release_date_current < release_date_win % MATLAB 2018
    msgbox(['PsPM UI is not supported by this version of MATLAB. ',...
      'Please consider updating your MATLAB to 2018a or newer, ',...
      'or alternatively using scripts only.']);
  else
    pspm_appdesigner
  end
elseif ismac
  if release_date_current < release_date_mac % MATLAB 2018
    msgbox(['PsPM UI is not supported by this version of MATLAB. ',...
      'Please consider updating your MATLAB to 2018a for macOS or newer, ',...
      'or alternatively using scripts only.']);
    % pspm_guide
  else
    pspm_appdesigner
  end
else % Linux
  if release_date_current < release_date_linux % MATLAB 2022
    msgbox(['PsPM UI is not supported by this version of MATLAB. ',...
      'Please consider updating your MATLAB to 2022a for Linux or newer, ',...
      'or alternatively using scripts only.']);
    % pspm_guide
  else
    pspm_appdesigner
  end
end
return
