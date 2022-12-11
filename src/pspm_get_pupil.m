function [sts, data] = pspm_get_pupil(import)
% ● Description
%   pspm_get_pupil is a common function for importing pupil data
% ● Format
%   [sts, data] = pspm_get_pupil(import)
% ● Arguments
%    import: [struct]
%     .data: column vector of waveform data
%       .sr: sample rate
%    .units:
% ● History
%   Introduced in PsPM 3.0
%   Written in 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)
%   Maintained in 2022 by Teddy Chao (UCL)

% initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
% assign respiratory data
data.data = import.data(:);
% add header
data.header.channeltype = 'pupil';
data.header.units = import.units;
data.header.sr = import.sr;
% check status
sts = 1;
end
