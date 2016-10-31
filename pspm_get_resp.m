function [sts, data]=pspm_get_resp(import)
% SCR_GET_RESP is a common function for importing respiration data
%
% FORMAT:
%   [sts, data]=pspm_get_resp(import)
%   with import.data: column vector of waveform data
%        import.sr: sample rate
%  
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id: pspm_get_resp.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

% v002 29.07.2013 changed to 3.0 architecture
% v001 17.9.2009 Dominik R Bach

global settings;
if isempty(settings), pspm_init; end;

% initialise status
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