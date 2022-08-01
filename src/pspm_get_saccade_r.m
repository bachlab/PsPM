function [sts, data]=pspm_get_saccade_r(import)
% ● Description
%   pspm_get_saccade_r is a common function for importing eyelink data
% (saccade_r data)
%
% ● Format
%   [sts, data]=pspm_get_saccade_r(import)
%   with import.data: column vector of waveform data
%        import.sr: sample rate
% ● Introduced In
%   PsPM 4.0.2
% ● Written By
%   (C) 2018 Laure Ciernik

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;

% assign pupil data
data.data = import.data(:);

% add header
data.header.chantype = 'saccade_r';
data.header.units = import.units;
data.header.sr = import.sr;

% check status
sts = 1;