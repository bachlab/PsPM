function [sts, data] = pspm_get_sps_l(import)
% pspm_get_sps_l is a comon function for importing left eye eyelink data (distances
% between following data points)
%
% FORMAT:
%   [sts, data]=pspm_get_sps_l(import)
%   with import.data: column vector of waveform data
%        import.sr: sample rate
%

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;

% assign sps data
data.data = import.data(:);

% add header
data.header.chantype = 'sps_l';
data.header.units = import.units;
data.header.sr = import.sr;
data.header.range = import.range;

% check status
sts = 1;

end

