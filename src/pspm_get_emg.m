function [sts, data] = pspm_get_emg(import)
% ● Description
%   pspm_get_emg is a common function for importing EMG data
% ● Format
%   [sts, data] = pspm_get_emg(import)
% ● Arguments
%   import: [struct]
%   .units:
%    .data: column vector of waveform data
%      .sr: sample rate
% ● History
%   Introduced in PsPM 3.0
%   Written in 2009-2014 by Tobias Moser (University of Zurich)
%   Maintained in 2022 by Teddy Chao (UCL)

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
return
