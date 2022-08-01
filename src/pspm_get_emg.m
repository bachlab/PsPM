function [sts, data]=pspm_get_emg(import)
% ● Description
%   pspm_get_emg is a common function for importing EMG data
% ● Format
%   [sts, data]= pspm_get_emg(import)
% ● Arguments
%   import.data: column vector of waveform data
%     import.sr: sample rate
% ● Introduced In
%   PsPM 3.0
% ● Written By
%   (C) 2009-2014 Tobias Moser (University of Zurich)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
% assign data
data.data = import.data(:);
% add header
data.header.chantype = 'emg';
data.header.units = import.units;
data.header.sr = import.sr;
% check status
sts = 1;
return;