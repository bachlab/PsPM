function [sts, data] = pspm_get_sps(import)
% pspm_get_sps is a comon function for importing eyelink data (distances
% between following data points)
%
% FORMAT:
%   [sts, data]=pspm_get_sps(import)
%   with import.data: column vector of waveform data
%        import.sr: sample rate
%

global settings;
if isempty(settings), pspm_init; end;



% initialise status
sts = -1;

% assign sps data
data.data = import.data(:);

% add header
data.header.chantype = 'sps';
data.header.units = import.units;
data.header.sr = import.sr;
data.header.range = import.range;

% check status
sts = 1;

end

