function [sts, data]=pspm_get_custom(import)
% SCR_GET_CUSTOM is a common function for importing custom data
% in this case the function was made for the blink-data in the 
% pspm_get_eyelink function
%
% FORMAT:
%   [sts, data]=pspm_get_custom(import)
%   with import.data: column vector of waveform data
%        import.sr: sample rate
%  
%__________________________________________________________________________
% PsPM 3.0
% (C) 2009-2014 Tobias Moser (University of Zurich)

% $Id$
% $Rev$


global settings;
if isempty(settings), pspm_init; end;

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