function [sts, data] = pspm_get_sps_r(import)
% ● Description
%   pspm_get_sps_r is a comon function for importing right eye eyelink data
%   (distances between following data points)
% ● Format
%   [sts, data] = pspm_get_sps_r(import)
% ● Arguments
%    import:
%     .data: column vector of waveform data
%       .sr: sample rate
%    .units:
%    .range:
% ● History
%   Introduced in PsPM version?
%   Maintained in 2022 by Teddy Chao (UCL)

% initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
% assign sps data
data.data = import.data(:);
% add header
data.header.channeltype = 'sps_r';
data.header.units = import.units;
data.header.sr = import.sr;
data.header.range = import.range;
% check status
sts = 1;
return
