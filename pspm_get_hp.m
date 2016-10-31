function [sts, data]=pspm_get_hp(import)
% SCR_GET_HP is a common function for importing heart period data
%
% FORMAT:
%   [sts, data]=pspm_get_hp(import)
%   with data: column vector of waveform data with interpolated heart 
%               period data in ms
%        import: import job structure with mandatory fields .data and .sr
%  
%__________________________________________________________________________
% PsPM 3.0
% (C) 2010-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id: pspm_get_hp.m 702 2015-01-22 15:06:14Z tmoser $
% $Rev: 702 $

global settings;
if isempty(settings), pspm_init; end;

% initialise status
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