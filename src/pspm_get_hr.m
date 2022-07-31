function [sts, data]=pspm_get_hr(import)
% pspm_get_hr is a common function for importing heart rate data
%
% FORMAT:
%   [sts, data]= pspm_get_hr(import)
%   with data: column vector of waveform data
%        import: import job structure with mandatory fields .data and .sr
% ● Introduced In
%   PsPM 3.0
% ● Written By
%   (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

%% Initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;

% assign respiratory data
data.data = import.data(:);

% add header
data.header.chantype = 'hr';
if strcmpi(import.units, 'unknown')
  data.header.units = 'bpm';
else
  data.header.units = import.units;
end;
data.header.sr = import.sr;

% check status
sts = 1;

return;