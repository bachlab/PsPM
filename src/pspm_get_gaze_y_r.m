function [sts, data]=pspm_get_gaze_y_r(import)
% ● Description
%   pspm_get_gaze_y_r is a common function for importing eyelink data
%   (gaze_y_r data)
% ● Format
%   [sts, data]= pspm_get_gaze_y_r(import)
% ● Arguments
%   import.data: column vector of waveform data
%     import.sr: sample rate
% ● Version History
%   Introduced in PsPM 3.1
% ● Written By
%   (C) 2015 Tobias Moser (University of Zurich)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;

% assign respiratory data
data.data = import.data(:);

% add header
data.header.chantype = 'gaze_y_r';
data.header.units = import.units;
data.header.sr = import.sr;
data.header.range = import.range;

% check status
sts = 1;
