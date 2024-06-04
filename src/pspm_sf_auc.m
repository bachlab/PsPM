function [sts, auc] = pspm_sf_auc(model, options)
% ● Description
%   pspm_sf_auc returns the integral/area under the curve of an SCR time series
% ● Format
%   [sts, auc] = pspm_sf_auc(scr, sr, options)
% ● Arguments
%       scr:
%        sr:
%   options:
% ● Outputs
%       auc:
% ● Reference
%   Bach DR, Friston KJ, Dolan RJ (2010). Analytic measures for the
%   quantification of arousal from spontanaeous skin conductance
%   fluctuations. International Journal of Psychophysiology, 76, 52-55.
% 
% ● References
%   [1] Bach DR, Friston KJ, Dolan RJ (2010). Analytic measures for the
%       quantification of arousal from spontanaeous skin conductance
%       fluctuations. International Journal of Psychophysiology, 76, 52-55.
% 
% ● History
%   Introduced In PsPM 3.0
%   Written in 2008-2015 by Dominik R Bach (Wellcome Trust Centre for Neuroimaging)
%   Maintained in 2022 by Teddy Chao (UCL)

%% initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
auc = [];

%% check input arguments
if nargin < 1
  warning('No data specified'); return;
end;
try model.scr; catch, warning('Input data is not defined.'); return; end
try model.sr; catch, warning('Sample rate is not defined.'); return; end
scr = model.scr;
sr = model.sr;
scr = scr - min(scr);
auc = mean(scr);
sts = 1;
