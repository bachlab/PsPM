function [sts, data]=scr_get_emg(import)
% SCR_GET_EMG is a common function for importing EMG data
%
% FORMAT:
%   [sts, data]=scr_get_emg(import)
%   with import.data: column vector of waveform data
%        import.sr: sample rate
%  
%__________________________________________________________________________
% PsPM 3.0
% (C) 2009-2014 Tobias Moser (University of Zurich)

% $Id$
% $Rev$


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
data.header.chantype = 'emg';
data.header.units = import.units;
data.header.sr = import.sr;

% check status
sts = 1;

return;