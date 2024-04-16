function [sts, scl] = pspm_sf_scl(model, options)
% ● Description
%   pspm_sf_scl returns the mean skin conductance level for an epoch
% ● Format
%   [sts, scl] = pspm_sf_scl(scr, sr)
% ● Arguments
%       scr:
%        sr:
%   options:
% ● Outputs
%       scl:
% ● References
% ● History
%   Introduced In PsPM 3.0
%   Written in 2008-2015 by Dominik R Bach (Wellcome Trust Centre for Neuroimaging)
%   Maintained in 2022 by Teddy Chao (UCL)

% initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
scl = [];


% check input arguments
if nargin < 1
  warning('No data specified'); return;
end;
try model.scr; catch, warning('Input data is not defined.'); return; end
try model.sr; catch, warning('Sample rate is not defined.'); return; end
scl = mean(scr);
sts = 1;

