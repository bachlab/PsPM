function [sts, data] = pspm_downsample(data, freqratio)
% ● Description
%   pspm_downsample implements a simple downsample routine for users who
%   don't have the Matlab Signal Processing Toolbox installed.
% ● Format
%   [sts, data] = pspm_downsample(data, freqratio)
% ● Arguments
%        data: the input data for performing downsampling on.
%   freqratio: the frequency ratio of downsampling operation.
% ● Output
%         sts: -1 if the frequency ratio is not an integer
% ● History
%   Introduced in PsPM 3.0
%   Written in 2008-2015 by Dominik R Bach (Wellcome Trust Centre for Neuroimaging)
%   Maintained in 2022 by Teddy Chao

%% 1 Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
%% 2 Check input arguments
if nargin < 2
  warning('Not enough input arguments.'); return
elseif floor(freqratio) ~= freqratio
  warning('Frequency ratio must be integer.'); return
end
%% 3 Performing downsampling
data = data(freqratio:freqratio:end);
sts = 1;
return