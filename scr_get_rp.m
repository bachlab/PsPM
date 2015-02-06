function [sts, data]=scr_get_rp(import)
% SCR_GET_RP is a common function for importing respiration period data
%
% FORMAT:
%   [sts, data]=scr_get_rp(import)
%   with data: column vector of waveform data with interpolated respiration 
%               period data in s
%        import: import job structure with mandatory fields .data and .sr
%  
%__________________________________________________________________________
% PsPM 3.0
% (C) 2010-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id: scr_get_rp.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

global settings;
if isempty(settings), scr_init; end;

% initialise status
sts = -1;

% assign respiratory data
data.data = import.data(:);

% add header
data.header.chantype = 'rp';
if strcmpi(import.units, 'unknown')
    data.header.units = 's';
else
    data.header.units = import.units;
end;
data.header.sr = import.sr;

% check status
sts = 1;

return;