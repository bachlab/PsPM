function [sts, data] = pspm_get_sound(import)
% ● Description
%   pspm_get_sound is a common function for importing sound data.
% ● Format
%   [sts, data]=pspm_get_sound(import)
% ● Arguments
%   import.data: column vector of waveform data
%     import.sr: sample rate
% ● Introduced In
%   PsPM 3.0
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
data.header.chantype = 'snd';
data.header.units = import.units;
data.header.sr = import.sr;
% check status
sts = 1;