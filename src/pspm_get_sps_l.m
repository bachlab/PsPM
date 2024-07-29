function [sts, data] = pspm_get_sps_l(import)
% ● Description
%   pspm_get_sps_l is a comon function for importing left eye eyelink data
%   (distances between following data points)
% ● Format
%   [sts, data] = pspm_get_sps_l(import)
% ● Arguments
%   ┌───import
%   ├────.data : Column vector of waveform data.
%   ├──────.sr : Sample rate.
%   ├───.units : Unit of waveform data.
%   └───.range : Range of data.
% ● History
%   Introduced in PsPM version?
%   Maintained in 2022 by Teddy

% initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;
% assign sps data
data.data = import.data(:);
% add header
data.header.chantype = 'sps_l';
data.header.units = import.units;
data.header.sr = import.sr;
data.header.range = import.range;
% check status
sts = 1;
return
