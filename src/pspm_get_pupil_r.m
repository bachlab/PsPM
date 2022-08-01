function [sts, data]=pspm_get_pupil_r(import)
% ● Description
%   pspm_get_pupil_r is a common function for importing eyelink data
%   (pupil_r data)
% ● Format
%   [sts, data]=pspm_get_pupil_r(import)
%   with import.data: column vector of waveform data
%        import.sr: sample rate
% ● Introduced In
%   PsPM 3.1
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
data.header.chantype = 'pupil_r';
data.header.units = import.units;
data.header.sr = import.sr;

% check status
sts = 1;
