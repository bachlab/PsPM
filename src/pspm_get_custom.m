function [sts, data]=pspm_get_custom(import)
% ● Description
%   pspm_get_custom is a common function for importing custom data in this case
%   the function was made for the blink-data in the pspm_get_eyelink function
% ● Format
%   [sts, data]= pspm_get_custom(import)
% ● Arguments
%   import.data: column vector of waveform data
%     import.sr: sample rate
% ● Version History
%   Introduced in PsPM 3.0
% ● Written By
%   (C) 2009-2014 Tobias Moser (University of Zurich)

%% Initialise
global settings
if isempty(settings)
	pspm_init;
end
%% assign data
data.data = import.data(:);
%% add header
data.header.chantype = 'custom';
data.header.units = import.units;
data.header.sr = import.sr;
%% check status
sts = 1;
return