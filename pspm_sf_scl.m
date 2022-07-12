function scl = pspm_sf_scl(scr, sr, options)
% pspm_sf_scl returns the mean skin conductance level for an epoch

% FORMAT:
% auc = pspm_sf_scl(scr, sr)
%
% REFERENCE:
%
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;

% check input arguments
if nargin < 1
  warning('No data specified'); return;
end;

scl = mean(scr);

return;

