function [sts, data]=pspm_get_saccade_l(import)
% pspm_get_saccade_l is a common function for importing eyelink data
% (saccade_l data)
%
% FORMAT:
%   [sts, data]=pspm_get_saccade_l(import)
%   with import.data: column vector of waveform data
%        import.sr: sample rate
%  
%__________________________________________________________________________
% PsPM 4.0.2
% (C) 2018 Laure Ciernik

%% Initialise
global settings
if isempty(settings)
	pspm_init;
end
sts = -1;

% assign pupil data
data.data = import.data(:);

% add header
data.header.chantype = 'saccade_l';
data.header.units = import.units;
data.header.sr = import.sr;

% check status
sts = 1;