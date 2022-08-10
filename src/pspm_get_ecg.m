function [sts, data]=pspm_get_ecg(import)
% ● Description
%   pspm_get_ecg is a common function for importing continuous ECG data.
% ● Format
%   [sts, data]= pspm_get_ecg(data, import)
% ● Arguments
%     data: column vector of waveform data
%   import: import job structure with mandatory fields .data and .sr
% ● Version History
%   Introduced in PsPM 3.0
% ● Written By
%   (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

%% Initialise
global settings
if isempty(settings)
	pspm_init;
end
%% assign respiratory data
data.data = import.data(:);
%% add header
data.header.chantype = 'ecg';
data.header.units = import.units;
data.header.sr = import.sr;
%% check status
sts = 1;
return