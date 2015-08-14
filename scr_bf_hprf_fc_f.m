function [fx, p, x] = scr_bf_hprf_fc_f(td, p)
% SCR_bf_hprf_fc_f
% Description: 
%
% FORMAT: [bf p] = SCR_bf_hprf_fc_f(td, p)
% with  td = time resolution in s
%       p(1):
%       p(2):
%       p(3):
%       p(4):
% 
% REFERENCE
%
%__________________________________________________________________________
% PsPM 3.0
% (C) 2015 Tobias Moser (University of Zurich)

% $Id$   
% $Rev$

% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), scr_init; end;
% -------------------------------------------------------------------------

if nargin < 1
   errmsg='No sampling interval stated'; warning(errmsg); return;
elseif nargin < 2
    p=[82.7785576729272 256389.754969900 0.00225906399760227 -574.596030378357];
end;

x0 = p(4);
b = p(3);
a = p(2);
A = p(1);

x = (0:td:10.9)';
fx = A * gampdf(x - x0, a, b);