function [sts, data] = pspm_get_sp_length(import )
% pspm_get_sp_length is a comon function for importing scanpath lengths
%
% FORMAT:
%   [sts, data]=pspm_get_sp_length(import)
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
data.header.chantype = 'sp_length';
data.header.units = import.units;
data.header.sr = import.sr;
data.header.range = import.range;

% check status
sts = 1;

end

