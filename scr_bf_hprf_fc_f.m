function [fx, x, p] = scr_bf_hprf_fc_f(td, p)
% SCR_bf_hprf_fc_f
% Description: 
%
% FORMAT: [bf p] = SCR_bf_hprf_fc_f(td, p)
% with  td = time resolution in s
%       p(1): a
%       p(2): b
%       p(3): x0
%       p(4): A
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
    % former parameters [256389.754969900,0.00225906399760227,-574.596030378357,82.7785576729272]
    p=[43.2180170215633,0.195621916215104,-3.46706926741904,81.0383536117737];
end;

x0 = p(3);
b = p(2);
a = p(1);
A = p(4);

gl = gammaln(a);

x = (0:td:10.9)';

% try not to use stats toolbox, but stats toolbox has also stirling
% approximation implemented. So this might be useful.
%
%fx = A * gampdf(x - x0, a, b);

fx = A * exp(log(x-x0).*(a-1) - gl - (x-x0)./b - log(b)*a);



