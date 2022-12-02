function [sts, data]=pspm_get_blink_l(import)
% pspm_get_blink_l is a common function for importing eyelink data
% (blink_l data)
%
% FORMAT:
%   [sts, data]= pspm_get_blink_l(import)
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
data.header.chantype = 'blink_l';
data.header.units = import.units;
data.header.sr = import.sr;

% check status
sts = 1;