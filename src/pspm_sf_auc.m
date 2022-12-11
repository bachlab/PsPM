function [sts, auc] = pspm_sf_auc(scr, sr, options)
% ● Description
%   pspm_sf_auc returns the integral/area under the curve of an SCR time series
% ● Format
%   auc = pspm_sf_auc(scr, sr, options)
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
% check input arguments
if nargin < 1
  warning('No data specified'); return;
end;
scr = scr - min(scr);
auc = mean(scr);

sts = 1;
end
