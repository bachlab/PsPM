function [sts, data]=pspm_get_ecg(import)
% SCR_GET_ECP is a common function for importing continuous ECG data
%
% FORMAT:
%   [sts, data]=pspm_get_ecg(data, import)
%   with data: column vector of waveform data
%        import: import job structure with mandatory fields .data and .sr
%  
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id: pspm_get_ecg.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

% v002 29.07.2013 changed to 3.0 architecture
% v001 08.05.2012 Dominik R Bach

global settings;
if isempty(settings), pspm_init; end;

% initialise status
sts = -1;

% assign respiratory data
data.data = import.data(:);

% add header
data.header.chantype = 'ecg';
data.header.units = import.units;
data.header.sr = import.sr;

% check status
sts = 1;

return;