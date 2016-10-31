function [sts, data]=pspm_get_pupil_r(import)
% SCR_GET_PUPIL_R is a common function for importing eyelink data
% (pupil_r data)
%
% FORMAT:
%   [sts, data]=pspm_get_pupil_r(import)
%   with import.data: column vector of waveform data
%        import.sr: sample rate
%  
%__________________________________________________________________________
% PsPM 3.1
% (C) 2015 Tobias Moser (University of Zurich)

% $Id$
% $Rev$

global settings;
if isempty(settings), pspm_init; end;

% initialise status
sts = -1;

% assign respiratory data
data.data = import.data(:);

% add header
data.header.chantype = 'pupil_r';
data.header.units = import.units;
data.header.sr = import.sr;

% check status
sts = 1;
