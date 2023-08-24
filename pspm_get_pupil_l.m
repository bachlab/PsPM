function [sts, data] = pspm_get_pupil_l(import)
% ● Description
%   pspm_get_pupil_l is a common function for importing eyelink data
%   (pupil_l data)
% ● Format
%   [sts, data]= pspm_get_pupil_l(import)
% ● Arguments
%   import: [struct]
%    .data: column vector of waveform data
%      .sr: sample rate
%   .units:
% ● History
%   Introduced in PsPM 3.1
%   Written in 2015 by Tobias Moser (University of Zurich)
%   Maintained in 2022 by Teddy Chao (UCL)

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
return
