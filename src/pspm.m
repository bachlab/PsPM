function pspm(varargin)
% ● Description
%   pspm.m handles the main GUI for PsPM
% ● Last Updated in
%   PsPM 6.1
% ● History
%   Updated 12-2023 by Teddy

if ispc
  if verLessThan('matlab','9.4') % MATLAB 2018
      pspm_guide
  else
      pspm_appdesigner
  end
elseif ismac
  if verLessThan('matlab','9.4') % MATLAB 2018
      pspm_guide
  else
      pspm_appdesigner
  end
else % Linux
  if verLessThan('matlab','9.12') % MATLAB 2022
      pspm_guide
  else
      pspm_appdesigner
  end
end
return
