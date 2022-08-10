function [sts, data]=pspm_get_hp(import)
% ● Description
%   pspm_get_hp is a common function for importing heart period data
% ● Format
%   [sts, data]= pspm_get_hp(import)
% ● Arguments
%     data: column vector of waveform data with interpolated heart period data
%           in ms
%   import: import job structure with mandatory fields .data and .sr
% ● Version History
%   Introduced in PsPM 3.0
% ● Written By
%   (C) 2010-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;

% assign respiratory data
data.data = import.data(:);

% add header
data.header.chantype = 'hp';
if strcmpi(import.units, 'unknown')
  data.header.units = 'ms';
else
  data.header.units = import.units;
end;
data.header.sr = import.sr;

% check status
sts = 1;

return;