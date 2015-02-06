function [sts, data]=scr_get_custom(import)
% SCR_GET_CUSTOM is a common function for importing custom data
% in this case the function was made for the blink-data in the 
% scr_get_eyelink function
%
% FORMAT:
%   [sts, data]=scr_get_custom(import)
%   with import.data: column vector of waveform data
%        import.sr: sample rate
%  
%__________________________________________________________________________
% PsPM 3.0
% (C) 2009-2014 Tobias Moser (University of Zurich)

% $Id: scr_get_custom.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $


global settings;
if isempty(settings), scr_init; end;

% initialise status
% -------------------------------------------------------------------------
sts = -1;

% assign data
% -------------------------------------------------------------------------
data.data = import.data(:);

% add header
% -------------------------------------------------------------------------
data.header.chantype = 'custom';
data.header.units = import.units;
data.header.sr = import.sr;

% check status
sts = 1;

return;