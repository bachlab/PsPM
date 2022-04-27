function [sts, data]=pspm_get_gaze_x_l(import)
% pspm_get_gaze_x_l is a common function for importing eyelink data
% (gaze_x_l data)
%
% FORMAT:
%   [sts, data]= pspm_get_gaze_x_l(import)
%   with import.data: column vector of waveform data
%        import.sr: sample rate
%
%__________________________________________________________________________
% PsPM 3.1
% (C) 2015 Tobias Moser (University of Zurich)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;

% assign respiratory data
data.data = import.data(:);

% add header
data.header.chantype = 'gaze_x_l';
data.header.units = import.units;
data.header.sr = import.sr;
data.header.range = import.range;

% check status
sts = 1;
