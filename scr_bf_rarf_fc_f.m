function [fx, x, p] = scr_bf_rarf_fc_f_gc(td, p)
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
% (C) 2016 G Castegnetti (University of Zurich)


% initialise
% -------------------------------------------------------------------------
global settings;
if isempty(settings), scr_init; end;
% -------------------------------------------------------------------------

if nargin < 1
   errmsg='No sampling interval stated'; warning('ID:invalid_input',errmsg); return;
elseif nargin < 2
    % former parameters [256389.754969900,0.00225906399760227,-574.596030378357,82.7785576729272]
    pe = [257461.681460029,0.00288615518335954,-738.062835972914,-0.141763084462924];
    pl = [3.92085862613853,0.917932618911215,7.44174302902533,0.106076296904016];
end;

if td > 10.9
    warning('ID:invalid_input', 'Time resolution is larger than duration of the function.'); return;
elseif td == 0
    warning('ID:invalid_input', 'Time resolution must be larger than 0.'); return;
end;

x0_e = pe(3);
b_e = pe(2);
a_e = pe(1);
A_e = pe(4);

x0_l = pl(3);
b_l = pl(2);
a_l = pl(1);
A_l = pl(4);

p = [pe pl];

gl_e = gammaln(a_e);
gl_l = gammaln(a_l);

x = (0:td:10.9-td)';

% try not to use stats toolbox, but stats toolbox has also stirling
% approximation implemented. So this might be useful.
%
%fx = A * gampdf(x - x0, a, b);

fx_e = A_e * exp(log(x-x0_e).*(a_e-1) - gl_e - (x-x0_e)./b_e - log(b_e)*a_e);
fx_l = A_l * gampdf(x - x0_l, a_l, b_l);
fx = [fx_e fx_l];