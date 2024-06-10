function [sts, data] = pspm_get_pupil_r(import)
% ● Description
%   pspm_get_pupil_r is a common function for importing eyelink data
%   (pupil_r data)
% ● Format
%   [sts, data] = pspm_get_pupil_r(import)
% ● Arguments
%    import: [struct]
%     .data: column vector of waveform data
%       .sr: sample rate
%    .units:
% ● History
%   Introduced in PsPM 3.1
%   Written in 2015 by Tobias Moser (University of Zurich)
%   Maintained in 2022 by Teddy

% initialise
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
return
