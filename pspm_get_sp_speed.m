function [sts, data] = pspm_get_sp_speed(import )
% pspm_get_sp_speed is a comon function for importing eyelink data (distances
% between following data points)
%
% FORMAT:
%   [sts, data]=pspm_get_sp_speed(import)
%   with import.data: column vector of waveform data
%        import.sr: sample rate
%

global settings;
if isempty(settings), pspm_init; end;

% initialise status
sts = -1;

% assign respiratory data
data.data = import.data(:);

% add header
data.header.chantype = 'sp_speed';
data.header.units = import.units;
data.header.sr = import.sr;
data.header.range = import.range;

% check status
sts = 1;

end

