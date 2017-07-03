function [sts, data]=pspm_get_hr(import)
% SCR_GET_HR is a common function for importing heart rate data
%
% FORMAT:
%   [sts, data]=pspm_get_hr(import)
%   with data: column vector of waveform data
%        import: import job structure with mandatory fields .data and .sr
%  
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id$
% $Rev$

% v002 29.07.2013 changed to 3.0 architecture
% v001 31.5.2010 Dominik R Bach

global settings;
if isempty(settings), pspm_init; end;

% initialise status
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