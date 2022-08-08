function [sts, data] = pspm_get_saccade_l(import)
% ● Description
%   pspm_get_saccade_l is a common function for importing eyelink data
%   (saccade_l data)
% ● Format
%   [sts, data] = pspm_get_saccade_l(import)
% ● Arguments
%    import:
%     .data: column vector of waveform data
%       .sr: sample rate
%    .units:
% ● Introduced In
%   PsPM 4.0.2
% ● Written By
%   (C) 2018 Laure Ciernik
% ● Maintained By
%   2022 Teddy Chao (UCL)

% initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
% assign pupil data
data.data = import.data(:);
% add header
data.header.chantype = 'saccade_l';
data.header.units = import.units;
data.header.sr = import.sr;
% check status
sts = 1;