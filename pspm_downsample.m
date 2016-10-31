function [sts data] = pspm_downsample(data, freqratio)
% This function implements a simple downsample routine for users who
% don't have the Matlab Signal Processing Toolbox installed
% FORMAT [sts data] = pspm_downsample(data, freqratio)
% returns sts = -1 if the frequency ratio is not an integer
%
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id: pspm_downsample.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

% v001 drb 9.12.2009

% initialise
% ------------------------------------------------------------------------

global settings;
if isempty(settings), pspm_init; end;
sts = -1;

% check input arguments
% ------------------------------------------------------------------------
if nargin < 2
    warning('Not enough input arguments.'); return
elseif floor(freqratio) ~= freqratio
    warning('Frequency ratio must be integer.'); return
end;

data = data(freqratio:freqratio:end);
sts = 1;