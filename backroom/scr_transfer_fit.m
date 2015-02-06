function MSE=scr_transfer_fit(c, R, PR)
% SCR_TRANSFER_FIT calculates the mean squared error (MSE) for a given
% constant to convert pulse rate (PR) to resistance/conductance, disregarding a
% serial resistor (which should be added to R) a known PR offset (which
% should be subtracted from PR)
%
% FORMAT:
% MSE=scr_transfer_fit(R, PR);
%
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id: scr_transfer_fit.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), scr_init; end;
% -------------------------------------------------------------------------
% SCRalyze2, 30.7.2008

% NOTE: the objective function is expressed as conductance (since that's
% what the error should be minimized upon, rather than resistance) and in
% microsiemens (otherwise, matlab precision doesn't suffice to find
% maximum)

MSE = mean(((PR/c)-(1e6./R)).^2);

