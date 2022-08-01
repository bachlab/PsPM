function [sts, data]=pspm_get_pupil_l(import)
% ● Description
%   pspm_get_pupil_l is a common function for importing eyelink data
%   (pupil_l data)
% ● Format
%   [sts, data]= pspm_get_pupil_l(import)
% ● Arguments
%   import.data: column vector of waveform data
%     import.sr: sample rate
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
% assign pupil data
data.data = import.data(:);
% add header
data.header.chantype = 'pupil_l';
data.header.units = import.units;
data.header.sr = import.sr;
% check status
sts = 1;