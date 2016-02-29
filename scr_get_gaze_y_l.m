function [sts, data]=scr_get_gaze_y_l(import)
% SCR_GET_GAZE_Y_L is a common function for importing eyelink data
% (gaze_y_l data)
%
% FORMAT:
%   [sts, data]=scr_get_gaze_y_l(import)
%   with import.data: column vector of waveform data
%        import.sr: sample rate
%  
%__________________________________________________________________________
% PsPM 3.1
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
data.header.chantype = 'gaze_y_l';
data.header.units = import.units;
data.header.sr = import.sr;

% check status
sts = 1;
