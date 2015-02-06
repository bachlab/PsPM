function scr=scr_transfer_function(data, c, Rs, offset)
% SCR_TRANSFER_FUNCTION converts input data into SCR in microsiemens
% assuming a linear transfer from total conductance to measured data
%
% FORMAT
% scr=scr_transfer_function(data, c, [Rs, offset])
% 
% c is the transfer constant: data = c * (total conductance in mcS)
%
% Rs and offset are optional argumens:
%
% Series resistors (Rs) are often used as current limiters in MRI and 
% will render the function non-linear. They can be taken into account 
% (in Ohm, default: Rs=0). 
% 
% Some systems have an offset (e.g. when using fiber optics in MRI, a minimum
% pulsrate), which can also be taken into account (default: offset=0)
%
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id: scr_transfer_function.m 701 2015-01-22 14:36:13Z tmoser $
% $Rev: 701 $

% v002 drb 27.07.2011 catch integer values
% SCRalyze2, 31.7.2008 - 6.5.2009

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), scr_init; end;
% -------------------------------------------------------------------------

% check input arguments
if nargin<1
    errmsg='No data given.'; warning(errmsg);
elseif nargin<2
    errmsg='No transfer constant given'; warning(errmsg);
elseif nargin<3
    Rs=0; offset=0;
elseif nargin<4
    offset=0;
end;
% catch zeros
z = (data == 0);
scr(z) = 0;

% catch integer types (linear algebra is not supported for integers)
data = double(data);

% convert
scr(~z) = 1./(c./(data(~z)-offset)-Rs*1e-6);

