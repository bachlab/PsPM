function [sts, data]=scr_get_sound(import)
% SCR_GET_SOUND is a common function for importing sound data
%
% FORMAT:
%   [sts, data]=scr_get_sound(import)
%   with import.data: column vector of waveform data
%        import.sr: sample rate
%  
%__________________________________________________________________________
% PsPM 3.0
% (C) 2015 Tobias Moser (University of Zurich)

% $Id$
% $Rev$

global settings;
if isempty(settings), scr_init; end;

% initialise status
sts = -1;

% assign respiratory data
data.data = import.data(:);

% add header
data.header.chantype = 'snd';
data.header.units = import.units;
data.header.sr = import.sr;

% check status
sts = 1;
