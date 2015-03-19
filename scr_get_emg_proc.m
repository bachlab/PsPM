function [sts, data]=scr_get_emg_proc(import)
% SCR_GET_EMG_PROC is a common function for importing EMG Processed data
%
% FORMAT:
%   [sts, data]=scr_get_emg_proc(import)
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
data.header.chantype = 'emg_proc';
data.header.units = import.units;
data.header.sr = import.sr;

% check status
sts = 1;

return;