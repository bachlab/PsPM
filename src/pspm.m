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
if ispc
  if isMATLABReleaseOlderThan('R2018a') % MATLAB 2018
      msgbox(['PsPM UI is not supported by this version of MATLAB. ',...
        'Please consider updating your MATLAB to 2018a or newer, ',...
        'or alternatively using scripts only.']);
  else
      pspm_appdesigner
  end
elseif ismac
  if isMATLABReleaseOlderThan('R2018a') % MATLAB 2018
    msgbox(['PsPM UI is not supported by this version of MATLAB. ',...
        'Please consider updating your MATLAB to 2018a for macOS or newer, ',...
        'or alternatively using scripts only.']);
     % pspm_guide
  else
      pspm_appdesigner
  end
else % Linux
  if isMATLABReleaseOlderThan('R2022a') % MATLAB 2022
    msgbox(['PsPM UI is not supported by this version of MATLAB. ',...
        'Please consider updating your MATLAB to 2022a for Linux or newer, ',...
        'or alternatively using scripts only.']);
      % pspm_guide
  else
      pspm_appdesigner
  end
end
return
