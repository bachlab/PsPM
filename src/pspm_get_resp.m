function [sts, data]=pspm_get_resp(import)
% pspm_get_resp is a common function for importing respiration data
%
% ● Format
%   [sts, data]=pspm_get_resp(import)
%   with import.data: column vector of waveform data
%        import.sr: sample rate
%
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
data.header.chantype = 'resp';
data.header.units = import.units;
data.header.sr = import.sr;

% check status
sts = 1;

return;